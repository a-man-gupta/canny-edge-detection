# Fixed-group unrolling and memory layout on ECE024

The Xeon Silver 4208 has a 32 KiB L1 data cache, 1 MiB private L2 and 64-byte cache lines. We used a pinned core for L1 measurements and eight pinned cores for complete frames. Sobel, NMS and standalone threshold use AVX2. The ten-row standalone Gaussian and packed hysteresis also use AVX-512BW. The production fused Gaussian calls the row primitives. A fixed group is expanded inside the horizontal scan; width, borders, image bands and hysteresis convergence remain runtime quantities.

## Kernel decisions

| Kernel | How independent work is scheduled | Limiting resource in the existing port model | Result on the matching L1 workload |
|---|---|---|---|
| Gaussian | Four 16-pixel groups in the AVX2 horizontal row. For standalone 10×256, keep ten independently computed horizontal vectors for a 32-column strip, then share them across vertical outputs. | Four-group horizontal pass needs about 14 load-port cycles per 64 outputs versus 6 multiply-issue cycles. The standalone 10-row trace instead bounds the combined p0/p5 workload. | Fully spelling out the 10-row specialization gave 38.95 versus 38.62 reference int ops/cycle. This difference is small. |
| Sobel | Two adjacent groups of 16. Start the next input row while completing this row’s differences, weighted sums, and gradient stores. | Adds, subtracts and absolute values share p0/p1/p5, with a 48 lane-op/cycle ideal. | Full source expansion of ten rows fell from 40.47 to 39.40 int ops/cycle and introduced two vector stack references. Keep the existing compiler-unrolled row schedule. |
| Fused NMS + threshold | Process 64 contiguous outputs per row in four 16-lane groups. Pack two groups per store. The image path supplies two rows per call, the L1 driver supplies ten. | Compare, selection and logic pressure across p0/p1/p5, plus pack/permutation work. | Fully expanding ten rows fell from 33.80 to 18.22 int ops/cycle. GCC outlined helpers and introduced stack accesses. Expanding only the four neighboring groups gave 33.88 versus 33.77 in paired runs. |
| Standalone threshold | Four independent 32-pixel blocks per trip, with a 64-pixel remainder. | Port 5 handles eight word packs, four byte packs and four permutations per 128 pixels. The 16-cycle floor gives 32 reference int ops/cycle. | 26.40 versus 25.64 int ops/cycle in confirmation, about 3% faster. This path is used for the standalone driver. NMS produces labels directly in the fused pipeline. |
| Hysteresis | Two packed rows per vector in the 256-wide sweep; later sweeps depend on the previous propagation result. | Traces of the ten-row sparse/dense workloads bound the combined p0/p5 work. The realized rate also depends on how many waves are needed. | Hand-expanding input packing and output expansion gave 9.03 versus 9.40 on sparse labels and 54.55 versus 53.09 on dense labels. Keep the existing path. |

## Layout and caches

Pages 218 and 220 of the supplied midsemester deck describe ten independent FP groups and a 14-row FP32 ring for ten vertical outputs. Page 232 lays out Sobel scratch in contiguous groups and arranges its results for the next stage. We tested a 14-slot pointer window for the 10×256 integer Gaussian fixture. Its reflected boundaries alias ten unique horizontal rows. It measured **27.04 versus 38.59 int ops/cycle** for the existing register-based tile. The slide’s full-width, L2-resident FP32 experiment has a different working set. The integrated pipeline already uses five horizontally filtered rows on demand.

Both tested Sobel pitches keep row starts on 64-byte boundaries. Tightening the pitch from 480 to 448 int16 elements dropped throughput from 40.47 to 39.54. Input windows displaced by one or two pixels still require unaligned accesses. Gaussian scratch padded to 352 instead of 320 words gave 38.74 versus 38.62. Neither result justified changing the pitches.

| Baseline process | L1-missing loads / (retired L1 hits + misses) |
|---|---:|
| Standalone Gaussian | 0.077% |
| Sobel | 0.019% |
| Fused NMS + threshold | 0.015% |
| Standalone threshold | 0.010% |
| Hysteresis, sparse / dense | 0.751% / 0.617% |

With the altered pitches Gaussian measured 0.089% and Sobel 0.039%. These are whole-driver counters on warmed L1 fixtures, including setup and checks. Rates alone do not identify latency stalls or establish a globally optimal layout.

## Assembly and correctness

The selected threshold loop passed the assembly analyzer’s instruction-mix, stack-access and call checks. Inspection found no direct vector operands relative to the frame or stack pointer in the checked Sobel, NMS labels and Gaussian row/ten-row functions. Gaussian also has an intentional expanded-input workspace. Hysteresis stores its reached/weak planes in local arrays for small slabs; those accesses are part of the algorithm. This audit cannot certify every helper and fallback as spill-free.

Checks included 510 guarded Gaussian cases, exact Sobel gradients/magnitude, 400 NMS fills, threshold boundaries, 64/128/192/2560-pixel threshold inputs, and byte-exact native 4K edges against scalar. The source-level unrolls used the same weights, thresholds and reference work counts.

Five nine-frame batches per build on native 4K Apollo rotated the baseline, explicit Gaussian groups, and explicit Gaussian plus four-group NMS. Median batch times were **4.127, 4.195, and 4.350 ms** respectively. Every batch matched scalar. We retained the existing fused Gaussian/Sobel/NMS/hysteresis schedules and promoted only the standalone 128-pixel threshold loop. The threshold optimization does not change fused-frame latency.
