# How the final Canny pipeline works

On the native 4K Apollo photograph, eight workers took **14.97 ms with five SIMD stages, 9.52 ms with partial fusion, and 4.57 ms with full filter fusion**. Every version produced exactly the same labels and edge pixels. That 3.28× speedup compares the same algorithm and the same eight workers. A separate scalar implementation took 260.47 ms in the fully fused eight-worker series.

[10-page IEEE report](Canny-final.pdf) · [Gaussian and hysteresis L1 review](gaussian-hysteresis-l1-review.md)

## 1. What moved when we fused the stages?

A stage is a mathematical step. A kernel is the code that performs work. Two steps can use one kernel, and two kernels can communicate through a small local buffer.

```text
                         Before                           After
Gaussian blur            full blurred image               five horizontal rows in a ring
Sobel gradients          full Gx, Gy and magnitude maps    three temporary tile planes
NMS                      full suppressed magnitude map    selected center in a register
Double threshold         full byte label map              full byte label map
Hysteresis               final edge map                   final edge map
```

The change after NMS is especially simple. Once we know whether the center survives, we already have its magnitude in a register. We can immediately compare it with 60 and 120 and write a byte. Hysteresis still needs its own pass because a connected weak edge can extend well beyond a tile.

## 2. Work through one pixel

**Gaussian.** Take a row of five pixels. Give the middle one the largest weight. The outer two share one weight and the inner two share another. In the code the 16-bit weights are integer approximations, and each product rounds before addition.

```text
Five pixels                     a       b       c       d       e
Pair the outer pixels           a + e
Pair the inner pixels                   b + d
Weighted result                M(a+e,1785) + M(b+d,8002) + M(c,13193)

M(x,k) = floor((x*k + 16384) / 32768).
Input to the first pass = 64 * pixel intensity.
```

Do this left-to-right, then top-to-bottom on five saved rows. Round the result back to an 8-bit intensity. For a step from 20 to 60 which continues vertically, six output intensities around the change are **20, 22, 32, 48, 58, 60**. Slide the ring by retiring the oldest row and filtering one new row. The earlier midterm used sigma 1.4; the final pipeline and its scalar oracle both use sigma 1.

**Sobel.** For a single output, the input patch, horizontal mask and vertical mask look like this:

```text
blurred input       Gx mask         Gy mask
22  32  48         -1  0  1       -1 -2 -1
22  32  48         -2  0  2        0  0  0
22  32  48         -1  0  1        1  2  1
```

For each input row, D = right − left = 26 and S = left + 2×center + right = 134. Then **Gx = 26 + 2×26 + 26 = 104**, **Gy = 134 − 134 = 0**, and **M = |Gx| + |Gy| = 104**. As we move down, the old middle and bottom source rows become the new top and middle. Because Gx can be written as (Dtop + Dmiddle) + (Dmiddle + Dbottom), one of these sums is ready for the next result. One AVX2 register holds sixteen 16-bit columns.

**NMS.** For this center Gy is zero, so inspect the left and right magnitudes. For the three values **48, 104, 104**, the middle beats 48 and ties 104. Our tie rule keeps this center. A vertical gradient selects above/below, and diagonal gradients select opposite corners. The four decisions in the source use magnitudes and signs without atan2. Page 5 shows the four neighbor pairs. The exact comparisons use the integer approximation to tan(22.5°).

**Threshold.** For 104, (104 > 60) + (104 > 120) equals **1**, so the center is weak. A retained magnitude of 121 gives **2** (strong); 60 gives **0**. These comparisons share the NMS loop.

**Hysteresis.** Weak pixels survive only when an eight-neighbor path joins them to a strong pixel. A queue carries that decision across any number of pixels.

```text
labels                    output
2  0  0  0  1            255    0    0    0    0
0  1  0  0  0              0  255    0    0    0
0  0  1  0  0              0    0  255    0    0
```

## 3. Which size refers to which thing?

