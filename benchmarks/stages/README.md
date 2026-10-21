# Sobel and NMS stages

Comparison view for Part 2 (Sobel) and Part 3 (non-maximum suppression). Millisecond timing still comes from `benchmarks/run.py` through `scripts/run_remote.sh`. This folder does not run a second timer and does not change the Canny kernels. The Part 2 executable also records an RDTSC measurement. That measurement is separate from the millisecond median plots.

```bash
./scripts/run_stages.sh
```

That command is the matched full-size run. It takes the next `benchmark_results/run-00N/` directory after the highest existing run and reuses the frozen baseline's image cases, warmup, iteration count, and scalar-only settings. The default baseline is run-003: procedural images, resolutions 640x480 through 7680x4320, warmup 3, 10 iterations, scalar. `benchmark_results/run-001/baseline.json` points at run-003 and those timing files are read in place. The previous baseline was `benchmark_results/archive/20261020T235216Z-2233567`; that archive is unchanged and is no longer the default. The older grace_hopper sweep `20261019T232528Z-1788498` is a different photo, warmup, and iteration count, so it is not this baseline.

Results stay in `benchmark_results/`. Open only:

- `benchmark_results/run-00N/comparison/sobel_time.png`
- `benchmark_results/run-00N/comparison/nms_time.png`
- `benchmark_results/run-00N/comparison/results.md`

Those are median milliseconds versus image size, smallest to largest, plus one table of the five stage medians, total time, and Sobel and NMS speedup. Speedup is the run-003 median divided by this run's median. The generic throughput, stage-stack, latency, and HTML plots are not written into `comparison/`.

`benchmark_results/run-001/` stores a pointer and checksums. run-003 is read in place. The previous archive `20261020T235216Z-2233567` stays where it is.

A run is a matched comparison only when the image cases, warmup, iteration count, compiler settings, machine, and thresholds match run-003, and each timed scalar edge map is an exact 0/255 match to the run-003 map for the same case (`run/edges/<case>_<scalar index>.pgm`). The in-run `accuracy.csv` scalar row compares the scalar output with itself, so the stage verdict does not use it. A mismatch is `failed` and that case has no Sobel or NMS speedup. A smoke run uses different sizes, so its maps are not compared to the full-size baseline maps. The table says `not compared to baseline edge map`, and the verdict is not a successful speedup:

```bash
./scripts/run_stages.sh --smoke -- --warmup 1 --iterations 2
```

`./scripts/run_stages.sh` times `build/canny_scalar`. To time the Part 2 Sobel kernel instead:

```bash
./scripts/run_stages.sh --kernel part2
```

That runs `build/canny_scalar` and `build/canny_part2` on the same images. The table times `part2`. The frozen-baseline edge check uses the part2 map, not the scalar-versus-scalar row in `accuracy.csv`. Magnitude is compared to the scalar dump bitwise, or within 1 float32 ulp if a last-bit difference remains. Direction is compared as the four NMS categories, not as a continuous angle. NMS and the final edge map must match the scalar executable exactly. `--kernel scalar` is the default. The next numbered directory is one past the highest existing `run-NNN`. A smoke run uses different sizes, so it is not a matched speedup.

The scalar reference keeps `-fno-tree-vectorize -fno-tree-slp-vectorize`. `sobel_kernel.cpp` adds `-mavx2 -ffp-contract=off` and does not get `-ffast-math` or `-mfma`. That AVX2 difference is written in the results table. It is not treated as a different machine. Both flag lines come from `build_provenance/compile_commands.json`.

`./scripts/run_stages.sh --kernel part2` also writes:

- `benchmark_results/run-00N/comparison/sobel_threshold.png`
- `benchmark_results/run-00N/comparison/sobel_cycles.csv`

`./scripts/run_stages.sh` without `--kernel part2` does not write those two files. `sobel_time.png` and `nms_time.png` stay median milliseconds.

## Lab clock and threshold

Same formula as the 18-645 benchmarking lab, `private/18645/benchmarking_starter/latency/latency_simd_fma.c`, and the kernel-design driver, `private/18645/KernelDesignTemplate/kernel_driver.c`.

The clock is `rdtsc`. Those files scale it by `MAX_FREQ / BASE_FREQ` with `MAX_FREQ = 3.4` and `BASE_FREQ = 2.4`:

```
turbo_cycles = rdtsc_cycles * 3.4 / 2.4
cycles_per_pixel = turbo_cycles / (width * height)
flops_per_cycle = (23 * width * height) / turbo_cycles
```

`cycles_per_pixel` is the latency line in `latency_simd_fma.c`: `MAX_FREQ/BASE_FREQ * rdtsc / outputs`, with one output per pixel. `flops_per_cycle` is the kernel-driver line `(2*m*n*k) / (rdtsc * MAX_FREQ/BASE_FREQ)`, with 23 floating-point operations per pixel instead of `2*m*n*k` (8 for `gx`, 8 for `gy`, 4 for the magnitude, 3 for the angle). The horizontal line is that lab's peak, 16 flops/cycle (2 FMA ports × 4 doubles × 2 flops, the same two ports that issue 16 single-precision adds per cycle), drawn as `23 / 16 = 1.4375` cycles/pixel. This is not the steady_clock millisecond median.

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
