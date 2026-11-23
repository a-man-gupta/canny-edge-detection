# Canny fusion on ECE024

Use `make fusion` in the ECE AFS checkout. It builds and runs the 1080p photograph
with eight OpenMP threads, a 320-column strip, eight NMS output rows per Sobel
block and exact SIMD hysteresis seed masks. The ordinary Sobel and NMS make
targets still run their isolated kernel drivers.

## Findings

All figures below are native runs on a Xeon Silver 4208, one physical thread
per core on one socket. Every timed call's byte labels and edges were compared
with an independent scalar pipeline. The fused implementation uses the team's
Q15 Gaussian with reflected edges, clamped Sobel sampling, signed 16-bit
gradients, |Gx|+|Gy|, strict thresholds 60/120, asymmetric NMS ties, a zero NMS
border and 8-connected hysteresis. The comparator uses exactly those rules.

| Image | Scalar ms¹ | Fused one core ms | Fused eight cores ms | Parallel speedup |
|---|---:|---:|---:|---:|
| 1920×1080 photo | 67.16 | 5.23 | 1.27 | 4.1× |
| 3840×2160 photo | 252.12 | 20.55 | 4.31 | 4.8× |
| 1920×1080 noise | 114.79 | 9.86 | 2.40 | 4.1× |
| 3840×2160 noise | 502.70 | 47.40 | 9.27 | 5.1× |

¹ Scalar full-frame arrays and work allocation are timed. Scalar values here
are from the sequential mask-test runs; each invocation times the oracle
three times after warm-up. Optimized medians pool two seven-trial batches per
configuration. Timings include per-call allocation, OpenMP team work, barriers,
halos and seam reconciliation. Disk I/O and correctness comparisons are outside
the interval. Scalar speedups therefore include differences in allocation and
memory traffic. Shared-host timing varied across invocations.

### Where fusion helps

Short-block staged and fused runs share the Sobel, NMS/classification and
hysteresis implementations. Staged Gaussian writes a full horizontal int16
plane and a full blurred byte image. On the 4K photo, eight-core filter times
were **7.98 ms staged and 3.65 ms fused**, with block seeding. Fusion keeps
five Gaussian horizontal rows per worker, advances local blur into Sobel and
consumes gradients and magnitudes in NMS. The SIMD NMS writes threshold labels
directly. Threads process disjoint tiles, synchronize, run local hysteresis
in horizontal slabs, then reconcile weak paths crossing slab boundaries.

The 1080p filter screen compared strips of 128, 256 and 320 columns, two Sobel
block heights and two tile traversal orders. Within every height/order group
320 gave the fastest filter time. At 320 columns the four row-major output rows
took 0.868 ms, eight took 0.865 ms. These are effectively tied at this precision.
A taller block computes two halo gradient rows per eight output rows instead of
per four. Its larger scratch can trade away that gain. The tallest tested
row-major configuration won the first filter screen narrowly and was used in
the independent seed-mask experiment. Morton visits rectangular tiles in Z
order while preserving contiguous pixels in every SIMD row. Its best 320-wide
filter time was 0.880 ms. A per-pixel Morton storage format was not benchmarked.

**Cache evidence.** The region counter covers 32 warmed full pipelines pinned
to one core. All four reported events ran 100% of enabled time. At 4K, staged,
fused row and fused Morton recorded **0.486, 0.283 and 0.283 L1 load misses
per pixel**; corresponding cycles/pixel were **6.71, 5.39 and 5.45**.
At 1080p these were 0.368, 0.300 and 0.301 misses/pixel and 5.28, 5.17 and
5.17 cycles/pixel. Fused row executes more instructions per pixel at 4K
(10.09 vs 8.24 staged) but completes in fewer cycles. These are whole-pipeline
events; they cannot attribute every miss to a specific kernel. At width 320
the principal allocated filter scratch is 28,480 bytes for the shorter block
and 42,048 bytes for the taller one. The latter exceeds the 32 KiB L1D.
Execution uses portions of those fixed-stride arrays in sequence.

### Where tracking helps

The initial 4K noise run spent approximately 12 of 15 ms in hysteresis.
The team kernel identifies blocks containing a seed and revisits weak pixels.
The experimental version uses the SIMD comparison result as a 32-bit mask,
marks the exact lanes and enqueues only those seeds. The paired eight-core
test reduced 4K noise tracking from **12.34 to 5.69 ms** and total time from
**15.92 to 9.27 ms**. On the 4K photo total time changed from 4.41 to 4.31 ms.
The next target on dense inputs is weak-edge queue propagation; on photos the
filter remains the larger phase. The remaining gap to eightfold thread scaling
includes serial seam reconciliation, barriers, work distribution and memory
traffic. Their individual shares have not been isolated.

### Peak

Use the standalone drivers' executed 16-bit lane operations with counted
core cycles. Across widths 64, 128, 256 and 384 the best measured Sobel
was **37.28 int ops/cycle** at width 384, versus the driver's **48.00**
arithmetic-port ceiling (77.7%). Standalone NMS reached **34.74** versus
**42.24** (82.2%). Sobel's model uses 138 vector arithmetic operations ×
16 lanes / 46 port cycles. NMS uses 176 × 16 / (200 / 3) port cycles.
The full pipeline also includes Gaussian, fused classification, stores and
data-dependent hysteresis. Its fixed-size stopwatch metric is ms/frame;
these standalone percentages do not measure utilization of the full pipeline.

## Figures and reproduction

[Time and tracking](results/performance.png) · [Layout and scaling](results/layout-scaling.png) · [Full inputs and edges](results/images.png)

The photo is the Grace Hopper example bundled with Matplotlib. Both sizes use
bicubic crops of the same source image; the 4K fixture is upsampled. White
noise is deterministic (NumPy seed 18645). Exact file hashes are recorded in
the trial CSV. On a workstation with Matplotlib, Pillow and NumPy generate
fixtures with `python3 benchmarks/fusion/fixtures.py canny-fusion-inputs`.
Pass `--photo path` to use a different source. Copy the four raw inputs to
the same directory in the ECE checkout. ECE024 already has the measured inputs.

```sh
make -j4 build/canny_tiled.x build/canny_tall.x
make check check-tiled
CANNY_MASK_SEEDS=1 make check-tiled
make fusion
make fusion FUSION_WIDTH=3840 FUSION_HEIGHT=2160 FUSION_IMAGE=canny-fusion-inputs/photo-3840.raw
python3 benchmarks/fusion/run.py canny-fusion-inputs benchmarks/fusion/results
python3 benchmarks/fusion/seeds.py canny-fusion-inputs benchmarks/fusion/results
bash benchmarks/fusion/counters.sh canny-fusion-inputs benchmarks/fusion/results
sh benchmarks/fusion/peak.sh > benchmarks/fusion/results/peak.log
python3 benchmarks/fusion/plot.py canny-fusion-inputs benchmarks/fusion/results
```

`trials.csv` holds individual fusion-screen and confirmation timings, and
`seeds.csv` holds the paired follow-up. The graph's whiskers span the middle
50% of observations. The layout/scaling graph uses the initial block seeder.
The input/edge PNG shows the full benchmark frames. Full-size raw edge maps
are alongside the results on ECE AFS.
