#include "sobel_kernel.hpp"

#include <cmath>
#include <cstddef>
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
    if (gy2 < gx2 * kTan22Sq)
        return 0.f;
    if (gx2 < gy2 * kTan22Sq)
        return 90.f;
    if (std::signbit(gx) == std::signbit(gy))
        return 45.f;
    return 135.f;
}

// One group of 8. gx = (a + b) + 2*dm, gy = (a - b) + 2*dv, a = br - tl, b = tr - bl.
// Blur values are whole numbers, so this matches the scalar formula bit for bit.
#define SOBEL_GRAD(c, gx, gy)                                                         \
    do {                                                                              \
        const __m256 a_ = _mm256_sub_ps(_mm256_loadu_ps(bot + (c) + 1), _mm256_loadu_ps(top + (c) - 1)); \
        const __m256 b_ = _mm256_sub_ps(_mm256_loadu_ps(top + (c) + 1), _mm256_loadu_ps(bot + (c) - 1)); \
        const __m256 dm_ = _mm256_sub_ps(_mm256_loadu_ps(mid + (c) + 1), _mm256_loadu_ps(mid + (c) - 1)); \
        const __m256 dv_ = _mm256_sub_ps(_mm256_loadu_ps(bot + (c)), _mm256_loadu_ps(top + (c))); \
        gx = _mm256_fmadd_ps(dm_, two, _mm256_add_ps(a_, b_));                        \
        gy = _mm256_fmadd_ps(dv_, two, _mm256_sub_ps(a_, b_));                        \
    } while (0)

// Sector tests on the squares already computed for the sqrt. blendv looks only at
// the sign bit of gx xor gy: 135 if the signs differ, else 45. Vertical replaces
// that, horizontal clears the lane to 0.
#define SOBEL_BIN(c, gx, gy, gx2, gy2)                                                \
    do {                                                                              \
        const __m256 horiz_ = _mm256_cmp_ps(gy2, _mm256_mul_ps(gx2, tan22sq), _CMP_LT_OQ); \
        const __m256 vert_ = _mm256_cmp_ps(gx2, _mm256_mul_ps(gy2, tan22sq), _CMP_LT_OQ); \
        __m256 bin_ = _mm256_blendv_ps(bin45, bin135, _mm256_xor_ps(gx, gy));         \
        bin_ = _mm256_blendv_ps(bin_, bin90, vert_);                                  \
        bin_ = _mm256_andnot_ps(horiz_, bin_);                                        \
        _mm256_storeu_ps(angle_row + (c), bin_);                                      \
    } while (0)

// 24 pixels starting at column x, unrolled to three groups. Four groups did not fit:
// two live sqrts plus four gx/gy plus the squares is more than 16 ymm registers, and
// gcc spilled the sqrt results. Three groups leave a register for the bin temps.
// Both sqrts of the first pair are issued before either bin. The third sqrt is issued
// before its own bin. Reads columns x-1 .. x+24, so the caller needs x+24 <= x_limit.
static inline void sobel24(const float* top, const float* mid, const float* bot,
                           float* mag_row, float* angle_row, int x) {
    const __m256 two = _mm256_set1_ps(2.0f);
    const __m256 tan22sq = _mm256_set1_ps(kTan22Sq);
    const __m256 bin45 = _mm256_set1_ps(45.f);
    const __m256 bin90 = _mm256_set1_ps(90.f);
    const __m256 bin135 = _mm256_set1_ps(135.f);

    __m256 gx0, gy0, gx1, gy1, gx2, gy2;
    SOBEL_GRAD(x, gx0, gy0);
    SOBEL_GRAD(x + 8, gx1, gy1);
    SOBEL_GRAD(x + 16, gx2, gy2);

    // mag = sqrt(gx*gx + gy*gy). No FMA. Both sqrts, then both bins.
    const __m256 gx2_0 = _mm256_mul_ps(gx0, gx0);
    const __m256 gy2_0 = _mm256_mul_ps(gy0, gy0);
    const __m256 mag0 = _mm256_sqrt_ps(_mm256_add_ps(gx2_0, gy2_0));
    const __m256 gx2_1 = _mm256_mul_ps(gx1, gx1);
    const __m256 gy2_1 = _mm256_mul_ps(gy1, gy1);
    const __m256 mag1 = _mm256_sqrt_ps(_mm256_add_ps(gx2_1, gy2_1));
    SOBEL_BIN(x, gx0, gy0, gx2_0, gy2_0);
    SOBEL_BIN(x + 8, gx1, gy1, gx2_1, gy2_1);
    _mm256_storeu_ps(mag_row + x, mag0);
    _mm256_storeu_ps(mag_row + x + 8, mag1);

    const __m256 gx2_2 = _mm256_mul_ps(gx2, gx2);
    const __m256 gy2_2 = _mm256_mul_ps(gy2, gy2);
    const __m256 mag2 = _mm256_sqrt_ps(_mm256_add_ps(gx2_2, gy2_2));
    SOBEL_BIN(x + 16, gx2, gy2, gx2_2, gy2_2);
    _mm256_storeu_ps(mag_row + x + 16, mag2);
}

#undef SOBEL_GRAD
#undef SOBEL_BIN

