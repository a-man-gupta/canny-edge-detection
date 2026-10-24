#include "nms_kernel.hpp"

#include <algorithm>
#include <cstddef>
#include <immintrin.h>

// Part 3: non-maximum suppression, 8 pixels per 256-bit register, 4 rows at a time.
//
// Same rule as canny_scalar.cpp (Part 3), bit for bit: the kernel only compares and selects,
// so every kept value is exactly mag[i] and every other value is 0.
// Note: the course's stage 3 wording still has to be confirmed with staff; this follows the
// team's scalar code.
//
// Input contract: angle holds Part 2's direction bins, 0, 45, 90 or 135 degrees (what the Part 2
// kernel writes). For those values "near 0" is just d < 22.5, so the scalar test
// d >= 157.5 is dropped. For any other angle the result can differ from the scalar code
// (the short-row fallback below still uses the full rule).
//
// Instruction set: AVX2 width (ymm, 8 floats) plus the AVX-512VL mask registers, like the
// Sobel kernel. Only 256-bit ops and no FP math, so the core keeps its full turbo clock.
//
// Reuse between rows: pixel (y, c) needs mag rows y-1, y, y+1 at columns c-1, c, c+1. Row y+1
// needs rows y, y+1, y+2: two of the three are the same registers. So for 8 columns we walk
// down 4 rows, loading only the 3 new vectors of the row below each time:
//   loads per 4 x 8 pixels: 3 x 6 rows + 4 angle = 22, i.e. 5.5 per 8 pixels (one row at a
//   time it is 10, and then the load ports, not the compares, are the limit).
//
// Per 8 pixels:
//   1. Angle: 3 compares into masks k (the if/else chain).
//   2. a = up-right, then masked moves of above, up-left, left overwrite the lanes whose test
//      passed (later tests win, which is the same as the first matching if). b likewise.
//   3. Keep test: m > a into a mask, then m >= b only in those lanes (masked compare).
//   4. Store m with the other lanes zeroed.
// Uops per 8 pixels: 5.5 loads, 5 compares, 6 masked moves, 1 zeroing move, 1 store, plus the
// addresses and the loop: about 20.
//
// Peak (Xeon Silver 4208, Cascade Lake), cycles per pixel:
//   compares:  5 per 8 px; compare-into-mask runs on port 5 only     -> 0.625
//   issue:     ~20 uops per 8 px, 4 per cycle                         -> 0.625
//   loads:     5.5 per 8 px on 2 load ports (plus cache-line splits)  -> 0.34 (~0.5)
//   ports 0/1/5: 5 + 6 + 1 = 12 per 8 px on 3 ports                   -> 0.50
// So the peak is 0.625 cycles/pixel (port 5 and issue together).
// Measured with data in L1: 0.75 cycles/pixel (84% of peak); one row at a time was 0.99.

// Markers so the op count can see one iteration. Present only with -DSOBEL_MARK_LOOPS.
#ifdef SOBEL_MARK_LOOPS
#define LOOP_BEGIN(pixels) __asm__ __volatile__("# loop nms begin %c0" :: "i"(pixels) : "memory")
#define LOOP_END() __asm__ __volatile__("# loop end" ::: "memory")
#else
#define LOOP_BEGIN(pixels)
#define LOOP_END()
#endif

// One group of 8 pixels, given the 3x3 neighborhood as 9 vectors (t/m/b = row above / this
// row / row below, l/c/r = columns shifted left / center / right).
static inline __attribute__((always_inline))
void nms_pick8(__m256 tl, __m256 tc, __m256 tr, __m256 ml, __m256 mc, __m256 mr,
               __m256 bl, __m256 bc, __m256 br, const float* ang, float* out,
               __m256 deg22, __m256 deg67, __m256 deg112) {
    // Scalar: float d = angle[i]; then the if/else chain that picks neighbors a and b:
    //   start (135)       -> up-right, down-left
    //   d < 112.5  (90)   -> above, below
    //   d < 67.5   (45)   -> up-left, down-right
    //   d < 22.5   (0)    -> left, right   (the scalar code also has d >= 157.5; no bin is)
    const __m256 d = _mm256_loadu_ps(ang);
    const __mmask8 lt112 = _mm256_cmp_ps_mask(d, deg112, _CMP_LT_OQ);
    const __mmask8 lt67 = _mm256_cmp_ps_mask(d, deg67, _CMP_LT_OQ);
    const __mmask8 lt22 = _mm256_cmp_ps_mask(d, deg22, _CMP_LT_OQ);

    __m256 a = _mm256_mask_mov_ps(tr, lt112, tc);   // up-right -> above
    a = _mm256_mask_mov_ps(a, lt67, tl);            // -> up-left
    a = _mm256_mask_mov_ps(a, lt22, ml);            // -> left
    __m256 b = _mm256_mask_mov_ps(bl, lt112, bc);   // down-left -> below
    b = _mm256_mask_mov_ps(b, lt67, br);            // -> down-right
    b = _mm256_mask_mov_ps(b, lt22, mr);            // -> right

    // Scalar: if (mag[i] > mag[a] && mag[i] >= mag[b]) suppressed[i] = mag[i];  (else 0)
    const __mmask8 gt = _mm256_cmp_ps_mask(mc, a, _CMP_GT_OQ);
    const __mmask8 keep = _mm256_mask_cmp_ps_mask(gt, mc, b, _CMP_GE_OQ);   // only lanes in gt
    _mm256_storeu_ps(out, _mm256_maskz_mov_ps(keep, mc));                   // other lanes 0.0f
}

