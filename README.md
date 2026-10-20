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

`setup_remote.sh` selects Python 3.10–3.14, because the default `python3` on this machine is too old for the pinned NumPy. `cpu_spec.txt` is a saved `lscpu` of the measurement machine. `./collect_hw_info.sh` writes a fresh CPU report. No script installs system packages.