// One interior row.
//
// Main loop: 48 pixels per iteration, the 24-pixel block twice. Three groups is the
// most that fits in 16 ymm registers once two sqrts are in flight. Unrolling halves
// the loop bookkeeping (pointer
// updates, compare, jump) per pixel.
// After that, one more 24-pixel block if it fits, then leftover groups of 8. If a few
// columns still remain, one more group of 8 ends on the last interior column. It
// overlaps columns already written and stores the same values. The right border is
// not written here.
int sobel_row_avx2(const float* top, const float* mid, const float* bot,
                   float* mag_row, float* angle_row, int x_begin, int x_limit) {
    int x = x_begin;

    for (; x + 48 <= x_limit; x += 48) {
        LOOP_BEGIN(48);
        sobel24(top, mid, bot, mag_row, angle_row, x);        // pixels x    .. x+23
        sobel24(top, mid, bot, mag_row, angle_row, x + 24);   // pixels x+24 .. x+47
        LOOP_END();
    }

    if (x + 24 <= x_limit) {
        sobel24(top, mid, bot, mag_row, angle_row, x);
        x += 24;
    }

    // Leftover whole groups of 8, then one overlapped group if a short tail remains.
    for (;;) {
        int c;
        if (x + 8 <= x_limit) {
            c = x;
            x += 8;
        } else if (x < x_limit && x_limit - 8 >= x_begin) {
            c = x_limit - 8;
            x = x_limit;
        } else {
            break;
        }

        // Same gx, gy as one group in sobel24.
        const __m256 a = _mm256_sub_ps(_mm256_loadu_ps(bot + c + 1), _mm256_loadu_ps(top + c - 1));
        const __m256 b = _mm256_sub_ps(_mm256_loadu_ps(top + c + 1), _mm256_loadu_ps(bot + c - 1));
        const __m256 dm = _mm256_sub_ps(_mm256_loadu_ps(mid + c + 1), _mm256_loadu_ps(mid + c - 1));
        const __m256 dv = _mm256_sub_ps(_mm256_loadu_ps(bot + c), _mm256_loadu_ps(top + c));
        const __m256 gx = _mm256_fmadd_ps(dm, _mm256_set1_ps(2.0f), _mm256_add_ps(a, b));
        const __m256 gy = _mm256_fmadd_ps(dv, _mm256_set1_ps(2.0f), _mm256_sub_ps(a, b));

        // Same magnitude and bin as one group in sobel24.
        const __m256 gx2 = _mm256_mul_ps(gx, gx);
        const __m256 gy2 = _mm256_mul_ps(gy, gy);
        _mm256_storeu_ps(mag_row + c, _mm256_sqrt_ps(_mm256_add_ps(gx2, gy2)));
        const __m256 tan22sq = _mm256_set1_ps(kTan22Sq);
        const __m256 horiz = _mm256_cmp_ps(gy2, _mm256_mul_ps(gx2, tan22sq), _CMP_LT_OQ);
        const __m256 vert = _mm256_cmp_ps(gx2, _mm256_mul_ps(gy2, tan22sq), _CMP_LT_OQ);
        __m256 bin = _mm256_blendv_ps(_mm256_set1_ps(45.f), _mm256_set1_ps(135.f), _mm256_xor_ps(gx, gy));
        bin = _mm256_blendv_ps(bin, _mm256_set1_ps(90.f), vert);
        bin = _mm256_andnot_ps(horiz, bin);
        _mm256_storeu_ps(angle_row + c, bin);
    }
    return x;
}

// One blur sample. A coordinate outside the image is clamped to the edge.
static float sample(const float* blur, int w, int h, int y, int x) {
    if (y < 0)
        y = 0;
    if (y >= h)
        y = h - 1;
    if (x < 0)
        x = 0;
    if (x >= w)
        x = w - 1;
    return blur[size_t(y) * w + x];
}

// One border pixel. gx and gy are written in the same order as canny_scalar.cpp.
static void scalar_at(const float* blur, int w, int h, int y, int x,
                      float* mag, float* angle) {
    float gx = -sample(blur, w, h, y - 1, x - 1) + sample(blur, w, h, y - 1, x + 1)
             - 2 * sample(blur, w, h, y, x - 1) + 2 * sample(blur, w, h, y, x + 1)
             - sample(blur, w, h, y + 1, x - 1) + sample(blur, w, h, y + 1, x + 1);
    float gy = -sample(blur, w, h, y - 1, x - 1) - 2 * sample(blur, w, h, y - 1, x) - sample(blur, w, h, y - 1, x + 1)
             + sample(blur, w, h, y + 1, x - 1) + 2 * sample(blur, w, h, y + 1, x) + sample(blur, w, h, y + 1, x + 1);
    size_t i = size_t(y) * w + x;
    mag[i] = std::sqrt(gx * gx + gy * gy);
    angle[i] = sobel_classify_angle(gx, gy);
}

// Whole image. Top and bottom rows clamp in y, so they stay scalar.
// Left and right borders clamp in x, so they stay scalar. The interior of each
// other row is sobel_row_avx2.
void sobel_kernel(int w, int h,
                  const float* __restrict blur,
                  float* __restrict mag,
                  float* __restrict angle) {
    for (int y = 0; y < h; ++y) {
        if (y == 0 || y == h - 1) {
            for (int x = 0; x < w; ++x)
                scalar_at(blur, w, h, y, x, mag, angle);
            continue;
        }

        scalar_at(blur, w, h, y, 0, mag, angle);
        const float* top = blur + size_t(y - 1) * w;
        const float* mid = blur + size_t(y) * w;
        const float* bot = blur + size_t(y + 1) * w;
        int x = sobel_row_avx2(top, mid, bot, mag + size_t(y) * w, angle + size_t(y) * w, 1, w - 1);
        for (; x < w; ++x)
            scalar_at(blur, w, h, y, x, mag, angle);
    }
}
