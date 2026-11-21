// Part 3 NMS kernel: exact integer non-maximum suppression, 8 pixels (int32) per group.
//
// Each group tests all four directions (8 compares, 4 andnot), then picks the pixel's own
// direction with three selects (vpblendmd driven by mask registers, 1 uop each). The direction
// comes as two bit arrays, one bit per pixel: odd = 45 or 135, hi = 90 or 135. Registers stay
// 256-bit (ymm), so the core keeps its AVX2 clock.
//
// Split loads: a 32-byte load at x-1 or x+1 crosses a 64-byte cache line in one of every two
// groups, and such loads are slow (measured: about 7% of the time). So the magnitudes come
// twice: mag (row starts + begin on a 64-byte boundary) and mag2, the same values stored 32
// bytes off that boundary. For each neighbor the kernel reads the copy where it does not cross:
// even groups (x = begin + 16k) take x-1 from mag2, odd groups (x = begin + 8 + 16k) take x+1
// from mag2; everything else comes from mag.
//
// Software pipelined like the schedule in docs/theoretical_peak.xlsx: the next group's loads
// (center, the four neighbors that need their own load instruction, and its two direction
// masks) are issued before this group's compares. The other four neighbors are loaded by the
// compare instruction itself (memory operand), so they cost no extra instruction.
#include "nms_kernel.hpp"
#include <algorithm>
#include <atomic>
#include <cstdlib>
#include <cstddef>
#include <cstdint>
#include <immintrin.h>
#include <vector>

#define INLINE static inline __attribute__((always_inline))

INLINE __m256i load(const int32_t *p) {
  return _mm256_loadu_si256((const __m256i *)p);
}
// One kmovb straight from memory. GCC 8 otherwise (also for _load_mask8) loads the byte into a
// general register first and then moves it to the mask register: two instructions instead of one.
INLINE __mmask8 load_mask(const uint8_t *p) {
  __mmask8 k;
  __asm__("kmovb %1, %0" : "=k"(k) : "m"(*p));
  return k;
}

// The loads of one group that are issued early (one group ahead).
struct GroupLoads {
  __m256i center;        // m[x]
  __m256i right;         // m[x+1]
  __m256i below_right;   // b[x+1]
  __m256i below;         // b[x]
  __m256i below_left;    // b[x-1]
  __mmask8 odd, hi;      // direction bits of these 8 pixels
};
// Rows of the two copies: t/m/b = top/middle/bottom row of mag, t2/m2/b2 the same rows of mag2.
struct Rows {
  const int32_t *t, *m, *b, *t2, *m2, *b2;
};
INLINE GroupLoads load_group(Rows r, int x, const uint8_t *odd, const uint8_t *hi, bool even) {
  GroupLoads g;
  g.center = load(r.m + x);
  g.right = load((even ? r.m : r.m2) + x + 1);
  g.below_right = load((even ? r.b : r.b2) + x + 1);
  g.below = load(r.b + x);
  g.below_left = load((even ? r.b2 : r.b) + x - 1);
  g.odd = load_mask(odd);
  g.hi = load_mask(hi);
  return g;
}

// Compare, select and store one group. The left / top neighbors are loaded by the compares.
INLINE void finish_group(GroupLoads g, Rows r, int32_t *dst, int x, bool even) {
  const int32_t *left_m = even ? r.m2 : r.m, *left_t = even ? r.t2 : r.t, *right_t = even ? r.t : r.t2;
  // k_d: center is a local maximum along direction d (strictly above a, at least b).
  __m256i k0 = _mm256_andnot_si256(_mm256_cmpgt_epi32(g.right, g.center),
                                   _mm256_cmpgt_epi32(g.center, load(left_m + x - 1)));
  __m256i k1 = _mm256_andnot_si256(_mm256_cmpgt_epi32(g.below_right, g.center),
                                   _mm256_cmpgt_epi32(g.center, load(left_t + x - 1)));
  __m256i k2 = _mm256_andnot_si256(_mm256_cmpgt_epi32(g.below, g.center),
                                   _mm256_cmpgt_epi32(g.center, load(r.t + x)));
  __m256i k3 = _mm256_andnot_si256(_mm256_cmpgt_epi32(g.below_left, g.center),
                                   _mm256_cmpgt_epi32(g.center, load(right_t + x + 1)));
  // 0: k0, 45: k1, 90: k2, 135: k3
  __m256i k = _mm256_mask_blend_epi32(g.odd, _mm256_mask_blend_epi32(g.hi, k0, k2),
                                      _mm256_mask_blend_epi32(g.hi, k1, k3));
  _mm256_storeu_si256((__m256i *)(dst + x), _mm256_and_si256(g.center, k));
}

