# Canny edge detection

18-645 project. See [agent.md](agent.md) for scope and [log.md](log.md) for verified decisions and results.

A runnable remote benchmark kit is in [benchmarks/README.md](benchmarks/README.md): hardware/cache discovery, deterministic datasets, scalar C++ and OpenCV CPU baselines, optional OpenCV CUDA, a CUDA bandwidth calibration, raw timing/accuracy data and plots. Team optimized CUDA tiers can be connected through executable adapters.

On the remote machine:

```bash
./scripts/setup_remote.sh
./scripts/run_remote.sh --smoke -- --iterations 3 --warmup 2
./scripts/run_remote.sh --photo /path/to/natural-image.jpg
```

CUDA-enabled C++ OpenCV needs a separate installation; see the benchmark guide. No scripts change clocks or install system packages.
