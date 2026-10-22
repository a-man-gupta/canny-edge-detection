#!/usr/bin/env bash
# Count the instructions in one iteration of each Sobel vector loop, and the peak they imply.
#
# The course's peak: units x 1 instruction per cycle. On the Xeon Silver 4208 the 2 FP
# units (ports 0 and 1) run add, sub, mul, FMA, compare, and issue sqrt. So
#     peak cycles per pixel = FP instructions per iteration / 2 / pixels per iteration.
# Run this on the benchmark machine; copy the numbers into the #defines in sobel_driver.cpp
# if they differ from the ones there.
#
# Usage: ./scripts/count_sobel_ops.sh            (uses $CXX, default c++)
set -euo pipefail
cd "$(dirname "$0")/.."
CXX=${CXX:-c++}
mkdir -p build
# Same flags as the real kernel build, plus the loop markers.
"$CXX" -std=c++17 -O3 -mavx2 -mfma -ffp-contract=off -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store -DSOBEL_MARK_LOOPS -S src/sobel_kernel.cpp -o build/sobel_kernel_marked.s

awk '
/# loop .* begin/ { inside = 1; name = $3; pixels = $NF; fp = 0; flop = 0; other = 0; next }
/# loop end/   {
    if (inside) {
        printf "%s loop, %3d pixels: %4d FP-unit instructions, %4d other vector instructions -> peak %.3f cycles/pixel, %.1f FLOP/pixel\n",
               name, pixels, fp, other, fp / 2 / pixels, flop / pixels
    }
    inside = 0; next
}
inside && $1 ~ /^v/ {
    op = $1
    if (op ~ /^vf(n)?m(add|sub)/)              { fp++; flop += 16 }   # FMA: 2 FLOP x 8 lanes
    else if (op ~ /^v(add|sub|mul|sqrt)ps/)    { fp++; flop += 8 }    # 1 FLOP x 8 lanes
    else if (op ~ /^vcmp/)                     { fp++ }               # uses an FP unit, 0 FLOP
    else                                       { other++ }            # loads, stores, logic, blends
}
' build/sobel_kernel_marked.s
