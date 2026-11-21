#pragma once
#include <cstdint>

// Exact nonnegative squared magnitudes and canonical bins 0/45/90/135 from
// Sobel. Arrays have w*h elements and do not overlap. Output borders are zero.
// Supports arbitrary positive dimensions; nonpositive dimensions are a no-op.
void nms_kernel(int w, int h, const int32_t *mag_sq, const uint8_t *bin,
                int32_t *out);

// Hot row loop (256-bit AVX2 vectors + AVX-512VL mask registers): 16 groups of
// 8 pixels (128 outputs) per iteration. mag points to the top of three
// stride-wide rows; mag2 holds the same values (it is read where mag would need
// a load that crosses a 64-byte cache line; fastest when mag + begin is 64-byte
// aligned, mag2 + begin 32 bytes off, and stride a multiple of 16; any layout
// gives correct results). out points to the center row. odd and hi are the direction
// bits of pixels begin .. begin+n-1, one bit per pixel, 8 pixels per byte (bit j
// of byte g is pixel begin + 8g + j): odd = 45 or 135, hi = 90 or 135.
// nms_pack_dirs writes them. Requires 1 <= begin, n >= 0 divisible by 128,
// begin+n < stride, reps >= 0 and nonoverlapping buffers. Only [begin,
// begin+n) is written. Repetition is inside this function so benchmark timing
// has no per-row calls.
extern "C" void nms_i32_repeat(const int32_t *mag, const int32_t *mag2, const uint8_t *odd,
                               const uint8_t *hi, int32_t *out, int stride,
                               int begin, int n, long reps);

// Packs canonical bins (0, 45, 90 or 135) at bin[begin .. begin+n-1] into
// nms_i32_repeat's direction bits. n is a multiple of 8; odd and hi get n/8 bytes.
// 45 and 135 are odd (bit 0 of the bin); 90 and 135 have bit 1 set.
template <class Bin>
static inline void nms_pack_dirs(const Bin *bin, int begin, int n, uint8_t *odd,
                                 uint8_t *hi) {
  for (int g = 0; g < n / 8; ++g) {
    unsigned o = 0, h = 0;
    for (int j = 0; j < 8; ++j) {
      const unsigned d = unsigned(bin[begin + 8 * g + j]);
      o |= (d & 1u) << j;
      h |= ((d >> 1) & 1u) << j;
    }
    odd[g] = uint8_t(o);
    hi[g] = uint8_t(h);
  }
}
