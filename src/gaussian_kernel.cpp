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

struct GaussianWork {
  int w;
  size_t pitch;        // ring row pitch in int16 elements
  int16_t* scratch_mem;
  int16_t* ring_mem;
};

static inline int reflect1(int p, int n) { return p < 0 ? -p : (p >= n ? 2 * n - 2 - p : p); }

GaussQ15 gaussian_q15(float sigma) {
  double g[3], sum = 0;
  for (int k = -2; k <= 2; ++k) sum += std::exp(-(double)(k * k) / (2.0 * sigma * sigma));
  for (int k = 0; k <= 2; ++k) g[k] = std::exp(-(double)(k * k) / (2.0 * sigma * sigma)) / sum;
  GaussQ15 q;
  q.c1 = (int16_t)std::lround(g[1] * 32768.0);
  q.c2 = (int16_t)std::lround(g[2] * 32768.0);
  q.c0 = (int16_t)(32767 - 2 * q.c1 - 2 * q.c2);
  return q;
}

static void* aligned_zero(size_t bytes) {
  void* p = nullptr;
  if (posix_memalign(&p, 4096, bytes)) abort();
  memset(p, 0, bytes);
  return p;
}

GaussianWork* gaussian_work_create(int w) {
  GaussianWork* k = new GaussianWork;
  k->w = w;
  size_t wp = ((size_t)w + 31) & ~(size_t)31;
  k->pitch = wp + 32;                       // padded; also off the power-of-two pitches
  while ((k->pitch * 2) % 1024 == 0) k->pitch += 32;
  k->scratch_mem = (int16_t*)aligned_zero((wp + 96) * sizeof(int16_t));
  k->ring_mem = (int16_t*)aligned_zero(5 * k->pitch * sizeof(int16_t));
  return k;
}

void gaussian_work_destroy(GaussianWork* k) {
  if (!k) return;
  free(k->scratch_mem);
  free(k->ring_mem);
  delete k;
}

int16_t* gaussian_scratch(GaussianWork* k) { return k->scratch_mem + 32; }
int16_t* gaussian_ring_row(GaussianWork* k, int slot) { return k->ring_mem + (size_t)slot * k->pitch; }

// ---- phase 1: uint8 row -> Q6 int16 row, with the two reflected samples on each side ----------

static inline __m256i widen_q6(__m128i bytes) {
  return _mm256_slli_epi16(_mm256_cvtepu8_epi16(bytes), 6);
}

// Partial-vector tails live out of line so the hot functions keep a small frame (no stack realignment).
__attribute__((noinline)) static void expand_tail(const uint8_t* in, int16_t* s, int rem) {
  uint8_t tmp[16] = {0};
  memcpy(tmp, in, (size_t)rem);
  _mm256_store_si256((__m256i*)s, widen_q6(_mm_loadu_si128((const __m128i*)tmp)));
}

// n samples starting at `in`; the two samples on each side come from `in` itself (interior strip edge)
// or are reflected (image border). Interior edges read in[-2], in[-1], in[n], in[n+1].
static void expand_impl(const uint8_t* in, int16_t* s, int n, bool left_border, bool right_border) {
  const uint8_t* src = in;
  int16_t* dst = s;
  int x = 0;
  for (; x + 64 <= n; x += 64) {
    __m256i a = widen_q6(_mm_loadu_si128((const __m128i*)(src)));
    __m256i b = widen_q6(_mm_loadu_si128((const __m128i*)(src + 16)));
    __m256i c = widen_q6(_mm_loadu_si128((const __m128i*)(src + 32)));
    __m256i d = widen_q6(_mm_loadu_si128((const __m128i*)(src + 48)));
    _mm256_store_si256((__m256i*)(dst), a);
    _mm256_store_si256((__m256i*)(dst + 16), b);
    _mm256_store_si256((__m256i*)(dst + 32), c);
    _mm256_store_si256((__m256i*)(dst + 48), d);
    src += 64; dst += 64;
    KEEP(src); KEEP(dst);
  }
  for (; x + 16 <= n; x += 16)
    _mm256_store_si256((__m256i*)(s + x), widen_q6(_mm_loadu_si128((const __m128i*)(in + x))));
  if (x < n) expand_tail(in + x, s + x, n - x);
  if (left_border) { s[-1] = s[1]; s[-2] = s[2]; }
  else { s[-1] = (int16_t)(in[-1] << 6); s[-2] = (int16_t)(in[-2] << 6); }
  if (right_border) { s[n] = s[n - 2]; s[n + 1] = s[n - 3]; }
  else { s[n] = (int16_t)(in[n] << 6); s[n + 1] = (int16_t)(in[n + 1] << 6); }
}

