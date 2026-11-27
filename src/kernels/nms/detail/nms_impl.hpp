#pragma once
// Fused non-maximum suppression and double threshold (sizes and layout in kernel_nms.hpp).
// One x-chunk is 64 columns: four groups of 16 int16 lanes, two of which pack into one store.
// Per 16 pixels: find the direction with masks, build one threshold per direction straight
// from memory, pick one threshold with three blends, then compare once.
// `rows` is the number of label rows. Drivers use 2 and 10; the tiled pipeline uses the
// Sobel strip interior (SOBEL_ROWS - 2) so each column chunk is classified once.
#include <cstddef>
#include <cstdint>
#include <immintrin.h>

namespace nms_l1 {
static inline __m256i LOAD(const int16_t *p) { return _mm256_loadu_si256((const __m256i *)p); }
static inline void STORE(int16_t *p, __m256i a) { _mm256_storeu_si256((__m256i *)p, a); }
static inline __m256i ADD(__m256i a, __m256i b) { return _mm256_add_epi16(a, b); }
static inline __m256i SUB(__m256i a, __m256i b) { return _mm256_sub_epi16(a, b); }
static inline __m256i ABS(__m256i a) { return _mm256_abs_epi16(a); }
static inline __m256i MAX(__m256i a, __m256i b) { return _mm256_max_epi16(a, b); }
static inline __m256i GT(__m256i a, __m256i b) { return _mm256_cmpgt_epi16(a, b); }
static inline __m256i AND(__m256i a, __m256i b) { return _mm256_and_si256(a, b); }
static inline __m256i XOR(__m256i a, __m256i b) { return _mm256_xor_si256(a, b); }
static inline __m256i MUL_HIGH(__m256i a, __m256i b) { return _mm256_mulhi_epu16(a, b); }
static inline __m256i SELECT(__m256i mask, __m256i yes, __m256i no) {
    return _mm256_blendv_epi8(no, yes, mask);
}
// keep = c > first AND c >= second  <=>  c > max(first, second - 1)   (integers)
static inline __m256i THRESHOLD(const int16_t *first, const int16_t *second, __m256i one) {
    return MAX(LOAD(first), SUB(LOAD(second), one));
}
} // namespace nms_l1

template<bool classify, bool ordered = false, int rows = 2, class Out>
static inline void nms_impl(const int16_t *top, std::ptrdiff_t ms, const int16_t *gx, const int16_t *gy,
                std::ptrdiff_t gs, Out *out, std::ptrdiff_t os, int width, [[maybe_unused]] int low, [[maybe_unused]] int high) {
    using namespace nms_l1;
    const __m256i one = _mm256_set1_epi16(1);
    const __m256i tan22 = _mm256_set1_epi16(27146);   // tan(22.5 deg) * 65536
    [[maybe_unused]] const __m256i lowv = _mm256_set1_epi16(static_cast<short>(low));
    [[maybe_unused]] const __m256i highv = _mm256_set1_epi16(static_cast<short>(high));
    for (int x = 0; x < width; x += 64) {
        // Unroll pairs of rows only. Fully expanding a 10-row strip spills.
#pragma GCC unroll 2
        for (int r=0; r<rows; ++r) {
#pragma GCC unroll 2
            for (int pair=0; pair<2; ++pair) {
                [[maybe_unused]] __m256i labels[2];
#pragma GCC unroll 2
                for (int j=0; j<2; ++j) {
                    const int c0 = x + 32*pair + 16*j;
                    const int16_t *up = top + r * ms + c0, *mid = up + ms, *down = mid + ms;

                    // ==================== DIRECTION ====================
                    __m256i dx = LOAD(gx + r * gs + c0), dy = LOAD(gy + r * gs + c0);
                    __m256i ax = ABS(dx), ay = ABS(dy);
                    __m256i t = MUL_HIGH(ax, tan22);                // |Gx| * tan 22.5
                    __m256i not_h = GT(ay, t);                       // not horizontal
                    __m256i vert = GT(ay, ADD(t, ADD(ax, ax)));      // vertical
                    __m256i sign = _mm256_srai_epi16(XOR(dx, dy), 15);   // Gx, Gy opposite signs

                    // ==================== ONE THRESHOLD PER DIRECTION ====================
                    __m256i t_h = THRESHOLD(mid - 1, mid + 1, one);   // left, right
                    __m256i t_v = THRESHOLD(up, down, one);           // top, bottom
                    __m256i t_d1 = THRESHOLD(up - 1, down + 1, one);  // top-left, bottom-right
                    __m256i t_d2 = THRESHOLD(up + 1, down - 1, one);  // top-right, bottom-left

                    // ==================== SELECT, COMPARE ONCE ====================
                    __m256i limit = SELECT(sign, t_d2, t_d1);
                    limit = SELECT(not_h, limit, t_h);
                    limit = SELECT(vert, t_v, limit);
                    __m256i c = LOAD(mid);
                    if constexpr (classify) {
                        __m256i classes;
                        if constexpr (ordered) {
                            // A surviving lane is 1 for weak or 2 for strong.
                            classes = AND(GT(c, MAX(limit, lowv)), SUB(one, GT(c, highv)));
                        } else {
                            __m256i kept = AND(c, GT(c, limit));
                            classes = SUB(_mm256_setzero_si256(), ADD(GT(kept, lowv), GT(kept, highv)));
                        }
                        labels[j] = classes;
                    } else {
                        STORE(out + r * os + c0, AND(c, GT(c, limit)));
                    }
                }
                if constexpr (classify) {
                    __m256i packed = _mm256_packus_epi16(labels[0],labels[1]);
                    packed = _mm256_permute4x64_epi64(packed,0xd8);
                    _mm256_storeu_si256((__m256i*)(out+r*os+x+32*pair),packed);
                }
            }
        }
    }
}

// Same contract as nms_labels, for a compile-time row count. Ordered thresholds when they fit in int16.
template<int Rows>
static inline void nms_labels_rows(const int16_t *top, std::ptrdiff_t ms, const int16_t *gx, const int16_t *gy,
                                   std::ptrdiff_t gs, uint8_t *out, std::ptrdiff_t os, int width, int low, int high) {
    if (low >= 0 && high >= low && high <= 32767)
        nms_impl<true, true, Rows>(top, ms, gx, gy, gs, out, os, width, low, high);
    else
        nms_impl<true, false, Rows>(top, ms, gx, gy, gs, out, os, width, low, high);
}
