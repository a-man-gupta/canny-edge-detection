#include "sobel_kernel.hpp"

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <immintrin.h>

// tan(22.5°) = sqrt(2) - 1. tan(67.5°) = 1 / tan(22.5°).
// OpenCV's Canny uses this sector test (its fixed-point TG22) and never calls atan2.
// One rule for every pixel, including zeros and exact boundaries:
//   |gy| < |gx| * tan(22.5°)            -> horizontal, store 0
//   |gx| < |gy| * tan(22.5°)            -> vertical,   store 90
//   otherwise, gx and gy the same sign  -> 45 degrees
//   otherwise                           -> 135 degrees
// Equality is the diagonal. This is not a promise that the bin matches atan2.
static const float kTan22 = static_cast<float>(std::sqrt(2.0) - 1.0);

// Assembly comments around one loop iteration, so scripts/count_sobel_ops.sh can count
// the instructions inside it ("# loop v1 begin 16" ... "# loop end").
// They only exist when compiled with -DSOBEL_MARK_LOOPS; the normal build has none.
#ifdef SOBEL_MARK_LOOPS
#define LOOP_BEGIN(name, pixels) __asm__ __volatile__("# loop " name " begin %c0" :: "i"(pixels) : "memory")
#define LOOP_END() __asm__ __volatile__("# loop end" ::: "memory")
#else
#define LOOP_BEGIN(name, pixels)
#define LOOP_END()
#endif

static float representative(int category) {
    if (category == 1)
        return 45.f;
    if (category == 2)
        return 90.f;
    if (category == 3)
        return 135.f;
    return 0.f;
}

static int direction_category(float gx, float gy) {
    float ax = std::fabs(gx);
    float ay = std::fabs(gy);
    if (ay < ax * kTan22)
        return 0;
    if (ax < ay * kTan22)
        return 2;
    return std::signbit(gx) == std::signbit(gy) ? 1 : 3;
}

float sobel_classify_angle(float gx, float gy) {
    return representative(direction_category(gx, gy));
}

static inline __m256 abs_ps(__m256 v) {
    return _mm256_andnot_ps(_mm256_set1_ps(-0.0f), v);
}

// One group of 8 lanes. Same comparisons as direction_category, no atan2.
static inline void classify_store(__m256 gx, __m256 gy, float* dst) {
    const __m256 tan22 = _mm256_set1_ps(kTan22);
    const __m256 ax = abs_ps(gx);
    const __m256 ay = abs_ps(gy);
    const __m256 ax_t = _mm256_mul_ps(ax, tan22);
    const __m256 ay_t = _mm256_mul_ps(ay, tan22);
    const __m256 horiz = _mm256_cmp_ps(ay, ax_t, _CMP_LT_OQ);
    const __m256 vert = _mm256_cmp_ps(ax, ay_t, _CMP_LT_OQ);
    const __m256 sign_bit = _mm256_set1_ps(-0.0f);
    const __m256 same = _mm256_castsi256_ps(_mm256_cmpeq_epi32(
        _mm256_castps_si256(_mm256_and_ps(gx, sign_bit)),
        _mm256_castps_si256(_mm256_and_ps(gy, sign_bit))));
    __m256 rep = _mm256_blendv_ps(_mm256_set1_ps(135.f), _mm256_set1_ps(45.f), same);
    rep = _mm256_blendv_ps(rep, _mm256_set1_ps(90.f), vert);
    rep = _mm256_blendv_ps(rep, _mm256_set1_ps(0.f), horiz);
    _mm256_storeu_ps(dst, rep);
}

