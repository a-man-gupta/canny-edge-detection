# Stage 4 (double threshold) and stage 5 (hysteresis)

Machine: ece024, Xeon Silver 4208 (Cascade Lake): L1d 32 KB, L2 1 MB/core, L3 11 MB/socket.
gcc 8.5, `-O3 -mavx2 -mtune=skylake -fno-tree-vectorize -fno-unroll-loops
-mno-avx256-split-unaligned-*` on the kernel files, plus `-mavx512f -mavx512vl` for hysteresis.
One thread, pinned with `taskset` (cores 10 and 5, siblings idle, load ~1).

Same method as stages 2 and 3: 256-bit registers only (AVX-512VL is used for `vpternlogd` on ymm,
not for 512-bit math), the peak is the tightest per-port bound of the compiled hot loop
(`make threshold-count`, `make hysteresis-count`: they objdump the driver and fail if the
instruction mix changes), and the drivers read real core cycles with `perf_event_open`.

Port model (uops.info, Skylake-X): packs and `vpermd` on port 5 only; `vpcmpgt*`, `vpcmpeqb`,
`vpabsb` on ports 0/1; `vpternlogd` on 0/5; `vpadd*`, `vpand` on 0/1/5; `vptest` = 1 uop on 0 + 1
on 5; 2 load ports, 1 store, 4 uops issued per cycle. Indexed memory operands of 3-operand
instructions are unlaminated (2 issue slots). The ALU bound is Hall's bound: for every set of
ports, the uops that can only run there, divided by the number of ports (`scripts/port_model.py`).

## Stage 4: double threshold (`src/threshold_kernel.cpp`, `make threshold`)

Input is NMS's output: int32 squared magnitude. Thresholds are squared too (floor(50²) = 2500,
floor(100²) = 10000), as in `canny_part2.cpp`. Output is a uint8 label: 0, 1 (weak), 2 (strong).

### Design

- Per 64 pixels: 8 loads of 8 int32. `vpackssdw` packs pairs to int16 with signed saturation.
  Every value above 32767 becomes 32767, which is still above any threshold ≤ 32766, so the
  compares stay exact and run on 16 lanes instead of 8. The whole-image function checks
  `0 ≤ low² < high² ≤ 32766` and otherwise uses the int32 scalar path.
- `(m > low) + (m > high)` per lane is 0, −1 or −2 (two compares and an add), `vpacksswb` packs
  to bytes, `vpermd` undoes the 128-bit-lane interleave of the packs, `vpabsb` gives 0/1/2.
- Bit-exact against the scalar loop (`test_threshold_kernel`: values at both thresholds, at the
  int16 saturation point, the full NMS range, thresholds the int16 path cannot hold, tails, offsets).

### Peak

| bound | work per 64 px | cycles/pixel |
| --- | --- | ---: |
| port 5 | 4 `vpackssdw` + 2 `vpacksswb` + 2 `vpermd` = 8 | **0.125** (peak) |
| issue | 31 fused uops / 4 | 0.121 |
| loads | 8 / 2 | 0.0625 |
| store | 2 | 0.031 |

Peak: **0.125 cycles/pixel = 8 pixels/cycle** (port 5, with issue nearly full).

### Results (driver: one row in L1, widths 256–6144)

| core | cycles/pixel | % of 0.125 | GHz |
| --- | ---: | ---: | ---: |
| 10 | 0.146–0.153 | 82–86% | 2.6–3.2 |
| 5  | 0.147–0.153 | 82–85% | 2.5 |

0.50 instructions/pixel. Cycles/pixel does not move with the clock, as expected with data in L1.

## Stage 5: hysteresis (`src/hysteresis_kernel.cpp`, `make hysteresis`)

Input: the labels. Output: uint8 edges, 255 for strong pixels and for weak pixels joined to a
strong one through 8-connected weak pixels; the same as `hysteresis()` in `hysteresis.hpp`.

### Design

The scalar code pushes every strong pixel onto a queue and walks it. That walk is a
data-dependent loop, not something a vector unit can do. So the kernel splits the work:

- **Vector pass (the hot loop).** Per 32 pixels of a row: `h = L[x−1] | L[x] | L[x+1]`, then
  `OR = h(y−1) | h(y) | h(y+1)`, the OR of the 3×3 neighborhood (one `vpternlogd` each). Labels are
  0, 1, 2, so `(2·center) & OR` is nonzero exactly where the center is weak and a neighbor is
  strong: a **seed**. `edges = (center == 2) ? 255 : 0`. A block of 4 rows reuses each row's h
  three times: 6 rows loaded (3 vectors each) for 4 rows out. The seed test is accumulated over
  the block and branched on once; blocks with a seed are listed and finished in scalar code.
