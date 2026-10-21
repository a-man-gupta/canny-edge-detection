# Sobel and NMS stages

Comparison view for Part 2 (Sobel) and Part 3 (non-maximum suppression). Timing still comes from `benchmarks/run.py` through `scripts/run_remote.sh`. This folder does not run a second timer and does not change the Canny kernels.

```bash
./scripts/run_stages.sh
```

That command is the matched full-size run. It takes the next free `benchmark_results/run-00N/` directory and reuses the frozen baseline's image cases, warmup, iteration count, and scalar-only settings. run-001 is the procedural full-size scalar sweep `20261020T235216Z-2233567` (resolutions through 7680x4320, warmup 3, 10 iterations, no photograph). The older grace_hopper sweep `20261019T232528Z-1788498` is a different photo, warmup, and iteration count, so it is not this baseline.

Results stay in `benchmark_results/`. Open only:

- `benchmark_results/run-00N/comparison/sobel_time.png`
- `benchmark_results/run-00N/comparison/nms_time.png`
- `benchmark_results/run-00N/comparison/results.md`

Those are median milliseconds versus image size, smallest to largest, plus one table of the five stage medians, total time, and Sobel and NMS speedup. Speedup is the run-001 median divided by this run's median. The generic throughput, stage-stack, latency, and HTML plots are not written into `comparison/`.

`benchmark_results/run-001/` stores a pointer and checksums. The timestamp directory is read in place.

A run is a matched comparison only when the image cases, warmup, iteration count, compiler settings, machine, and thresholds match run-001, and each resolution case has scalar status `ok` with accuracy.csv F1 1 and agreement 100 against the scalar reference. Anything else is marked `not matched` or `failed`. Those cells are not a speedup. A smoke run uses different sizes, so it is not a successful speedup against the 8K baseline:

```bash
./scripts/run_stages.sh --smoke -- --warmup 1 --iterations 2
```

## Source-level operations per pixel

These counts are read off `src/canny_scalar.cpp`. They are separate from the measured times. The benchmark did not measure CPU instruction counts. The compiler can hoist, fold, or drop operations; this estimate does not claim an instruction mix.

Loop tests and increments are not counted. Casts are not counted. `std::clamp` counts as two comparisons. `h - 1` and `w - 1` sit inside `b()`, so they count on every call. Each `b()` call counts separately, including a neighbor the source reads more than once. Logical `&&` and `||` are not an extra operation beyond the comparisons they guard.

### Part 2, Sobel: 161 operations per pixel

Every pixel, including the border. Twelve `b(j, k)` calls:

| In one `b()` call | Count |
| --- | ---: |
| `y + j`, `x + k`, and the index add | 3 adds |
| `h - 1`, `w - 1` | 2 subtracts |
| row clamp and column clamp | 4 comparisons |
| `sample_row * w` | 1 multiply |
| load `blur[...]` | 1 indexed load |

Twelve calls: 36 adds, 24 subtracts, 48 comparisons, 12 multiplies, 12 loads.

Outside those calls, still per pixel:

| Source | Count |
| --- | --- |
| `gx` and `gy` (unary minus, the `2 *` weights, and the adds and subtracts between the six taps) | 2 negations, 6 adds, 4 subtracts, 4 multiplies |
| `i = y * w + x` | 1 multiply, 1 add |
| `sqrt(gx * gx + gy * gy)` and the store of `mag[i]` | 2 multiplies, 1 add, 1 square root, 1 store |
| `atan2(gy, gx) * 180 / pi` | 1 atan2, 1 multiply, 1 divide |
| `degrees < 0` and `degrees + 180`, then the store of `angle[i]` | 1 comparison, 1 add, 1 store |

Total: 45 adds, 28 subtracts, 2 negations, 20 multiplies, 1 divide, 1 square root, 1 atan2, 49 comparisons, 12 indexed loads, 2 indexed stores. 161.

### Part 3, NMS: 1 store per pixel, plus 12 to 17 operations on each interior pixel that is kept

`std::fill` writes 0 into every suppressed pixel, including the border that the loop never visits: 1 store per pixel.

Each interior pixel always does `i = y * w + x` (1 multiply, 1 add), one load of `angle[i]`, loads of `mag[i]`, `mag[a]`, and `mag[b]`, two magnitude comparisons, and, on the keep path, one store. That common keep-path work is 9 operations. Direction work depends on which branch runs:

| Direction | Comparisons on `d` | Index arithmetic | Keep-path total |
| --- | ---: | --- | ---: |
| Horizontal, `d < 22.5` | 1 | `i-1`, `i+1` | 12 |
| Horizontal, `d >= 157.5` | 2 | `i-1`, `i+1` | 13 |
| Near 45° | 3 | `i-w-1`, `i+w+1` | 16 |
| Near 90° | 4 | `i-w`, `i+w` | 15 |
| Near 135° | 4 | `i-w+1`, `i+w-1` | 17 |

A pixel rejected by `mag[i] > mag[a]` skips the `mag[b]` load, the second magnitude comparison, and the store (3 fewer). Border pixels are only the clear store.