// v1 vector loop for one interior row (moved out of sobel_kernel unchanged).
// Sixteen interior pixels: group A is x..x+7, group B is x+8..x+15.
// x+15 is still left of x_limit, so neither group clamps or reads past column x_limit.
int sobel_row_avx2(const float* top, const float* mid, const float* bot,
                   float* mag_row, float* angle_row, int x_begin, int x_limit) {
    int x = x_begin;
    for (; x + 16 <= x_limit; x += 16) {
        LOOP_BEGIN("v1", 16);
        // Group A starts at column x. Group B starts eight pixels later.
        // Each step issues A and then B so the two chains stay independent.
        __m256 a_tl = _mm256_loadu_ps(top + x - 1);
        __m256 b_tl = _mm256_loadu_ps(top + x + 7);
        __m256 a_tm = _mm256_loadu_ps(top + x);
        __m256 b_tm = _mm256_loadu_ps(top + x + 8);
        __m256 a_tr = _mm256_loadu_ps(top + x + 1);
        __m256 b_tr = _mm256_loadu_ps(top + x + 9);

        // gx = -tl + tr. gy = -tl - 2*tm - tr. 2*tm is tm+tm.
        __m256 a_gx = _mm256_sub_ps(_mm256_setzero_ps(), a_tl);
        __m256 b_gx = _mm256_sub_ps(_mm256_setzero_ps(), b_tl);
        __m256 a_gy = a_gx;
        __m256 b_gy = b_gx;
        a_gx = _mm256_add_ps(a_gx, a_tr);
        b_gx = _mm256_add_ps(b_gx, b_tr);
        a_gy = _mm256_sub_ps(a_gy, _mm256_add_ps(a_tm, a_tm));
        b_gy = _mm256_sub_ps(b_gy, _mm256_add_ps(b_tm, b_tm));
        a_gy = _mm256_sub_ps(a_gy, a_tr);
        b_gy = _mm256_sub_ps(b_gy, b_tr);

        __m256 a_ml = _mm256_loadu_ps(mid + x - 1);
        __m256 b_ml = _mm256_loadu_ps(mid + x + 7);
        __m256 a_mr = _mm256_loadu_ps(mid + x + 1);
        __m256 b_mr = _mm256_loadu_ps(mid + x + 9);
        // Middle row has vertical weight 0, so only gx uses it.
        a_gx = _mm256_sub_ps(a_gx, _mm256_add_ps(a_ml, a_ml));
        b_gx = _mm256_sub_ps(b_gx, _mm256_add_ps(b_ml, b_ml));
        a_gx = _mm256_add_ps(a_gx, _mm256_add_ps(a_mr, a_mr));
        b_gx = _mm256_add_ps(b_gx, _mm256_add_ps(b_mr, b_mr));

        __m256 a_bl = _mm256_loadu_ps(bot + x - 1);
        __m256 b_bl = _mm256_loadu_ps(bot + x + 7);
        __m256 a_bm = _mm256_loadu_ps(bot + x);
        __m256 b_bm = _mm256_loadu_ps(bot + x + 8);
        __m256 a_br = _mm256_loadu_ps(bot + x + 1);
        __m256 b_br = _mm256_loadu_ps(bot + x + 9);
        a_gx = _mm256_sub_ps(a_gx, a_bl);
        b_gx = _mm256_sub_ps(b_gx, b_bl);
        a_gx = _mm256_add_ps(a_gx, a_br);
        b_gx = _mm256_add_ps(b_gx, b_br);
        a_gy = _mm256_add_ps(a_gy, a_bl);
        b_gy = _mm256_add_ps(b_gy, b_bl);
        a_gy = _mm256_add_ps(a_gy, _mm256_add_ps(a_bm, a_bm));
        b_gy = _mm256_add_ps(b_gy, _mm256_add_ps(b_bm, b_bm));
        a_gy = _mm256_add_ps(a_gy, a_br);
        b_gy = _mm256_add_ps(b_gy, b_br);

        // Separate squares, then add, then hardware sqrt. Group B is independent of group A.
        __m256 a_sum = _mm256_add_ps(_mm256_mul_ps(a_gx, a_gx), _mm256_mul_ps(a_gy, a_gy));
        __m256 b_sum = _mm256_add_ps(_mm256_mul_ps(b_gx, b_gx), _mm256_mul_ps(b_gy, b_gy));
        __m256 a_mag = _mm256_sqrt_ps(a_sum);
        __m256 b_mag = _mm256_sqrt_ps(b_sum);
        _mm256_storeu_ps(mag_row + x, a_mag);
        _mm256_storeu_ps(mag_row + x + 8, b_mag);

        // Magnitudes are stored. Park group B so its two registers can be reused
        // by the masks in group A's direction test, then reload B and classify it.
        alignas(32) float b_gx_mem[8], b_gy_mem[8];
        _mm256_store_ps(b_gx_mem, b_gx);
        _mm256_store_ps(b_gy_mem, b_gy);
        classify_store(a_gx, a_gy, angle_row + x);
        classify_store(_mm256_load_ps(b_gx_mem), _mm256_load_ps(b_gy_mem), angle_row + x + 8);
        LOOP_END();
    }
    return x;
}

