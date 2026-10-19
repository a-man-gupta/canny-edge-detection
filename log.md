# Canny edge detection project log

This is a decision and evidence log for the team's work, not an automatic transcript of private chats. Append dated entries when decisions change or work is completed. Preserve older entries.

## 2026-10-19 — Initial project context captured from the current chat

### Repository state
- Team repository identified: https://github.com/a-man-gupta/canny-edge-detection
- At inspection, `main` contained only `README.md` and `.gitattributes`; no Canny implementation, benchmark, tests, or build files were present. No code has been built or timed.
- This entry records the conversation's findings. It does not claim the team has implemented or measured a kernel.

### Course requirements found in the supplied overview slides
- 18-645, How to Write Fast Code; team of three; Canny Edge Detection appears on the pre-approved project list.
- The slides recommend a fast OpenCV implementation, allow existing code and helpers as starting points, and focus on computation rather than file I/O.
- Mid-project presentation is marked October 19-21. The nearby phases call for code analysis, kernel design/implementation, comparing performance against expectations, and designing memory movement. Later work includes memory movement, cross-kernel optimization, initial parallelization, and final six-page paper/video.
- The slides do not require OpenCL/GPU and do not specify a separate written mid-project report format. Earlier chat assumed OpenCL; that assumption was corrected after reading the slides.

### Decisions and provisional plan
- Use OpenCV as a correctness baseline and image I/O helper. Implement the team's own computation kernels and optimize them after obtaining a working baseline.
- Mid-project priority: fixed reference settings and images, at least one team-owned implemented kernel, correctness checks, initial timing, analysis of work/memory traffic, and the next memory optimization plan. Full optimized Canny is not stated as a mid-project requirement in the overview.
- Provisional effort-balanced division: Person 1 owns Gaussian plus double threshold and benchmarking; Person 2 owns gradients plus suppression; Person 3 owns hysteresis. Names and interfaces are still to be agreed.
- Agree on image and intermediate data types, border policy, Gaussian parameters, gradient norm, thresholds, and stage interfaces before integration.
- The slide's stage 3 wording differs from standard Canny's non-maximum suppression; confirm with course staff which operation is expected.
- Keep performance results tied to actual hardware, compiler settings, images, timing method, and commit. Distinguish stage time from end-to-end time and exclude file I/O when measuring computation.

### References found
- OpenCV Canny guide: https://docs.opencv.org/4.x/da/d22/tutorial_py_canny.html
- OpenCV Canny implementation: https://github.com/opencv/opencv/blob/4.x/modules/imgproc/src/canny.cpp
- Third-party OpenCL example with benchmark suite: https://github.com/smskelley/canny-opencl ; useful for ideas but old and not a required target.
- Berkeley BSDS500: https://www2.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/resources.html ; potential edge-quality benchmark, separate from runtime timing.
- Course overview: user-provided `18645-Project Overview-slides (2).pdf` (not committed to this repository).

### Open questions / next action
1. Confirm teammates' names and stage ownership.
2. Confirm stage 3 interpretation, target hardware/language, and any newer mid-project rubric with course staff.
3. Add runnable reference, shared stage interface, fixed test images, and a benchmark harness.
4. Implement and measure the first kernel; then update this log with commands and actual results.

## Log entry template
### YYYY-MM-DD — Short title
- Owner:
- Source/commit:
- Decision or change:
- Files:
- Verification and measured result:
- Remaining risk:
- Next action:

## 2026-10-19 — Runnable remote benchmark kit

