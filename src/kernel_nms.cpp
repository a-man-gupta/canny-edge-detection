#include "kernel_nms.hpp"
#include <immintrin.h>

// One loop iteration: 2 rows x 64 columns, as four independent groups of 16 int16 pixels.
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

void nms_kernel(const int16_t *top, std::ptrdiff_t ms, const int16_t *gx, const int16_t *gy,
                std::ptrdiff_t gs, int16_t *out, std::ptrdiff_t os, int width) {
    using namespace nms_l1;
    const __m256i one = _mm256_set1_epi16(1);
    const __m256i tan22 = _mm256_set1_epi16(27146);   // tan(22.5 deg) * 65536
    for (int x = 0; x < width; x += 64) {
#pragma GCC unroll 4
        for (int g = 0; g < 4; g++) {
#pragma GCC unroll 2
            for (int r = 0; r < 2; r++) {
                const int c0 = x + 16 * g;
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
                STORE(out + r * os + c0, AND(c, GT(c, limit)));
            }
        }
    }
}
