# Matched L1 width experiments on ECE024
The width sweep uses 128, 192, 256 and 320 columns. Row counts follow each kernel's neighbor requirements. All measurements pin to CPU 10 and retain the scalar checks. Use the 256-column case to compare stages. The first sweep indicated considerable host variability, so compare alternatives in alternating order.

- widths.py and widths.csv record ten trials per width, stage and group count.
- other.sh and other.log cover Gaussian phases, threshold, seed scan and sparse/dense tracking. The 30.5 seed benchmark ceiling was estimated for width 256.
- expressions.py and expressions.csv compare equivalent Sobel and NMS expressions. Values on the original 26-operation NMS scale quantify speedup. Recount the changed assembly before calling that ratio port utilization.
- gaussian.py and gaussian.log compare the installed rotating row window with the baseline from commit 218e262. Median round times are 0.787 and 0.886 cycles/pixel. The Gaussian test passed 468 cases. This change affects gaussian_u8. The fused filter has a separate caller for row primitives.

Next: verify the NMS candidate's actual arithmetic count and threshold domain, and test full frames. Sobel and the complete Gaussian are below 80%. The queue has variable work per input pixel; report time and visitation counts separately from the fixed-work seed scan.

## Packed production NMS and common width

The ordered nonnegative threshold path now combines the low cutoff with neighbor suppression and packs two adjacent groups into one 32-byte store. The general threshold path preserves the previous expression. The installed ordered loop (0xaf0 through 0xfbf in installed-nms.asm) has 200 counted vector instructions, 24 additional blend micro-ops, four packs and four permutations per 128 pixels. At one dispatch per cycle on each of p0/p1/p5, the aggregate ceiling is (200 × 16) / (232 / 3) = 41.38 integer lane-ops/cycle. Three consecutive 11-trial rounds at width 256 reached 33.30, 33.29 and 33.30. An earlier 11-trial verification reached 32.80. The native 3840×2160 eight-worker run with a 256-wide strip matched the scalar edges exactly. The Makefile now lets both L1 drivers share L1_WIDTH, default 256.

Explicitly specializing Gaussian for width 256 did not beat the rotating-window version. Changing GCC instruction scheduling also left the ten-row Sobel below 80%; see gaussian-width.log and scheduling.csv. Next evaluate Sobel row pitches and Gaussian expansion cost.

## Sobel reaches the 80% arithmetic target

The installed ten-row Sobel computes two groups of 16 columns together, prepares the next input row before finishing the current one, and uses a pitch of 480 words for both input and output. The L1 driver now places the output immediately after the input as the fused scratch structure does. Its 256-column benchmark touches 22,272 cache-line bytes. The compiled loop counts 110 word adds, 68 subtracts, and 40 absolute values across 320 pixels. At three eligible units the arithmetic peak is 48 int16 lane-ops per cycle. Three separate eleven-trial medians were 40.39, 40.45 and 40.24 (83.8–84.3%). See installed-sobel.asm and installed-sobel.log. The scalar checks passed. All paired native 4K frames matched; the new pipeline took 4.78–4.91 ms in these two experiments and the before/after speedup depended on the run. See installed-sobel-frames.log and installed-layouts.log.

For Gaussian, processing two adjacent vertical outputs together reached 18.60 versus 17.87 lane-ops/cycle in a matched experiment. This is an experimental six-row buffer: the five-row driver's original allocation estimate printed in gaussian-pair.log is 576 bytes low for this variant (16,576 bytes including the extra row). The established 28.44 implementation ceiling applies to the original schedule. Larger vertical batches, fixed-width code, Clang, register lookahead, and direct unexpanded input did not establish 80% for the complete filter. Keep standalone and complete-frame measurements distinct.

## Gaussian four-row staging at width 256

ECE024, CPU 10, 256×24 pixels. The AVX-512BW standalone path expands up to four rows before reading their overlapping horizontal neighborhoods. The filtered row ring still supplies four adjacent vertical outputs. In nine alternating pairs the median of the per-run medians rose from 29.14 to 31.22 integer ops/cycle, and the staged version won eight pairs (native-delayed-pairs.log). Each output counts 14 fixed-point arithmetic operations. The guarded validation passed 468 cases (installed-delayed-check.log). This measures the standalone filter only.

The benchmark's 17,024-byte footprint line predates the additional local staging array. Reserving the entire array adds 2,560 bytes, giving a conservative 19,584 bytes of pixel and row storage under that accounting, before other stack state. Native-delayed.log records store-forwarding events before and after. Installed-gaussian-trace.csv describes the four-row binary *before* delayed staging. A matched functional-unit ceiling for the final binary remains outstanding.

## Installed Gaussian reaches 80% on the 256-column L1 tile

The width-256 standalone path expands a band of rows, rolls five horizontal sums through registers, and processes two adjacent 32-column vectors together. On ECE024 CPU 10, nine 5-trial medians for the checked 256×24 tile gave a median of **37.96 reference integer ops/core cycle** (37.50–38.08). Each tile counts 256 × 24 × 14 = 86,016 reference ops. The benchmark reserves 30,208 bytes for input, output and the full padded band array, within 32 KiB L1D. A separate process-wide counter run recorded 29,006,021 retired L1 load hits and 72,332 misses. The 888-case guarded suite including heights around band boundaries was bit-exact.

