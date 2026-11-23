# Non-maximum suppression

NMS thins the magnitude ridge along the gradient direction. For each center, compute ax = |Gx|, ay = |Gy| and t = floor(ax × 27146 / 65536). Choose left/right for ay ≤ t, up/down for ay > t + 2ax, or a diagonal from the signs of Gx and Gy. Keep the center when it exceeds the first neighbor and equals or exceeds the second.

**Tile and fusion.** Two rows × 64 columns contain four groups of sixteen lanes per row. The implementation forms max(first, second − 1), selects the directional limit with vector masks, and compares once. VPMULHUW computes t. VPMAXSW, VPBLENDVB and VPCMPGTW implement selection and comparison. The integrated entry point nms_labels applies both thresholds before writing a byte.

**Standalone NMS benchmark.** 176 counted vector operations × 16 lanes / (200 port micro-ops / 3 ports) = **42.24 integer lane-ops/cycle**. Measured **34.74**, or **82.2%**. The fused label loop adds compares and byte packing. Its time is included in the integrated filter phase.

[Source](kernel_nms.cpp) · [Fused assembly](../../../assembly/nms-threshold.asm) · [Standalone results](../../../benchmarks/fusion/results/peak.log).