void gaussian_expand_row(const uint8_t* in, int16_t* s, int w) { expand_impl(in, s, w, true, true); }

// ---- phase 2: horizontal filter -----------------------------------------------------------------

static inline __m256i hfilter(const int16_t* s, __m256i c0, __m256i c1, __m256i c2) {
  __m256i c = _mm256_load_si256((const __m256i*)s);
  __m256i l1 = _mm256_loadu_si256((const __m256i*)(s - 1));
  __m256i r1 = _mm256_loadu_si256((const __m256i*)(s + 1));
  __m256i l2 = _mm256_loadu_si256((const __m256i*)(s - 2));
  __m256i r2 = _mm256_loadu_si256((const __m256i*)(s + 2));
  __m256i a = _mm256_mulhrs_epi16(c, c0);
  __m256i b = _mm256_mulhrs_epi16(_mm256_add_epi16(l1, r1), c1);
  __m256i d = _mm256_mulhrs_epi16(_mm256_add_epi16(l2, r2), c2);
  return _mm256_add_epi16(_mm256_add_epi16(a, b), d);
}

void gaussian_horiz_row(const int16_t* s, int16_t* h, int w, const GaussQ15& q) {
  const __m256i c0 = _mm256_set1_epi16(q.c0), c1 = _mm256_set1_epi16(q.c1), c2 = _mm256_set1_epi16(q.c2);
  const int nv = (w + 15) >> 4;
  const int16_t* src = s;
  int16_t* dst = h;
  int v = 0;
  for (; v + 4 <= nv; v += 4) {
    __m256i a = hfilter(src, c0, c1, c2);
    __m256i b = hfilter(src + 16, c0, c1, c2);
    __m256i c = hfilter(src + 32, c0, c1, c2);
    __m256i d = hfilter(src + 48, c0, c1, c2);
    _mm256_store_si256((__m256i*)(dst), a);
    _mm256_store_si256((__m256i*)(dst + 16), b);
    _mm256_store_si256((__m256i*)(dst + 32), c);
    _mm256_store_si256((__m256i*)(dst + 48), d);
    src += 64; dst += 64;
    KEEP(src); KEEP(dst);
  }
  for (; v < nv; ++v) _mm256_store_si256((__m256i*)(h + 16 * v), hfilter(s + 16 * v, c0, c1, c2));
}

// ---- phase 3: vertical filter + round + pack to uint8 --------------------------------------------

static inline __m256i vfilter(const int16_t* const r[5], size_t x, __m256i c0, __m256i c1, __m256i c2) {
  __m256i m = _mm256_load_si256((const __m256i*)(r[2] + x));
  __m256i s1 = _mm256_add_epi16(_mm256_load_si256((const __m256i*)(r[1] + x)),
                                _mm256_load_si256((const __m256i*)(r[3] + x)));
  __m256i s2 = _mm256_add_epi16(_mm256_load_si256((const __m256i*)(r[0] + x)),
                                _mm256_load_si256((const __m256i*)(r[4] + x)));
  __m256i a = _mm256_mulhrs_epi16(m, c0);
  __m256i b = _mm256_mulhrs_epi16(s1, c1);
  __m256i d = _mm256_mulhrs_epi16(s2, c2);
  return _mm256_add_epi16(_mm256_add_epi16(a, b), d);
}

// (Y + 32) >> 6 is exactly vpmulhrsw(Y, 512) for Y >= 0: one p01 uop instead of an add and a shift.
static inline __m256i finish(__m256i y0, __m256i y1, __m256i k512) {
  y0 = _mm256_mulhrs_epi16(y0, k512);
  y1 = _mm256_mulhrs_epi16(y1, k512);
  return _mm256_permute4x64_epi64(_mm256_packus_epi16(y0, y1), 0xD8);
}

__attribute__((noinline)) static void vert_tail(const int16_t* const rr[5], uint8_t* out, size_t x, int rem,
                                                __m256i c0, __m256i c1, __m256i c2, __m256i k512) {
  __m256i a = vfilter(rr, x, c0, c1, c2);
  __m256i b = rem > 16 ? vfilter(rr, x + 16, c0, c1, c2) : a;
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
    __m256i a = vfilter(rr, 0, c0, c1, c2);
    __m256i b = vfilter(rr, 16, c0, c1, c2);
    __m256i c = vfilter(rr, 32, c0, c1, c2);
    __m256i d = vfilter(rr, 48, c0, c1, c2);
    _mm256_storeu_si256((__m256i*)(o), finish(a, b, round));
    _mm256_storeu_si256((__m256i*)(o + 32), finish(c, d, round));
    p0 += 64; p1 += 64; p2 += 64; p3 += 64; p4 += 64; o += 64;
    KEEP(p0); KEEP(p1); KEEP(p2); KEEP(p3); KEEP(p4); KEEP(o);
  }
  const int16_t* const rr[5] = {r[0], r[1], r[2], r[3], r[4]};
  for (; x + 32 <= w; x += 32) {
    __m256i a = vfilter(rr, (size_t)x, c0, c1, c2);
    __m256i b = vfilter(rr, (size_t)x + 16, c0, c1, c2);
    _mm256_storeu_si256((__m256i*)(out + x), finish(a, b, round));
  }
  if (x < w) vert_tail(rr, out + x, (size_t)x, w - x, c0, c1, c2, round);   // 1..31 pixels left
}

