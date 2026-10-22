# Stage 2 and stage 3

Runs are on `ece024` (the same Xeon Silver 4208 the writeup calls ece020): 2 sockets × 8 cores × 2 threads, L1d 32 KB, L2 1 MB/core, L3 11 MB/socket, AVX2 and AVX-512. gcc 8.5, `-O3 -mavx2 -ffp-contract=off`, no `-mfma`, no `-ffast-math`. One thread, `taskset -c 0`.

`rdtsc` ticks at 2.1 GHz. The driver turns ticks into core cycles with a chain of dependent `vaddps` (latency 4). That clock moves: samples in these runs were about 2.1–2.5 GHz. Each row below samples it after that row’s warm-up. The earlier single-sample runs are cited only where the text says so.

Course peak: 2 FP units (ports 0 and 1) × 1 instruction per cycle. Kernel peak in cycles/pixel is FP-unit instructions per pixel / 2. Machine peak is 2 × 8 floats × 2 = 32 FLOP/cycle. `scripts/count_sobel_ops.sh` counts an FP-unit instruction as `vadd/vsub/vmul/vsqrtps`, `vcmpps`, or an FMA. A compare is 0 FLOP. FLOP/cycle in the tables is FLOP/pixel divided by the measured cycles/pixel.

The default 32-pixel Sobel loop is 80 FP-unit instructions, so its peak is 1.25 cycles/pixel and 18 FLOP/pixel. NMS is 2 `vcmpps` per 8 pixels, so the script’s peak is 0.125 cycles/pixel and 0 FLOP/pixel. The fused kernel is those two added together: 1.375 cycles/pixel and 18 FLOP/pixel.

## 1. Gap to the 1.25 peak

Real object, not the marker build: `row_v2<4>` in `build/CMakeFiles/sobel_driver.dir/src/sobel_kernel.cpp.o`. The 32-pixel loop is 193 instructions.

| op | count | what it is |
| --- | ---: | --- |
| vaddps | 28 | FP port |
| vsubps | 24 | FP port |
| vmulps | 16 | FP port |
| vcmpltps | 8 | FP port |
| vsqrtps | 4 | FP port, divider |
| vmovups | 40 | half of a split 256-bit load or store |
| vinsertf128 | 32 | the other half of each unaligned load |
| vextractf128 | 8 | the high half of each store |
| vandnps | 12 | abs and the horizontal bin |
| vblendvps | 8 | four of these reload a constant from `.rip` |
| vxorps | 4 | sign test |
| vmovaps | 2 | spill stores |
| sub / cmp / jne | 7 | pointer bumps and the loop |

Stack: two aligned YMM stores (`[rsp-0x20]`, `[rsp-0x40]`) and three arithmetic instructions that reload them. No register-to-register `vmovaps` copies. gcc is holding four groups of `gx, gy` plus the broadcast constants, and 16 YMM registers are not enough, so two values spill. Hoisting the five broadcasts to after the gradients did not change this object code, so that change is not in the source.

Bounds for one iteration (32 pixels):

| unit | work | cycles | cycles/pixel |
| --- | --- | ---: | ---: |
| FP ports 0 and 1 | 80 instructions / 2 | 40 | 1.25 |
| sqrt divider | 4 × ~6 cycles | 24 | 0.75 |
| ports 0, 1, and 5 | 80 FP + 12 vandn + 4 xor + 16 blendv uops + 32 inserts = 144 / 3 | 48 | 1.50 |
| loads | ~71 load uops / 2 per cycle | 36 | 1.11 |
| stores | 18 / 1 per cycle | 18 | 0.56 |
| issue | 193 / 4 per cycle | 48 | 1.51 |

The FP-port peak (1.25) is not what the compiled loop hits. gcc’s generic tune splits every unaligned 256-bit load into `vmovups xmm` + `vinsertf128`, and every store into `vmovups xmm` + `vextractf128`. Those inserts, the blends (`vblendvps` is 2 uops), and the logic fill ports 0/1/5 and the 4-wide issue pipe to about 1.50 cycles/pixel. Loads and stores are under that. The two spills are real but small next to the 32 inserts.

