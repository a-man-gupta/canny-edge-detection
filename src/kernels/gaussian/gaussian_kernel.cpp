// Part 1: 5x5 Gaussian blur, AVX2 integer. Design: whole-row streaming with a five-row ring of
// horizontal results (int16, Q6) and independent expand / horizontal / vertical loops per row.
// See gaussian_kernel.hpp for the numeric contract.
#include "gaussian_kernel.hpp"

#include <immintrin.h>

#include <cmath>
#include <cstdlib>
#include <cstring>

// Makes a pointer opaque to the optimizer so that GCC keeps one plain [reg+disp] address per stream
// instead of rewriting the loop into a shared index ([base+index*scale]). On Skylake/Cascade Lake an
// indexed memory operand of a 3-operand vector instruction (and any indexed store) is un-laminated into
// two allocation slots; plain pointers keep the load/store micro-fused.
#define KEEP(p) asm("" : "+r"(p))

// Fused Gaussian: horizontal five-tap sum, then the vertical sum and byte pack.
// Five taps share three weights because the Gaussian is symmetric.
#define LOAD(p, dst)         ((dst) = _mm256_loadu_si256(reinterpret_cast<const __m256i*>(p)))
#define ADD(a, b, dst)       ((dst) = _mm256_add_epi16((a), (b)))
#define MUL_Q15(a, b, dst)   ((dst) = _mm256_mulhrs_epi16((a), (b)))

#define WEIGHTED_SUM(center, inner, outer, c0, c1, c2, dst) do { \
  __m256i center_term, inner_term, outer_term; \
  MUL_Q15(center, c0, center_term); \
  MUL_Q15(inner, c1, inner_term); \
  MUL_Q15(outer, c2, outer_term); \
  ADD(center_term, inner_term, dst); \
  ADD(dst, outer_term, dst); \
} while (0)

// Both passes use this same kernel. Each pointer supplies 16 neighboring outputs.
static inline __m256i gaussian_5tap(const int16_t* outer_l, const int16_t* inner_l,
                                    const int16_t* middle, const int16_t* inner_r,
                                    const int16_t* outer_r, __m256i c0, __m256i c1, __m256i c2) {
  __m256i center, left, right, inner, outer, sum;
  LOAD(middle, center);
  LOAD(inner_l, left);
  LOAD(inner_r, right);
  ADD(left, right, inner);
  LOAD(outer_l, left);
  LOAD(outer_r, right);
  ADD(left, right, outer);
  WEIGHTED_SUM(center, inner, outer, c0, c1, c2, sum);
  return sum;
}

#define HORIZONTAL(s) gaussian_5tap((s)-2, (s)-1, (s), (s)+1, (s)+2, c0, c1, c2)
#define VERTICAL(r, x) gaussian_5tap((r)[0]+(x), (r)[1]+(x), (r)[2]+(x), (r)[3]+(x), (r)[4]+(x), c0, c1, c2)

void gaussian_horiz_row(const int16_t* s, int16_t* h, int w, const GaussQ15& q) {
  const __m256i c0 = _mm256_set1_epi16(q.c0), c1 = _mm256_set1_epi16(q.c1), c2 = _mm256_set1_epi16(q.c2);
  const int nv = (w + 15) >> 4;
  const int16_t* src = s;
  int16_t* dst = h;
  int v = 0;
  for (; v + 4 <= nv; v += 4) {
    __m256i h0 = HORIZONTAL(src + 0);
    __m256i h1 = HORIZONTAL(src + 16);
    __m256i h2 = HORIZONTAL(src + 32);
    __m256i h3 = HORIZONTAL(src + 48);
    _mm256_store_si256(reinterpret_cast<__m256i*>(dst + 0), h0);
    _mm256_store_si256(reinterpret_cast<__m256i*>(dst + 16), h1);
    _mm256_store_si256(reinterpret_cast<__m256i*>(dst + 32), h2);
    _mm256_store_si256(reinterpret_cast<__m256i*>(dst + 48), h3);
    src += 64; dst += 64;
    KEEP(src); KEEP(dst);
  }
  // The last block contains zero to three padded vectors.
  if (v < nv)     _mm256_store_si256((__m256i*)dst, HORIZONTAL(src));
  if (v + 1 < nv) _mm256_store_si256((__m256i*)(dst + 16), HORIZONTAL(src + 16));
  if (v + 2 < nv) _mm256_store_si256((__m256i*)(dst + 32), HORIZONTAL(src + 32));
}

