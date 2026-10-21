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

// Part 2 kernel.
// 1. Read blur with the same clamped border as canny_scalar.cpp.
// 2. Sobel gx, gy with the scalar left-to-right association. 2*sample is sample+sample.
// 3. Magnitude is gx*gx, gy*gy, add, then sqrt. No rsqrt and no FMA.
// 4. Direction is the four Part 3 bins, stored as 0, 45, 90, or 135.
void sobel_kernel(int w, int h,
                  const float* __restrict blur,
                  float* __restrict mag,
                  float* __restrict angle) {
   
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

    // One group of 8 lanes. Same comparisons as direction_category, no atan2.
    auto classify_store = [&](__m256 gx, __m256 gy, float* dst) {
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
        float* mag_row = mag + size_t(y) * w;
        float* angle_row = angle + size_t(y) * w;
        int x = 1;
        // Sixteen interior pixels: group A is x..x+7, group B is x+8..x+15.
        // x+15 is still left of the right border, so neither group clamps or reads past the row.
        for (; x + 16 <= w - 1; x += 16) {
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
        }
        // Width tail and the right border. Same classifier, clamped samples.
        for (; x < w; ++x)
            scalar_at(y, x);
    }
}