// Columns c .. c+7 of rows y .. y+rows-1. rows is a constant at each call (4 or 1), so the
// row loop is unrolled and the 9 vectors stay in registers (rotated by renaming, no copies).
static inline __attribute__((always_inline))
void nms_col8(const float* mag, const float* angle, float* out, int w, int y, int rows, int c,
              __m256 deg22, __m256 deg67, __m256 deg112) {
    const float* p = mag + size_t(y - 1) * w + c;   // row y-1, column c
    __m256 tl = _mm256_loadu_ps(p - 1), tc = _mm256_loadu_ps(p), tr = _mm256_loadu_ps(p + 1);
    p += w;
    __m256 ml = _mm256_loadu_ps(p - 1), mc = _mm256_loadu_ps(p), mr = _mm256_loadu_ps(p + 1);
#pragma GCC unroll 4
    for (int r = 0; r < rows; ++r) {
        p += w;   // the new row below
        const __m256 bl = _mm256_loadu_ps(p - 1), bc = _mm256_loadu_ps(p), br = _mm256_loadu_ps(p + 1);
        const size_t i = size_t(y + r) * w + c;
        nms_pick8(tl, tc, tr, ml, mc, mr, bl, bc, br, angle + i, out + i, deg22, deg67, deg112);
        tl = ml; tc = mc; tr = mr;   // move the window down one row
        ml = bl; mc = bc; mr = br;
    }
}

// Columns x_begin .. x_limit-1 of `rows` rows from y: steps of 8, the last group ending on the
// last column (it overlaps columns already written and stores the same values). Rows with
// fewer than 8 interior pixels are left to the scalar code. Returns the first column not written.
static inline __attribute__((always_inline))
int nms_block(const float* mag, const float* angle, float* out, int w, int y, int rows,
              int x_begin, int x_limit) {
    // Direction thresholds, the same numbers as the scalar if/else chain.
    const __m256 deg22 = _mm256_set1_ps(22.5f);
    const __m256 deg67 = _mm256_set1_ps(67.5f);
    const __m256 deg112 = _mm256_set1_ps(112.5f);

    int x = x_begin;
    for (; x + 8 <= x_limit; x += 8) {
        LOOP_BEGIN(8 * rows);
        nms_col8(mag, angle, out, w, y, rows, x, deg22, deg67, deg112);
        LOOP_END();
    }
    if (x_limit - x_begin < 8 || x == x_limit)
        return x;
    nms_col8(mag, angle, out, w, y, rows, x_limit - 8, deg22, deg67, deg112);
    return x_limit;
}

int nms_rows4(const float* mag, const float* angle, float* out, int w, int y, int x_begin, int x_limit) {
    return nms_block(mag, angle, out, w, y, 4, x_begin, x_limit);
}

// One row (the 1-3 rows left after the blocks of 4): 10 loads per 8 pixels instead of 5.5.
static int nms_row1(const float* mag, const float* angle, float* out, int w, int y, int x_begin, int x_limit) {
    return nms_block(mag, angle, out, w, y, 1, x_begin, x_limit);
}

// One interior pixel, exactly the scalar code (used for rows too short for the vector loop).
static float nms_scalar_at(const float* mag, const float* angle, int w, size_t i) {
    float d = angle[i];
    size_t a, b;
    if (d < 22.5f || d >= 157.5f) {
        a = i - 1;
        b = i + 1;
    } else if (d < 67.5f) {
        a = i - w - 1;
        b = i + w + 1;
    } else if (d < 112.5f) {
        a = i - w;
        b = i + w;
    } else {
        a = i - w + 1;
        b = i + w - 1;
    }
    return (mag[i] > mag[a] && mag[i] >= mag[b]) ? mag[i] : 0.f;
}

// Whole image. The border (first and last rows and columns) stays 0, like the scalar code.
void nms_kernel(int w, int h, const float* mag, const float* angle, float* suppressed) {
    std::fill(suppressed, suppressed + size_t(w) * h, 0.f);
    int y = 1;
    for (; y + 4 <= h - 1; y += 4) {
        const int x = nms_rows4(mag, angle, suppressed, w, y, 1, w - 1);
        for (int r = y; r < y + 4; ++r)
            for (int c = x; c < w - 1; ++c)
                suppressed[size_t(r) * w + c] = nms_scalar_at(mag, angle, w, size_t(r) * w + c);
    }
    for (; y < h - 1; ++y) {
        const int x = nms_row1(mag, angle, suppressed, w, y, 1, w - 1);
        for (int c = x; c < w - 1; ++c)
            suppressed[size_t(y) * w + c] = nms_scalar_at(mag, angle, w, size_t(y) * w + c);
    }
}
