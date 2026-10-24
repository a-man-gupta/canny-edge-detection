# Canny edge detection

18-645 (How to Write Fast Code) project. This tree is the CPU Canny edge detector: a scalar C++ pipeline and OpenCV CPU baselines used to measure it.

The scalar program in `src/canny_scalar.cpp` reads a grayscale PGM and runs the five Canny stages:

1. Gaussian blur, to smooth noise.
2. Sobel gradients, for magnitude and direction.
3. Non-maximum suppression, to thin the gradient to a local ridge.
4. Double threshold, into strong, weak, and rejected pixels.
5. Hysteresis, in `src/hysteresis.hpp`, to keep weak pixels that connect to a strong edge.

It then writes a binary edge map and prints per-stage times. Defaults are a 5x5 Gaussian with sigma 1.4 and thresholds 50 and 100. File reads and writes sit outside the timed loop.

OpenCV comparisons live in `benchmarks/run.py`: `opencv-1` (one thread) and `opencv-multi`. Both call `cv2.ocl.setUseOpenCL(False)` so the library stays on the CPU. How to generate images and read the plots is in [benchmarks/README.md](benchmarks/README.md).

```bash
./scripts/setup_remote.sh
./scripts/run_remote.sh --smoke -- --iterations 3 --warmup 2
./scripts/run_remote.sh --photo /path/to/natural-image.jpg
```

`setup_remote.sh` selects Python 3.10–3.14, because the default `python3` on this machine is too old for the pinned NumPy. `./collect_hw_info.sh` writes a CPU report. No script installs system packages.

## Part 2: the Sobel kernel

Measured on the Xeon Silver 4208 (Cascade Lake: 2 FP units on ports 0 and 1, AVX2 + AVX-512, 2.1 GHz base) on ece017–ece024.

- `src/sobel_kernel.cpp` — `sobel_row`, the vector loop for one image row, and `sobel_classify_angle`, the scalar direction bin. 8 pixels per ymm register. The loop is software-pipelined: it computes the gradients of the next 32 pixels while it finishes the current 32, and the direction bins use AVX-512VL mask registers. It does not call `atan2`: the direction is one of the four Part 3 bins, picked with the same sector test OpenCV uses, bit-exact with the scalar bin.
- `src/sobel_image.cpp` — `sobel_kernel`, the whole image: `sobel_row` on the interior of each row, scalar code for the border pixels with the same clamped border as `canny_scalar.cpp`.
- `src/sobel_driver.cpp` — the benchmark, written like the assignment's kernel_driver.c: the kernel on 3 rows with all data in L1, for row widths 130..1026. For each width it prints FLOP/cycle, a correctness flag against the naive loop, cycles/pixel and the clock of the run.
- `src/canny_part2.cpp` — the full pipeline with the kernel; same output and JSON as `canny_scalar`.
- `scripts/count_sobel_ops.sh` (or `make count`) — counts the instructions in one loop iteration from the compiler's assembly, which is where the peak comes from.

```bash
make CORE=10                           # build and run the driver on core 10
make count                             # instructions per loop -> peak cycles/pixel
make assemble                          # kernel assembly in sobel_kernel.S

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
ctest --test-dir build                 # magnitude bit-exact vs the scalar formula
taskset -c 10 ./build/sobel_driver     # pick a core whose hyperthread sibling is idle
```

How the peak is computed (the course's method: units × 1 instruction per cycle): the 2 FP units run add, sub, mul, FMA and issue sqrt, so peak cycles/pixel = FP-unit instructions per pixel ÷ 2. The loop has 112 per 64 pixels → **0.875 cycles/pixel**, 18 FLOP/pixel → 20.6 FLOP/cycle. Other floors: sqrt 0.75 cycles/pixel (6 cycles per 8 floats), and issue 1.0 cycles/pixel (4.0 uops per pixel, 4 per cycle), which is the real ceiling for this loop. Machine peak is 2 units × 8 floats × 2 (FMA) = 32 FLOP/cycle.

The clock is not fixed: it moved between 2.0 and 3.0 GHz with turbo and load on the other cores. `rdtsc` ticks at 2.1 GHz whatever the core does, so the driver reads the core's own cycle counter (`perf_event_open`, user mode) around the timed loop, and prints the clock as cycles ÷ (rdtsc ticks ÷ 2.1). If the counter cannot be opened it falls back to `MAX_FREQ`.

Results (1026-wide row, quiet core, all 8 machines): **1.27–1.31 cycles/pixel**, ~14 FLOP/cycle, 69% of the 0.875 peak and ~79% of the issue ceiling. The earlier one-stage AVX2 loop with `vblendvps` ran at 1.51. Short rows are slower (1.96 at width 130), because filling and draining the pipeline costs as much as the loop. The buffers must not line up inside a 4 KB page (4K aliasing): with input and output rows 64 bytes apart an earlier version measured 2.15 instead of 1.7.