L1, data in the 32 KB cache, G=4: **2.27 cycles/pixel, 55% of the 1.25 peak, 7.95 FLOP/cycle, 25% of 32**. That is 1.50/2.27 ≈ 66% of the issue/port bound. The rest is the sqrt latency (4 independent sqrts, each ~12 cycles) and the spills, not another unit sitting at 2.27.

Optional, not the default flags. gcc 8.5 has no `-march=cascadelake`. `-march=skylake-avx512 -mno-fma` is this chip’s AVX-512 tune (Cascade Lake adds VNNI, which this loop does not use) and keeps the add/mul path. The same 32-pixel loop becomes 143 instructions: 32 full `vmovups` loads, 8 stores, no inserts, no spills, no `.rip` reloads. Blends stay `vblendvps`; gcc did not rewrite them to mask blends. FP ports are again the tight bound at 1.25, and issue drops to 143/4/32 ≈ 1.12. Two L1 samples: generic **2.29 and 2.22** cycles/pixel, skylake-avx512 **1.80 and 1.72**. Still short of 1.25, which fits a loop whose sqrts and blend chains are not fully hidden behind the 80 arithmetic ops.

Group count, L1, default build:

| groups | pixels/iter | cycles/pixel | % of 1.25 | FLOP/cycle | % of 32 |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 8 | 2.68 | 47% | 6.72 | 21% |
| 2 | 16 | 2.33 | 54% | 7.71 | 24% |
| 4 | 32 | 2.27 | 55% | 7.95 | 25% |
| 8 | 64 | 2.47 | 51% | 7.28 | 23% |

Four groups is the best. Eight groups needs more live `gx, gy` pairs than the 16 YMM registers can hold, so it gets slower. One group does not have enough independent adds to fill both FP ports.

## 2. Overlapped tail

v2 used to finish each row with scalar code for the leftover 1–7 interior columns. It now runs one more group of 8 that ends on the last interior column. That step rewrites columns already done and writes the same values. The right border stays scalar. Widths 9, 10, 11, 12, 20, 23, 40, and 70 are in the test; v2 still matches v1 bit for bit.

The 32-pixel loop is outside that tail, so the instruction count did not change (still 80 FP, 106 other, peak 1.25).

Whole image, v2 with 4 groups. “Before” is the run with one clock sample at the start (2.34 GHz). “After” samples the clock per row.

| image | before | after | % of 1.25 | FLOP/cycle | % of 32 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 256×256 | 3.78 | 3.16 | 40% | 5.69 | 18% |
| 768×768 | 3.24 | 2.83 | 44% | 6.36 | 20% |
| 1920×1080 | 3.18 | 3.18 | 39% | 5.65 | 18% |
| 3840×2160 | 3.27 | 3.48 | 36% | 5.18 | 16% |

256×256 is the one this was aimed at. Its interior width leaves 6 columns, and those used the scalar classifier on every row, which was most of the non-vector work. Dropping that tail is worth about 0.6 cycles/pixel there and about 0.4 at 768. A 1080p or 4K row is thousands of pixels, so six leftover columns do not move the average. 4K went from 3.27 to 3.48; that is inside the clock movement seen on this machine (the overlap itself adds one 8-pixel group per row, which is noise at this width). L1 did not change, because the 1026-wide row has no tail.

## 3. Memory

Stream copy, one core, 200 MB read and 200 MB written with normal AVX2 stores (so the destination is write-allocated): **12.25 GB/s useful, 4.88 bytes per core cycle**. The allocate is a third trip on the bus, so the bus rate is about 1.5× that, **7.3 bytes per core cycle**.

Bytes per pixel, counting the allocate read of every line that is written:

| kernel | read | write | allocate | total | DRAM floor |
| --- | ---: | ---: | ---: | ---: | ---: |
| float angle | blur 4 | mag 4 + angle 4 | 8 | 20 | 20/7.3 = 2.7 cyc/px |
| byte bin | blur 4 | mag 4 + bin 1 | 5 | 14 | 1.9 cyc/px |
| fused | blur 4 | suppressed 4 | 4 | 12 | 1.6 cyc/px |