- Owner: Codex, requested by user; no teammate stage ownership assumed.
- Source: current working tree on main (additions are uncommitted); agent.md and preceding log inspected before implementation. NVIDIA CUDA 13 release notes and official OpenCV CUDA source/API checked for runtime attributes and stream interfaces. No new course materials were supplied.
- Decision: provide runnable measurement infrastructure and baselines now, with explicit executable adapters for future team global/tiled/fused CUDA implementations. Do not fabricate GPU tiers, internal OpenCV stage timings, physical DRAM utilization, cache-residency conclusions, or course approval.
- Files added/changed:
  - `collect_hw_info.sh`, `src/cuda_probe.cu`: best-effort read-only hardware/toolchain/OpenCV discovery, CUDA-version-compatible memory-clock attribute, shared-memory/register/cache/topology limits, PCIe/clock/power state; missing tools produce diagnostics. Uses a normal tee pipeline so reports also work where process substitution is restricted.
  - `CMakeLists.txt`, `src/canny_scalar.cpp`, `src/hysteresis.hpp`, `src/test_hysteresis.cpp`: dependency-free scalar C++17 five-stage reference, reusable buffers, queue hysteresis to convergence, per-stage and pipeline raw timings, explicit algorithm contract, compiler vectorization disabled, connectivity/border/state-reuse tests.
  - `src/canny_opencv_cuda.cpp`: optional CUDA-enabled C++ OpenCV reference with pinned transfers, CUDA events in an explicit stream, synchronized host end-to-end timing, blur and aggregate Canny timing, C++ build provenance in stderr. Implemented but not compiled/run here.
  - `src/cuda_bandwidth.cu`, `scripts/run_bandwidth.sh`: optional large-working-set triad and pinned-transfer calibration, ten warmups, raw iterations, median/p95, output validation and >4x-L2 footprint check. Implemented but not compiled/run here.
  - `benchmarks/generate_dataset.py`, `run.py`, `plot.py`, `test_benchmarks.py`: deterministic/hash-checked resolution and density/stress datasets; CPU OpenCV one/multiple-thread runners; executable-adapter protocol; raw/median/p95/throughput data; exact agreement/F1/precision/recall vs scalar and OpenCV; output maps; error/skip recording; PNGs/HTML; opt-in logical-byte bandwidth model and scalar F1 gate.
  - `requirements-bench.txt`, `.gitignore`, `scripts/setup_remote.sh`, `scripts/run_remote.sh`, `scripts/package_remote.sh`, benchmark example JSONs, README.md and `benchmarks/README.md`: dependencies, remote setup/run/package instructions, source archives, build/environment provenance, and interpretation limits. Scripts executable; generated artifacts ignored.
- Verification:
  - Release CMake build with AppleClang 21 succeeded; CTest passed 1/1 hysteresis test (1024-pixel chain, border connectivity, disconnected weak candidates, no row wrapping, weak-only/strong-only/reused state).
  - `python -m unittest discover -s benchmarks -p 'test_*.py' -v`: 5/5 passed, including a larger sparse-map identity test, deterministic noise, adapter validation, scalar intensity-step localization, blank output and continued collection after a missing custom executable.
  - `shellcheck collect_hw_info.sh scripts/*.sh`, Bash syntax, Python compileall and `git diff --check` passed.
  - Setup script executed with an existing temporary environment and PIP_NO_INDEX=1 (dependencies already installed); configuration/build/package freeze succeeded. Fresh network installation was exercised separately in that temporary environment.
  - Full wrapper smoke run: `/private/tmp/canny-bench-final`, using Python 3.14.7, NumPy 2.3.5, OpenCV 4.13.0, 2 warmups/3 samples, requested OpenCV multi threads=2. Six small cases produced 18 successful CPU case/backend results, 54 raw samples, 14 PNG plots and an HTML accuracy table. Six optional CUDA case/backend results explicitly skipped because the GPU executable was not built. Both hardware reports and source/build provenance were created; one stage chart inspected visually.
  - Full dataset generation exercised: ten cases including the five resolution sizes through 8K, four 4K density/stress fixtures and blank sanity. This is dataset generation, not a full-resolution benchmark claim.
  - Additional 640x480 procedural-image check (2 warmups/3 samples): scalar median compute 4.32625 ms, OpenCV single-thread median 0.588 ms, scalar/OpenCV pixel agreement 99.913411%, exact-pixel F1 0.978444. Development-machine sanity measurements only; not representative remote-machine results or proof of optimization speedup. Scalar/OpenCV differences are documented algorithm/rounding/border differences, not silently approved correctness.
  - Logical threshold-byte model exercised on measured scalar data: CSV emitted and GPU peak percentages left blank for CPU rows even when a GPU peak was supplied. No DRAM counter measurements made.
- Issue found/corrected: a locally cached NumPy 2.2.6 build for Python 3.14 produced inconsistent large-array boolean-complement results, corrupting accuracy statistics. Selected NumPy 2.3.5 for Python >=3.14, retained 2.2.6 for 3.10–3.13, updated OpenCV wheel to 4.13.0.92, added a large-array identity regression and startup accuracy preflight. Earlier temporary accuracy files from that incompatible environment are superseded by `/private/tmp/canny-bench-final` and `/private/tmp/canny-sd-final`.
- Remaining risks: no nvcc/NVIDIA GPU or CUDA-enabled C++ OpenCV on this Mac, so CUDA compilation/runtime and remote performance remain unverified. No natural photo supplied; defaults are labeled procedural. No optimized team GPU kernels implemented. Exact scalar/OpenCV equality is not promised; standard NMS remains provisional pending staff clarification. Full 100-iteration remote sweeps and any physical DRAM profiling remain unrun.
- Next action: package/copy sources to the actual remote machine, run setup and small smoke comparison there, collect hardware/bandwidth calibration, enable the optional CUDA reference if available, then run the full 100-sample suite with a supplied natural photograph. Register team kernels only after implementing and independently validating them.
