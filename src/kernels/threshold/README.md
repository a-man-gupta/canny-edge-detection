# Double threshold

In the integrated 2×64 NMS loop each surviving magnitude m becomes label = (m > 60) + (m > 120). Zero means discarded, one means weak, and two means strong. SIMD compares produce masks, then arithmetic and packing produce byte labels. Computing these labels while magnitudes are still in registers saves a full-image intermediate write and read.

**Historical standalone benchmark.** For a separate 64-pixel threshold loop, eight packing/permutation micro-ops on port 5 require eight cycles. Peak = 64 / 8 = **8 pixels/cycle**. It measured **0.146–0.153 cycles/pixel** on core 10, or **82–86%** of peak. The final fused implementation shares loads with NMS, so this standalone peak applies only to its own driver.

[Fused source](../nms/kernel_nms.cpp) · [Fused assembly](../../../assembly/nms-threshold.asm) · [Standalone evidence](../../../docs/stage4_5_results.md).

[Standalone threshold source](threshold_kernel.cpp).

The current standalone driver processes four explicitly written 32-pixel blocks per iteration. On a contiguous 10×256 L1 fixture it measured 26.40 reference int ops/cycle, up from 25.64. Its 16 port-5 operations per 128 outputs give the same 32 int ops/cycle ceiling. [Unroll and layout comparisons](../../../benchmarks/final/matched/unroll-layout.md)
