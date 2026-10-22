// Part 2, AVX-512 experiment. Same math as sobel_kernel.cpp (AVX2), 16 pixels per register.
//
// Measured on ece024 (Xeon Silver 4208), see the report:
//   - zmm add/mul: 1 per cycle (ports 0 and 1 work together as one 512-bit unit), so the
//     FP unit does 16 floats per cycle, the same as two ymm units.
//   - zmm compare writes a mask register (k) and runs on port 5, next to the adds.
//   - mask blends (vblendmps) are 1 uop, instead of 2 for the AVX2 vblendvps.
//   - 32 zmm registers instead of 16.
//   - the core clock drops to about 1.7 GHz while zmm FP code runs (2.55 GHz for AVX2).
//
// Compile with -mavx512f -mavx512dq -ffp-contract=off.
#include "sobel_kernel_512.hpp"

#include <cmath>
#include <immintrin.h>

// tan(22.5 degrees)^2 = (sqrt(2) - 1)^2 = 3 - 2*sqrt(2). Same sector test as the AVX2 kernel.
static const float kTan22Sq = static_cast<float>(3.0 - 2.0 * std::sqrt(2.0));

// Markers so the op count can see one iteration. Present only with -DSOBEL_MARK_LOOPS.
#ifdef SOBEL_MARK_LOOPS
#define LOOP_BEGIN(pixels) __asm__ __volatile__("# loop kernel begin %c0" :: "i"(pixels) : "memory")
#define LOOP_END() __asm__ __volatile__("# loop end" ::: "memory")
#else
#define LOOP_BEGIN(pixels)
#define LOOP_END()
#endif

// Helpers are pasted into the loop (always_inline), never called.
#define ALWAYS_INLINE static inline __attribute__((always_inline))

// gx and gy for 16 pixels, centers at columns c .. c+15. `use` marks which lanes to load
// (all 16 in the main loop, fewer for the last few pixels of the row).
//   a = br - tl, b = tr - bl
//   gx = (a + b) + 2*(mr - ml)      gy = (a - b) + 2*(bm - tm)
ALWAYS_INLINE void gradients16(const float* top, const float* mid, const float* bot, int c,
                               __mmask16 use, __m512& gx, __m512& gy) {
    const __m512 a = _mm512_sub_ps(_mm512_maskz_loadu_ps(use, bot + c + 1), _mm512_maskz_loadu_ps(use, top + c - 1));
    const __m512 b = _mm512_sub_ps(_mm512_maskz_loadu_ps(use, top + c + 1), _mm512_maskz_loadu_ps(use, bot + c - 1));
    const __m512 dm = _mm512_sub_ps(_mm512_maskz_loadu_ps(use, mid + c + 1), _mm512_maskz_loadu_ps(use, mid + c - 1));
    const __m512 dv = _mm512_sub_ps(_mm512_maskz_loadu_ps(use, bot + c), _mm512_maskz_loadu_ps(use, top + c));
    gx = _mm512_add_ps(_mm512_add_ps(a, b), _mm512_add_ps(dm, dm));
    gy = _mm512_add_ps(_mm512_sub_ps(a, b), _mm512_add_ps(dv, dv));
}

// Magnitude and direction for 16 pixels, then both stores (only the `use` lanes).
ALWAYS_INLINE void finish16(__m512 gx, __m512 gy, float* mag, float* angle, __mmask16 use) {
    // mag = sqrt(gx*gx + gy*gy). No FMA.
    const __m512 gx2 = _mm512_mul_ps(gx, gx);
    const __m512 gy2 = _mm512_mul_ps(gy, gy);
    _mm512_mask_storeu_ps(mag, use, _mm512_sqrt_ps(_mm512_add_ps(gx2, gy2)));

    // The two sector tests on the squares. Each one gives a 16-bit mask, one bit per pixel.
    const __m512 tan22sq = _mm512_set1_ps(kTan22Sq);
    const __mmask16 horiz = _mm512_cmp_ps_mask(gy2, _mm512_mul_ps(gx2, tan22sq), _CMP_LT_OQ);
    const __mmask16 vert = _mm512_cmp_ps_mask(gx2, _mm512_mul_ps(gy2, tan22sq), _CMP_LT_OQ);
    // Bit set where gx and gy have different signs: test the sign bit of gx xor gy.
    const __mmask16 differ = _mm512_test_epi32_mask(_mm512_castps_si512(_mm512_xor_ps(gx, gy)),
                                                    _mm512_set1_epi32(0x80000000));

    // Diagonal first: 135 where the signs differ, else 45. Then vertical, then horizontal.
    __m512 bin = _mm512_mask_blend_ps(differ, _mm512_set1_ps(45.f), _mm512_set1_ps(135.f));
    bin = _mm512_mask_blend_ps(vert, bin, _mm512_set1_ps(90.f));
    bin = _mm512_mask_blend_ps(horiz, bin, _mm512_setzero_ps());
    _mm512_mask_storeu_ps(angle, use, bin);
}

// 64 pixels starting at column x: four groups of 16. All four gradients first (an add takes
// 4 cycles, so four independent groups keep the unit busy), then finish them.
ALWAYS_INLINE void sobel64(const float* top, const float* mid, const float* bot,
                           float* mag_row, float* angle_row, int x) {
    const __mmask16 all = 0xFFFF;
    __m512 gx[4], gy[4];
    for (int g = 0; g < 4; ++g)
        gradients16(top, mid, bot, x + 16 * g, all, gx[g], gy[g]);
    for (int g = 0; g < 4; ++g)
        finish16(gx[g], gy[g], mag_row + x + 16 * g, angle_row + x + 16 * g, all);
}

// One interior row, columns x_begin .. x_limit-1.
// Main loop: 128 pixels per iteration, the 64-pixel block unrolled twice by hand.
// Then leftover groups of 16, then one masked group for the last 1..15 pixels:
// masked loads and stores never touch memory outside the row.
int sobel_row_avx512(const float* top, const float* mid, const float* bot,
                     float* mag_row, float* angle_row, int x_begin, int x_limit) {
    const __mmask16 all = 0xFFFF;
    int x = x_begin;

    for (; x + 128 <= x_limit; x += 128) {
        LOOP_BEGIN(128);
        sobel64(top, mid, bot, mag_row, angle_row, x);        // pixels x    .. x+63
        sobel64(top, mid, bot, mag_row, angle_row, x + 64);   // pixels x+64 .. x+127
        LOOP_END();
    }

    for (; x + 16 <= x_limit; x += 16) {
        __m512 gx, gy;
        gradients16(top, mid, bot, x, all, gx, gy);
        finish16(gx, gy, mag_row + x, angle_row + x, all);
    }

    if (x < x_limit) {
        const __mmask16 use = (__mmask16)((1u << (x_limit - x)) - 1);
        __m512 gx, gy;
        gradients16(top, mid, bot, x, use, gx, gy);
        finish16(gx, gy, mag_row + x, angle_row + x, use);
        x = x_limit;
    }
    return x;
}