// ---------------------------------------------------------------------------------
// v2: same results, fewer instructions, more independent work per iteration.
//
// Why the results match v1: the pipeline's blur is rounded to whole numbers 0..255.
// Then gx and gy are whole numbers (|g| <= 1020) and gx*gx + gy*gy < 2^24, so every
// partial sum is exact in float. Adding the terms in a different order gives the
// same bits, so v2 can use a shorter formula than v1.
//
// What changed, per group of 8 pixels (counted from clang -O3 -mavx2 output):
//   v1: 23 instructions on the 2 FP ports (add/sub/mul/cmp/sqrt)
//   v2: 20 (gx, gy as small trees; direction picked with xor + andnot)
// And v2 handles G groups per iteration (default 4 = 32 pixels). The 2 FP ports
// each take 4 cycles per add, so about 8 independent instructions must be ready
// every cycle; 4 groups give enough of them.
// ---------------------------------------------------------------------------------

// gx = (tr - tl) + (br - bl) + 2 (mr - ml);  gy = (bl - tl) + (br - tr) + 2 (bm - tm).
static inline void gradients8(const float* top, const float* mid, const float* bot, int x,
                              __m256& gx, __m256& gy) {
    const __m256 tl = _mm256_loadu_ps(top + x - 1);
    const __m256 tr = _mm256_loadu_ps(top + x + 1);
    const __m256 bl = _mm256_loadu_ps(bot + x - 1);
    const __m256 br = _mm256_loadu_ps(bot + x + 1);
    const __m256 dm = _mm256_sub_ps(_mm256_loadu_ps(mid + x + 1), _mm256_loadu_ps(mid + x - 1));
    const __m256 dv = _mm256_sub_ps(_mm256_loadu_ps(bot + x), _mm256_loadu_ps(top + x));
#ifdef __FMA__
    const __m256 two = _mm256_set1_ps(2.f);
    gx = _mm256_fmadd_ps(two, dm, _mm256_add_ps(_mm256_sub_ps(tr, tl), _mm256_sub_ps(br, bl)));
    gy = _mm256_fmadd_ps(two, dv, _mm256_add_ps(_mm256_sub_ps(bl, tl), _mm256_sub_ps(br, tr)));
#else
    gx = _mm256_add_ps(_mm256_add_ps(_mm256_sub_ps(tr, tl), _mm256_sub_ps(br, bl)), _mm256_add_ps(dm, dm));
    gy = _mm256_add_ps(_mm256_add_ps(_mm256_sub_ps(bl, tl), _mm256_sub_ps(br, tr)), _mm256_add_ps(dv, dv));
#endif
}

// Magnitude, then the same bin as direction_category:
//   rep = 45 if the sign bits of gx and gy match, else 135   (blendv reads the xor sign bit)
//   rep = 90 where |gx| < |gy| tan22
//   rep = 0  where |gy| < |gx| tan22                       (andnot: 0.0f is all-zero bits)
static inline void finish8(__m256 gx, __m256 gy, float* mag, float* angle) {
#ifdef __FMA__
    const __m256 sum = _mm256_fmadd_ps(gx, gx, _mm256_mul_ps(gy, gy));
#else
    const __m256 sum = _mm256_add_ps(_mm256_mul_ps(gx, gx), _mm256_mul_ps(gy, gy));
#endif
    _mm256_storeu_ps(mag, _mm256_sqrt_ps(sum));
    const __m256 sign = _mm256_set1_ps(-0.0f);
    const __m256 tan22 = _mm256_set1_ps(kTan22);
    const __m256 ax = _mm256_andnot_ps(sign, gx);
    const __m256 ay = _mm256_andnot_ps(sign, gy);
    const __m256 horiz = _mm256_cmp_ps(ay, _mm256_mul_ps(ax, tan22), _CMP_LT_OQ);
    const __m256 vert = _mm256_cmp_ps(ax, _mm256_mul_ps(ay, tan22), _CMP_LT_OQ);
    __m256 rep = _mm256_blendv_ps(_mm256_set1_ps(45.f), _mm256_set1_ps(135.f), _mm256_xor_ps(gx, gy));
    rep = _mm256_blendv_ps(rep, _mm256_set1_ps(90.f), vert);
    rep = _mm256_andnot_ps(horiz, rep);
    _mm256_storeu_ps(angle, rep);
}

// G groups of 8 pixels per iteration.
// Step 1: gx, gy for every group (2 registers per group stay live).
// Step 2: finish the groups one at a time (magnitude, sqrt, direction, two stores).
// With G = 4 this needs about 12 of the 16 ymm registers, so nothing spills to memory.
// G is a template parameter so the compiler keeps gx[] and gy[] in registers.
template <int G>
static int row_v2(const float* top, const float* mid, const float* bot,
                  float* mag_row, float* angle_row, int x_begin, int x_limit) {
    int x = x_begin;
    for (; x + 8 * G <= x_limit; x += 8 * G) {
        LOOP_BEGIN("v2", 8 * G);
        __m256 gx[G], gy[G];
        for (int g = 0; g < G; ++g)
            gradients8(top, mid, bot, x + 8 * g, gx[g], gy[g]);
        for (int g = 0; g < G; ++g)
            finish8(gx[g], gy[g], mag_row + x + 8 * g, angle_row + x + 8 * g);
        LOOP_END();
    }
    // Leftover whole groups of 8.
    for (; x + 8 <= x_limit; x += 8) {
        __m256 gx, gy;
        gradients8(top, mid, bot, x, gx, gy);
        finish8(gx, gy, mag_row + x, angle_row + x);
    }
    return x;
}

