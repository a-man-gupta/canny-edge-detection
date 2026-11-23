# Reusing Sobel halo rows on native 4K

The input is a centered, pixel-for-pixel 3840×2160 grayscale crop (left 369, top 1209) from the [4579×4579 original Apollo photograph](https://images-assets.nasa.gov/image/as17-148-22727/as17-148-22727~orig.jpg). Input SHA-256 is `8c067fa2edcfbc864b530178caa22a649aca45ee74451e64227f23185a1f18d8`.

Both builds used the same 320-column row-major strips, eight NMS rows per block, exact seed masks, thresholds 60/120 and OpenMP affinity on ECE024. The initial block computes ten gradient rows. On continuation the experiment keeps two magnitude rows and one row of each signed gradient, then computes eight fresh rows. One full 64-row band needs 66 Sobel output rows versus 80 previously, counting recomputation. Preserving the halos incurs local row copies.

Each cell below is the median over 88 warm trials. Each batch had eleven trials. Eight paired batches alternated execution order. Each run compared labels and edges to the scalar reference; each pair also compared both optimized edge maps byte-for-byte. File I/O and scalar checks are outside the timer. The baseline Sobel object code matched the pre-experiment instruction bytes.

| Threads | Before (ms) | Reuse (ms) | Whole-pipeline speedup | Time saved | Filter before → reuse (ms) | Faster paired batches |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 32.265 | 36.483 | 0.884× | -13.1% | 15.970 → 18.119 | 4/8 |
| 8 | 7.603 | 7.493 | 1.015× | +1.4% | 3.573 → 3.457 | 7/8 |

Final edge SHA-256 for both versions was `379ad09f239b48adb8ef0f8bd8bdd6ccdb644b0c599b6402fe6feb32e0674702`. The default fusion target still selects the original implementation.

Reproduce on ECE024 from the project root with the benchmark input already installed.

```sh
make -j4 build/canny_tall.x build/canny_halo.x
python3 benchmarks/fusion/halo.py
```
