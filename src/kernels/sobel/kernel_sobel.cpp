#include "kernel_sobel.hpp"
#include <immintrin.h>

// Exact integer Sobel, L1 magnitude (sizes and layout in kernel_sobel.hpp).
//
// Each input row is reduced once:   D = R - L,   S = L + 2C + R = 2(C + R) - D.
// Each output row then needs only:  E = D_mid + D_bot,   Gx = E_prev + E = D_top + 2 D_mid + D_bot,
//                                   Gy = S_bot - S_top,  M = |Gx| + |Gy|.
// D_mid, E_prev, S_top and S_mid stay in registers and slide down one row per output row.
#define LOAD(p, dst)     ((dst) = _mm256_loadu_si256(reinterpret_cast<const __m256i*>(p)))
#define STORE(p, value)  _mm256_storeu_si256(reinterpret_cast<__m256i*>(p), (value))
#define ADD(a, b, dst)   ((dst) = _mm256_add_epi16((a), (b)))
#define SUB(a, b, dst)   ((dst) = _mm256_sub_epi16((a), (b)))
#define ABS(a, dst)      ((dst) = _mm256_abs_epi16(a))

// One input row of 16 pixels: L, C, R are the row at column offsets 0, 1, 2.
#define ROW(p, d, s) do { \
    const uint16_t* row_ptr = (p); \
    __m256i left, center, right, twice; \
    LOAD(row_ptr + 2, right); \
    LOAD(row_ptr, left); \
    SUB(right, left, d); \
    LOAD(row_ptr + 1, center); \
    ADD(right, center, twice); \
    ADD(twice, twice, twice); \
    SUB(twice, d, s); \
} while (0)

void sobel_kernel(const uint16_t *input, int16_t *output, int width) {
    constexpr int groups = 2;
    for (const uint16_t *end = input + width; input != end; input += 16*groups, output += 16*groups) {
        __m256i d_mid[groups], e_prev[groups], s_top[groups], s_mid[groups];

        // ==================== SETUP: INPUT ROWS 0 AND 1 ====================
#pragma GCC unroll 2
        for (int g = 0; g < groups; g++) {
            __m256i d_top;
            ROW(input + 16 * g, d_top, s_top[g]);
            ROW(input + SOBEL_IN_STRIDE + 16 * g, d_mid[g], s_mid[g]);
            ADD(d_top, d_mid[g], e_prev[g]);   // E = D_top + D_mid
        }

        // Reduce the next input row while finishing the current gradients.
        __m256i next_d[groups], next_s[groups];
#pragma GCC unroll 2
        for (int g = 0; g < groups; ++g)
            ROW(input + 2 * SOBEL_IN_STRIDE + 16 * g, next_d[g], next_s[g]);

        // ==================== ONE OUTPUT ROW PER NEW INPUT ROW ====================
#if SOBEL_ROWS == 10
#pragma GCC unroll 10
#else
#pragma GCC unroll 8
#endif
        for (int r = 0; r < SOBEL_ROWS; r++) {
#pragma GCC unroll 2
            for (int g = 0; g < groups; g++) {
                __m256i d = next_d[g], s = next_s[g];
                if (r + 1 < SOBEL_ROWS)
                    ROW(input + (r + 3) * SOBEL_IN_STRIDE + 16 * g, next_d[g], next_s[g]);
                __m256i e, gx, gy, ax, ay, magnitude;
                ADD(d_mid[g], d, e);          // E  = D_mid + D_bot
                ADD(e_prev[g], e, gx);        // Gx = D_top + 2 D_mid + D_bot
                SUB(s, s_top[g], gy);         // Gy = S_bot - S_top
                ABS(gx, ax);
                ABS(gy, ay);
                ADD(ax, ay, magnitude);       // M  = |Gx| + |Gy|
                int16_t *o = output + r * SOBEL_OUT_STRIDE + 16 * g;
                STORE(o, magnitude);
                STORE(o + SOBEL_PLANE, gx);
                STORE(o + 2 * SOBEL_PLANE, gy);
                // Slide the window down one row.
                d_mid[g] = d;
                e_prev[g] = e;
                s_top[g] = s_mid[g];
                s_mid[g] = s;
            }
        }
    }
}

#undef ROW
#undef ABS
#undef SUB
#undef ADD
#undef STORE
#undef LOAD
