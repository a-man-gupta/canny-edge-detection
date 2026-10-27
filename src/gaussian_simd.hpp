#pragma once
// AVX2 5x5 Gaussian blur built from an 8x8 register-blocked micro-kernel.
// Same contract as gaussian_naive: uint8 input, reflect-101 borders, float output
// quantized to floor(value + 0.5) clamped to 0..255. Requires 8 <= w <= MAX_W and h >= 8.
#include <immintrin.h>

#include <algorithm>
#include <cstddef>
#include <cstdint>

namespace gsimd {

constexpr int ROWS = 8;            // output rows per block (one ymm accumulator each)
constexpr int IN_ROWS = ROWS + 4;  // input rows a block reads
constexpr int PAD = 2;             // mirrored pixels on each side of a strip row
// Floats per strip row. A compile-time constant, so each of the 60 input loads in a
// block is one pointer plus a fixed offset; a runtime stride made GCC spill addresses.
// Multiple of 16 (rows start on a 64-byte line), not a power of two (rows map to
// different L1 sets).
constexpr size_t STRIDE = 8208;
constexpr int MAX_W = int(STRIDE) - 2 * PAD;
constexpr size_t STRIP_FLOATS = IN_ROWS * STRIDE;

// Returns p unchanged, but the optimizer cannot see through it. Loads through the result
// are re-issued each time instead of being hoisted into registers that would then spill.
template <class T>
__attribute__((always_inline)) inline T* opaque(T* p) {
    asm volatile("" : "+r"(p));
    return p;
}

inline int reflect101(int p, int n) {
    while (p < 0 || p >= n)
        p = p < 0 ? -p : 2 * n - 2 - p;
    return p;
}

// Converts the 12 input rows of the strip starting at output row y0 to float,
// with reflect-101 applied to rows and PAD mirrored columns on each side.
__attribute__((target("avx2")))
inline void pack_strip(const uint8_t* image, int w, int h, int y0, float* strip) {
    for (int r = 0; r < IN_ROWS; ++r) {
        const uint8_t* src = image + size_t(reflect101(y0 - PAD + r, h)) * w;
        float* dst = strip + r * STRIDE;
        int x = 0;
        for (; x + 8 <= w; x += 8) {
            __m128i bytes = _mm_loadl_epi64(reinterpret_cast<const __m128i*>(src + x));
            _mm256_storeu_ps(dst + PAD + x, _mm256_cvtepi32_ps(_mm256_cvtepu8_epi32(bytes)));
        }
        for (; x < w; ++x) dst[PAD + x] = src[x];
        dst[0] = src[2];
        dst[1] = src[1];
        dst[PAD + w] = src[w - 2];
        dst[PAD + w + 1] = src[w - 3];
    }
}

// floor(acc + 0.5), clamp to [0, 255], store one 8-pixel row per accumulator.
__attribute__((target("avx2"), always_inline))
inline void store_quantized(const __m256* acc, float* dst, size_t dst_stride) {
    const __m256 half = _mm256_set1_ps(0.5f), lo = _mm256_setzero_ps(), hi = _mm256_set1_ps(255.0f);
#pragma GCC unroll 8
    for (int y = 0; y < ROWS; ++y, dst += dst_stride) {
        __m256 q = _mm256_round_ps(_mm256_add_ps(acc[y], half), _MM_FROUND_TO_NEG_INF | _MM_FROUND_NO_EXC);
        _mm256_storeu_ps(dst, _mm256_min_ps(_mm256_max_ps(q, lo), hi));
    }
}

// FMA kernel over one strip: 8 rows x `cols` output pixels, in 8x8 blocks.
// Taps are summed k-outer with fused multiply-add, so results can differ from
// gaussian_naive by one gray level where a value lands on a rounding boundary.
__attribute__((target("avx2,fma"), noinline))
void blur_strip_fma(const float* strip, const float* wts, float* dst, size_t dst_stride, int cols) {
    for (int x = 0;; x += 8) {
        const int x0 = std::min(x, cols - 8);  // last block overlaps instead of a scalar tail
        const float* src = strip + x0;
        const float* wb = opaque(wts);
        __m256 acc[ROWS];
#pragma GCC unroll 8
        for (int y = 0; y < ROWS; ++y) acc[y] = _mm256_setzero_ps();
#pragma GCC unroll 5
        for (int k = 0; k < 5; ++k) {
            __m256 w[5];
#pragma GCC unroll 5
            for (int j = 0; j < 5; ++j) w[j] = _mm256_broadcast_ss(wb + j * 5 + k);
#pragma GCC unroll 12
            for (int r = 0; r < IN_ROWS; ++r) {
                __m256 v = _mm256_loadu_ps(src + r * STRIDE + k);
#pragma GCC unroll 5
                for (int j = 0; j < 5; ++j) {
                    const int y = r - j;
                    if (y >= 0 && y < ROWS) acc[y] = _mm256_fmadd_ps(w[j], v, acc[y]);
                }
            }
        }
        store_quantized(acc, dst + x0, dst_stride);
        if (x0 == cols - 8) break;
    }
}

// Bit-exact kernel: per lane, the same separate multiply then add, in the same
// j-outer, k-inner order as gaussian_naive. No "fma" target, so the compiler cannot fuse them.
// no-tree-ter: with it on, GCC 8 issues every load of a block up front and spills ~550 times.
__attribute__((target("avx2"), optimize("no-tree-ter"), noinline))
void blur_strip_exact(const float* strip, const float* wts, float* dst, size_t dst_stride, int cols) {
    for (int x = 0;; x += 8) {
        const int x0 = std::min(x, cols - 8);
        const float* src = strip + x0;
        __m256 acc[ROWS];
#pragma GCC unroll 8
        for (int y = 0; y < ROWS; ++y) acc[y] = _mm256_setzero_ps();
#pragma GCC unroll 12
        for (int r = 0; r < IN_ROWS; ++r) {
            const float* wb = opaque(wts);  // each weight is broadcast where it is used
#pragma GCC unroll 5
            for (int k = 0; k < 5; ++k) {
                __m256 v = _mm256_loadu_ps(src + r * STRIDE + k);
#pragma GCC unroll 5
                for (int j = 0; j < 5; ++j) {
                    const int y = r - j;
                    if (y >= 0 && y < ROWS)
                        acc[y] = _mm256_add_ps(acc[y], _mm256_mul_ps(_mm256_broadcast_ss(wb + j * 5 + k), v));
                }
            }
        }
        store_quantized(acc, dst + x0, dst_stride);
        if (x0 == cols - 8) break;
    }
}

using StripFn = void (*)(const float*, const float*, float*, size_t, int);

// Whole-image blur: pack each 8-row strip, then run the strip kernel across it.
// The last strip overlaps the previous one so every strip is full height.
// strip: STRIP_FLOATS floats, 64-byte aligned.
inline void gaussian_simd(StripFn strip_fn, const uint8_t* image, float* blur, int w, int h,
                          const float weights[5][5], float* strip) {
    for (int s = 0;; s += ROWS) {
        const int y0 = std::min(s, h - ROWS);
        pack_strip(image, w, h, y0, strip);
        strip_fn(strip, &weights[0][0], blur + size_t(y0) * w, size_t(w), w);
        if (y0 == h - ROWS) break;
    }
}

}  // namespace gsimd
