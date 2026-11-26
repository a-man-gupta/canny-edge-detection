#pragma once
#include <immintrin.h>
#include <cstdint>

// Native row prefixes for large strips. The caller handles the final 0..31 pixels.
namespace gaussian_native {
inline bool available(int width) {
    return width >= 96 && __builtin_cpu_supports("avx512bw");
}

__attribute__((target("avx512bw")))
static void expand(const uint8_t* input, int16_t* scratch, int width) {
#pragma GCC unroll 4
    for (int x = 0; x < width; x += 32) {
        __m256i pixels = _mm256_loadu_si256(reinterpret_cast<const __m256i*>(input + x));
        __m512i words = _mm512_cvtepu8_epi16(pixels);
        _mm512_storeu_si512(scratch + x, _mm512_slli_epi16(words, 6));
    }
}

__attribute__((target("avx512bw")))
static void horizontal(const int16_t* src, int16_t* dst, int width, const GaussQ15& q) {
    const __m512i c0 = _mm512_set1_epi16(q.c0), c1 = _mm512_set1_epi16(q.c1), c2 = _mm512_set1_epi16(q.c2);
#pragma GCC unroll 4
    for (int x = 0; x < width; x += 32) {
        const int16_t* p = src + x;
        __m512i inner = _mm512_add_epi16(_mm512_loadu_si512(p - 1), _mm512_loadu_si512(p + 1));
        __m512i outer = _mm512_add_epi16(_mm512_loadu_si512(p - 2), _mm512_loadu_si512(p + 2));
        __m512i center = _mm512_mulhrs_epi16(_mm512_loadu_si512(p), c0);
        inner = _mm512_mulhrs_epi16(inner, c1);
        outer = _mm512_mulhrs_epi16(outer, c2);
        _mm512_storeu_si512(dst + x, _mm512_add_epi16(center, _mm512_add_epi16(inner, outer)));
    }
}

__attribute__((target("avx512bw")))
static void vertical(const int16_t* const rows[5], uint8_t* out, int width, const GaussQ15& q) {
    const int16_t* a = rows[0], *b = rows[1], *c = rows[2], *d = rows[3], *e = rows[4];
    const __m512i c0 = _mm512_set1_epi16(q.c0), c1 = _mm512_set1_epi16(q.c1), c2 = _mm512_set1_epi16(q.c2);
    const __m512i round = _mm512_set1_epi16(512);
#pragma GCC unroll 4
    for (int x = 0; x < width; x += 32) {
        __m512i inner = _mm512_add_epi16(_mm512_loadu_si512(b + x), _mm512_loadu_si512(d + x));
        __m512i outer = _mm512_add_epi16(_mm512_loadu_si512(a + x), _mm512_loadu_si512(e + x));
        __m512i center = _mm512_mulhrs_epi16(_mm512_loadu_si512(c + x), c0);
        __m512i sum = _mm512_add_epi16(center, _mm512_add_epi16(_mm512_mulhrs_epi16(inner, c1),
                                                                _mm512_mulhrs_epi16(outer, c2)));
        __m512i pixels = _mm512_mulhrs_epi16(sum, round);
        _mm256_storeu_si256(reinterpret_cast<__m256i*>(out + x), _mm512_cvtusepi16_epi8(pixels));
    }
}
}
