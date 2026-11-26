# Sobel gradients and magnitude

Each output uses a 3×3 neighborhood. For each input row compute D = right − left and S = left + 2 × center + right. Then Gx = Dtop + 2 × Dmiddle + Dbottom, Gy = Sbottom − Stop, and M = |Gx| + |Gy|. Store M, Gx and Gy in separate contiguous int16 spans for NMS.

**Final tile.** Twelve blurred rows feed ten gradient rows. The tuned loop handles sixteen columns per group, one int16 per YMM lane. It carries adjacent row sums and differences forward. The earlier two-group version wrote six YMM temporaries to the stack. The selected single-group loop has no vector stack operands in the audited assembly. VPADDW, VPSUBW and VPABSW do the gradient and magnitude arithmetic.

**Standalone peak.** The earlier 6×32 benchmark counts 138 arithmetic instructions × 16 lanes and 46 port cycles across p0/p1/p5. Peak = **48.00 integer lane-ops/cycle**. Measured = **37.28** at width 384, or **77.7%**. The 10×16 integrated version has a different instruction stream. Its matched eight-core whole-pipeline experiment moved from 5.611 to 5.537 ms when changing the grouping with the original queue.

[Source](kernel_sobel.cpp) · [Final assembly](../../../assembly/sobel.asm) · [Standalone results](../../../benchmarks/fusion/results/peak.log).

**Final 10×16 L1 measurement.** Width 128, 11,520 cache-line bytes, 32.5 integer lane-ops/cycle against a 48.0 arithmetic-port ceiling (68%). [Group sweeps and port measurements](../../../docs/final/WALKTHROUGH.md).
