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

// 32 pixels starting at column x: four groups of 8. An add takes 4 cycles and there
// are 2 FP units, so all four gradients are computed before any group is finished.
// Reads columns x-1 .. x+32, so the caller needs x+32 <= x_limit.
static inline void sobel32(const float* top, const float* mid, const float* bot,
                           float* mag_row, float* angle_row, int x) {
    __m256 gx[4], gy[4];

    // gx = (tr - tl) + (br - bl) + 2*(mr - ml)
    // gy = (bl - tl) + (br - tr) + 2*(bm - tm)
    // t/m/b are the three blur rows. l/r are one column left or right of the center.
    // The corners appear in both, so share them: with a = br - tl and b = tr - bl,
    //   gx = (a + b) + 2*dm      gy = (a - b) + 2*dv
    // That is 10 adds/subs per group instead of 12.
    // 2*d is d+d, not a multiply. Blur values are whole numbers, so this add order
    // still matches the scalar formula bit for bit.
    for (int g = 0; g < 4; ++g) {
        const int c = x + 8 * g;
        const __m256 a = _mm256_sub_ps(_mm256_loadu_ps(bot + c + 1), _mm256_loadu_ps(top + c - 1));
        const __m256 b = _mm256_sub_ps(_mm256_loadu_ps(top + c + 1), _mm256_loadu_ps(bot + c - 1));
        const __m256 dm = _mm256_sub_ps(_mm256_loadu_ps(mid + c + 1), _mm256_loadu_ps(mid + c - 1));
        const __m256 dv = _mm256_sub_ps(_mm256_loadu_ps(bot + c), _mm256_loadu_ps(top + c));
        gx[g] = _mm256_add_ps(_mm256_add_ps(a, b), _mm256_add_ps(dm, dm));
        gy[g] = _mm256_add_ps(_mm256_sub_ps(a, b), _mm256_add_ps(dv, dv));
    }

    // Magnitude, then the direction bin, then both stores.
    for (int g = 0; g < 4; ++g) {
        const int c = x + 8 * g;
        // mag = sqrt(gx*gx + gy*gy). Multiply, multiply, add, sqrt. No FMA.
        const __m256 gx2 = _mm256_mul_ps(gx[g], gx[g]);
        const __m256 gy2 = _mm256_mul_ps(gy[g], gy[g]);
        _mm256_storeu_ps(mag_row + c, _mm256_sqrt_ps(_mm256_add_ps(gx2, gy2)));

        // The two sector tests on the squares. Each lane is all-ones where the test is true.
        const __m256 tan22sq = _mm256_set1_ps(kTan22Sq);
        const __m256 horiz = _mm256_cmp_ps(gy2, _mm256_mul_ps(gx2, tan22sq), _CMP_LT_OQ);
        const __m256 vert = _mm256_cmp_ps(gx2, _mm256_mul_ps(gy2, tan22sq), _CMP_LT_OQ);

        // Diagonal first. gx xor gy has its sign bit set when the signs differ,
        // and blendv looks only at that bit: 135 if they differ, else 45.
        __m256 bin = _mm256_blendv_ps(_mm256_set1_ps(45.f), _mm256_set1_ps(135.f), _mm256_xor_ps(gx[g], gy[g]));
        // Vertical replaces the diagonal.
        bin = _mm256_blendv_ps(bin, _mm256_set1_ps(90.f), vert);
        // Horizontal replaces both. 0.0f is all zero bits, so clearing the lane stores 0.
        bin = _mm256_andnot_ps(horiz, bin);
        _mm256_storeu_ps(angle_row + c, bin);
    }
}

// One interior row.
//
// Main loop: 64 pixels per iteration, i.e. the 32-pixel block unrolled twice by hand.
// Each block finishes its four groups before the next block starts, so at most four
// groups are live and everything stays in the 16 ymm registers (no spills; unrolling
// as eight groups at once spilled). Unrolling halves the loop bookkeeping (pointer
// updates, compare, jump) per pixel.
// After that, one more 32-pixel block if it fits, then leftover groups of 8. If a few
// columns still remain, one more group of 8 ends on the last interior column. It
// overlaps columns already written and stores the same values. The right border is
// not written here.
int sobel_row_avx2(const float* top, const float* mid, const float* bot,
                   float* mag_row, float* angle_row, int x_begin, int x_limit) {
    int x = x_begin;

    for (; x + 64 <= x_limit; x += 64) {
        LOOP_BEGIN(64);
        sobel32(top, mid, bot, mag_row, angle_row, x);        // pixels x    .. x+31
        sobel32(top, mid, bot, mag_row, angle_row, x + 32);   // pixels x+32 .. x+63
        LOOP_END();
    }

    if (x + 32 <= x_limit) {
        sobel32(top, mid, bot, mag_row, angle_row, x);
        x += 32;
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

        // Same gx, gy as one group in sobel32.
        const __m256 a = _mm256_sub_ps(_mm256_loadu_ps(bot + c + 1), _mm256_loadu_ps(top + c - 1));
        const __m256 b = _mm256_sub_ps(_mm256_loadu_ps(top + c + 1), _mm256_loadu_ps(bot + c - 1));
        const __m256 dm = _mm256_sub_ps(_mm256_loadu_ps(mid + c + 1), _mm256_loadu_ps(mid + c - 1));
        const __m256 dv = _mm256_sub_ps(_mm256_loadu_ps(bot + c), _mm256_loadu_ps(top + c));
        const __m256 gx = _mm256_add_ps(_mm256_add_ps(a, b), _mm256_add_ps(dm, dm));
        const __m256 gy = _mm256_add_ps(_mm256_sub_ps(a, b), _mm256_add_ps(dv, dv));

        // Same magnitude and bin as one group in sobel32.
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
