// Part 2 Sobel kernel: gradient magnitude and direction bin for one image row.
//
// 8 pixels per ymm register (256-bit). Uses AVX2 + FMA for the math and AVX-512VL/DQ for
// mask registers (k) and 32 ymm registers. It stays on 256-bit registers, so the core keeps
// the AVX2 clock (512-bit zmm code drops to about 2/3 of it on this Xeon).
// Compile with -mavx2 -mfma -mavx512f -mavx512vl -mavx512dq -ffp-contract=off.
//
// Measured on ece017-024 (Xeon Silver 4208), real core cycles, 1026-wide row in L1:
//   1.16-1.18 cycles/pixel. Peak 0.8125 (13 FP-unit instructions per 8 pixels / 2 FP units).
//   The same loop with the direction test as 2 FMAs ran at 1.27-1.30, and the earlier
//   one-stage AVX2 loop with vblendvps at 1.51.
#include "sobel_kernel.hpp"

#include <cmath>
#include <immintrin.h>


// Sector test on squares: gy^2 < gx^2 * tan(22.5)^2 is |gy| < |gx| * tan(22.5) without the
// absolute values (gx*gx and gy*gy are already computed for the magnitude, and are exact
// because blur values are whole numbers). With t = tan(22.5)^2 = 3 - 2*sqrt(2) and
// s = gx^2 + gy^2 (also computed for the magnitude):
//   gy^2 < gx^2 * t   <=>   gy^2 < s * t / (1 + t)
// So one product p = s * c serves both tests (gy^2 < p, gx^2 < p): 1 multiply instead of 2 FMAs.
// Checked for every integer pair |gx|, |gy| <= 1020 (all Sobel values of 0..255 blur):
// the bins are identical to the FMA form fma(-gx^2, t, gy^2) < 0.
static const float kSectorC = static_cast<float>((3.0 - 2.0 * std::sqrt(2.0)) / (4.0 - 2.0 * std::sqrt(2.0)));

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
    float p = (gx2 + gy2) * kSectorC;      // the same rounding as the vector code
    if (gy2 < p)                           // gy^2 < gx^2 * tan^2: horizontal
        return 0.f;
    if (gx2 < p)                           // gx^2 < gy^2 * tan^2: vertical
        return 90.f;
    if (std::signbit(gx) == std::signbit(gy))
        return 45.f;
    return 135.f;
}

// Helpers are pasted into the loop (always_inline), never called.
#define ALWAYS_INLINE static inline __attribute__((always_inline))

// gx and gy for the 8 pixels at columns c .. c+7.
// Scalar: gx = -tl + tr - 2*ml + 2*mr - bl + br
//         gy = -tl - 2*tm - tr + bl + 2*bm + br
// (t/m/b = row above / this row / row below, l/r = one column left / right)
ALWAYS_INLINE void gradients8(const float* top, const float* mid, const float* bot, int c,
                              __m256 two, __m256& gx, __m256& gy) {
    const __m256 a  = _mm256_sub_ps(_mm256_loadu_ps(bot + c + 1), _mm256_loadu_ps(top + c - 1));   // br - tl
    const __m256 b  = _mm256_sub_ps(_mm256_loadu_ps(top + c + 1), _mm256_loadu_ps(bot + c - 1));   // tr - bl
    const __m256 dm = _mm256_sub_ps(_mm256_loadu_ps(mid + c + 1), _mm256_loadu_ps(mid + c - 1));   // mr - ml
    const __m256 dv = _mm256_sub_ps(_mm256_loadu_ps(bot + c), _mm256_loadu_ps(top + c));           // bm - tm
    gx = _mm256_fmadd_ps(dm, two, _mm256_add_ps(a, b));   // gx = 2*(mr - ml) + (br - tl) + (tr - bl)
    gy = _mm256_fmadd_ps(dv, two, _mm256_sub_ps(a, b));   // gy = 2*(bm - tm) + (br - tl) - (tr - bl)
}

