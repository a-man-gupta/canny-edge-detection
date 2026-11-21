// Part 2 Sobel kernel, AVX2 integer (int16 pixels, 16 per ymm register).
//
// Each group of 16 pixels goes through four steps:
//   1. load_and_subtract: 8 neighbor loads and the 4 shared differences
//   2. combine:           gx and gy from the differences
//   3. store_magnitude:   gx*gx + gy*gy (stored) and the first half of the direction test
//   4. finish_direction:  the 0 / 45 / 90 / 135 degree bin (stored)
// The loop is software pipelined like the schedule in docs/theoretical_peak.xlsx: while group g
// is in steps 3 and 4, group g+1 already does steps 1 and 2, so its loads (7 cycles) are done
// by the time the vector ALU needs them.
#include "sobel_kernel.hpp"
#include <algorithm>
#include <cstddef>
#include <cstdlib>
#include <immintrin.h>
#include <vector>

#define INLINE static inline __attribute__((always_inline))

INLINE __m256i load16(const int16_t *pixels) {
    return _mm256_loadu_si256((const __m256i *)pixels);
}
static inline int16_t direction(int gx, int gy) {
    int x = std::abs(gx);
    int y = std::abs(gy) * 32768;
    if (y < x * 13573)
        return 0;
    if (y > x * 13573 + x * 65536)
        return 90;
    return (gx < 0) != (gy < 0) ? 135 : 45;
}

// Step 1: the four neighbor differences of 16 pixels starting at x.
struct Differences {
    __m256i diagonal_down;  // bottom-right - top-left
    __m256i diagonal_up;    // top-right - bottom-left
    __m256i horizontal;     // right - left
    __m256i vertical;       // bottom - top
};
INLINE Differences load_and_subtract(const int16_t *top, const int16_t *middle, const int16_t *bottom,
                                     int x) {
    // One statement per load so the compiler keeps this order (left load, then right load).
    Differences d;
    d.diagonal_down = load16(bottom + x + 1);
    d.diagonal_down = _mm256_sub_epi16(d.diagonal_down, load16(top + x - 1));
    d.diagonal_up = load16(top + x + 1);
    d.diagonal_up = _mm256_sub_epi16(d.diagonal_up, load16(bottom + x - 1));
    d.horizontal = load16(middle + x + 1);
    d.horizontal = _mm256_sub_epi16(d.horizontal, load16(middle + x - 1));
    d.vertical = load16(bottom + x);
    d.vertical = _mm256_sub_epi16(d.vertical, load16(top + x));
    return d;
}

// Step 2: gx = (down + up) + 2*horizontal, gy = (down - up) + 2*vertical.
struct Gradients {
    __m256i gx;
    __m256i gy;
};
INLINE Gradients combine(Differences d) {
    Gradients g;
    g.gx = _mm256_add_epi16(d.diagonal_down, d.diagonal_up);
    g.gx = _mm256_add_epi16(g.gx, _mm256_add_epi16(d.horizontal, d.horizontal));
    g.gy = _mm256_sub_epi16(d.diagonal_down, d.diagonal_up);
    g.gy = _mm256_add_epi16(g.gy, _mm256_add_epi16(d.vertical, d.vertical));
    return g;
}