| Size | Meaning |
|---|---|
| 5×5 | Gaussian footprint for one output. Implemented as two five-tap passes. |
| 3×3 | Sobel footprint for one output. |
| 10 rows × 16 columns | Production Sobel register tile. Twelve blurred rows and eighteen columns cover it. |
| 2 rows × 64 columns | One production NMS/classification loop. Each row has four 16-pixel groups. |
| 64 rows × 320 columns | Maximum full-pipeline ownership tile in this measurement. Its approximately 41 KiB of worker scratch can span L1 and L2. |
| Width 128 | Width of the warmed Sobel and NMS strips for the principal kernel measurements below. |

Each Sobel tile emits ten rows of magnitude and gradients. The top and bottom rows serve as NMS neighbors, so eight label rows can be produced. Workers scan contiguous columns, keep local intermediate planes, and share a full-frame label image. After local tracking they inspect adjacent slabs and propagate across seams. The checked border policy guarantees that the direct-offset queue never needs to divide each linear address by the image width to check its left/right neighbors.

## 4. How did we measure the real kernels?

The drivers changed from the earlier 6×32 Sobel and suppression-only NMS to the **ten-row object used in production** and **nms_labels**. The Sobel check validates all three int16 planes, including flat, alternating and random inputs. NMS checks 400 fills against scalar labels, including small ranges, ties, both diagonal signs and threshold comparisons. Full frames separately validate both labels and final edges.

On ECE024 a Xeon Silver 4208 core has a 32 KiB L1 data cache and 1 MiB L2. There are eight cores per socket, two sockets, two hardware threads per core. A 256-bit register holds sixteen words or 32 bytes. Packed arithmetic can use eligible ports among p0/p1/p5; loads use p2/p3 and store data p4. A slot in the front end and an execution-port use are different resources.

The driver warms the same input, then measures user core cycles for repeated calls with a pinned counter. It counts distinct 64-byte lines, including halos and output planes. At width 128 Sobel touched 11,520 bytes and fused NMS 2,624. The driver rejects oversized buffers and multiplexed measurements. The separate port measurements count one raw event together with core cycles. The rate includes calls and loop bookkeeping. At width 256 Sobel's buffers also fit by byte count, but its replacement rate increased substantially. This is why cache capacity and measured cache traffic are both reported.

## 5. Where is the bottleneck and how much did we achieve?

| Timed work | Working set | Optimistic ceiling | Measured | Meaning |
|---|---:|---:|---:|---|
| Gaussian, complete 256×24 hot image | 16,000 B | 48 arithmetic; 28.44 implementation int lane-ops/cycle | 9.97 paired; 16.05 earlier | Shifted loads predicted to limit H; allocation predicted to limit V. Other activity affected absolute rates. |
| Sobel, 10×16 | 11,520 B | 48.00 arithmetic int lane-ops/cycle | 32.53 (67.8%) | Shared p0/p1/p5 demand; allocation gives a tighter optimistic bound of about 45.3. |
| NMS + threshold, 2×64 | 2,624 B | 40.26 arithmetic int lane-ops/cycle | 30.43 (75.6%) | Aggregate p0/p1/p5 work, including blend and shuffle costs. |
| Historical standalone threshold | 2,560 B | 32 useful lane-ops/cycle | 12.96 at 64 outputs, 18.64 at 128 | Port 5 packing cost. This standalone stage uses the older 32-bit magnitude interface. |
| Exact hysteresis seed scan | 6,740 B | 30.5 byte lane-ops/cycle | 17.29 (about 57%) | Estimated split-load pressure on p2/p3. |
| Complete direct-offset tracking | 21,056 B | Data-dependent work | 3.496 sparse, 54.679 dense cycles/pixel | Different queue lengths. One uniform integer-work numerator would hide that difference. |

