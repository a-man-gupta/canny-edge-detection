# Hysteresis

Start with [hysteresis_kernel.cpp](hysteresis_kernel.cpp) for the fused slab entry point and packed edge-propagation loop. The public header declares the interface. The `detail/` folder holds the 256-column specialization, seed scan and queue fallback.

Keep every strong label and every weak pixel connected to a strong pixel through eight-neighbor steps. The seed scan processes 32 byte labels at once. VPTERNLOGD combines neighbor masks and VPMOVMSKB identifies candidate lanes. In the masked pipeline, each worker tracks connectivity in a slab with zero side columns. On ECE024, widths divisible by 64 use packed weak and reached bit masks. At width 256, each vector holds an entire row. Each pass propagates reachability from the eight neighbors until no bits change. Wider slabs sweep groups of 64 pixels in alternating directions. Long winding paths use the queue fallback. Slab seams are joined after all local traversals finish.

**Standalone seed-pass model.** The historical four-row × 32-pixel pass needs 27 load/address-port uses including splits, served by two ports. Peak = 128 / (27 / 2) = **9.48 pixels/cycle**. On seed-free data the driver measured **0.118–0.123 cycles/pixel**, about **86–90%** of peak. Queue length depends on the image, so that rate cannot describe full hysteresis.

**Integrated measurement.** On native 4K Apollo with eight workers, simplifying queue traversal cut tracking from 3.04 to 2.10 ms in the matched experiment. On dense noise, it fell from 4.07 to 2.45 ms.

[Source](hysteresis_kernel.cpp) · [Assembly](../../../assembly/hysteresis.asm) · [Matched trials](../../../benchmarks/fusion/audit/queue.log).


**Whole hysteresis, 256×8 in L1.** The installed path computes two packed rows per 512-bit vector. In five alternating comparisons this raised throughput from 6.89 to **7.57 reference integer ops/core cycle** on sparse input and from 35.82 to **43.83** on dense input. Its vector-unit ceilings are 17.00 and 77.75 respectively (44.5% and 56.4%). Work counts are input-specific because the scalar connectivity traversal examines a different number of neighbors. [Peak model, timing records and earlier native 4K comparison](../../../benchmarks/final/matched/README.md).
