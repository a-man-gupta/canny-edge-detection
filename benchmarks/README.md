# CPU Canny benchmark

Measures three CPU implementations on the same images:

- `scalar` — `build/canny_scalar`, the five-stage C++ pipeline
- `opencv-1` — OpenCV Gaussian blur plus Canny, one thread, OpenCL off
- `opencv-multi` — the same OpenCV calls with the requested thread count

Default is all three. Pass `--implementations` to run a subset. `--adapters file.json` can add another program that accepts the same flags as `canny_scalar` and prints the same JSON timings.

## Run

From the repository root, after `./scripts/setup_remote.sh`:

```bash
./scripts/run_remote.sh --smoke -- --warmup 2 --iterations 3
./scripts/run_remote.sh --photo /absolute/path/to/street.jpg
./scripts/run_remote.sh --photo /absolute/path/to/street.jpg -- \
  --implementations opencv-1 opencv-multi --threads 8
```

`--smoke` only shrinks the images. `--` forwards the rest to `benchmarks/run.py`. A full scalar 8K sweep is slow; each executable has a 7200-second timeout. The full image set is about 130 MB of PGM files, and an 8K case can need several GB of RAM. Failures are recorded in `status.json` and are not turned into timings.

Results go to `benchmark_results/<UTC>-<pid>/`. Open `run/plots/index.html`. `OUT=/some/new/path` picks the directory. `PYTHON=/path/to/venv/bin/python` picks the interpreter. Each run refuses to reuse an existing output directory.

`./collect_hw_info.sh hardware_report.txt` records CPU, cache, memory, and the Python OpenCV build. Cache sizes are topology, not a measured performance limit.

## Sobel and NMS

Part 2 and Part 3 use `./scripts/run_stages.sh`. The view for that command is two line plots and one table under `benchmark_results/run-00N/comparison/`. Details are in [stages/README.md](stages/README.md).

For a single-core scalar run, prefix the wrapper with `taskset -c 2`. The same pin also limits `opencv-multi`. Stop other heavy jobs if you are comparing times.

## Dataset and what the scalar code does

Resolution cases: 640x480, 1280x720, 1920x1080, 3840x2160, 7680x4320, from the photo you pass or from a labeled procedural image. Density cases at 4K: sparse shapes, the medium image, seeded noise, and a serpentine ramp. A blank 96x64 sanity image is always included.

Inputs are grayscale uint8 PGM, seed 18645. The manifest stores dimensions and a hash of each file. A hash mismatch stops the run. Photo resize uses `INTER_AREA` and is not part of the timed loop.

Shared settings: Gaussian 5x5, sigma 1.4, low/high 50/100. The scalar program reflects blur samples, quantizes the blur to uint8, uses a 3x3 Sobel with L2 magnitude, suppresses non-maxima in four directions (`>` the first neighbor and `>=` the second), leaves the outer pixel ring at zero, and thresholds with a strict `>`. Hysteresis is 8-connected and keeps a weak chain of any length. Sobel samples clamp at the border. Buffers are allocated before timing. GCC/Clang builds disable loop and SLP vectorization. The scalar computation does not call OpenCV and does not start threads.

Scalar output is not bit-identical to OpenCV. Blur rounding, OpenCV's integer gradient, tie-breaking, and borders can change pixels. `accuracy.csv` reports agreement, F1, precision, and recall against both the scalar map (when scalar ran) and the one-thread OpenCV map. Background pixels dominate agreement, so read F1 as well. `--min-f1 0.99` fails the run when a scalar comparison is below that value.

## How to read the numbers

- Each implementation is warmed up, then timed for `--iterations` (default 100). Loading the image, writing the edge map, and the accuracy check are outside the samples.
- For scalar and for the OpenCV CPU baselines, `compute_ms` and `e2e_ms` are the same: blur through the edge map, with no copy to another device. Python timing includes the call overhead. Scalar splits that interval into `blur_ms`, `sobel_ms`, `nms_ms`, `threshold_ms`, and `hysteresis_ms`. OpenCV reports `blur_ms` and one `canny_ms` for the rest.
- `raw.csv` is every sample. `summary.csv` is the median and the linear-interpolated p95, plus megapixels per second (`pixels / median_ms / 1000`).
- Stage charts use the mean of each stage, so the pieces add. Latency charts use the median, with the whisker at p95. The sum of stage medians need not equal the median of the total.
- `status.json` is ok, skipped, or failed per case. A failed executable still lets the other cases finish. The process exits nonzero if anything failed or if every case was skipped.

## Checks

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
ctest --test-dir build --output-on-failure
.venv/bin/python -m unittest discover -s benchmarks -p 'test_*.py' -v
bash -n collect_hw_info.sh scripts/*.sh
```

Smoke runs check that the tools work. They are not a full-resolution timing result.