// Step 3: store gx*gx + gy*gy (int32) and start the direction test.
struct DirectionTest {
    __m256i abs_low, abs_high;    // (|gx|, |gy|) pairs
    __m256i test_low, test_high;  // 13573*|gx| - 32768*|gy|
    __m256i opposite_signs;       // all ones where gx and gy have opposite signs
};
INLINE DirectionTest store_magnitude(Gradients g, int32_t *magnitude_sq, int x) {
    // Packed signed coefficients: 13573 for |gx|, -32768 for |gy|.
    const __m256i direction_coefficients = _mm256_set1_epi32(int(0x80003505u));
    // Pair each pixel: gx0, gy0, gx1, gy1, ... within 128-bit halves.
    __m256i pairs_low = _mm256_unpacklo_epi16(g.gx, g.gy);
    __m256i pairs_high = _mm256_unpackhi_epi16(g.gx, g.gy);
    __m256i magnitude_low = _mm256_madd_epi16(pairs_low, pairs_low);
    __m256i magnitude_high = _mm256_madd_epi16(pairs_high, pairs_high);
    // Put the 128-bit halves back in pixel order and store.
    _mm256_storeu_si256((__m256i *)(magnitude_sq + x),
                        _mm256_permute2x128_si256(magnitude_low, magnitude_high, 0x20));
    _mm256_storeu_si256((__m256i *)(magnitude_sq + x + 8),
                        _mm256_permute2x128_si256(magnitude_low, magnitude_high, 0x31));
    DirectionTest t;
    t.abs_low = _mm256_abs_epi16(pairs_low);
    t.abs_high = _mm256_abs_epi16(pairs_high);
    t.test_low = _mm256_madd_epi16(t.abs_low, direction_coefficients);
    t.test_high = _mm256_madd_epi16(t.abs_high, direction_coefficients);
    t.opposite_signs = _mm256_srai_epi16(_mm256_xor_si256(g.gx, g.gy), 15);
    return t;
}

// Step 4: pick 0, 45, 90 or 135 degrees and store.
INLINE void finish_direction(DirectionTest t, int16_t *direction_bins, int x) {
    const __m256i zero = _mm256_setzero_si256();
    const __m256i degrees45 = _mm256_set1_epi16(45);
    const __m256i degrees90 = _mm256_set1_epi16(90);
    // Horizontal: 32768*|gy| < 13573*|gx|.
    __m256i horizontal = _mm256_packs_epi32(_mm256_cmpgt_epi32(t.test_low, zero),
                                            _mm256_cmpgt_epi32(t.test_high, zero));
    // Vertical: 32768*|gy| > (13573 + 65536)*|gx|.
    __m256i vertical_low = _mm256_add_epi32(t.test_low, _mm256_slli_epi32(t.abs_low, 16));
    __m256i vertical_high = _mm256_add_epi32(t.test_high, _mm256_slli_epi32(t.abs_high, 16));
    __m256i vertical = _mm256_packs_epi32(_mm256_cmpgt_epi32(zero, vertical_low),
                                          _mm256_cmpgt_epi32(zero, vertical_high));
    // Diagonal: 45 when gx and gy have the same sign, 45 + 90 when not.
    __m256i bins = _mm256_add_epi16(degrees45, _mm256_and_si256(t.opposite_signs, degrees90));
    bins = _mm256_blendv_epi8(bins, degrees90, vertical);
    bins = _mm256_andnot_si256(horizontal, bins);
    _mm256_storeu_si256((__m256i *)(direction_bins + x), bins);
}

// One pipelined step: finish the group at x (its gradients are `current`) and start the group at
// x + 16. Returns the new group's gradients.
INLINE Gradients step(const int16_t *top, const int16_t *middle, const int16_t *bottom, Gradients current,
                      int32_t *magnitude_sq, int16_t *direction_bins, int x) {
    Differences next = load_and_subtract(top, middle, bottom, x + 16);  // next group: loads first
    DirectionTest test = store_magnitude(current, magnitude_sq, x);     // this group: multiplies
    Gradients next_gradients = combine(next);                           // next group: adds
    finish_direction(test, direction_bins, x);                          // this group: compares
    return next_gradients;
}

__attribute__((noinline)) void sobel_i16_row(const int16_t *top, const int16_t *middle, const int16_t *bottom,
                                             int32_t *magnitude_sq, int16_t *direction_bins, int begin,
                                             int end) {
    int x = begin;
    if (x + 16 <= end) {
        Gradients current = combine(load_and_subtract(top, middle, bottom, x));
        // Main loop: 4 groups (64 pixels) per iteration, written out so there is no inner loop.
        for (; x + 80 <= end; x += 64) {
            current = step(top, middle, bottom, current, magnitude_sq, direction_bins, x);
            current = step(top, middle, bottom, current, magnitude_sq, direction_bins, x + 16);
            current = step(top, middle, bottom, current, magnitude_sq, direction_bins, x + 32);
            current = step(top, middle, bottom, current, magnitude_sq, direction_bins, x + 48);
        }
        // Leftover groups, one at a time; the last group has no next group to start.
        for (; x + 32 <= end; x += 16)
            current = step(top, middle, bottom, current, magnitude_sq, direction_bins, x);
        finish_direction(store_magnitude(current, magnitude_sq, x), direction_bins, x);
        x += 16;
    }
    for (; x < end; ++x) {
        int gx =
            -top[x - 1] + top[x + 1] - 2 * middle[x - 1] + 2 * middle[x + 1] - bottom[x - 1] + bottom[x + 1];
        int gy = -top[x - 1] - 2 * top[x] - top[x + 1] + bottom[x - 1] + 2 * bottom[x] + bottom[x + 1];
        magnitude_sq[x] = gx * gx + gy * gy;
        direction_bins[x] = direction(gx, gy);
    }
}

