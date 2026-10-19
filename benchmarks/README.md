# Remote Canny benchmark kit

The kit runs an original scalar C++ baseline, Python OpenCV CPU baselines (one thread and a recorded thread count), and an optional C++ OpenCV CUDA baseline. The team's global/tiled/fused CUDA kernels **do not exist yet**; register them through the executable adapter contract below when implemented. Nothing is labeled as a team GPU result until it actually runs.

## Quick start on a Linux remote machine

Copy/clone this repository on the machine you want to measure. To copy the current uncommitted kit from your laptop:

```bash
./scripts/package_remote.sh /tmp/canny-benchmark-kit.tar.gz
scp /tmp/canny-benchmark-kit.tar.gz USER@HOST:~/
# Then on the remote machine:
mkdir -p ~/canny-edge-detection
cd ~/canny-edge-detection
tar -xzf ~/canny-benchmark-kit.tar.gz
```

Replace USER@HOST with your SSH destination. The archive excludes local binaries, environments and results so the remote compiles its own executable.

Requirements: Bash, CMake >=3.18, a C++17 compiler, Python 3.10–3.14 with venv/pip, and internet access for Python dependencies. CUDA tools additionally require an NVIDIA GPU, a working driver and nvcc. No script installs system packages, changes GPU clocks, or uses sudo.

```bash
# Run inside this repository on the REMOTE machine.
./scripts/setup_remote.sh
./scripts/run_remote.sh --smoke -- --warmup 2 --iterations 3

# Full resolution + density sweep: 10 warmups and 100 recorded runs by default.
# Supply a real photo so the medium cases use natural photography.
./scripts/run_remote.sh --photo /absolute/path/to/street.jpg

# Run CPU/library baselines first if the scalar 8K sweep is too slow.
./scripts/run_remote.sh --photo /absolute/path/to/street.jpg -- \
  --implementations opencv-1 opencv-multi --threads 8
```

`--smoke` only reduces image sizes. Use `-- --warmup 2 --iterations 3` to reduce iterations too. Full scalar 8K runs can take a long time; each executable/case has a configurable 7200-second timeout. The full suite stores about 130 MB of input PGM images, plus one edge map per backend/case. At 8K, scalar buffers, a worst-case connectivity queue, OpenCV buffers and saved references may require several GB of RAM. GPU library workspaces also consume VRAM. Out-of-memory failures are recorded, never turned into timings.

Inspect/download `benchmark_results/<UTC>-<pid>/`. Open `run/plots/index.html` locally; individual PNGs and CSVs are standalone artifacts. `OUT=/some/new/path` chooses the wrapper output. `PYTHON=/path/to/venv/bin/python` chooses an existing Python environment. `VENV=/some/path` changes the setup environment (set PYTHON accordingly when running). Each run rejects an existing output directory.

For CPU affinity on Linux, prefix the wrapper with `taskset -c 2-9`; for scalar measurements alone, `taskset -c 2`. A process pinned to one core will constrain the multithreaded baseline too. Record the same settings for comparisons. Stop unrelated workloads; collect multiple independent sessions to inspect variability. The scripts run implementations in a fixed order; repeated sessions/reordered `--implementations` help identify thermal/order bias.

## GPU setup and hardware discovery

```bash
# Discovery only; missing commands are reported, not fatal.
./collect_hw_info.sh hardware_report.txt

# CUDA bandwidth microbenchmark, separate from Canny.
# Args: MiB PER ARRAY (3 device arrays), iterations; default 256 and 100.
CUDA_VISIBLE_DEVICES=0 ./scripts/run_bandwidth.sh 256 100
```

The discovery report includes CPU caches (including sharing), SIMD flags, NUMA, RAM/cgroup constraints, PCIe link telemetry (when readable), GPU clocks/power/temperature/other processes, complete Python OpenCV build information, and a dynamically compiled CUDA limit probe. `nvidia-smi` lists physical GPU state; `CUDA_VISIBLE_DEVICES` controls runtime visibility, so correlate device names and PCI bus IDs. No nvcc means the probe is explicitly unavailable, even if a GPU is present. Unsupported `nvidia-smi` options or unprivileged PCIe reads remain visible as diagnostics. CPU cache capacity is topology data, not a measured performance boundary.