// One pipelined step: load group j+1 of the block, then finish group j. Returns group j+1's loads.
// (j is a constant after inlining, so even / odd costs no instruction.)
INLINE GroupLoads step(GroupLoads current, Rows r, int32_t *dst, int x, const uint8_t *odd,
                       const uint8_t *hi, int j) {
  GroupLoads next = load_group(r, x + 8 * (j + 1), odd + j + 1, hi + j + 1, (j + 1) % 2 == 0);
  finish_group(current, r, dst, x + 8 * j, j % 2 == 0);
  return next;
}

extern "C" __attribute__((noinline)) void
nms_i32_repeat(const int32_t *mag, const int32_t *mag2, const uint8_t *odd, const uint8_t *hi,
               int32_t *out, int stride, int begin, int n, long reps) {
  const Rows r = {mag, mag + stride, mag + 2 * stride, mag2, mag2 + stride, mag2 + 2 * stride};
  for (long pass = 0; pass < reps; ++pass) {
    // ko, kh: this block's 16 bytes of direction bits (16 groups of 8 pixels)
    const uint8_t *ko = odd, *kh = hi;
    for (int x = begin; x < begin + n; x += 128, ko += 16, kh += 16) {
      // 16 groups (128 pixels), written out so there is no inner loop. Group 15 has no next
      // group in this block, so it is finished on its own (no loads past the block).
      GroupLoads g = load_group(r, x, ko, kh, true);
      g = step(g, r, out, x, ko, kh, 0);
      g = step(g, r, out, x, ko, kh, 1);
      g = step(g, r, out, x, ko, kh, 2);
      g = step(g, r, out, x, ko, kh, 3);
      g = step(g, r, out, x, ko, kh, 4);
      g = step(g, r, out, x, ko, kh, 5);
      g = step(g, r, out, x, ko, kh, 6);
      g = step(g, r, out, x, ko, kh, 7);
      g = step(g, r, out, x, ko, kh, 8);
      g = step(g, r, out, x, ko, kh, 9);
      g = step(g, r, out, x, ko, kh, 10);
      g = step(g, r, out, x, ko, kh, 11);
      g = step(g, r, out, x, ko, kh, 12);
      g = step(g, r, out, x, ko, kh, 13);
      g = step(g, r, out, x, ko, kh, 14);
      finish_group(g, r, out, x + 120, false);
    }
    // Compiler barrier only, in C++: ensure every pass executes; no CPU fence
    // instruction.
    std::atomic_signal_fence(std::memory_order_seq_cst);
  }
}

// Full-image entry point consumes the public Sobel output (int32 magnitude
// squares, uint8 direction bins). Packing the bins into direction bits and
// arbitrary-width tails are outside the hot loop.
void nms_kernel(int w, int h, const int32_t *mag, const uint8_t *bin,
                int32_t *out) {
  if (w <= 0 || h <= 0)
    return;
  std::fill(out, out + size_t(w) * h, int32_t(0));
  if (w < 3 || h < 3)
    return;
  const int vector_pixels = ((w - 2) / 128) * 128;
  // The two copies the hot loop needs: row stride a multiple of 16 values, pixel x of a row at
  // index 15 + x, so pixel 1 (the first group) starts on a 64-byte boundary in copy 1 and 32
  // bytes off it in copy 2.
  const int stride = (w + 15 + 15) / 16 * 16;
  int32_t *copy1 = nullptr, *copy2 = nullptr;
  if (vector_pixels) {
    copy1 = static_cast<int32_t *>(std::aligned_alloc(64, size_t(stride) * h * 4 + 64));
    copy2 = static_cast<int32_t *>(std::aligned_alloc(64, size_t(stride) * h * 4 + 128));
    for (int y = 0; y < h; ++y)
      for (int x = 0; x < w; ++x) {
        copy1[size_t(y) * stride + 15 + x] = mag[size_t(y) * w + x];
        copy2[8 + size_t(y) * stride + 15 + x] = mag[size_t(y) * w + x];
      }
  }
  std::vector<uint8_t> row_odd(vector_pixels / 8 + 1), row_hi(vector_pixels / 8 + 1);
  for (int y = 1; y < h - 1; ++y) {
    const size_t row = size_t(y) * w;
    if (vector_pixels) {
      nms_pack_dirs(bin + row, 1, vector_pixels, row_odd.data(), row_hi.data());
      const size_t top = size_t(y - 1) * stride + 15;
      nms_i32_repeat(copy1 + top, copy2 + 8 + top, row_odd.data(), row_hi.data(), out + row,
                     stride, 1, vector_pixels, 1);
    }
    for (int x = 1 + vector_pixels; x < w - 1; ++x) {
      const size_t i = row + x;
      const int d = bin[i];
      const int delta = d == 0 ? 1 : d == 45 ? w + 1 : d == 90 ? w : w - 1;
      out[i] = mag[i] > mag[i - delta] && mag[i] >= mag[i + delta] ? mag[i] : 0;
    }
  }
  std::free(copy1);
  std::free(copy2);
}
