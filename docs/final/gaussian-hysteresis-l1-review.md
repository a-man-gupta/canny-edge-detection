# Gaussian and hysteresis on ECE024
November 26, 2026. Intel Xeon Silver 4208, pinned to logical CPU 10, 10 rows × 256 columns. Timings use hardware core cycles, warm inputs and scalar-checked outputs. Peak is an ideal vector execution-port bound. Rates are reference integer ops per core cycle.

| Current code path | Trials | Best | Median | Port peak | Median / peak |
|---|---:|---:|---:|---:|---:|
| Gaussian, standalone AVX-512 ten-row tile | 5 | 39.37 | 38.97 | 47.56 | 81.9% |
| Packed hysteresis, sparse labels | 9 | 10.27 | 10.20 | 17.35 | 58.8% |
| Packed hysteresis, dense labels | 9 | 53.42 | 53.37 | 85.16 | 62.7% |

Single-stepping one invocation outside the timed trials gave the following executed instruction counts. The limiting resource in the model is the combined capacity of p0 and p5. Loads, stores, scalar control and dependencies can reduce achieved throughput.

- Gaussian computes 2,560 × 14 = 35,840 reference ops. The trace contains 560 rounded multiplies, 80 shifts, 80 widenings, three broadcasts, 80 narrowings at two dispatches each and 624 adds. Peak = 35,840 / (1,507 / 2) = 47.56. This tests the standalone image specialization. The fused pipeline uses separate AVX2 row primitives.
- Sparse hysteresis counts 2,941 scalar-reference predicates. The executed path has 54 p0-only, 149 p5-only and 136 flexible vector dispatches. Peak = 2,941 / (339 / 2) = 17.35.
- Dense hysteresis counts 26,867 predicates. The path has 126 p0-only, 241 p5-only and 264 flexible vector dispatches. Peak = 26,867 / (631 / 2) = 85.16. The compiled tracker packs label masks and propagates connectivity with vector logic and tests for convergence. Different label maps change both the reference work and the executed instruction count.

The highest previously reported experimental medians on these 10 × 256 sparse and dense generators were 11.33 and 72.38 using an empty-border specialization. Its generator always clears the outer rows. The ten-row Gaussian previously recorded 39.45 as a multi-round median. See benchmarks/final/matched/README.md.
