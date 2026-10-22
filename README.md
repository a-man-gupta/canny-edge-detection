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

## Part 2: the AVX2 Sobel kernel

Measured on the Xeon Silver 4208 (Cascade Lake, 2 FP units on ports 0 and 1, AVX2, 2.1 GHz base).

- `src/sobel_kernel.cpp` — the kernel: 4 groups of 8 pixels (32 pixels) per loop. It does not call `atan2`: the direction is one of the four Part 3 bins, picked with the same sector test OpenCV uses. Border pixels use scalar code with the same clamped border as `canny_scalar.cpp`.
- `src/sobel_driver.cpp` — the benchmark, written like the assignment's kernel_driver.c: the kernel on 3 rows with all data in L1, 5 runs, each printing GHz, cycles/pixel, % of peak, pixels/cycle, FLOP/cycle and a correctness flag against the naive loop.
- `src/canny_part2.cpp` — the full pipeline with the kernel; same output and JSON as `canny_scalar`.
- `scripts/count_sobel_ops.sh` — counts the instructions in one loop iteration from the compiler's assembly, which is where the peak comes from.

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
ctest --test-dir build                 # magnitude bit-exact vs the scalar formula
./scripts/count_sobel_ops.sh           # instructions per loop -> peak cycles/pixel
taskset -c 10 ./build/sobel_driver     # pick a core whose hyperthread sibling is idle
```

How the peak is computed (the course's method: units × 1 instruction per cycle): the 2 FP units run add, sub, mul, compare and issue sqrt, so peak cycles/pixel = FP-unit instructions per pixel ÷ 2. The kernel has 80 per 32 pixels → 1.25 cycles/pixel. Machine peak is 2 units × 8 floats × 2 (FMA) = 32 FLOP/cycle; this kernel uses no FMAs, so it can't come close to that. If `count_sobel_ops.sh` prints different counts, update the `#define`s at the top of `sobel_driver.cpp`.

`rdtsc` ticks at 2.1 GHz, not at the core clock. The driver measures the real clock with a chain of dependent `vaddps` (4 cycles each) instead of assuming a turbo frequency, and prints it at the start and the end.

Results on ece024 (kernel alone, data in L1, quiet core, clock ~2.48 GHz): 1.66 cycles/pixel median = 75% of the 1.25 peak, 0.60 pixels/cycle (~1.49 Gpixels/s), 10.9 FLOP/cycle (34% of 32). The scalar loop is ~96 cycles/pixel. The buffers must not line up inside a 4 KB page (4K aliasing): with input and output rows 64 bytes apart the same kernel measured 2.15.