The driver also prints a higher floor (4.10 cycles/pixel for the float kernel). That one divides the 20 bytes by the *useful* 4.88 bytes/cycle, so it charges the allocate twice. The 2.7 figure is the consistent one.

1920×1080 and 4K are not a pure memory limit, and they are not the L1 rate either.

- Float angle, G=4: L1 is 2.27. 1080p is 3.18, 4K is 3.48. The DRAM floor is 2.7. Both sizes sit a little above that floor, and clearly above L1, so the extra store of the angle is visible but the loop’s 1.5-cycle instruction bound is still in the time.
- Byte bin (next section): 1080p is 2.75 and 4K is 2.85, against a floor of 1.9 and an instruction rate near 2.3. Those two are limited by the loop, with a smaller DRAM add-on.

L3 is 11 MB. 1080p at 20 bytes/pixel is about 40 MB, and 4K is about 160 MB, so both miss L3. 256×256 at 20 bytes is about 1.3 MB (L2). Its 3.16 cycles/pixel is the tail and the scalar border, not DRAM.

## 4. Direction as a byte

`sobel_kernel_bins` is a second function next to v2. Same magnitude. The bin is a byte: 0 horizontal, 1 for 45°, 2 vertical, 3 for 135°. `canny_part2` did not call it until stage 3 did.

The arithmetic count is unchanged: 80 FP-unit instructions per 32 pixels, peak 1.25, 18 FLOP/pixel. Packing the byte adds other vector ops (127 other per 32 pixels, against 106 for the float store).

| image | float v2 G=4 | byte bin | bytes of output | % of 1.25 | FLOP/cycle | % of 32 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 256×256 | 3.16 | 3.52 | 9 B vs 12 B stored with the read | 36% | 5.12 | 16% |
| 768×768 | 2.83 | 2.77 | | 45% | 6.51 | 20% |
| 1920×1080 | 3.18 | 2.75 | | 45% | 6.54 | 20% |
| 3840×2160 | 3.48 | 2.85 | | 44% | 6.32 | 20% |

At 1080p and 4K the byte store is faster (3.18 → 2.75, 3.48 → 2.85) even though the FP work is identical. That is the memory effect from section 3: one byte instead of one float, so less write-allocate traffic, and the time moves toward the L1 rate. At 256×256 the working set already fits in L2, and the extra pack instructions cost more than the saved store, so the byte kernel is slower there (3.52 vs 3.16).

## 5. Non-maximum suppression

Scalar NMS in the driver is the same neighbor rule as `canny_scalar.cpp`: left/right, up-left/down-right, up/down, up-right/down-left, and keep the pixel only when `mag > mag[a]` and `mag >= mag[b]`. The vector row does 8 pixels. The bin selects the pair with three integer compares and six blends. Borders stay 0. A short tail is one overlapped group of 8 ending on the last interior column, same as Sobel.

The test checks the vector result, and the fused result, against that scalar loop, bit for bit. `canny_part2` (v2) calls `sobel_kernel_bins` then `nms_kernel`. v1 still computes the float angle and converts the four values to the same bytes. On a step, a diagonal, noise, and a 256×256 step, the edge map matches `canny_scalar` for both kernels. `ctest` passes.

Real 8-pixel loop: 39 instructions, no spills. 10 `vmovups` and 9 `vinsertf128` (the generic tune splitting the 9 magnitude loads), 6 `vblendvps`, 3 `vpcmpeqd`, 2 `vandps`, 1 `vcmpgtps`, 1 `vcmpgeps`, one split store. The script counts only the two `vcmpps` as FP-unit ops (peak 0.125). The three `vpcmpeqd` also issue on ports 0 and 1, so the FP-port bound is really 5/2/8 = 0.31 cycles/pixel. That is still not the limit:

| unit | cycles/pixel |
| --- | ---: |
| FP ports, including the 3 integer compares | 0.31 |
| ports 0/1/5 (blends are 2 uops, plus the inserts) | ~1.2 |
| loads (19 load uops / 2) | ~1.2 |
| issue (39 / 4 / 8) | 1.22 |

| image | scalar | vector | % of script peak 0.125 | FLOP/cycle | % of 32 |
| --- | ---: | ---: | ---: | ---: | ---: |
| L1, 1026×3 | | 2.00 | 6% | 0 | 0% |
| 256×256 | 35.9 | 2.34 | 5% | 0 | 0% |
| 768×768 | 36.6 | 2.57 | 5% | 0 | 0% |
| 1920×1080 | 34.0 | 3.04 | 4% | 0 | 0% |
| 3840×2160 | 37.4 | 3.99 | 3% | 0 | 0% |

The 6% is the script’s peak, and it is the wrong ceiling. There is no arithmetic FLOP in this loop (a compare is not one), so FLOP/cycle and the share of the 32 FLOP/cycle peak are 0. The loop is a chain of six dependent blends fed by split loads. L1 at 2.00 cycles/pixel is about 60% of the ~1.2 load/issue bound; the gap is that blend chain, whose latency the 8-wide loop does not hide. 1080p and 4K are slower than L1 (3.0 and 4.0). NMS gathers 9 neighbors, many of them unaligned, so a large image moves more than one clean stream per pixel. It is not the 1.9-cycle byte-bin floor from section 3.

Against the scalar loop the vector row is about 15× at 256×256 and about 9× at 4K.

## 6. Fusion

`sobel_nms_fused` keeps three magnitude rows and three bin rows. Suppressing row y needs mag y−1, y, y+1 and the bin of row y, then the buffer slot is reused. The full magnitude image is not stored. It is measured in the driver and is not what `canny_part2` calls, so the two stages can still be timed apart.

| image | bins + NMS | fused | speedup | % of 1.375 | FLOP/cycle | % of 32 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 256×256 | 3.52 + 2.34 = 5.86 | 5.46 | 1.07× | 25% | 3.30 | 10% |
| 768×768 | 2.77 + 2.57 = 5.34 | 5.10 | 1.05× | 27% | 3.53 | 11% |
| 1920×1080 | 2.75 + 3.04 = 5.79 | 5.41 | 1.07× | 25% | 3.33 | 10% |
| 3840×2160 | 2.85 + 3.99 = 6.83 | 5.95 | 1.15× | 23% | 3.03 | 9% |

The large-image speedup is 7% at 1080p and 15% at 4K. Both stages still run, so the time stays near the sum. What goes away is the write and the later read of the full magnitude image. At 4K that traffic is enough to see; it is not enough to approach the 1.6-cycle DRAM floor or the 1.375 arithmetic peak. The fused row is also less overlapped than two separate passes that each fill the FP ports on their own. I left it out of the pipeline.

## What is near the peak, and what is not

The L1 Sobel loop is the closest. Its compiled form is bounded at about 1.50 cycles/pixel by issue and by ports 0/1/5, because every unaligned 256-bit access is split, and the measured 2.27 is 66% of that and 55% of the 1.25 FP peak. Four groups is the right unroll. A Cascade Lake tune, which this gcc only has under the name skylake-avx512, removes the splits and the spills and lands at about 1.75, still short of 1.25 because of sqrt and blend latency. That flag is not the default build.

Whole images with a float angle sit a little above a ~2.7 cycle DRAM floor. Storing a byte instead of a float pulls 1080p and 4K down to about 2.8, which is the instruction loop plus a small memory tax. The overlapped tail is why 256×256 went from 3.78 to 3.16; it does not matter at 4K.

NMS has almost no FP arithmetic, so “percent of the 0.125 peak” is not a useful grade. The real bound is about 1.2 cycles/pixel from split loads and issue, and L1 measures 2.0 because the neighbor blends are a dependent chain. Large images are slower than that because the gathers miss. Fusion saves the magnitude round trip and is 1.07–1.15× on the big images, which is the whole of the win available once both loops have to run.