// ---- whole image -----------------------------------------------------------------------------------

void gaussian_u8(int w, int h, const uint8_t* in, uint8_t* out, const GaussQ15& q, GaussianWork* k) {
  int16_t* scratch = gaussian_scratch(k);
  auto ring = [&](int row) { return gaussian_ring_row(k, row % 5); };
  auto produce = [&](int row) {
    gaussian_expand_row(in + (size_t)row * w, scratch, w);
    gaussian_horiz_row(scratch, ring(row), w, q);
  };
  produce(0);
  produce(1);
  produce(2);
  for (int y = 0; y < h; ++y) {
    if (y >= 1 && y + 2 < h) produce(y + 2);
    const int16_t* rows[5];
    for (int j = 0; j < 5; ++j) rows[j] = ring(reflect1(y + j - 2, h));
    gaussian_vert_row(rows, out + (size_t)y * w, w, q);
  }
}

// Column strips of width up to `strip` (work created for width `strip`): the whole row pipeline runs down
// each strip, so the ring is 5*strip*2 bytes whatever the image width. Strip edges read their two
// neighbour columns straight from the image, so the result equals gaussian_u8 bit for bit.
// prefetch_rows > 0 prefetches that many input rows ahead of the row being expanded.
void gaussian_u8_strips(int w, int h, const uint8_t* in, uint8_t* out, const GaussQ15& q, GaussianWork* k,
                        int strip, int prefetch_rows) {
  int16_t* scratch = gaussian_scratch(k);
  auto ring = [&](int row) { return gaussian_ring_row(k, row % 5); };
  for (int x0 = 0; x0 < w; x0 += strip) {
    int sw = w - x0 < strip ? w - x0 : strip;
    const bool lb = x0 == 0, rb = x0 + sw == w;
    const uint8_t* src = in + x0;
    uint8_t* dst = out + x0;
    auto produce = [&](int row) {
      if (prefetch_rows && row + prefetch_rows < h) {
        const uint8_t* p = src + (size_t)(row + prefetch_rows) * w;
        for (int i = 0; i < sw; i += 64) _mm_prefetch((const char*)(p + i), _MM_HINT_T0);
      }
      expand_impl(src + (size_t)row * w, scratch, sw, lb, rb);
      gaussian_horiz_row(scratch, ring(row), sw, q);
    };
    produce(0);
    produce(1);
    produce(2);
    for (int y = 0; y < h; ++y) {
      if (y >= 1 && y + 2 < h) produce(y + 2);
      const int16_t* rows[5];
      for (int j = 0; j < 5; ++j) rows[j] = ring(reflect1(y + j - 2, h));
      gaussian_vert_row(rows, dst + (size_t)y * w, sw, q);
    }
  }
}

// ---- scalar reference of the integer contract ------------------------------------------------------

static inline int mulq(int a, int c) { return (a * c + 16384) >> 15; }

void gaussian_ref_q(int w, int h, const uint8_t* in, uint8_t* out, const GaussQ15& q) {
  int* hz = new int[(size_t)w * h];
  for (int y = 0; y < h; ++y)
    for (int x = 0; x < w; ++x) {
      auto X = [&](int dx) { return (int)in[(size_t)y * w + reflect1(x + dx, w)] << 6; };
      hz[(size_t)y * w + x] = mulq(X(0), q.c0) + mulq(X(-1) + X(1), q.c1) + mulq(X(-2) + X(2), q.c2);
    }
  for (int y = 0; y < h; ++y)
    for (int x = 0; x < w; ++x) {
      auto H = [&](int dy) { return hz[(size_t)reflect1(y + dy, h) * w + x]; };
      int yv = mulq(H(0), q.c0) + mulq(H(-1) + H(1), q.c1) + mulq(H(-2) + H(2), q.c2);
      int v = (yv + 32) >> 6;
      out[(size_t)y * w + x] = (uint8_t)(v < 0 ? 0 : (v > 255 ? 255 : v));
    }
  delete[] hz;
}
