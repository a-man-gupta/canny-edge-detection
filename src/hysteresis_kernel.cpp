// Part 5 hysteresis kernel.
//
// Vector pass, per 32 pixels of a row: h = L[x-1] | L[x] | L[x+1] for the rows above, at and
// below, then OR = h(y-1) | h(y) | h(y+1), the OR of the 3x3 neighborhood. Labels are 0, 1 or 2,
// so (2 * center) & OR is nonzero exactly where the center is weak (2 * 1 = 2) and a neighbor is
// strong (bit 1 of OR); a strong center gives 4 & OR = 0. edges = (center == 2) ? 255 : 0.
// Working down a block of 4 rows, each row's h is used by three output rows, so 6 rows are
// loaded (3 vectors each) for 4 rows of output. The seed test is accumulated over the block and
// branched on once; blocks with a seed are listed and finished in scalar code.
//
// The x-1 and x+1 loads are unaligned; with x on a 32-byte boundary one of the two crosses a
// 64-byte line, so each loaded row costs one split load.
#include "hysteresis_kernel.hpp"

#include <algorithm>
#include <atomic>
#include <immintrin.h>

#define INLINE static inline __attribute__((always_inline))

INLINE __m256i load(const uint8_t *p) { return _mm256_loadu_si256((const __m256i *)p); }
// a | b | c in one vpternlogd.
INLINE __m256i or3(__m256i a, __m256i b, __m256i c) {
  return _mm256_ternarylogic_epi32(a, b, c, 0xFE);
}
// a | (b & c) in one vpternlogd.
INLINE __m256i or_and(__m256i a, __m256i b, __m256i c) {
  return _mm256_ternarylogic_epi32(a, b, c, 0xF8);
}

template <int R>
INLINE long rows_repeat(const uint8_t *labels, uint8_t *edges, long stride, long begin, long n,
                        uint32_t *hits, long reps) {
  const __m256i two = _mm256_set1_epi8(2);
  long count = 0;
  for (long pass = 0; pass < reps; ++pass) {
    count = 0;
    for (long x = begin; x < begin + n; x += 32) {
      const uint8_t *p = labels + x;
      __m256i center[R + 2], h[R + 2];
      for (int r = 0; r < R + 2; ++r) {
        const uint8_t *row = p + (r - 1) * stride;
        center[r] = load(row);
        h[r] = or3(load(row - 1), center[r], load(row + 1));
      }
      __m256i seeds;
      for (int r = 1; r <= R; ++r) {
        __m256i all = or3(h[r - 1], h[r], h[r + 1]);
        _mm256_storeu_si256((__m256i *)(edges + (r - 1) * stride + x),
                            _mm256_cmpeq_epi8(center[r], two));
        __m256i doubled = _mm256_add_epi8(center[r], center[r]);
        seeds = r == 1 ? _mm256_and_si256(doubled, all) : or_and(seeds, doubled, all);
      }
      if (__builtin_expect(!_mm256_testz_si256(seeds, seeds), 0))
        hits[count++] = uint32_t(x);
    }
    // Compiler barrier only: every pass executes; no fence instruction.
    std::atomic_signal_fence(std::memory_order_seq_cst);
  }
  return count;
}

extern "C" __attribute__((noinline)) long
hysteresis_rows4_repeat(const uint8_t *labels, uint8_t *edges, long stride, long begin, long n,
                        uint32_t *hits, long reps) {
  return rows_repeat<4>(labels, edges, stride, begin, n, hits, reps);
}

extern "C" __attribute__((noinline)) long
hysteresis_rows1_repeat(const uint8_t *labels, uint8_t *edges, long stride, long begin, long n,
                        uint32_t *hits, long reps) {
  return rows_repeat<1>(labels, edges, stride, begin, n, hits, reps);
}

void hysteresis_kernel(int w, int h, const uint8_t *labels, uint8_t *edges,
                       std::vector<size_t> &queue) {
  queue.clear();
  if (w <= 0 || h <= 0)
    return;
  // A weak pixel with a strong neighbor starts the queue, already marked as an edge.
  auto seed = [&](int y, int x) {
    for (int j = -1; j <= 1; ++j)
      for (int k = -1; k <= 1; ++k) {
        if (y + j < 0 || y + j >= h || x + k < 0 || x + k >= w)
          continue;
        if (labels[size_t(y + j) * w + x + k] == 2) {
          edges[size_t(y) * w + x] = 255;
          queue.push_back(size_t(y) * w + x);
          return;
        }
      }
  };
  auto scalar_pixel = [&](int y, int x) {
    const size_t i = size_t(y) * w + x;
    edges[i] = labels[i] == 2 ? 255 : 0;
    if (labels[i] == 1)
      seed(y, x);
  };

  // Columns 1 .. vector_pixels go through the vector pass on rows 1 .. h-2.
  const int vector_pixels = h >= 3 && w >= 34 ? (w - 2) / 32 * 32 : 0;
  std::vector<uint32_t> hits(vector_pixels / 32 + 1);
  auto rows = [&](int y, int count) {
    const size_t row = size_t(y) * w;
    long found = 0;
    if (vector_pixels)
      found = count == 4 ? hysteresis_rows4_repeat(labels + row, edges + row, w, 1, vector_pixels,
                                                   hits.data(), 1)
                         : hysteresis_rows1_repeat(labels + row, edges + row, w, 1, vector_pixels,
                                                   hits.data(), 1);
    for (long f = 0; f < found; ++f)
      for (int r = 0; r < count; ++r)
        for (int x = int(hits[f]); x < int(hits[f]) + 32; ++x)
          if (labels[size_t(y + r) * w + x] == 1)
            seed(y + r, x);
    for (int r = 0; r < count; ++r) {
      scalar_pixel(y + r, 0);
      for (int x = 1 + vector_pixels; x < w; ++x)
        scalar_pixel(y + r, x);
    }
  };

  for (int x = 0; x < w; ++x)
    scalar_pixel(0, x);
  int y = 1;
  for (; y + 4 <= h - 1; y += 4)
    rows(y, 4);
  for (; y < h - 1; ++y)
    rows(y, 1);
  if (h > 1)
    for (int x = 0; x < w; ++x)
      scalar_pixel(h - 1, x);

  // Queue pass: grow from the seeds through weak pixels.
  for (size_t head = 0; head < queue.size(); ++head) {
    const size_t i = queue[head];
    const int y = int(i / w), x = int(i % w);
    for (int j = -1; j <= 1; ++j)
      for (int k = -1; k <= 1; ++k) {
        if (y + j < 0 || y + j >= h || x + k < 0 || x + k >= w)
          continue;
        const size_t nb = size_t(y + j) * w + x + k;
        if (labels[nb] == 1 && !edges[nb]) {
          edges[nb] = 255;
          queue.push_back(nb);
        }
      }
  }
}
