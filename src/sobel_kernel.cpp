#include "sobel_kernel.hpp"

#include <cmath>
#include <immintrin.h>


// Sector test on squares: gy^2 < gx^2 * tan(22.5)^2 is |gy| < |gx| * tan(22.5) without the
// absolute values (gx*gx and gy*gy are already computed for the magnitude, and are exact
// because blur values are whole numbers). tan(22.5)^2 = (sqrt(2) - 1)^2 = 3 - 2*sqrt(2).
static const float kTan22Sq = static_cast<float>(3.0 - 2.0 * std::sqrt(2.0));

// Markers so scripts/count_sobel_ops.sh can see one iteration.
// Present only with -DSOBEL_MARK_LOOPS. The normal build has none.
#ifdef SOBEL_MARK_LOOPS
#define LOOP_BEGIN(pixels) __asm__ __volatile__("# loop kernel begin %c0" :: "i"(pixels) : "memory")
#define LOOP_END() __asm__ __volatile__("# loop end" ::: "memory")
#else
#define LOOP_BEGIN(pixels)
#define LOOP_END()
#endif

// Scalar direction bin. Borders use this. Same four tests as the vector path.
float sobel_classify_angle(float gx, float gy) {
    float gx2 = gx * gx;
    float gy2 = gy * gy;
    // The same fused multiply-add as the vector code (one rounding), so both agree bit for bit.
    if (std::fma(-gx2, kTan22Sq, gy2) < 0)   // gy^2 - gx^2 * tan^2 < 0
        return 0.f;
    if (std::fma(-gy2, kTan22Sq, gx2) < 0)   // gx^2 - gy^2 * tan^2 < 0
        return 90.f;
    if (std::signbit(gx) == std::signbit(gy))
        return 45.f;
    return 135.f;
}

