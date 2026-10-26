#!/usr/bin/env python3
"""Audit the emitted 4-row x 32-column hysteresis vector-pass loop (hysteresis_rows4_repeat);
Cascade Lake bounds. 256-bit vectors plus AVX-512VL vpternlogd: no zmm, spills or calls. The
cold seed-hit branch is outside the loop. A changed instruction mix fails.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import port_model  # noqa: E402

binary = sys.argv[1] if len(sys.argv) > 1 else 'hysteresis_driver.x'
ins = port_model.disassemble(binary, 'hysteresis_rows4_repeat')
loop = port_model.hot_loop(ins, lambda rows: sum(r[1] == 'vpternlogd' for r in rows) == 13)
c = port_model.count(loop)
expected = {'vpternlogd': 13, 'vpcmpeqb': 4, 'vpaddb': 4, 'vpand': 1, 'vptest': 1}
if any(c['mix'].get(k) != v for k, v in expected.items()):
    sys.exit('FAIL: instruction mix changed; update the resource model: %s' % c['mix'])
if c['loads'] != 18 or c['stores'] != 4:
    sys.exit('FAIL: expected 18 loads and 4 stores, got %d and %d' % (c['loads'], c['stores']))
# 6 label rows are loaded at x-1, x, x+1. With x on a 32-byte boundary, one of the x-1 / x+1
# loads of every row crosses a 64-byte line.
port_model.report('Hysteresis vector pass, AVX2 + AVX-512VL vpternlogd (256-bit): '
                  '4 rows x 32 = 128 pixels/iteration', c, 128, split_loads=6)
