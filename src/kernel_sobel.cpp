#include "kernel_sobel.hpp"
#include <immintrin.h>

// Exact integer Sobel, L1 magnitude. One loop iteration: SOBEL_ROWS rows x 32 columns,
// as two independent groups of 16 int16 pixels.
namespace sobel_l1 {
static inline __m256i LOAD(const void *p) { return _mm256_loadu_si256((const __m256i *)p); }
static inline void STORE(int16_t *p, __m256i a) { _mm256_storeu_si256((__m256i *)p, a); }
static inline __m256i ADD(__m256i a, __m256i b) { return _mm256_add_epi16(a, b); }
static inline __m256i SUB(__m256i a, __m256i b) { return _mm256_sub_epi16(a, b); }
static inline __m256i ABS(__m256i a) { return _mm256_abs_epi16(a); }
// One input row of 16 pixels (L, C, R at columns 0, 1, 2):
//   D = R - L,   S = L + 2C + R = 2(C + R) - D.
// L and C are each used once, so the compiler folds them into the subtract and the add.
static inline void ROW(const uint16_t *p, __m256i &d, __m256i &s) {
    __m256i right = LOAD(p + 2);
    d = SUB(right, LOAD(p));
    __m256i t = ADD(right, LOAD(p + 1));
    s = SUB(ADD(t, t), d);
}
} // namespace sobel_l1

void sobel_kernel(const uint16_t *input, int16_t *output, int width) {
    using namespace sobel_l1;
    for (const uint16_t *end = input + width; input != end; input += 32, output += 32) {
        __m256i d_mid[2], e_prev[2], s_top[2], s_mid[2];

        // ==================== SETUP: INPUT ROWS 0 AND 1 ====================
#pragma GCC unroll 2
        for (int g = 0; g < 2; g++) {
            __m256i d_top;
            ROW(input + 16 * g, d_top, s_top[g]);
            ROW(input + SOBEL_IN_STRIDE + 16 * g, d_mid[g], s_mid[g]);
            e_prev[g] = ADD(d_top, d_mid[g]);   // E = D_top + D_mid
        }

        // ==================== ONE OUTPUT ROW PER NEW INPUT ROW ====================
#pragma GCC unroll 8
        for (int r = 0; r < SOBEL_ROWS; r++) {
#pragma GCC unroll 2
            for (int g = 0; g < 2; g++) {
                __m256i d, s;
                ROW(input + (r + 2) * SOBEL_IN_STRIDE + 16 * g, d, s);
                __m256i e = ADD(d_mid[g], d);    // E = D_mid + D_bottom
                __m256i gx = ADD(e_prev[g], e);  // Gx = D_top + 2 D_mid + D_bottom
                __m256i gy = SUB(s, s_top[g]);   // Gy = S_bottom - S_top
                int16_t *o = output + r * SOBEL_OUT_STRIDE + 16 * g;
                STORE(o, ADD(ABS(gx), ABS(gy)));  // M = |Gx| + |Gy|
                STORE(o + SOBEL_PLANE, gx);
                STORE(o + 2 * SOBEL_PLANE, gy);
                d_mid[g] = d;
                e_prev[g] = e;
                s_top[g] = s_mid[g];
                s_mid[g] = s;
            }
        }
    }
}
