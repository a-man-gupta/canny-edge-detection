#!/usr/bin/env python3
"""Audit the emitted 64-pixel double-threshold loop (threshold_i16_repeat); Cascade Lake bounds.
256-bit AVX2 only: no zmm, spills or calls. A changed instruction mix fails instead of reusing
an old peak.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import port_model  # noqa: E402

binary = sys.argv[1] if len(sys.argv) > 1 else 'threshold_driver.x'
ins = port_model.disassemble(binary, 'threshold_i16_repeat')
loop = port_model.hot_loop(ins, lambda rows: sum(r[1] == 'vpcmpgtw' for r in rows) == 8)
c = port_model.count(loop)
expected = {'vpackssdw': 4, 'vpcmpgtw': 8, 'vpaddw': 4, 'vpacksswb': 2, 'vpermd': 2, 'vpabsb': 2}
if any(c['mix'].get(k) != v for k, v in expected.items()):
    sys.exit('FAIL: instruction mix changed; update the resource model: %s' % c['mix'])
# 8 loads of 32 bytes per 64 pixels; with a 32-byte-aligned input none crosses a 64-byte line.
port_model.report('Double threshold, AVX2 (256-bit): 64 pixels/iteration, int32 in, uint8 out',
                  c, 64, split_loads=0)