int sobel_row_avx2_v2(const float* top, const float* mid, const float* bot,
                      float* mag_row, float* angle_row, int x_begin, int x_limit, int groups) {
    switch (groups) {
    case 1: return row_v2<1>(top, mid, bot, mag_row, angle_row, x_begin, x_limit);
    case 2: return row_v2<2>(top, mid, bot, mag_row, angle_row, x_begin, x_limit);
    case 8: return row_v2<8>(top, mid, bot, mag_row, angle_row, x_begin, x_limit);
    default: return row_v2<4>(top, mid, bot, mag_row, angle_row, x_begin, x_limit);
    }
}

// One interior row with the chosen vector loop. Returns the first column it did not write.
static int vector_row(int version, int groups,
                      const float* top, const float* mid, const float* bot,
                      float* mag_row, float* angle_row, int x_begin, int x_limit) {
    if (version == 2)
        return sobel_row_avx2_v2(top, mid, bot, mag_row, angle_row, x_begin, x_limit, groups);
    return sobel_row_avx2(top, mid, bot, mag_row, angle_row, x_begin, x_limit);
}

// Whole image. The border pixels (and the few columns left over at the end of each row)
// need clamped samples, so they use the scalar code. Everything else uses the vector loop.
static void sobel_image(int w, int h, const float* __restrict blur,
                        float* __restrict mag, float* __restrict angle,
                        int version, int groups) {
    auto scalar_at = [&](int y, int x) {
        auto b = [&](int j, int k) {
            int sample_row = std::clamp(y + j, 0, h - 1);
            int sample_col = std::clamp(x + k, 0, w - 1);
            return blur[size_t(sample_row) * w + sample_col];
        };
        // Same association as canny_scalar.cpp.
        float gx = -b(-1, -1) + b(-1, 1)
                 - 2 * b(0, -1) + 2 * b(0, 1)
                 - b(1, -1) + b(1, 1);
        float gy = -b(-1, -1) - 2 * b(-1, 0) - b(-1, 1)
                 + b(1, -1) + 2 * b(1, 0) + b(1, 1);
        size_t i = size_t(y) * w + x;
        mag[i] = std::sqrt(gx * gx + gy * gy);
        angle[i] = sobel_classify_angle(gx, gy);
    };

    for (int y = 0; y < h; ++y) {
        // Top and bottom rows clamp in y, so the whole row stays scalar.
        if (y == 0 || y == h - 1) {
            for (int x = 0; x < w; ++x)
                scalar_at(y, x);
            continue;
        }
        // Left border clamps in x.
        scalar_at(y, 0);
        const float* top = blur + size_t(y - 1) * w;
        const float* mid = blur + size_t(y) * w;
        const float* bot = blur + size_t(y + 1) * w;
        // x_limit = w - 1 keeps every load inside the row (no clamp, no reading past it).
        int x = vector_row(version, groups, top, mid, bot,
                           mag + size_t(y) * w, angle + size_t(y) * w, 1, w - 1);
        // Width tail and the right border. Same classifier, clamped samples.
        for (; x < w; ++x)
            scalar_at(y, x);
    }
}

// Part 2 kernel (v1).
// 1. Read blur with the same clamped border as canny_scalar.cpp.
// 2. Sobel gx, gy with the scalar left-to-right association. 2*sample is sample+sample.
// 3. Magnitude is gx*gx, gy*gy, add, then sqrt. No rsqrt and no FMA.
// 4. Direction is the four Part 3 bins, stored as 0, 45, 90, or 135.
void sobel_kernel(int w, int h,
                  const float* __restrict blur,
                  float* __restrict mag,
                  float* __restrict angle) {
    sobel_image(w, h, blur, mag, angle, 1, 0);
}

// Part 2 kernel (v2). Same borders as v1; the interior uses sobel_row_avx2_v2.
void sobel_kernel_v2(int w, int h,
                     const float* __restrict blur,
                     float* __restrict mag,
                     float* __restrict angle,
                     int groups) {
    sobel_image(w, h, blur, mag, angle, 2, groups);
}
