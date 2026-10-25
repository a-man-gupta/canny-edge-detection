#include "nms_kernel.hpp"
#include <algorithm>
#include <cstdio>
#include <random>
#include <stdexcept>
#include <vector>

static int32_t reference(const int32_t *m, uint8_t d, size_t i, int stride) {
  int delta = d == 0 ? 1 : d == 45 ? stride + 1 : d == 90 ? stride : stride - 1;
  return m[i] > m[i - delta] && m[i] >= m[i + delta] ? m[i] : 0;
}
static int32_t magnitude(std::mt19937 &rng, int kind) {
  static const int32_t limits[] = {0,     1,     32767,   32768,
                                   65535, 65536, 1040400, 2080800};
  if (kind == 0)
    return rng() % 4; // strict vs non-strict ties
  if (kind == 1)
    return 2080800;
  if (kind == 2)
    return limits[rng() % 8];
  return rng() % 2080801;
}
int main() try {
  std::mt19937 rng(18645);
  long images = 0, ranges = 0;
  std::vector<int> widths;
  for (int w = 1; w < 42; ++w)
    widths.push_back(w);
  for (int w : {126, 127, 128, 129, 130, 131, 255, 256,  257,  258,
                259, 385, 386, 387, 513, 514, 515, 1025, 1026, 1027})
    widths.push_back(w);
  for (int w : widths)
    for (int h : {1, 2, 3, 4, 6, 7, 10})
      for (int kind = 0; kind < 4; ++kind)
        for (int direction = -1; direction < 4; ++direction) {
          size_t n = size_t(w) * h;
          std::vector<int32_t> m(n), out(n, -12345), want(n, 0);
          std::vector<uint8_t> bins(n);
          for (size_t i = 0; i < n; ++i) {
            m[i] = magnitude(rng, kind);
            bins[i] = uint8_t(45 * (direction < 0 ? rng() % 4 : direction));
          }
          for (int y = 1; y < h - 1; ++y)
            for (int x = 1; x < w - 1; ++x) {
              size_t i = size_t(y) * w + x;
              want[i] = reference(m.data(), bins[i], i, w);
            }
          nms_kernel(w, h, m.data(), bins.data(), out.data());
          if (out != want) {
            fprintf(stderr, "image mismatch %dx%d pattern=%d direction=%d\n", w,
                    h, kind, direction);
            return 1;
          }
          ++images;
        }
  // Direct hot-loop ranges: vary the first column, alignment, zero work, and
  // exact halos.
  for (int begin : {1, 2, 7, 16})
    for (int n : {0, 128, 256, 384})
      for (int offset : {0, 1, 4, 8})
        for (long reps : {0L, 1L, 3L}) {
          int stride = begin + n + 1;
          std::vector<int32_t> storage(3 * stride + offset),
              out_storage(stride + offset, -12345);
          std::vector<int16_t> dir_storage(stride + offset);
          std::vector<uint8_t> odd_bits(stride / 8 + 8), hi_bits(stride / 8 + 8);
          int32_t *m = storage.data() + offset;
          int32_t *out = out_storage.data() + offset;
          int16_t *bins = dir_storage.data() + offset;
          for (int i = 0; i < 3 * stride; ++i)
            m[i] = magnitude(rng, 2);
          for (int x = 0; x < stride; ++x) {
            bins[x] = 45 * (rng() % 4);
          }
          nms_pack_dirs(bins, begin, n, odd_bits.data(), hi_bits.data());
          std::vector<int32_t> copy(m, m + 3 * stride);
          nms_i32_repeat(m, copy.data(), odd_bits.data(), hi_bits.data(), out, stride, begin, n, reps);
          for (int x = 0; x < stride; ++x) {
            int32_t want =
                reps > 0 && x >= begin && x < begin + n
                    ? reference(m, uint8_t(bins[x]), stride + x, stride)
                    : -12345;
            if (out[x] != want)
              throw std::runtime_error("hot-loop range/tie/sentinel mismatch");
          }
          for (int i = 0; i < offset; ++i)
            if (out_storage[i] != -12345)
              throw std::runtime_error("prefix overwritten");
          ++ranges;
        }
  nms_kernel(0, 3, nullptr, nullptr, nullptr);
  nms_kernel(3, 0, nullptr, nullptr, nullptr);
  printf("PASS: %ld images and %ld hot-loop ranges; ties, full magnitude "
         "range, directions, borders, tails, offsets, zero work\n",
         images, ranges);
  return 0;
} catch (const std::exception &e) {
  fprintf(stderr, "FAIL: %s\n", e.what());
  return 1;
}
