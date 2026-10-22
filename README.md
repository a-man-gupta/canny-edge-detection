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

- `src/sobel_kernel.cpp` — the kernel. `sobel_kernel` (v1) is the first version: 16 pixels per loop. `sobel_kernel_v2` gives the same results with fewer instructions per pixel and 4 groups of 8 pixels per loop (32 pixels). Neither calls `atan2`: the direction is one of the four Part 3 bins, picked with the same sector test OpenCV uses.
- `src/sobel_driver.cpp` — the benchmark, in the style of the assignment drivers. It times the scalar baseline (the `canny_scalar.cpp` loop), v1, and v2 with 1, 2, 4, 8 groups, and prints cycles per pixel, the peak, % of peak, FLOP/cycle and % of the machine peak, plus a correctness check against the baseline.
- `src/canny_part2.cpp` — the full pipeline with the kernel (`--kernel v1|v2`); same output and JSON as `canny_scalar`.
- `scripts/count_sobel_ops.sh` — counts the instructions in one loop iteration from the compiler's assembly, which is where the peak comes from.

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
ctest --test-dir build                 # v1 matches the scalar formula, v2 matches v1 bit for bit
./scripts/count_sobel_ops.sh           # instructions per loop -> peak cycles/pixel
taskset -c 0 ./build/sobel_driver      # the results table
```

How the peak is computed (the course's method: units × 1 instruction per cycle): the 2 FP units run add, sub, mul, compare and issue sqrt, so peak cycles/pixel = FP-unit instructions per pixel ÷ 2. With clang -O3 -mavx2: v1 = 46 per 16 pixels → 1.44 cycles/pixel; v2 = 20 per 8 pixels → 1.25 cycles/pixel. Machine peak is 2 units × 8 floats × 2 (FMA) = 32 FLOP/cycle; this kernel has few FMAs (none in the default no-FMA build), so it can't come close to that. If `count_sobel_ops.sh` prints different counts on the Xeon, update the `#define`s at the top of `sobel_driver.cpp`.

`rdtsc` ticks at 2.1 GHz, not at the core clock. The driver measures the real clock with a chain of dependent `vaddps` (4 cycles each) instead of assuming a turbo frequency, and prints it at the start and the end.