// Magnitude and direction for 8 pixels, then both stores.
ALWAYS_INLINE void finish8(__m256 gx, __m256 gy, float* mag, float* angle, __m256 sectorc) {
    // Scalar: mag[i] = sqrt(gx*gx + gy*gy)
    const __m256 gxx = _mm256_mul_ps(gx, gx);
    const __m256 gyy = _mm256_mul_ps(gy, gy);
    const __m256 s = _mm256_add_ps(gxx, gyy);
    _mm256_storeu_ps(mag, _mm256_sqrt_ps(s));

    // Scalar: angle[i] = sobel_classify_angle(gx, gy). Each test gives a mask, one bit per pixel.
    // A compare into a mask register runs on port 5 and a masked move is 1 uop, so ports 0 and 1
    // (the FP units) keep the math. vblendvps would be 2 uops that compete for ports 0 and 1.
    const __m256 zero = _mm256_setzero_ps();
    const __m256 p = _mm256_mul_ps(s, sectorc);
    const __mmask8 horiz = _mm256_cmp_ps_mask(gyy, p, _CMP_LT_OQ);   // gy^2 < s*c
    const __mmask8 vert  = _mm256_cmp_ps_mask(gxx, p, _CMP_LT_OQ);   // gx^2 < s*c
    const __mmask8 differ = _mm256_test_epi32_mask(_mm256_castps_si256(_mm256_xor_ps(gx, gy)),
                                                   _mm256_set1_epi32(0x80000000));                 // sign of gx xor gy

    __m256 bin = _mm256_mask_blend_ps(differ, _mm256_set1_ps(45.f), _mm256_set1_ps(135.f));  // signs differ -> 135, else 45
    bin = _mm256_mask_blend_ps(vert, bin, _mm256_set1_ps(90.f));                              // vertical -> 90
    bin = _mm256_mask_blend_ps(horiz, bin, zero);                                             // horizontal -> 0
    _mm256_storeu_ps(angle, bin);
}