// One interior row, columns x_begin .. x_limit-1, written as one function with the loops
// unrolled by hand. Returns the first column not written.
//
// Each iteration does 32 pixels as four independent groups of 8 (A, B, C, D), one ymm
// register per group. Why four: an FP add/sub/mul/FMA takes 4 cycles and there are 2 FP
// units, so 4 x 2 = 8 independent operations must be in flight; each group gives 2 per step
// (gx and gy), so 4 groups. All four gradients come first, then the four finishes.
//
// Order the instructions appear in (each column is one group; down = later):
//
//        A            B            C            D
//   load, 4 sub  load, 4 sub  load, 4 sub  load, 4 sub     <- gradients, all independent
//   a+b, a-b     a+b, a-b     a+b, a-b     a+b, a-b
//   FMA gx, gy   FMA gx, gy   FMA gx, gy   FMA gx, gy
//      |            |            |            |
//   gx2, gy2        |            |            |            <- finishes, one group at a time;
//   sum -> sqrt     |            |            |               while A waits on its sqrt,
//   cmp, blend      |            |            |               B, C, D still have work
//   store A      gx2, gy2        |            |
//                sum -> sqrt     |            |
//                cmp, blend      |            |
//                store B      ... C ...    ... D ...
//
// The last 8..31 pixels: groups of 8, then one group of 8 that ends on the last column
// (it overlaps columns already written and stores the same values). Rows shorter than 8
// are left to the scalar code.
int sobel_row_avx2(const float* top, const float* mid, const float* bot,
                   float* mag_row, float* angle_row, int x_begin, int x_limit) {
    // Constants, kept in registers for the whole row.
    const __m256 two = _mm256_set1_ps(2.0f);
    const __m256 tan22sq = _mm256_set1_ps(kTan22Sq);
    const __m256 deg45 = _mm256_set1_ps(45.f);
    const __m256 deg90 = _mm256_set1_ps(90.f);
    const __m256 deg135 = _mm256_set1_ps(135.f);
    const __m256 zero = _mm256_setzero_ps();

    int x = x_begin;
    for (; x + 32 <= x_limit; x += 32) {
        LOOP_BEGIN(32);
        // ---- Group A: gradients for pixels x .. x+7 ----
        // Scalar: gx = -tl + tr - 2*ml + 2*mr - bl + br
        //         gy = -tl - 2*tm - tr + bl + 2*bm + br
        // (t/m/b = row above / this row / row below, l/r = one column left / right)
        const __m256 aA  = _mm256_sub_ps(_mm256_loadu_ps(bot + x + 1), _mm256_loadu_ps(top + x - 1));   // br - tl
        const __m256 bA  = _mm256_sub_ps(_mm256_loadu_ps(top + x + 1), _mm256_loadu_ps(bot + x - 1));   // tr - bl
        const __m256 dmA = _mm256_sub_ps(_mm256_loadu_ps(mid + x + 1), _mm256_loadu_ps(mid + x - 1));   // mr - ml
        const __m256 dvA = _mm256_sub_ps(_mm256_loadu_ps(bot + x), _mm256_loadu_ps(top + x));           // bm - tm
        const __m256 gxA = _mm256_fmadd_ps(dmA, two, _mm256_add_ps(aA, bA));   // gx = 2*(mr - ml) + (br - tl) + (tr - bl)
        const __m256 gyA = _mm256_fmadd_ps(dvA, two, _mm256_sub_ps(aA, bA));   // gy = 2*(bm - tm) + (br - tl) - (tr - bl)

        // ---- Group B: gradients for pixels x+8 .. x+15 ----
        // Scalar: gx = -tl + tr - 2*ml + 2*mr - bl + br
        //         gy = -tl - 2*tm - tr + bl + 2*bm + br
        // (t/m/b = row above / this row / row below, l/r = one column left / right)
        const __m256 aB  = _mm256_sub_ps(_mm256_loadu_ps(bot + x + 8 + 1), _mm256_loadu_ps(top + x + 8 - 1));   // br - tl
        const __m256 bB  = _mm256_sub_ps(_mm256_loadu_ps(top + x + 8 + 1), _mm256_loadu_ps(bot + x + 8 - 1));   // tr - bl
        const __m256 dmB = _mm256_sub_ps(_mm256_loadu_ps(mid + x + 8 + 1), _mm256_loadu_ps(mid + x + 8 - 1));   // mr - ml
        const __m256 dvB = _mm256_sub_ps(_mm256_loadu_ps(bot + x + 8), _mm256_loadu_ps(top + x + 8));           // bm - tm
        const __m256 gxB = _mm256_fmadd_ps(dmB, two, _mm256_add_ps(aB, bB));   // gx = 2*(mr - ml) + (br - tl) + (tr - bl)
        const __m256 gyB = _mm256_fmadd_ps(dvB, two, _mm256_sub_ps(aB, bB));   // gy = 2*(bm - tm) + (br - tl) - (tr - bl)

        // ---- Group C: gradients for pixels x+16 .. x+23 ----
        // Scalar: gx = -tl + tr - 2*ml + 2*mr - bl + br
        //         gy = -tl - 2*tm - tr + bl + 2*bm + br
        // (t/m/b = row above / this row / row below, l/r = one column left / right)
        const __m256 aC  = _mm256_sub_ps(_mm256_loadu_ps(bot + x + 16 + 1), _mm256_loadu_ps(top + x + 16 - 1));   // br - tl
        const __m256 bC  = _mm256_sub_ps(_mm256_loadu_ps(top + x + 16 + 1), _mm256_loadu_ps(bot + x + 16 - 1));   // tr - bl
        const __m256 dmC = _mm256_sub_ps(_mm256_loadu_ps(mid + x + 16 + 1), _mm256_loadu_ps(mid + x + 16 - 1));   // mr - ml
        const __m256 dvC = _mm256_sub_ps(_mm256_loadu_ps(bot + x + 16), _mm256_loadu_ps(top + x + 16));           // bm - tm
        const __m256 gxC = _mm256_fmadd_ps(dmC, two, _mm256_add_ps(aC, bC));   // gx = 2*(mr - ml) + (br - tl) + (tr - bl)
        const __m256 gyC = _mm256_fmadd_ps(dvC, two, _mm256_sub_ps(aC, bC));   // gy = 2*(bm - tm) + (br - tl) - (tr - bl)

        // ---- Group D: gradients for pixels x+24 .. x+31 ----
        // Scalar: gx = -tl + tr - 2*ml + 2*mr - bl + br
        //         gy = -tl - 2*tm - tr + bl + 2*bm + br
        // (t/m/b = row above / this row / row below, l/r = one column left / right)
        const __m256 aD  = _mm256_sub_ps(_mm256_loadu_ps(bot + x + 24 + 1), _mm256_loadu_ps(top + x + 24 - 1));   // br - tl
        const __m256 bD  = _mm256_sub_ps(_mm256_loadu_ps(top + x + 24 + 1), _mm256_loadu_ps(bot + x + 24 - 1));   // tr - bl
        const __m256 dmD = _mm256_sub_ps(_mm256_loadu_ps(mid + x + 24 + 1), _mm256_loadu_ps(mid + x + 24 - 1));   // mr - ml
        const __m256 dvD = _mm256_sub_ps(_mm256_loadu_ps(bot + x + 24), _mm256_loadu_ps(top + x + 24));           // bm - tm
        const __m256 gxD = _mm256_fmadd_ps(dmD, two, _mm256_add_ps(aD, bD));   // gx = 2*(mr - ml) + (br - tl) + (tr - bl)
        const __m256 gyD = _mm256_fmadd_ps(dvD, two, _mm256_sub_ps(aD, bD));   // gy = 2*(bm - tm) + (br - tl) - (tr - bl)

        // All four gradients are done. Each group now finishes on its own chain while the
        // others still have independent work for the FP units.

        // ---- Group A: magnitude and direction for pixels x .. x+7 ----
        // Scalar: mag[i] = sqrt(gx*gx + gy*gy)
        const __m256 gxxA = _mm256_mul_ps(gxA, gxA);
        const __m256 gyyA = _mm256_mul_ps(gyA, gyA);
        _mm256_storeu_ps(mag_row + x, _mm256_sqrt_ps(_mm256_add_ps(gxxA, gyyA)));
        // Scalar: angle[i] = direction bin (sobel_classify_angle: the same four tests)
        const __m256 horizA = _mm256_fnmadd_ps(gxxA, tan22sq, gyyA);  // gy^2 - gx^2*tan^2: negative near 0 degrees
        const __m256 vertA  = _mm256_fnmadd_ps(gyyA, tan22sq, gxxA);  // gx^2 - gy^2*tan^2: negative near 90 degrees
        __m256 binA = _mm256_blendv_ps(deg45, deg135, _mm256_xor_ps(gxA, gyA));  // signs differ -> 135, else 45
        binA = _mm256_blendv_ps(binA, deg90, vertA);                               // vertical -> 90
        binA = _mm256_blendv_ps(binA, zero, horizA);                               // horizontal -> 0
        _mm256_storeu_ps(angle_row + x, binA);

        // ---- Group B: magnitude and direction for pixels x+8 .. x+15 ----
        // Scalar: mag[i] = sqrt(gx*gx + gy*gy)
        const __m256 gxxB = _mm256_mul_ps(gxB, gxB);
        const __m256 gyyB = _mm256_mul_ps(gyB, gyB);
        _mm256_storeu_ps(mag_row + x + 8, _mm256_sqrt_ps(_mm256_add_ps(gxxB, gyyB)));
        // Scalar: angle[i] = direction bin (sobel_classify_angle: the same four tests)
        const __m256 horizB = _mm256_fnmadd_ps(gxxB, tan22sq, gyyB);  // gy^2 - gx^2*tan^2: negative near 0 degrees
        const __m256 vertB  = _mm256_fnmadd_ps(gyyB, tan22sq, gxxB);  // gx^2 - gy^2*tan^2: negative near 90 degrees
        __m256 binB = _mm256_blendv_ps(deg45, deg135, _mm256_xor_ps(gxB, gyB));  // signs differ -> 135, else 45
        binB = _mm256_blendv_ps(binB, deg90, vertB);                               // vertical -> 90
        binB = _mm256_blendv_ps(binB, zero, horizB);                               // horizontal -> 0
        _mm256_storeu_ps(angle_row + x + 8, binB);

        // ---- Group C: magnitude and direction for pixels x+16 .. x+23 ----
        // Scalar: mag[i] = sqrt(gx*gx + gy*gy)
        const __m256 gxxC = _mm256_mul_ps(gxC, gxC);
        const __m256 gyyC = _mm256_mul_ps(gyC, gyC);
        _mm256_storeu_ps(mag_row + x + 16, _mm256_sqrt_ps(_mm256_add_ps(gxxC, gyyC)));
        // Scalar: angle[i] = direction bin (sobel_classify_angle: the same four tests)
        const __m256 horizC = _mm256_fnmadd_ps(gxxC, tan22sq, gyyC);  // gy^2 - gx^2*tan^2: negative near 0 degrees
        const __m256 vertC  = _mm256_fnmadd_ps(gyyC, tan22sq, gxxC);  // gx^2 - gy^2*tan^2: negative near 90 degrees
        __m256 binC = _mm256_blendv_ps(deg45, deg135, _mm256_xor_ps(gxC, gyC));  // signs differ -> 135, else 45
        binC = _mm256_blendv_ps(binC, deg90, vertC);                               // vertical -> 90
        binC = _mm256_blendv_ps(binC, zero, horizC);                               // horizontal -> 0
        _mm256_storeu_ps(angle_row + x + 16, binC);

        // ---- Group D: magnitude and direction for pixels x+24 .. x+31 ----
        // Scalar: mag[i] = sqrt(gx*gx + gy*gy)
        const __m256 gxxD = _mm256_mul_ps(gxD, gxD);
        const __m256 gyyD = _mm256_mul_ps(gyD, gyD);
        _mm256_storeu_ps(mag_row + x + 24, _mm256_sqrt_ps(_mm256_add_ps(gxxD, gyyD)));
        // Scalar: angle[i] = direction bin (sobel_classify_angle: the same four tests)
        const __m256 horizD = _mm256_fnmadd_ps(gxxD, tan22sq, gyyD);  // gy^2 - gx^2*tan^2: negative near 0 degrees
        const __m256 vertD  = _mm256_fnmadd_ps(gyyD, tan22sq, gxxD);  // gx^2 - gy^2*tan^2: negative near 90 degrees
        __m256 binD = _mm256_blendv_ps(deg45, deg135, _mm256_xor_ps(gxD, gyD));  // signs differ -> 135, else 45
        binD = _mm256_blendv_ps(binD, deg90, vertD);                               // vertical -> 90
        binD = _mm256_blendv_ps(binD, zero, horizD);                               // horizontal -> 0
        _mm256_storeu_ps(angle_row + x + 24, binD);
        LOOP_END();
    }

    // Leftover pixels, one group of 8 at a time (same code as group A above).
    if (x_limit - x_begin < 8)
        return x;
    while (x < x_limit) {
        const int c = (x + 8 <= x_limit) ? x : x_limit - 8;   // the last group may overlap
        // ---- Tail group: gradients for pixels c .. c+7 ----
        // Scalar: gx = -tl + tr - 2*ml + 2*mr - bl + br
        //         gy = -tl - 2*tm - tr + bl + 2*bm + br
        // (t/m/b = row above / this row / row below, l/r = one column left / right)
        const __m256 aT  = _mm256_sub_ps(_mm256_loadu_ps(bot + c + 1), _mm256_loadu_ps(top + c - 1));   // br - tl
        const __m256 bT  = _mm256_sub_ps(_mm256_loadu_ps(top + c + 1), _mm256_loadu_ps(bot + c - 1));   // tr - bl
        const __m256 dmT = _mm256_sub_ps(_mm256_loadu_ps(mid + c + 1), _mm256_loadu_ps(mid + c - 1));   // mr - ml
        const __m256 dvT = _mm256_sub_ps(_mm256_loadu_ps(bot + c), _mm256_loadu_ps(top + c));           // bm - tm
        const __m256 gxT = _mm256_fmadd_ps(dmT, two, _mm256_add_ps(aT, bT));   // gx = 2*(mr - ml) + (br - tl) + (tr - bl)
        const __m256 gyT = _mm256_fmadd_ps(dvT, two, _mm256_sub_ps(aT, bT));   // gy = 2*(bm - tm) + (br - tl) - (tr - bl)
        // ---- Tail group: magnitude and direction for pixels c .. c+7 ----
        // Scalar: mag[i] = sqrt(gx*gx + gy*gy)
        const __m256 gxxT = _mm256_mul_ps(gxT, gxT);
        const __m256 gyyT = _mm256_mul_ps(gyT, gyT);
        _mm256_storeu_ps(mag_row + c, _mm256_sqrt_ps(_mm256_add_ps(gxxT, gyyT)));
        // Scalar: angle[i] = direction bin (sobel_classify_angle: the same four tests)
        const __m256 horizT = _mm256_fnmadd_ps(gxxT, tan22sq, gyyT);  // gy^2 - gx^2*tan^2: negative near 0 degrees
        const __m256 vertT  = _mm256_fnmadd_ps(gyyT, tan22sq, gxxT);  // gx^2 - gy^2*tan^2: negative near 90 degrees
        __m256 binT = _mm256_blendv_ps(deg45, deg135, _mm256_xor_ps(gxT, gyT));  // signs differ -> 135, else 45
        binT = _mm256_blendv_ps(binT, deg90, vertT);                               // vertical -> 90
        binT = _mm256_blendv_ps(binT, zero, horizT);                               // horizontal -> 0
        _mm256_storeu_ps(angle_row + c, binT);

        x = c + 8;
    }
    return x;
}
