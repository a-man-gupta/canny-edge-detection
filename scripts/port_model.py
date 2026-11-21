"""Cascade Lake port model shared by analyze_threshold.py and analyze_hysteresis.py.

Each hot-loop instruction becomes micro-ops with the ports they may use (uops.info, Skylake-X /
Cascade Lake, 256-bit forms). The execution bound is Hall's bound: for every set S of ALU ports,
the micro-ops that can only run on S need at least count / |S| cycles. Loads use ports 2/3, store
addresses 2/3/7 (7 only for [base + displacement]), store data port 4. Issue is 4 fused-domain
slots per cycle. Unknown instruction forms fail instead of guessing.
"""
import itertools
import re
import subprocess
import sys

P01, P05, P015, P0156, P06, P5 = '01', '05', '015', '0156', '06', '5'
ALU_PORTS = '0156'

# op -> ALU micro-ops (each a string of allowed ports)
VECTOR = {
    'vpackssdw': [P5], 'vpacksswb': [P5], 'vpermd': [P5],
    'vpcmpgtw': [P01], 'vpcmpgtd': [P01], 'vpcmpeqb': [P01], 'vpabsb': [P01],
    'vpaddb': [P015], 'vpaddw': [P015], 'vpand': [P015], 'vpor': [P015], 'vpandn': [P015],
    'vpternlogd': [P05], 'vptest': ['0', P5],
}
SCALAR = {'add': [P0156], 'sub': [P0156], 'inc': [P0156], 'dec': [P0156], 'lea': [P0156],
          'mov': [P0156], 'xor': [P0156]}
MOVES = ('vmovdqu', 'vmovdqu32', 'vmovdqu64', 'vmovdqa', 'vmovdqa64', 'vmovups', 'vmovaps')


def disassemble(binary, function):
    text = subprocess.check_output(['objdump', '-d', '-C', '--no-show-raw-insn', binary],
                                   universal_newlines=True)
    body = text.split('<%s>:' % function, 1)[1]
    body = re.split(r'\n[0-9a-f]+ <', body)[0]
    if re.search(r'%zmm', body):
        sys.exit('FAIL: 512-bit zmm register in %s' % function)
    ins = []
    for line in body.splitlines():
        m = re.match(r'\s*([0-9a-f]+):\s+(\w+)\s*(.*)', line)
        if m:
            ins.append((int(m[1], 16), m[2], m[3], line))
    return ins


def hot_loop(ins, accept):
    """Shortest backward-branch range whose instructions satisfy accept(rows)."""
    best = None
    for i, (addr, op, args, line) in enumerate(ins):
        if not op.startswith('j') or not re.match(r'[0-9a-f]+ ', args):
            continue
        target = int(args.split()[0], 16)
        if target >= addr:
            continue
        rows = [r for r in ins[:i + 1] if target <= r[0] <= addr]
        if accept(rows) and (best is None or len(rows) < len(best)):
            best = rows
    if best is None:
        sys.exit('FAIL: hot loop not found')
    if any(re.search(r'\([^)]*%r(?:sp|bp)', r[2]) for r in best):
        sys.exit('FAIL: hot-loop stack access (spill)')
    if any(r[1].startswith('call') for r in best):
        sys.exit('FAIL: hot-loop call')
    return best


def count(loop):
    """Fused-domain slots, ALU micro-ops, loads, store addresses and store data of one iteration."""
    slots, alu, loads, store_addr_p23, store_addr_p237, stores = 0, [], 0, 0, 0, 0
    mix = {}
    prev_cmp = False
    for addr, op, args, line in loop:
        mem = bool(re.search(r'\([^)]*%', args))
        indexed = bool(re.search(r'\([^)]*,[^)]*\)', args))
        mix[op] = mix.get(op, 0) + 1
        if op in MOVES:
            if not mem:
                slots += 1; alu.append(P015)        # register copy
            elif args.lstrip().startswith('%'):
                slots += 1; stores += 1             # store: data on port 4
                if indexed: store_addr_p23 += 1
                else: store_addr_p237 += 1
            else:
                slots += 1; loads += 1
        elif op in VECTOR:
            uops = VECTOR[op]
            alu += uops
            slots += len(uops)
            if mem:
                loads += 1
                # Indexed memory operands of 3-operand VEX/EVEX instructions are unlaminated.
                slots += int(indexed)
        elif op in SCALAR:
            if mem:
                sys.exit('FAIL: unexpected scalar memory operand: ' + line)
            alu += SCALAR[op]; slots += 1
        elif op == 'cmp' or op == 'test':
            if mem:
                sys.exit('FAIL: unexpected scalar memory operand: ' + line)
            alu.append(P0156); slots += 1; prev_cmp = True
            continue
        elif op.startswith('j'):
            if prev_cmp:                            # macro-fused with the cmp: one p06 uop
                alu[-1] = P06
            else:
                alu.append(P06); slots += 1
        else:
            sys.exit('FAIL: unknown hot-loop instruction ' + line)
        prev_cmp = False
    return dict(slots=slots, alu=alu, loads=loads, store_addr_p23=store_addr_p23,
                store_addr_p237=store_addr_p237, stores=stores, mix=mix)


def alu_bound(alu):
    """Hall's bound over every set of ALU ports, and the set that sets it."""
    best, best_set = 0.0, ''
    for k in range(1, len(ALU_PORTS) + 1):
        for s in itertools.combinations(ALU_PORTS, k):
            n = sum(1 for u in alu if set(u) <= set(s))
            if n / k > best:
                best, best_set = n / k, ''.join(s)
    return best, best_set


def report(title, c, pixels, split_loads):
    alu_cycles, ports = alu_bound(c['alu'])
    load_ops = c['loads'] + c['store_addr_p23']
    limits = [
        ('issue (%d fused slots / 4)' % c['slots'], c['slots'] / 4),
        ('ALU ports %s (%d uops that can only use them)' %
         (ports, sum(1 for u in c['alu'] if set(u) <= set(ports))), alu_cycles),
        ('load ports 2/3 (%d loads + %d indexed store addresses)' % (c['loads'], c['store_addr_p23']),
         load_ops / 2),
        ('load ports 2/3 incl. %d cache-line-split loads' % split_loads, (load_ops + split_loads) / 2),
        ('store data port 4 (%d stores)' % c['stores'], c['stores']),
    ]
    print(title)
    print('Instruction mix:', c['mix'])
    for name, cycles in limits:
        print('  %-62s %7.3f cycles/iteration = %.4f cycles/pixel' % (name, cycles, cycles / pixels))
    peak = max(cycles for _, cycles in limits)
    print('Peak (tightest bound): %.4f cycles/pixel = %.2f pixels/cycle' % (peak / pixels, pixels / peak))
    return peak / pixels
