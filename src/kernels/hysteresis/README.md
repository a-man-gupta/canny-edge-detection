# Hysteresis

Keep every strong label and every weak pixel connected to a strong pixel through eight-neighbor steps. The seed scan processes 32 byte labels at once. VPTERNLOGD combines neighbor masks and VPMOVMSKB identifies candidate lanes. Each worker then expands a queue through its horizontal slab. Known-zero image side columns permit direct neighbor offsets. Top and bottom slab rows still require bounds checks.

**Standalone seed-pass model.** The historical four-row × 32-pixel pass needs 27 load/address-port uses including splits, served by two ports. Peak = 128 / (27 / 2) = **9.48 pixels/cycle**. On seed-free data the driver measured **0.118–0.123 cycles/pixel**, about **86–90%** of peak. Queue length depends on the image, so that rate cannot describe full hysteresis.

**Integrated measurement.** On native 4K Apollo with eight workers, simplifying queue traversal cut tracking from 3.04 to 2.10 ms in the matched experiment. On dense noise, it fell from 4.07 to 2.45 ms.

[Source](hysteresis_kernel.cpp) · [Assembly](../../../assembly/hysteresis.asm) · [Matched trials](../../../benchmarks/fusion/audit/queue.log).
