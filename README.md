# Canny edge detection: Sobel and NMS kernels

18-645 (How to Write Fast Code), Team 11. This branch holds the two AVX2 kernels for stages 2 and 3
of Canny, written for the Xeon Silver 4208 (Cascade Lake) on the ECE machines:

- **Sobel** (`src/kernel_sobel.cpp`): 3x3 gradients `Gx`, `Gy` and the L1 magnitude `M = |Gx| + |Gy|`,
  all int16 and exact. One loop iteration produces 6 rows x 32 columns.
- **NMS** (`src/kernel_nms.cpp`): non-maximum suppression on Sobel's int16 planes. It keeps a pixel if
  `c > max(first, second - 1)` along its gradient direction, chosen with masks, not branches.
  One loop iteration produces 2 rows x 64 columns.

The threshold and hysteresis stages are on the `stage_4_5` branch.

## Files

| File | What it is |
| --- | --- |
| `src/kernel_sobel.cpp`, `.hpp` | Sobel kernel and its buffer layout (fixed strides 448 / 416) |
| `src/kernel_nms.cpp`, `.hpp` | NMS kernel |
| `src/driver_sobel.cpp` | Checks Sobel against a scalar reference, then times it |
| `src/driver_nms.cpp` | Checks NMS against a scalar reference, then times it |
| `src/benchmark.hpp` | Shared timing code: reads real core cycles with `perf_event_open` |
| `Makefile` | Builds and runs everything (below) |

## Using the Makefile

Run on an ECE machine. Pick a quiet core, and check that its hyperthread sibling is idle too
(`cat /sys/devices/system/cpu/cpu10/topology/thread_siblings_list`, then look at `top`).

```bash
make              # build both drivers, then run Sobel and NMS (same as make run)
make sobel        # Sobel only
make nms          # NMS only
make check        # correctness checks only, no timing
make assemble     # disassembly in build/kernel_sobel.S and build/kernel_nms.S
make clean        # delete build/
```

Each target builds what it needs first, so there is no separate build step. Outputs go to `build/`.

Settings can be changed on the command line:

| Variable | Default | Meaning |
| --- | --- | --- |
| `CORE` | 10 | core the run is pinned to (`taskset -c`) |
| `SOBEL_SIZE` | 256 | Sobel width: a multiple of 32, at most 384 |
| `NMS_SIZE` | 768 | NMS width: a multiple of 64 |
| `RUNS` | 100000 | kernel calls per timed trial |
| `TRIALS` | 9 | timed trials; the median is reported |

```bash
make sobel SOBEL_SIZE=384 CORE=4
make nms NMS_SIZE=1536 TRIALS=21
```

**How it builds.** The kernels and the drivers are compiled separately, with different flags:

- Kernels: `-O3 -mavx2 -mno-avx512f` with auto-vectorization off, so the AVX2 intrinsics are exactly
  what runs (256-bit only).
- Sobel also gets `-fno-tree-forwprop -fschedule-insns -fsched-pressure`. Without them GCC reorders
  the adds and spills registers, and Sobel drops from about 80% to about 70% of peak.
- Drivers: `-O3` with auto-vectorization off, so the scalar reference stays scalar.

## What the output means

```
Correctness: PASS (exact Gx, Gy, |Gx|+|Gy|; zero, 255, stripes, 96 random fills)
Sobel L1, tile 6 rows x 32 columns, width 256
  ports 0,1,5: (114 add/sub + 24 abs) / 3 = 46.00 cycles per loop
  peak     = 138 instructions x 16 lanes / 46.00 = 48.00 ops/cycle
  measured = 38.35 ops/cycle (median of 9), 79.9% of peak, 0.300 cycles/pixel
```

- **Correctness**: the kernel's output matches the scalar reference exactly on every test input.
  The program stops with `FAIL` and the row and column if it does not.
- **peak**: the theoretical peak. It counts the loop's instructions, puts them on the ALU ports
  (0, 1, 5) that can run them, and takes the busiest port group. Sobel's peak is 48 int16 ops/cycle,
  NMS's is 42.2 (each blend takes two port slots).
- **measured**: int16 operations per real core cycle, the median over the trials, with data in L1.

Typical results on ece024: Sobel about 80% of peak (38.5 ops/cycle), NMS about 84% (35.3 ops/cycle).