// ---- phase 3: vertical filter + round + pack to uint8 --------------------------------------------

#undef WEIGHTED_SUM
#undef MUL_Q15
#undef ADD
#undef LOAD

// (Y + 32) >> 6 is exactly vpmulhrsw(Y, 512) for Y >= 0: one p01 uop instead of an add and a shift.
static inline __m256i finish(__m256i y0, __m256i y1, __m256i k512) {
  y0 = _mm256_mulhrs_epi16(y0, k512);
  y1 = _mm256_mulhrs_epi16(y1, k512);
  return _mm256_permute4x64_epi64(_mm256_packus_epi16(y0, y1), 0xD8);
}

__attribute__((noinline)) static void vert_tail(const int16_t* const rr[5], uint8_t* out, size_t x, int rem,
                                                __m256i c0, __m256i c1, __m256i c2, __m256i k512) {
  __m256i a = VERTICAL(rr, x);
  __m256i b = rem > 16 ? VERTICAL(rr, x + 16) : a;
  alignas(32) uint8_t tmp[32];
  _mm256_store_si256((__m256i*)tmp, finish(a, b, k512));
  memcpy(out, tmp, (size_t)rem);
}

void gaussian_vert_row(const int16_t* const r[5], uint8_t* out, int w, const GaussQ15& q) {
  const __m256i c0 = _mm256_set1_epi16(q.c0), c1 = _mm256_set1_epi16(q.c1), c2 = _mm256_set1_epi16(q.c2);
  const __m256i round = _mm256_set1_epi16(512);   // vpmulhrsw constant of finish()
  const int16_t *p0 = r[0], *p1 = r[1], *p2 = r[2], *p3 = r[3], *p4 = r[4];   // local copies: no reload after stores
  uint8_t* o = out;
  int x = 0;
  for (; x + 64 <= w; x += 64) {
    const int16_t* const rr[5] = {p0, p1, p2, p3, p4};
    __m256i a = VERTICAL(rr, 0);
    __m256i b = VERTICAL(rr, 16);
    __m256i c = VERTICAL(rr, 32);
    __m256i d = VERTICAL(rr, 48);
    _mm256_storeu_si256((__m256i*)(o), finish(a, b, round));
    _mm256_storeu_si256((__m256i*)(o + 32), finish(c, d, round));
    p0 += 64; p1 += 64; p2 += 64; p3 += 64; p4 += 64; o += 64;
    KEEP(p0); KEEP(p1); KEEP(p2); KEEP(p3); KEEP(p4); KEEP(o);
  }
  const int16_t* const rr[5] = {r[0], r[1], r[2], r[3], r[4]};
  if (x + 32 <= w) {
    __m256i a = VERTICAL(rr, (size_t)x);
    __m256i b = VERTICAL(rr, (size_t)x + 16);
    _mm256_storeu_si256((__m256i*)(out + x), finish(a, b, round));
    x += 32;
  }
  if (x < w) vert_tail(rr, out + x, (size_t)x, w - x, c0, c1, c2, round);   // 1..31 pixels left
}

// Vertical filter straight to uint16, 16 pixels per step. Same rounding and clamp as the uint8
// version: vpmulhrsw(Y, 512) = (Y + 32) >> 6, and min/max reproduces vpackuswb's [0, 255] clamp.
void gaussian_vert_row_u16(const int16_t* const r[5], uint16_t* out, int w, const GaussQ15& q) {
  const __m256i c0 = _mm256_set1_epi16(q.c0), c1 = _mm256_set1_epi16(q.c1), c2 = _mm256_set1_epi16(q.c2);
  const __m256i round = _mm256_set1_epi16(512), lo = _mm256_setzero_si256(), hi = _mm256_set1_epi16(255);
  for (int x = 0; x < w; x += 16) {
    __m256i y = _mm256_mulhrs_epi16(VERTICAL(r, x), round);
    y = _mm256_min_epi16(_mm256_max_epi16(y, lo), hi);
    _mm256_storeu_si256(reinterpret_cast<__m256i*>(out + x), y);
  }
}

#undef HORIZONTAL
#undef VERTICAL

#include "detail/gaussian_support.inc"
