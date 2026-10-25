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

## Part 2: the Sobel kernel (integer)

Measured on the Xeon Silver 4208 (Cascade Lake, 2.1 GHz base; Sobel uses AVX2 only) on ece017–ece024.

The kernel computes the same numbers as OpenCV's Canny with `apertureSize=3` and `L2gradient=True`, in integers like OpenCV:

| | Type | What |
|---|---|---|
| input | `uint8` | the blurred image (what `cv2.GaussianBlur` gives for a uint8 image) |
| `mag_sq` | `int32` | gx² + gy², with no square root. OpenCV squares the two thresholds instead, so the double-threshold stage compares against `low*low` and `high*high`. |
| `bin` | `uint8` | direction bin 0, 45, 90 or 135, from OpenCV's integer test (`TG22 = 13573`, tan 22.5° × 2¹⁵) |

- `src/sobel_kernel.cpp`:
  - `sobel_i16_row` is the intrinsics-only vector loop: two groups of 16 pixels per iteration, with 15 YMM registers and no hot-loop spills in the checked GCC 8.5 build.
  - `sobel_kernel` is the whole image, with scalar code for the borders (the edge pixel is repeated, as in OpenCV).
  - `sobel_bin` is the scalar direction bin.
- `src/sobel_driver.cpp`: the benchmark, written like the assignment's kernel_driver.c. It runs the kernel on 3 int16 rows with all data in L1, for row widths 130..1026. For each width it prints cycles/pixel, useful integer ops/cycle (19/pixel convention), an estimated clock and a correctness flag against the naive loop. Cycles come from the core's own counter (`perf_event_open`, user mode), so turbo and clock changes don't distort them.
- `src/test_sobel_kernel.cpp` (`ctest`): checks every pixel of many images of every shape against the scalar OpenCV formulas, and checks every direction bin for all integer gradients.
- `src/canny_part2.cpp`: the full pipeline with the kernel. It uses a uint8 blur, int32 squared magnitude, uint8 bins and squared thresholds.

```bash
make CORE=10                           # build and run the driver on core 10
make count                             # audit compiled loop: ISA, spills, registers and resource bounds
make assemble                          # kernel assembly in sobel_kernel.S

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
ctest --test-dir build
taskset -c 10 ./build/sobel_driver     # pick a core whose hyperthread sibling is idle
```

**Current implementation (2026-10-24).** `src/sobel_kernel.cpp` uses C++ AVX2 intrinsics, with no inline assembly. The whole-image API still takes and returns byte images/bins; it widens input and narrows bins outside the optimized row loop. The benchmark times the int16 row kernel directly and excludes these conversions. The integer NMS implementation is described below.

**Compiled loop.** GCC 8.5, with the Makefile/CMake flags (including `-fno-tree-forwprop` for Sobel), generates 92 instructions per 32 pixels, 15 YMM registers, no vector-register copies, no stack accesses or calls, and one loop backedge. Guards, pipeline fill/drain and scalar tails are outside that loop. `make count` audits the actual object. Other compiler versions require a fresh assembly check.

**Resource bound.** 74 vector execution uops across ports 0/1/5 give 74/(3*32) = 0.770833 cycles/pixel. Retirement needs 95/(4*32) = 0.742188 cycles/pixel. The arithmetic bound is stronger; it is not proof of an achievable CPU speed or a single saturated port. The 19 useful-ops/pixel convention gives 24.65 ops/cycle at that bound.

**Measurement.** The selected intrinsics version measured median 1.055764 cycles/pixel over six accepted 1024-pixel samples on ECE024 core 3, sibling activity <=1%, with hardware core-cycle counters and no counter multiplexing. This is a row-only measurement, not a whole-image speedup. The earlier 1.029063 result belongs to the hand-assembly experiment, not this source. Evidence and rejected samples: `experiments/integer_avx2_spillfree/integration/intrinsics-final-timing.json`.

## Part 3: integer NMS (AVX2 only)

`src/nms_kernel.cpp` now uses exact int32 squared magnitudes and the same canonical direction bins as integer Sobel. The whole-image API accepts uint8 bins; it widens bins outside the vector loop and handles borders and arbitrary-width tails. The timed row API takes int16 bins directly. C++ intrinsics implement the kernel; no handwritten assembly or AVX-512 mask registers are used.

```bash
make nms_driver.x
make nms-count
taskset -c 10 ./nms_driver.x          # choose a quiet core and check its SMT sibling
./nms_driver.x test
# Optional: output pixels, repetitions, samples
taskset -c 10 ./nms_driver.x 1024 120000 5
```

The hot loop has 16 independent groups x 8 lanes = **128 output pixels per iteration**, using 11 vector registers with no hot-loop spills or calls and one loop backedge. `make nms-count` inspects the actual executable and rejects unexpected instruction forms. With GCC 8.5, the loop has 407 instructions, 470 issue/retirement slots, 352 arithmetic/shuffle execution micro-ops, 160 loads and 16 stores. The resource bound is max(470/4, 352/3, 160/2)/128 = **0.91796875 cycles/pixel**; it is not a proven achievable speed.

The driver prints its types and ISA. `pixels` counts one output row; `width` is the allocated stride, including 32 padding pixels. Timing contains repeated execution of the row loop, with setup, warmup, conversion and reference checking excluded. Outer repetition control is amortized; there are no per-row function calls in the timed loop. Hardware core cycles are mandatory, multiplexed samples fail, and GHz is explicitly a nominal estimate from core/reference cycles. The former 0.75 cycles/pixel result came from the different float/AVX-512VL kernel and is not the AVX2 baseline.

The integrated executable passed the default width sweep on ECE024 core 7, with sibling 23 activity 0.00%. It measured about 1.23 core cycles/pixel in that run; see `experiments/nms_avx2_schedule/integration/default-driver.log` for all rows. The original controlled experiment measured 1.215 cycles/pixel at width 1024. These are separate runs, not guaranteed fixed timings. Larger 32- and 64-group experiments remained spill-free but improved the same-run median by less than 1%; the smaller 16-group schedule is retained. None reached the ideal bound.

The project tests pass (3/3). NMS validates 8,540 full images and 192 direct row ranges, including small dimensions, all direction bins, strict/non-strict ties, magnitudes above 16-bit range, borders, tails, offsets and zero work. Valgrind reports zero errors and no leaks. Detailed calculations and original experiments are in `experiments/nms_avx2_schedule/REPORT.txt`; current integration status is in `experiments/nms_avx2_schedule/integration/RESULTS.txt`.
