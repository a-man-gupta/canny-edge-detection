// Hysteresis on a slab: grow strong edges through eight-connected weak labels.
#include "hysteresis_kernel.hpp"
#include <algorithm>
#include <atomic>
#include <immintrin.h>

template<bool exact_masks, bool zero_side_borders>
static void track(int, int, const uint8_t*, uint8_t*, std::vector<size_t>&);
__attribute__((target("avx512bw,avx512vl"))) static bool
track256(int, const uint8_t*, uint8_t*, std::vector<size_t>&);
__attribute__((target("avx512bw,avx512vl"))) static bool
hysteresis_words(int, int, const uint8_t*, uint8_t*, std::vector<size_t>&);

void hysteresis_slab(int w, int h, const uint8_t *labels, uint8_t *edges,
                     std::vector<size_t> &queue) {
  if (w > 0 && w % 64 == 0 && h > 0 && __builtin_cpu_supports("avx512bw") &&
      (w == 256 ? track256(h, labels, edges, queue)
                : hysteresis_words(w, h, labels, edges, queue)))
    return;
  track<true, true>(w, h, labels, edges, queue);
}

// Pack labels, propagate reachability, then write the edge bytes.
__attribute__((target("avx512bw,avx512vl"))) static bool
hysteresis_words(int w, int h, const uint8_t *labels, uint8_t *out,
                 std::vector<size_t> &scratch) {
  const int words = w / 64, pitch = words + 2;
  const size_t plane = (size_t(h) + 2) * pitch;
  // A one-word border makes all eight neighbor reads valid. Reuse the caller's
  // allocation.
  scratch.assign(plane * 2, 0);
  uint64_t *reached = scratch.data() + pitch + 1;
  uint64_t *weak = reached + plane;
  const auto one = _mm512_set1_epi8(1), two = _mm512_set1_epi8(2);
  for (int y = 0; y < h; ++y)
    for (int x = 0; x < words; ++x) {
      const auto *p = labels + size_t(y) * w + x * 64;
      const auto values = _mm512_loadu_si512(p);
      size_t i = size_t(y) * pitch + x;
      weak[i] = _mm512_cmpeq_epi8_mask(values, one);
      reached[i] = _mm512_cmpeq_epi8_mask(values, two);
    }
  // The bounded sweeps leave long winding paths to the linear-time queue.
  bool previous_changed = true;
  for (int sweep = 0, dir = 1; sweep < 16; ++sweep, dir = -dir) {
    bool changed = false;
    for (int row = 0; row < h; ++row) {
      int y = dir == 1 ? row : h - 1 - row;
      uint64_t *r = reached + size_t(y) * pitch;
      const auto *adjacent = r - dir * pitch;
      for (int col = 0; col < words; ++col) {
        int x = dir == 1 ? col : words - 1 - col;
        uint64_t seeds = r[x] | adjacent[x];
        uint64_t neighbors = seeds | (seeds << 1) | (seeds >> 1) |
                             ((r[x - 1] | adjacent[x - 1]) >> 63) |
                             ((r[x + 1] | adjacent[x + 1]) << 63);
        const uint64_t allowed = weak[size_t(y) * pitch + x];
        uint64_t fresh = neighbors & allowed & ~r[x];
        if (!fresh)
          continue;
        changed = true;
        do {
          r[x] |= fresh;
          fresh = ((fresh << 1) | (fresh >> 1)) & allowed & ~r[x];
        } while (fresh);
      }
    }
    if (!changed && !previous_changed)
      break;
    previous_changed = changed;
    if (sweep == 15)
      return false;
  }
  for (int y = 0; y < h; ++y)
    for (int x = 0; x < words; ++x) {
      uint64_t bits = reached[size_t(y) * pitch + x];
      auto *p = out + size_t(y) * w + x * 64;
      _mm512_storeu_si512(p, _mm512_maskz_set1_epi8(bits, -1));
    }
  scratch.clear();
  return true;
}

#include "detail/hysteresis_support.inc"
