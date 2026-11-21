#!/usr/bin/env python3
"""Audit the actual compiled AVX2 Sobel hot loop (GNU objdump) and print its resource bounds.

The main loop is the backward loop with the most vpblendvb (one per 16-pixel group); it is
hand-unrolled to 4 groups = 64 pixels. Checks: AVX2 only (no EVEX, no ymm16+ or k registers),
no stack access, no call, no register-to-register vector copy, one branch per iteration.
"""
import re
import subprocess
import sys

obj = sys.argv[1] if len(sys.argv) > 1 else 'sobel_kernel.o'
text = subprocess.check_output(['objdump', '-d', '-C', '--no-show-raw-insn', obj], universal_newlines=True)
raw = subprocess.check_output(['objdump', '-d', obj], universal_newlines=True)
assert not re.search(r'^\s*[0-9a-f]+:\s+62\s', raw, re.M), 'EVEX instruction found'
assert not re.search(r'%[xyz]mm(?:1[6-9]|[2-9][0-9])|%k[0-7]', text), 'non-AVX2 register'
function = text.split('<sobel_i16_row(', 1)[1].split('\n\n', 1)[0]
rows = []
for line in function.splitlines():
    match = re.match(r'\s*([0-9a-f]+):\s+(\w+)\s*(.*)', line)
    if match:
        rows.append((int(match[1], 16), match[2], match[3]))
loops = []
for i, (addr, op, args) in enumerate(rows):
    if op != 'jne':
        continue
    target = int(args.split()[0], 16)
    body = [r for r in rows[:i+1] if target <= r[0] <= addr]
    if target < addr:
        loops.append(body)
loop = max(loops, key=lambda body: sum(r[1] == 'vpblendvb' for r in body))
groups = sum(r[1] == 'vpblendvb' for r in loop)
pixels = 16 * groups
assert groups == 4, 'expected the hand-unrolled 4-group (64-pixel) main loop'
joined = '\n'.join(args for _, _, args in loop)
assert not re.search(r'%r(?:sp|bp)', joined), 'hot-loop stack access'
assert sum(op.startswith('j') for _, op, _ in loop) == 1, 'extra hot branch'
assert not any(op.startswith('call') for _, op, _ in loop), 'hot call'
assert not any(op.startswith('vmov') and '(' not in args for _, op, args in loop), 'vector copy'
regs = set(map(int, re.findall(r'%[xy]mm(\d+)', joined)))
vector = sum(2 if op == 'vpblendvb' else 1 for _, op, _ in loop if op.startswith('v') and not op.startswith('vmov'))
loads = sum(bool(re.search(r'\([^)]*%[a-z]', args)) and not args.endswith(')') for _, _, args in loop)
stores = sum(op.startswith('vmov') and args.endswith(')') for _, op, args in loop)
scalar = sum(not op.startswith('v') for _, op, _ in loop)
# Register-only VPBLENDVB has two retirement slots; an indexed load folded into an ALU op unlaminates;
# cmp/sub + jne macro-fuse.
indexed_alu_loads = sum(op.startswith('v') and not op.startswith('vmov') and bool(re.search(r'\([^)]*,[^)]*\)', args)) for _, op, args in loop)
retire = len(loop) + sum(op == 'vpblendvb' for _, op, _ in loop) + indexed_alu_loads - 1
arith = vector / 3 / pixels
issue = retire / 4 / pixels
print('PASS: %d pixels, %d instructions, YMM registers %d (max ymm%d), no hot-loop spills/copies/calls, one loop backedge'
      % (pixels, len(loop), len(regs), max(regs)))
print('%d vector execution uops; %d scalar instructions; %d retirement slots; %d loads; %d stores'
      % (vector, scalar, retire, loads, stores))
print('Resource bounds: arithmetic (ports 0/1/5) %.6f, retirement %.6f, loads %.6f cycles/pixel'
      % (arith, issue, loads / 2 / pixels))
print('Strongest bound: %.6f cycles/pixel (not proof of an attainable CPU speed)' % max(arith, issue, loads / 2 / pixels))