- **Queue pass.** Grow from the seeds only, through weak pixels, like the scalar loop. Strong
  pixels never enter the queue.
- Rows 0 and h−1, column 0 and the last columns use the scalar rule. Bit-exact against
  `hysteresis()` (`test_hysteresis_kernel`: 3180 images of every small shape, serpentine chains
  across blocks and borders, dense / sparse / noise labels, and the hot loop's seed hits directly).

### Peak (vector pass)

| bound | work per 128 px (4 rows × 32) | cycles/pixel |
| --- | --- | ---: |
| loads incl. splits | 18 loads + 3 indexed store addresses + 6 split loads, / 2 | **0.1055** (peak) |
| issue | 49 fused uops / 4 | 0.0957 |
| loads, no splits | 21 / 2 | 0.082 |
| ports 0/1/5 | 24 uops / 3 | 0.0625 |
| store | 4 | 0.031 |

The x−1 and x+1 loads are unaligned; with x on a 32-byte boundary one of the two crosses a 64-byte
line on every loaded row (6 per block). Counting each split as a second load-port use, the load
ports are the limit: **0.1055 cycles/pixel = 9.5 pixels/cycle**. Without the splits, issue
(0.0957) would be.

### Results (driver: 4 rows of a 6-row block in L1, widths 320–3008; no seeds in the data)

| core | cycles/pixel | % of 0.1055 | % of issue bound | GHz |
| --- | ---: | ---: | ---: | ---: |
| 10 | 0.118–0.123 | 86–90% | 78–81% | 2.5–3.2 |
| 5  | 0.118–0.122 | 86–90% | 78–81% | 2.5–2.9 |

0.35 instructions/pixel.

The vector-pass number is the kernel. The queue pass depends on the image: it costs about
one scalar neighborhood walk per weak pixel that gets kept, which is why the noise image below
barely improves.

## Whole images (`make threshold-whole`, `make hysteresis-whole`)

Core 10, median of 21 calls on the same buffers, against the scalar code built the same way as
`canny_part2` (`-O3 -fno-tree-vectorize`).

Double threshold, NMS-like values (80% zero; of the rest, most below low, 3% weak, 2% strong):

| size | kernel ms (cycles/px) | scalar ms (cycles/px) | speedup |
| --- | ---: | ---: | ---: |
| 1920×1080 | 0.48 (0.73) | 2.38 (3.55) | 4.9× |
| 3840×2160 | 3.09 (1.19) | 9.60 (3.70) | 3.1× |

Hysteresis, labels from the integer pipeline (blur, `sobel_kernel`, `nms_kernel`,
`threshold_kernel`, low 50 / high 100) on the benchmark dataset:

| image | strong px | queue (kernel) | kernel ms (cycles/px) | scalar ms (cycles/px) | speedup |
| --- | ---: | ---: | ---: | ---: | ---: |
| resolution 1920×1080 | 14,653 | 450 | 0.35 (0.42) | 1.97 (2.38) | 5.7× |
| resolution 3840×2160 | 29,680 | 795 | 1.28 (0.49) | 6.12 (2.34) | 4.7× |
| sparse 3840×2160 | 5,880 | 0 | 1.27 (0.49) | 4.95 (1.91) | 3.9× |
| chains 3840×2160 | 1,359,967 | 11,990 | 1.89 (0.73) | 40.4 (15.4) | 21.1× |
| noise 3840×2160 | 1,472,106 | 1,216,004 | 122 (46.6) | 138 (52.6) | 1.13× |

A whole image does not fit in L1, so both kernels are memory bound there: threshold is 5–8× and
the hysteresis vector pass 3.5–4× slower per pixel than in L1. Threshold moves 4 bytes in and 1
out per pixel (6 with the write-allocate of the output line); at 4K, 3.09 ms is about 16 GB/s from
one core, close to the ~18 GB/s a single-core copy loop measured on this machine. Hysteresis
stays at 0.4–0.5 cycles/pixel while the queue is small; on the noise image 1.2 M of the 8.3 M
pixels go through the scalar queue pass and that pass is the whole cost.

## Benchmark pitfalls

- 4K aliasing: the threshold driver puts the output 2 KB past the input's page offset; the
  hysteresis driver picks the edge-row offset farthest (mod 4096) from every label row.
- The hysteresis hot-loop data has strong and weak pixels but no weak pixel next to a strong one,
  so the seed branch is never taken; the whole-image runs include real seed blocks.
- L1 size: hysteresis needs 6 label rows + 4 edge rows (10 × width bytes), so widths stop at 3008;
  threshold needs 5 bytes/pixel, so widths stop at 6144.