// One interior row, columns x_begin .. x_limit-1. Returns the first column not written.
//
// Why the loop is shaped like this:
//   One group of 8 pixels is one long dependency chain, about 40 cycles:
//       loads -> 4 sub -> add -> FMA -> mul -> add -> sqrt (12) -> store
//                                       add -> mul -> compare -> 3 blends -> store
//   An instruction waiting for its inputs sits in the scheduler (97 entries), and when the
//   scheduler is full the core cannot look further ahead for independent work.
//   So the loop is software-pipelined: it computes the gradients of the NEXT 32 pixels while
//   it finishes the current 32. The finish instructions then find their inputs ready.
//
//   Blocks of 32 pixels = four groups of 8 (A, B, C, D). Two register sets: g (current block)
//   and n (next block), 16 ymm registers. AVX-512VL has 32 ymm registers, so both sets and the
//   temporaries fit with no spills. One iteration does two blocks and the sets swap roles,
//   so there are no register copies at the end of an iteration:
//
//     before the loop:  g = gradients(block 0)
//     iteration:        n = gradients(block 1)   while finishing g (block 0)
//                       g = gradients(block 2)   while finishing n (block 1)
//     after the loop:   one more pipelined block if two are left, then finish g
//
//   Inside each half the groups alternate: gradients of next A, finish of current A,
//   gradients of next B, finish of current B, ...
//
// The last 8..31 pixels: groups of 8, then one group of 8 that ends on the last column
// (it overlaps columns already written and stores the same values). Rows shorter than 8
// are left to the scalar code.
int sobel_row(const float* top, const float* mid, const float* bot,
              float* mag_row, float* angle_row, int x_begin, int x_limit) {
    // Constants, kept in registers for the whole row.
    const __m256 two = _mm256_set1_ps(2.0f);
    const __m256 sectorc = _mm256_set1_ps(kSectorC);

    int x = x_begin;
    if (x + 32 <= x_limit) {
        __m256 gxA, gyA, gxB, gyB, gxC, gyC, gxD, gyD;   // current block
        __m256 nxA, nyA, nxB, nyB, nxC, nyC, nxD, nyD;   // next block
        gradients8(top, mid, bot, x, two, gxA, gyA);
        gradients8(top, mid, bot, x + 8, two, gxB, gyB);
        gradients8(top, mid, bot, x + 16, two, gxC, gyC);
        gradients8(top, mid, bot, x + 24, two, gxD, gyD);

        for (; x + 96 <= x_limit; x += 64) {
            LOOP_BEGIN(64);
            // n = block at x+32, finish g = block at x
            gradients8(top, mid, bot, x + 32, two, nxA, nyA);
            finish8(gxA, gyA, mag_row + x, angle_row + x, sectorc);
            gradients8(top, mid, bot, x + 40, two, nxB, nyB);
            finish8(gxB, gyB, mag_row + x + 8, angle_row + x + 8, sectorc);
            gradients8(top, mid, bot, x + 48, two, nxC, nyC);
            finish8(gxC, gyC, mag_row + x + 16, angle_row + x + 16, sectorc);
            gradients8(top, mid, bot, x + 56, two, nxD, nyD);
            finish8(gxD, gyD, mag_row + x + 24, angle_row + x + 24, sectorc);
            // g = block at x+64, finish n = block at x+32
            gradients8(top, mid, bot, x + 64, two, gxA, gyA);
            finish8(nxA, nyA, mag_row + x + 32, angle_row + x + 32, sectorc);
            gradients8(top, mid, bot, x + 72, two, gxB, gyB);
            finish8(nxB, nyB, mag_row + x + 40, angle_row + x + 40, sectorc);
            gradients8(top, mid, bot, x + 80, two, gxC, gyC);
            finish8(nxC, nyC, mag_row + x + 48, angle_row + x + 48, sectorc);
            gradients8(top, mid, bot, x + 88, two, gxD, gyD);
            finish8(nxD, nyD, mag_row + x + 56, angle_row + x + 56, sectorc);
            LOOP_END();
        }

        // One more pipelined block if two full blocks are left.
        if (x + 64 <= x_limit) {
            gradients8(top, mid, bot, x + 32, two, nxA, nyA);
            finish8(gxA, gyA, mag_row + x, angle_row + x, sectorc);
            gradients8(top, mid, bot, x + 40, two, nxB, nyB);
            finish8(gxB, gyB, mag_row + x + 8, angle_row + x + 8, sectorc);
            gradients8(top, mid, bot, x + 48, two, nxC, nyC);
            finish8(gxC, gyC, mag_row + x + 16, angle_row + x + 16, sectorc);
            gradients8(top, mid, bot, x + 56, two, nxD, nyD);
            finish8(gxD, gyD, mag_row + x + 24, angle_row + x + 24, sectorc);
            gxA = nxA; gyA = nyA; gxB = nxB; gyB = nyB;
            gxC = nxC; gyC = nyC; gxD = nxD; gyD = nyD;
            x += 32;
        }

        // Finish the last loaded block.
        finish8(gxA, gyA, mag_row + x, angle_row + x, sectorc);
        finish8(gxB, gyB, mag_row + x + 8, angle_row + x + 8, sectorc);
        finish8(gxC, gyC, mag_row + x + 16, angle_row + x + 16, sectorc);
        finish8(gxD, gyD, mag_row + x + 24, angle_row + x + 24, sectorc);
        x += 32;
    }

    // Leftover pixels, one group of 8 at a time.
    if (x_limit - x_begin < 8)
        return x;
    while (x < x_limit) {
        const int c = (x + 8 <= x_limit) ? x : x_limit - 8;   // the last group may overlap
        __m256 gx, gy;
        gradients8(top, mid, bot, c, two, gx, gy);
        finish8(gx, gy, mag_row + c, angle_row + c, sectorc);
        x = c + 8;
    }
    return x;
}