uint8_t sobel_bin(int gx, int gy) {
    return uint8_t(direction(gx, gy));
}

// One pixel with the edge repeated outside the image (OpenCV's BORDER_REPLICATE).
// Inlined into sobel_kernel, so the border path is not a separate call.
static inline __attribute__((always_inline)) void scalar_at(const uint8_t *blur, int w, int h, int y, int x,
                                                            int32_t *mag_sq, uint8_t *bin) {
    auto s = [&](int j, int k) {
        int yy = y + j, xx = x + k;
        yy = yy < 0 ? 0 : (yy >= h ? h - 1 : yy);
        xx = xx < 0 ? 0 : (xx >= w ? w - 1 : xx);
        return (int)blur[(size_t)yy * w + xx];
    };
    const int gx = -s(-1, -1) + s(-1, 1) - 2 * s(0, -1) + 2 * s(0, 1) - s(1, -1) + s(1, 1);
    const int gy = -s(-1, -1) - 2 * s(-1, 0) - s(-1, 1) + s(1, -1) + 2 * s(1, 0) + s(1, 1);
    const size_t i = (size_t)y * w + x;
    mag_sq[i] = gx * gx + gy * gy;
    bin[i] = sobel_bin(gx, gy);
}

void sobel_kernel(int w, int h, const uint8_t *blur, int32_t *mag_sq, uint8_t *bin) {
    if (w <= 0 || h <= 0)
        return;
    // Right-pad every row out to a multiple of 64 interior columns, repeating the last pixel
    // (the same value BORDER_REPLICATE would return). The vector loop then writes
    // columns 1 .. n_pad and has nothing left over. Columns past w-2 are discarded; the real
    // border pixels stay on the scalar path. A 3x3 at columns 1 .. w-2 never reads the pad.
    const int n = w > 2 ? w - 2 : 0;
    const int n_pad = (n + 63) & ~63;
    const int stride = n_pad + 2; // last load of the final group stops on index n_pad + 1
    std::vector<int16_t> pad(size_t(stride) * h);
    std::vector<int32_t> mag_pad(size_t(stride) * h);
    std::vector<int16_t> bin_pad(size_t(stride) * h);
    for (int y = 0; y < h; ++y) {
        int16_t *dst = pad.data() + size_t(y) * stride;
        const uint8_t *src = blur + size_t(y) * w;
        std::copy(src, src + w, dst);
        std::fill(dst + w, dst + stride, src[w - 1]);
    }

    for (int y = 0; y < h; ++y) {
        if (y == 0 || y == h - 1 || n_pad == 0) {
            for (int x = 0; x < w; ++x)
                scalar_at(blur, w, h, y, x, mag_sq, bin);
            continue;
        }
        scalar_at(blur, w, h, y, 0, mag_sq, bin);
        scalar_at(blur, w, h, y, w - 1, mag_sq, bin);
        const size_t prow = size_t(y) * stride;
        sobel_i16_row(pad.data() + prow - stride, pad.data() + prow, pad.data() + prow + stride,
                      mag_pad.data() + prow, bin_pad.data() + prow, 1, n_pad + 1);
        const size_t row = size_t(y) * w;
        for (int x = 1; x < w - 1; ++x) {
            mag_sq[row + x] = mag_pad[prow + x];
            bin[row + x] = bin_pad[prow + x];
        }
    }
}