The CUDA probe reports per-block and per-SM shared memory/register limits, opt-in shared memory, warp size, dimensions, SM count, L2 and VRAM. It uses `cudaDeviceGetAttribute(cudaDevAttrMemoryClockRate)` rather than the field removed in CUDA 13 ([NVIDIA release notes](https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html)). Register use per thread comes from compiled kernels (`nvcc --ptxas-options=-v`) and occupancy analysis; it is not a fixed `cudaDeviceProp` value. The DDR-style bandwidth formula is only a nominal estimate: check the clock convention and memory technology against device specifications.

`run_bandwidth.sh` measures large-array triad effective logical device bandwidth and pinned H2D/D2H throughput with CUDA events, plus host wall time. It performs ten warmups, saves all raw samples, reports median/p95, checks the triad output, requires a footprint >4x reported L2, and checks available VRAM. This is a sustained streaming calibration, **not** a hardware-counter DRAM-byte measurement or theoretical peak. Host pinned-memory allocation can fail under OS limits; reduce MiB per array, while preserving a footprint larger than L2. No CPU DRAM bandwidth microbenchmark is included; use a separately documented STREAM run if needed for a CPU roofline.

### Optional OpenCV CUDA reference

PyPI OpenCV wheels supply CPU baselines; they do not supply the CUDA-enabled C++ OpenCV build required here. Obtain/build an OpenCV + opencv_contrib installation with matching versions and `core`, `imgcodecs`, `cudafilters`, `cudaimgproc`, plus CUDA Toolkit development libraries. Confirm its own build information and supported target GPU. Then:

```bash
./scripts/setup_remote.sh -DBUILD_OPENCV_CUDA=ON \
  -DOpenCV_DIR=/absolute/path/to/opencv/lib/cmake/opencv4
CUDA_VISIBLE_DEVICES=0 ./scripts/run_remote.sh --smoke -- \
  --iterations 3 --warmup 2 --implementations scalar opencv-1 opencv-cuda
```