**Sobel math.** One 160-output iteration has 55 adds + 34 subtracts + 20 absolute values. Work is 109 × 16 = 1744 lane-ops. At one eligible micro-op per port per cycle, three arithmetic ports require at least 109 / 3 = 36.33 cycles. Peak = 1744 / 36.33 = **48**. Measured = 10.9 ops per pixel / 0.335 cycles per pixel = **32.53**. The port group is an analytical limit; the measurements do not identify one inherently slow instruction.

**NMS math.** Eight row-groups × 26 counted word operations × 16 lanes = **3328 operations**. A variable blend is one counted lane operation per lane but two execution micro-ops. Add the second micro-op for 24 blends and the cost of 16 extracts/packs to the 208 counted vector instructions. Peak = 3328 / ((208 + 24 + 16) / 3) = **40.26**. Measured = 26 / 0.8545 = **30.43**. Comparisons count as lane operations here. Extracts and packs consume ports but are excluded from useful work.

**Did we fill the ports?** At width 128 the p0/p1/p5 event rates were 0.705/0.742/0.749 for Sobel and 0.792/0.813/0.754 for fused NMS. The model assumes ready operands and feasible routing. A measured rate below one does not reveal which dependency made each individual cycle idle. This is why the group sweep matters.

## 6. What happened when we added work or changed the schedule?

| Experiment | Result | Production decision |
|---|---|---|
| Gaussian, 2 → 4 → 8 groups | 1.553 → 1.405 → 1.558 cycles/pixel; eight groups spilled | Keep four |
| Gaussian, shifted loads → shuffled neighbors | 1.405 → 1.538 cycles/pixel for complete image | Keep shifted loads |
| Sobel, 1 → 2 → 4 groups | Width 128 improved; width 256 regressed at four. Four-group loop had 40 stack-referencing vector instructions. | Keep one 16-column group for the pipeline |
| Fused NMS, 1 → 2 → 4 → 8 groups | 0.938 → 0.926 → 0.854 → 0.897 cycles/pixel at width 128 | Keep four |
| Gate low threshold inside the NMS limit | 0.858 → 0.813 cycles/pixel in L1; eight-core native 4K frame results mixed | Keep production expression; save candidate for a quieter paired test |
| Pair exact hysteresis seed rows | Sparse traversal improved 1.27×; dense traversal slowed | Keep original for varied scenes |

A Gaussian multiply takes five cycles to deliver its result and two can start per cycle. Ten independent, ready products would cover those five cycles ideally. Four groups expose twelve potential products, but inputs and pair sums must be ready first. A shuffle can arrange the inputs, while the rounded weighted products still have to execute. The direct experiment shows that four works best among the tested whole-Gaussian variants.

Raw group sweeps and frame trials are retained in the private ECE024 experiment archive (commit `3fb833e`).

## 7. Milliseconds, integer throughput and FLOPs

- **End-to-end, same eight cores, 4K:** 14.974 / 4.566 = **3.28×** from SIMD stages to SIMD tiles. On 1080p, 3.109 / 0.860 = **3.62×**. The partial step includes reduced materialization, adaptation copies and synchronization.
- **End-to-end, scalar versus complete optimized implementation:** 260.472 / 4.566 = **57.0×** for the eight-core 4K comparison. This ratio includes parallelism. Comparing to one optimized worker gives 261.724 / 23.287 = **11.24×**. Full-frame timings include workspace creation and tracking, and exclude file I/O.
- **FLOPs of the fused pixel math:** zero. The actual PMU experiment observed zero retired FP32 arithmetic and zero packed FP64 arithmetic. Eleven scalar-double events per frame occur in the timed wrapper. Coefficients are prepared before timing. Report milliseconds/image, pixels/s and the appropriate kernel int lane-ops/cycle alongside the FLOP count.
- **Positive FP reference:** the earlier direct FP32 Gaussian has 25 tap multiplications and 25 accumulator adds per pixel. At 1080p that is 103.68 million tap FLOPs / 0.250383 s = **0.414 GFLOP/s**. This is a different algorithmic implementation and is excluded from the fixed-point fusion speedup denominator.