Intel PT recorded 5,376 instructions in the native image routine with zero decoding errors. Per tile, p0 handles 1,344 rounded multiplies and 192 shifts; p5 handles 192 byte expansions, three coefficient broadcasts and 192 narrowings at two dispatches each. The remaining 1,536 word adds can run on either port. The vector-unit throughput floor is (1,344 + 192 + 192 + 3 + 384 + 1,536) / 2 = 1,825.5 cycles. Both fixed-port counts fit within the floor. The ideal vector-unit ceiling is 86,016 / 1,825.5 = **47.12 reference int ops/cycle**. The installed median reaches **80.6%** (eight of nine round medians above 80%). The calculation excludes scalar address work and register copies. The single-instruction tests in gaussian-units.csv independently verify the port assignments on this CPU.

Measurements: installed-columns-l1.log, installed-columns-trace.csv, gaussian-units.csv and two-column-guards.log. The fused image path calls separate row primitives. Full connected-edge tracking still lacks a matched whole-kernel utilization result; its exact-mask scan timing covers the no-seed case only.

## Whole hysteresis with packed connectivity

The input width is 256 and height 8, including border pixels. Input and output occupy 4,096 bytes. Accounting for the complete reserved queue adds 16,384 bytes, for 20,480 bytes of buffers. Each dataset was verified against scalar 8-connected tracking, then timed for three rounds of nine trials. Reference integer work counts one initial strong-label test per pixel, one weak-label test for each valid neighbor of a reached pixel in the scalar traversal, and a visited test when the neighbor is weak. These counts apply to both binaries. Hot floating-point operations are zero.

| Dataset | Reference ops/tile | Queue int ops/cycle | Packed int ops/cycle | Ideal vector-unit ceiling | Achieved |
|---|---:|---:|---:|---:|---:|
| Sparse | 2,346 | 0.549 | 6.719 | 18.046 | 37.2% |
| Dense | 20,059 | 0.384 | 35.601 | 76.953 | 46.3% |

The ECE024 single-instruction tests assign each vector operation to its eligible ports. For sparse input the traced vector operations need 390 dispatches across ports 0, 1 and 5, yielding at least 130 cycles. Dense input needs 782 dispatches, or at least 260.67 cycles. Across both traces the total demand on the three ports gives the tightest vector-unit floor. This ideal excludes scalar instructions, data movement and propagation dependencies. Observed p5 dispatches were 0.666 and 0.679 per core cycle; retirement was 3.33 and 3.44 slots/cycle. Neither number is the achieved fraction of the ideal vector-unit ceiling.

Reproduce the sparse bound with `python3 benchmarks/final/matched/hysteresis_port_model.py benchmarks/final/matched/hysteresis-packed-benchmark.asm benchmarks/final/matched/sparse.latest.ips 2346`. Substitute `dense.latest.ips` and `20059` for dense. See installed-flat-hysteresis.csv, installed-flat-pmu.csv and hysteresis-units.csv.

On the native 3840×2160 Apollo photograph with eight OpenMP workers, all ten runs in five alternating pairs matched the scalar edges exactly. Median tracking time across rounds fell from 2.118 to 1.468 ms. Median complete pipeline latency fell from 4.737 to 4.123 ms (1.15×). See installed-hyst-4k-pairs.log. The guarded queue fallback limits work for paths requiring many sweeps. The direct test passed 3,390 image checks and 288 hot-loop ranges, including weak serpentine paths and slab boundaries.

## Two packed rows per vector

For even-height, 256-column slabs on ECE024 a 512-bit vector fits two entire rows. It computes their horizontal neighbors independently, then exchanges the needed masks between the two halves and the adjacent row pair. The existing single-row vector loop handles odd heights. Other widths keep the previous packed/queue dispatch. This change targets the L1 kernel; the earlier native 4K result uses the general-width path.

Five alternating round pairs, nine trials per variant per round, gave 7.566 versus 6.892 reference integer ops/cycle on sparse input and 43.833 versus 35.816 on dense. These are the medians of all 45 trials per input and variant. The complete byte-based candidate was slower on both datasets. Keeping four row pairs in registers did not beat processing one pair at a time. The installed two-row code passed 3,390 scalar image comparisons and 288 hot-loop ranges.

| Input | Port 0 only | Port 5 only | Either port | Ideal cycles | Reference ops | Peak | Measured / peak |
|---|---:|---:|---:|---:|---:|---:|---:|
| Sparse | 45 | 121 | 110 | 138 | 2,346 | 17.00 | 44.5% |
| Dense | 105 | 197 | 214 | 258 | 20,059 | 77.75 | 56.4% |

The port floor is the largest of the two fixed-port demands and the total demand divided by two. For sparse input this is (45+121+110)/2=138 cycles. The table uses vector arithmetic and mask conversions under the same scope as the previous model. These ceilings exclude scalar loop work, loads, stores and loop-carried dependencies. The eligible ports were measured on ECE024 (hyst-pair-units.csv). Reproduce with hysteresis_port_model.py, hysteresis-two-rows.asm, sparse.two-rows.ips or dense.two-rows.ips, and the reference count from the table. The trace had zero decode errors. Full trial output is in installed-hysteresis-row-pairs.log.