CUDA Canny is configured with `L2gradient=true` ([OpenCV CUDA API](https://docs.opencv.org/4.x/d0/d05/group__cudaimgproc.html)). It includes a separate Gaussian blur. The C++ CUDA library may differ in version/options from the Python CPU library: compare `metadata.json`, `opencv_build.txt`, and `build_provenance/CMakeCache.txt`, and native stderr (the CUDA executable prints its C++ OpenCV build information) when interpreting accuracy. Build failures from missing CUDA modules are not silently downgraded. An unbuilt default GPU executable is skipped; a built executable that fails is an error.

GPU clocks are left under the machine owner's policy. Optional manual clock locking requires supported clocks, permission and explicit reset, and may affect other users. Use `nvidia-smi -q -d SUPPORTED_CLOCKS` and the site's policy; do not assume the maximum observed clock is a valid lock setting. Record any changes and restore the prior policy yourself.

## Dataset and algorithm contract

Resolution sweep: 640x480, 1280x720, 1920x1080, 3840x2160, 7680x4320, using one supplied photo or a clearly labeled procedural medium image. Density/stress sweep: 4K sparse geometry, medium image, seeded noise, and a serpentine contrast ramp intended to stress connectivity. A blank sanity case is always included. The ramp is not guaranteed to be worst-case Canny input. Noise does not guarantee long weak chains after blur/NMS. `accuracy.csv` records observed output edge density; graph topology and thresholds matter independently.

Inputs are grayscale uint8 PGM, fixed seed 18645; no network image downloads. Manifest records dimensions, generation seed, OpenCV version, original photo hash/path and each generated file hash. A hash mismatch is fatal. Resizing excludes I/O and preprocessing from timings. Photo resize uses INTER_AREA at all sizes, including upscaling; benchmark scaling measures resized instances, not independent photographs.

Shared defaults: Gaussian 5x5, sigma 1.4, REFLECT_101 blur borders, quantized uint8 blur, Sobel aperture 3, L2 gradient magnitude, low/high 50/100, 8-connected hysteresis to convergence. CLI allows thresholds/sigma changes and saves them. Scalar uses explicit 25-tap Gaussian, float magnitude/direction, four-direction NMS (`>` first neighbor, `>=` second), rejects the outer NMS ring, strict `>` thresholds, and a queue that preserves arbitrarily long weak chains connected to strong seeds. Sobel samples replicate borders. It allocates buffers/queue before timing and disables compiler loop and SLP vectorization on GCC/Clang; no threads or OpenCV are used by the scalar computation. Other compiler transformations can still apply: inspect generated code for instruction-level analysis.

Scalar is an understandable reference with an explicit contract, **not bit-identical OpenCV Canny**. Blur rounding, integer/tangent NMS in OpenCV, tie-breaking, and borders can change edge maps beyond floating-point roundoff. Accuracy is reported against both scalar (when run) and the fixed single-threaded OpenCV reference, with no silent tolerance or automatic pass threshold. Pixel agreement is dominated by background; use F1, precision, recall and edge density too. Empty-vs-empty F1=1; a prediction with no edges has precision=0 when reference edges exist; reference with no edges has recall=1. `--min-f1 0.99` explicitly enables a scalar-reference quality gate and fails if scalar did not run. Choose a justified tolerance after aligning algorithms; an OpenCV mismatch alone is not evidence of a kernel bug. Exact pixel F1 has no spatial tolerance and is not BSDS boundary quality evaluation.

Course context: standard NMS is used provisionally, following agent.md. Confirm course staff's intended stage 3 and newest rubric before claiming course approval.

## Timing and output interpretation

- Full pipeline is warmed up per implementation/case. Decode, fixture resize, output writing, correctness checks and external process launch are excluded from per-sample timing.
- CPU `compute_ms` and `e2e_ms` cover blur+Canny (or five scalar stages); they are equal because there is no device transfer. Python timing includes API-call overhead. Scalar reports five stages with `steady_clock`; Python OpenCV exposes blur and aggregate Canny. Outer buffers are preallocated; library-internal allocations remain included where performed.
- CUDA `compute_ms`: events surrounding blur+Canny on the same explicit stream. H2D, blur, aggregate Canny, D2H each have CUDA-event timing. These event intervals measure stream elapsed time including possible enqueue gaps/internal synchronization, not a profiler sum of kernel durations. `e2e_ms` is host wall time from before upload enqueue through final event synchronization and includes pinned H2D+D2H. Pinned host buffers and outer device buffers are allocated before warmup. No file I/O, context setup, or pinning is timed.
- `raw.csv` contains every recorded iteration. `summary.csv` gives per-metric median and NumPy linear-interpolated p95, both compute/e2e MP/s, timing method and actual OpenCV thread setting. Throughput is pixels / median milliseconds / 1000. `accuracy.csv` compares final output maps outside timing. There is no hidden synthetic GPU fallback.
- Stage plots use **means**, which add across per-iteration segments; total latency plots use median/p95. Sums of independently computed medians need not equal median total latency. CUDA stage sums exclude host submission/synchronization overhead, so do not expect them to equal host e2e time. H2D plus five stages plus D2H is seven segments; fused/library stages are labeled aggregates, not invented subdivisions.
- `status.json` records ok/skipped/failed for each case/backend; any execution error yields nonzero exit after collecting unaffected cases. A run with only skipped backends also fails. A successful exit with a skipped GPU backend means CPU results only. Partial outputs and native stdout/stderr logs are retained.
- Metadata includes exact invocation, parameters, machine/Python/library versions, git commit/status/tracked diff, dataset manifest, executable hashes and selected environment variables. The wrapper captures hardware before/after and available CMake/compiler/package provenance. The wrapper saves `source.tar.gz` with the actual harness sources, including uncommitted additions; executable adapter sources outside this repository must be archived separately. Hardware reports can contain host names and local paths: review before sharing publicly.

## Register future team implementations

Copy `benchmarks/adapters.example.json`, replace absolute executable paths, and select those names explicitly:

```bash
.venv/bin/python benchmarks/run.py --manifest benchmark_data/manifest.json \
  --output benchmark_results/team-comparison \
  --adapters /absolute/path/to/adapters.json \
  --implementations scalar opencv-1 team-global team-tiled team-fused
```

Each adapter is an argument array executed directly (no shell). First entry must be an existing executable path. All receive:

```text
--input IMAGE.pgm --output EDGES.pgm --iterations 100 --warmup 10 --low 50 --high 100 --sigma 1.4
```

Decode/allocate first; warm up; run the entire pipeline for each iteration; synchronize correctly; emit final 0/255 uint8 PGM with identical dimensions. Return nonzero on allocation, CUDA, convergence or output errors; never cap hysteresis iterations and silently accept partial connectivity. For future hysteresis variants, add converged/iteration counts in a separate stderr or sidecar diagnostic until a structured non-timing metadata extension is defined. Write diagnostics to stderr. Stdout must be one JSON object:

```json
{
  "timing_method": "CUDA events in stream 0; synchronized wall e2e; pinned transfers",
  "samples": [
    {"compute_ms": 1.2, "e2e_ms": 1.8, "h2d_ms": 0.2,
     "blur_ms": 0.3, "fused_ms": 0.5, "hysteresis_ms": 0.4, "d2h_ms": 0.2}
  ]
}
```

The example shows one sample; emit exactly `--iterations` samples with consistent keys, positive totals and finite nonnegative stage times. Allowed plot stages are `h2d_ms`, `blur_ms`, `sobel_ms`, `nms_ms`, `threshold_ms`, `hysteresis_ms`, `canny_ms`, `fused_ms`, `d2h_ms`. Additional `*_ms` timing columns are saved in CSV but not automatically assigned to stacked plot segments. Avoid overlapping stage segments. Time separable horizontal+vertical blur as aggregate `blur_ms`; label fused Sobel+NMS+threshold with `fused_ms`. Kernel total must include the full pipeline, including all hysteresis iterations, convergence checks and required stream work. Context creation, allocation and transfers are excluded from compute; transfers and necessary synchronization are included in host wall e2e. Reuse buffers as the builtins do; record additional setup separately.

## Bandwidth interpretation and plots

A cache size alone does not prove cache residency, VRAM traffic or fusion benefit. Constant-memory broadcast latency, occupancy and whether a stage is memory/compute/launch bound must be measured. Steps 1–4 have fixed asymptotic work per pixel, but measured runtime can vary with branching/cache/data; hysteresis complexity depends on algorithm and topology. Do not write conclusions before measurement.

`traffic_model.example.json` deliberately contains an example only for an unimplemented threshold kernel; it is never auto-applied to library baselines. Write a model from the actual buffer types/accesses, choose a device-specific nominal bandwidth, then:

```bash
.venv/bin/python benchmarks/plot.py benchmark_results/team-comparison \
  --traffic-model /absolute/path/to/verified-traffic-model.json --peak-gbs 448
```

448 is an example placeholder, not this machine's hardware value. The tool saves the supplied model/rationale/peak value and reports `logical_bytes / median_time`, and for `device=gpu` its percentage of nominal peak. CPU rows are never divided by GPU peak. Repeated stencil reads, shared-memory reuse, write allocation, cache hits and compression mean logical traffic differs from physical DRAM traffic; values above 100% can occur. For **measured** DRAM utilization, profile a separate representative run using Nsight Compute's device-supported DRAM-byte/throughput metrics (`ncu --query-metrics`). Profiling can perturb timing; keep profiler evidence separate from normal latency samples. No measured-DRAM percentage is fabricated by these scripts.

Dependency pins select NumPy 2.2.6 for Python 3.10–3.13 and 2.3.5 for Python 3.14. A large-array accuracy preflight rejects incompatible NumPy builds before recording results; this caught an incompatible locally cached Python 3.14/NumPy 2.2.6 build during development.

## Local checks

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
ctest --test-dir build --output-on-failure
.venv/bin/python -m unittest discover -s benchmarks -p 'test_*.py' -v
bash -n collect_hw_info.sh scripts/*.sh
```

Run the smoke comparison on the remote GPU before a full sweep; it validates tooling, not full-resolution correctness or speedup. CUDA sources require a remote build/run before any GPU support or performance claim.
