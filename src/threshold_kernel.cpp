// Part 4 double-threshold kernel: int32 squared magnitude in, uint8 label (0/1/2) out.
//
// Per 64 pixels: 8 loads of 8 int32. vpackssdw packs pairs to int16 with signed saturation
// (values above 32767 become 32767, still above any threshold <= 32766), so the compares run
// on 16 lanes instead of 8. Two compares per 16 pixels give 0 / -1 masks; their sum is 0, -1
// or -2. vpacksswb packs to bytes, vpermd undoes the 128-bit lane interleave of the two packs,
// and vpabsb turns -1 / -2 into 1 / 2. Registers stay 256-bit (ymm).
#include "threshold_kernel.hpp"

#include <atomic>
#include <immintrin.h>

#define INLINE static inline __attribute__((always_inline))

INLINE __m256i load(const int32_t *p) { return _mm256_loadu_si256((const __m256i *)p); }

// 16 int16 lanes -> 0 / -1 / -2 per lane.
INLINE __m256i classify(__m256i w, __m256i low, __m256i high) {
  return _mm256_add_epi16(_mm256_cmpgt_epi16(w, low), _mm256_cmpgt_epi16(w, high));
}

// 32 pixels: four loads, packed to two int16 vectors, classified, packed to one byte vector.
// The packs work within 128-bit lanes, so the result's dwords (4 pixels each) hold pixels
// 0-3, 8-11, 16-19, 24-27 | 4-7, 12-15, 20-23, 28-31; order = {0,4,1,5,2,6,3,7} restores them.
INLINE __m256i block32(const int32_t *p, __m256i low, __m256i high, __m256i order) {
  __m256i w0 = _mm256_packs_epi32(load(p), load(p + 8));
  __m256i w1 = _mm256_packs_epi32(load(p + 16), load(p + 24));
  __m256i b = _mm256_packs_epi16(classify(w0, low, high), classify(w1, low, high));
  return _mm256_abs_epi8(_mm256_permutevar8x32_epi32(b, order));
}

extern "C" __attribute__((noinline)) void threshold_i16_repeat(const int32_t *mag_sq,
                                                               uint8_t *labels, long n,
                                                               int low_sq, int high_sq,
                                                               long reps) {
  const __m256i low = _mm256_set1_epi16(short(low_sq));
  const __m256i high = _mm256_set1_epi16(short(high_sq));
  const __m256i order = _mm256_setr_epi32(0, 4, 1, 5, 2, 6, 3, 7);
  for (long pass = 0; pass < reps; ++pass) {
    const int32_t *in = mag_sq;
    uint8_t *out = labels;
    for (const int32_t *end = mag_sq + n; in != end; in += 64, out += 64) {
      _mm256_storeu_si256((__m256i *)out, block32(in, low, high, order));
      _mm256_storeu_si256((__m256i *)(out + 32), block32(in + 32, low, high, order));
    }
    // Compiler barrier only: every pass executes; no fence instruction.
    std::atomic_signal_fence(std::memory_order_seq_cst);
  }
}

void threshold_kernel(size_t n, const int32_t *mag_sq, uint8_t *labels, int64_t low_sq,
                      int64_t high_sq) {
  size_t done = 0;
  if (low_sq >= 0 && low_sq < high_sq && high_sq <= 32766) {
    done = n / 64 * 64;
    threshold_i16_repeat(mag_sq, labels, long(done), int(low_sq), int(high_sq), 1);
  }
  for (size_t i = done; i < n; ++i)
    labels[i] = mag_sq[i] > high_sq ? 2 : (mag_sq[i] > low_sq ? 1 : 0);
}
