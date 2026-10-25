#!/usr/bin/env python3
"""Audit the emitted 128-pixel integer NMS loop; Cascade Lake resource bounds.
The loop uses 256-bit AVX2 vectors plus AVX-512VL mask registers (kmovb loads, masked blends).
It must not use 512-bit zmm registers (they would lower the core clock), spill, or call.
Unknown instruction forms fail instead of silently reusing a peak from another binary.
"""
import collections
import re
import subprocess
import sys
from pathlib import Path

obj=sys.argv[1] if len(sys.argv)>1 else 'nms_driver.x'
text=subprocess.check_output(['objdump','-d','-C','--no-show-raw-insn',obj],universal_newlines=True)
body=text.split('<nms_i32_repeat>:',1)[1]
body=re.split(r'\n[0-9a-f]+ <',body)[0]
if re.search(r'%zmm',body):sys.exit('FAIL: 512-bit zmm register in nms_i32_repeat')
ins=[]
for line in body.splitlines():
    m=re.match(r'\s*([0-9a-f]+):\s+(\w+)\s*(.*)',line)
    if m:ins.append((int(m[1],16),m[2],m[3],line))
loops=[]
for i,(addr,op,args,line) in enumerate(ins):
    if not op.startswith('j') or not re.match(r'[0-9a-f]+ ',args):continue
    target=int(args.split()[0],16)
    rows=[r for r in ins[:i+1] if target<=r[0]<=addr]
    if target<addr and sum(r[1]=='vpcmpgtd' for r in rows)==128 and sum(r[1].startswith('j') for r in rows)==1:loops.append(rows)
if len(loops)!=1:sys.exit('FAIL: expected exactly one 16-group / 128-pixel hot loop')
loop=loops[0]
if any(re.search(r'\([^)]*%r(?:sp|bp)',r[2]) for r in loop):sys.exit('FAIL: hot-loop stack access')
if any(r[1].startswith('call') for r in loop):sys.exit('FAIL: hot-loop call')
regs=sorted(set(map(int,re.findall(r'%[xy]mm(\d+)','\n'.join(r[3] for r in loop)))))

counts=collections.Counter()
slots=0;loads=0;stores=0;indexed_stores=0;copies=0
for addr,op,args,line in loop:
    mem=bool(re.search(r'\([^)]*%',args));indexed=bool(re.search(r'\([^)]*,[^)]*\)',args))
    masked=bool(re.search(r'\{%k[1-7]\}',args))
    if op in ('vmovdqu','vmovdqu32','vmovdqu64','vmovups','vmovdqa','vmovdqa32','vmovdqa64','vmovaps'):
        if masked and not mem:
            counts['blend']+=1;slots+=1            # masked register move = the select (1 uop)
        elif not mem:
            copies+=1;slots+=1                     # plain register copy
        elif args.lstrip().startswith('%'):
            stores+=1;indexed_stores+=indexed;slots+=1
        else:
            loads+=1;slots+=1
    elif op=='vpblendmd':
        if mem:sys.exit('FAIL: unexpected memory-operand blend')
        counts['blend']+=1;slots+=1
    elif op=='kmovb':
        if not mem:sys.exit('FAIL: direction mask no longer loaded straight from memory')
        counts['kmovb']+=1;loads+=1;slots+=1
    elif op=='vpcmpgtd':
        counts[op]+=1;loads+=mem;slots+=1+int(mem and indexed) # indexed AVX compare unlamination
    elif op in ('vpandn','vpand'):
        if mem:sys.exit('FAIL: unexpected folded memory operation')
        counts[op]+=1;slots+=1
    elif op in {'add','sub','inc','dec','lea','mov','movslq','sar','shr','shl','and','or','xor','test','cmp','jne','jl','jle','jg','jge','jb','jbe','ja','jae'}:
        if mem:sys.exit('FAIL: unexpected scalar memory operation')
        slots+=1
    else:sys.exit('FAIL: unknown hot-loop instruction '+op)
expected={'vpcmpgtd':128,'vpandn':64,'vpand':16,'blend':48,'kmovb':32}
if any(counts[k]!=v for k,v in expected.items()):sys.exit('FAIL: instruction mix changed; update the resource model: %s'%dict(counts))
# GCC emits an adjacent cmp/jcc pair; confirm it stays within a 64-byte fetch block.
if loop[-2][1]!='cmp' or not loop[-1][1].startswith('j'):sys.exit('FAIL: inspect loop-control fusion')
if loop[-2][0]//64!=loop[-1][0]//64:sys.exit('FAIL: inspect cmp/branch fusion at cache-line boundary')
slots-=1
arithmetic=counts['vpcmpgtd']+counts['vpandn']+counts['vpand']+counts['blend']+copies
p01=counts['vpcmpgtd']
px=128
limits={'issue/retirement':slots/4,'arithmetic ports 0/1/5':arithmetic/3,'restricted ports 0/1 (compares)':p01/2,'load ports 2/3 (+ indexed store addresses)':(loads+indexed_stores)/2,'store data':stores,'all load/store addresses':(loads+stores)/3}
print('Integer NMS, AVX2 vectors + AVX-512VL masks (256-bit): 16 groups x 8 pixels = 128 pixels/iteration')
print('Hot loop: %d instructions, %d vector registers, no spills/calls/zmm, one loop branch'%(len(loop),len(regs)))
print('Arithmetic execution micro-ops:',arithmetic,'; issue/retirement slots:',slots,'; loads:',loads,'; stores:',stores,'; register copies:',copies)
for name,cycles in limits.items():print('  %-50s %8.3f cycles/iteration = %.8f cycles/pixel'%(name,cycles,cycles/px))
print('Ideal resource bound: %.8f cycles/pixel (not a measured or guaranteed achievable speed)'%(max(limits.values())/px))
print('Instruction counts:',dict(counts))
if len(sys.argv)>2:Path(sys.argv[2]).write_text('\n'.join(r[3] for r in loop)+'\n')
