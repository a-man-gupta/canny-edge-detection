# Stage 2 (Sobel) and stage 3 (NMS)

Machines: ece017–ece024, all Xeon Silver 4208 (Cascade Lake): L1d 32 KB, L2 1 MB/core,
L3 11 MB/socket. gcc 8.5, `-O3 -mavx2 -mfma -ffp-contract=off -mno-avx256-split-unaligned-*`,
plus `-mavx512f -mavx512vl -mavx512dq` on the two kernel files. One thread, pinned with `taskset`.

Both kernels use 256-bit registers only (8 floats). AVX-512VL is used for its mask registers and
its 32 ymm registers, not for 512-bit math, so the core stays at the AVX2 clock (3.0–3.2 GHz when
quiet). The drivers read real core cycles from the CPU's cycle counter (`perf_event_open`), not
rdtsc × a fixed clock, and print the GHz of each run.

Core facts used for the peaks: 2 FP ports (0 and 1), compare-into-mask on port 5 only, 2 load
ports, 4 uops issued per cycle, `vsqrtps` 6 cycles per 8 floats.

## Stage 2: Sobel (`src/sobel_kernel.cpp`, `make` / `make count`)

64 pixels per iteration, software pipelined (gradients of the next block while the current one
finishes), 0 spills.

| bound | work per 64 px | cycles/pixel |
| --- | --- | ---: |
| FP ports 0+1 | 112 FP instructions / 2 | **0.875** (peak) |
| issue | ~256 uops / 4 | ~1.0 |
| sqrt | 8 × 6 cycles | 0.75 |

Measured, data in L1, width 1026, all 8 machines: **1.27–1.31 cycles/pixel**, 69% of the 0.875
peak, about 79% of the issue bound. 18 FLOP/pixel, so ~14 FLOP/cycle.

## Stage 3: NMS (`src/nms_kernel.cpp`, `make nms` / `make nms-count`)

### Design

- Per 8 pixels: 3 compares of the angle into masks; the neighbors a and b are picked with masked
  moves (start from the 135° pair, then lanes with d < 112.5, < 67.5, < 22.5 are overwritten,
  same as the first matching `if`); keep = (m > a) and (m >= b) as a mask compare plus a masked
  compare; store m with the other lanes zeroed.
- 4 rows at a time. Pixel (y, c) needs mag rows y−1, y, y+1 at columns c−1, c, c+1. Walking down
  4 rows, two of those three rows are already in registers, so only the 3 vectors of the new row
  below are loaded: 22 loads per 32 pixels (5.5 per 8) instead of 40.
- Rows left over after the blocks of 4 use the same code with 1 row; rows shorter than 8 interior
  pixels and the last columns use the scalar rule. Borders stay 0. Bit-exact against the scalar
  code (`test_nms_kernel`, 1325 images).

### Peak

No FP arithmetic (compares are not FLOPs), so the peak is the busiest port, per 8 pixels:

| bound | work per 8 px | cycles/pixel |
| --- | --- | ---: |
| port 5 | 5 compares into a mask | **0.625** |
| issue | ~20 uops / 4 | ~0.625 |
| ports 0/1/5 | 5 + 6 masked moves + 1 = 12 / 3 | 0.50 |
| loads | 5.5 / 2 (plus ~40% cache-line splits) | 0.34 (~0.5) |

Peak: **0.625 cycles/pixel** (port 5 and issue are both full).

### Results (driver: 4 rows of a 6-row image, data in L1)

| version | cycles/pixel | % of 0.625 | GHz |
| --- | ---: | ---: | ---: |
| original: `vblendvps` chain, 1 row | 1.52 | 41% | 2.9 |
| masked loads, 1 row | 0.99 | 63% | 3.2 |
| masked moves, 4 rows (current) | **0.74–0.78** | **80–84%** | 2.5–3.2 |

ece018, ece019, ece022 (quiet); every run correct = 1. On a busy machine (ece024, load 5)
it was 1.25–1.35, which is the hyperthread sibling, not the kernel.

What limited each version:

- Original: `vblendvps` is 2 uops (3 when it reads memory), 4.0 uops/pixel: issue bound.
- Masked loads, 1 row: 10 loads per 8 px, and about half of the unaligned loads at c−1 / c+1 cross
  a 64-byte line and use the load port twice. That is 0.85–0.91 cycles/pixel of load-port time,
  and it ran at 0.99.
- 4 rows: loads drop to 5.5 per 8 px, so port 5 and issue are the limit (0.625).

Tried and not kept: wider column unrolling (same speed), software pipelining (same), ymm compares
for the keep test to free port 5 (more uops: 0.88), 6 rows at a time (spills).

### Benchmark pitfalls

- 4K aliasing: a load that matches a recent store in the low 12 address bits waits. With the
  output rows at the same page offsets as the input rows, NMS measured 1.07 instead of 0.75.
  The driver picks an output offset away from every input row.
- L1 size: 4 rows need 6 mag + 4 angle + 4 output rows; above ~580 pixels wide that is more than
  32 KB, so the driver's widths stop at 578.

### Whole images

A whole image does not fit in cache, so NMS is memory bound: 1.7 cycles/pixel at 514×386 and 1.9
at 1026×1026, the same for 1 row and 4 rows at a time. If `malloc` puts mag, angle and output at
the same page offset (large blocks usually are), 4K aliasing adds 10–40% there too.