## 8. How to reproduce

ECE024 private checkout: `/afs/ece.cmu.edu/usr/krishp2/Private/18645/canny-edge-detection`. The hand-in ZIP includes both measured grayscale fixtures.

```sh
# Run in the project root on ECE024.
make -j4 check
make sobel nms CORE=10 SOBEL_SIZE=128 NMS_SIZE=128 RUNS=30000 TRIALS=7
make fusion FUSION_IMAGE=noise
make pipeline-asm

# Archived experiments below require the private ECE024 benchmark checkout at 3fb833e.
SIZE=128 python3 benchmarks/final/l1/run.py
SIZE=256 python3 benchmarks/final/l1/run.py
python3 benchmarks/final/l1/label_gate.py
python3 benchmarks/final/l1/frame_compare.py
bash benchmarks/final/other-stages/run.sh
bash benchmarks/final/fusion/build.sh
bash benchmarks/final/fusion/run.sh > benchmarks/final/fusion/results.log
bash benchmarks/final/fusion/counters.sh > benchmarks/final/fusion/pmu.log
bash benchmarks/final/fusion/legacy-fp.sh > benchmarks/final/fusion/legacy-fp.json
```

The L1 group script retains compiler output per group count. The main production listing is under [assembly](../../assembly/). Cache counters have different scopes: the main Sobel/NMS sweep counts repeated kernel calls; the auxiliary Gaussian/threshold/seed PMU runs count the process with a dominant repeated kernel; the fusion PMU enables counters only over 32 warmed frame calls. Use ratios only between comparable variants.

To regenerate the report, run `python3 docs/final/figures.py` with NumPy, pandas and Matplotlib, then run `pdflatex report.tex` twice from this folder with IEEEtran installed. The delivered PDF and all plot data are already included.

## 9. What the class material changed

| Course material | Decision or check it motivated |
|---|---|
| Project Overview, Welcome, Benchmarking slides and worksheet | Pair a scalar oracle with a fast version. State the counted work, CPU clock source, timer boundary and input size. |
| Architecture, Kernels, SIMD, Kernel Design worksheet | Calculate lanes from register width. Assign eligible micro-ops, take the limiting demand, and distinguish result latency from throughput. |
| Compilers and Wrapping Up Sequential Design | Disassemble every candidate; check spills and folded memory instructions; test group count instead of inferring full occupancy. |
| Memory Hierarchy and Design for Caches | Count all touched lines, reuse Gaussian rows, test set conflicts and measure retired misses on both small and full inputs. |
| Explicit Parallelism | Define independent filter tiles, measure strong scaling, and isolate serial seam handling. |
| Collectives, Cost, Load Balancing and Implementation | Account for communication before proposing distributed memory. A multi-node MPI version would have to exchange halos and reconcile cross-node connectivity; our final single-host production measurements use OpenMP. |

The independent TA-style review challenged the Gaussian floor, exact seed-scan model, NMS footprint and signs of shared-host noise. The final version includes the phase-specific Gaussian limits, exact scan measurements, L1 line counts, and both pooled and matched-round evidence. For future work, try Halide schedules on the same fixed-point reference and improve tracking balance on images with long chains. The report makes no Halide performance claim.

## 10. Suggested 9-minute team video

| Time | Segment | Evidence to put on screen |
|---|---|---|
| 0:00–3:00 | First presenter: follow a pixel through Gaussian and show how five rows rotate. | Blurred step, three rounded products, shifted-load/shuffle comparison |
| 3:00–6:00 | Second presenter: Sobel reuse, thinning and direct byte labels. | 10×16 tile, tie example, 128-wide L1 group sweep and measured port counts |
| 6:00–9:00 | Third presenter: connected weak edges, worker boundaries, final result. | A seam crossing, the 14.97 → 9.52 → 4.57 ms chart, what the FLOP counters counted |

The course asks all team members to present. This is a recording outline; the submitted PDF and implementation ZIP are separate files.
