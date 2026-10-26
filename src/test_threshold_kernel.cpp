#include "threshold_kernel.hpp"
#include <cstdio>
#include <random>
#include <stdexcept>
#include <vector>

static uint8_t reference(int32_t m, int64_t low_sq, int64_t high_sq) {
  return m > high_sq ? 2 : (m > low_sq ? 1 : 0);
}
// Values around both thresholds, around the int16 saturation point, and the full NMS range.
static int32_t magnitude(std::mt19937 &rng, int kind, int64_t low_sq, int64_t high_sq) {
  static const int32_t limits[] = {0, 1, 32766, 32767, 32768, 65535, 65536, 2080800};
  if (kind == 0)
    return int32_t(low_sq) - 2 + int32_t(rng() % 5);
  if (kind == 1)
    return int32_t(high_sq) - 2 + int32_t(rng() % 5);
  if (kind == 2)
    return limits[rng() % 8];
  return int32_t(rng() % 2080801);
}
int main() try {
  std::mt19937 rng(18645);
  long arrays = 0, ranges = 0;
  // Default (50, 100), the int16 limit, thresholds the int16 path cannot hold, and low = 0.
  const int64_t thresholds[][2] = {{2500, 10000}, {0, 1}, {32765, 32766}, {2500, 32767},
                                   {40000, 90000}, {0, 2080800}};
  for (auto &t : thresholds)
    for (size_t n : {0, 1, 31, 63, 64, 65, 127, 128, 129, 1000, 4096, 4099})
      for (int kind = 0; kind < 4; ++kind) {
        std::vector<int32_t> m(n);
        std::vector<uint8_t> out(n + 1, 77), want(n + 1, 77);
        for (size_t i = 0; i < n; ++i) {
          m[i] = magnitude(rng, kind, t[0], t[1]);
          if (m[i] < 0)
            m[i] = 0;
          want[i] = reference(m[i], t[0], t[1]);
        }
        threshold_kernel(n, m.data(), out.data(), t[0], t[1]);
        if (out != want) {
          fprintf(stderr, "mismatch n=%zu kind=%d low_sq=%lld high_sq=%lld\n", n, kind,
                  (long long)t[0], (long long)t[1]);
          return 1;
        }
        ++arrays;
      }
  // Direct hot-loop calls: unaligned starts, zero work, repeated passes, no write past n.
  for (int offset : {0, 1, 4, 13})
    for (long n : {0L, 64L, 128L, 640L})
      for (long reps : {0L, 1L, 3L}) {
        std::vector<int32_t> storage(n + offset);
        std::vector<uint8_t> out_storage(n + offset + 64, 77);
        int32_t *m = storage.data() + offset;
        uint8_t *out = out_storage.data() + offset;
        for (long i = 0; i < n; ++i)
          m[i] = magnitude(rng, int(rng() % 4), 2500, 10000);
        threshold_i16_repeat(m, out, n, 2500, 10000, reps);
        for (long i = -offset; i < n + 64; ++i) {
          uint8_t want = reps > 0 && i >= 0 && i < n ? reference(m[i], 2500, 10000) : 77;
          if (out[i] != want)
            throw std::runtime_error("hot-loop range/sentinel mismatch");
        }
        ++ranges;
      }
  printf("PASS: %ld arrays and %ld hot-loop ranges; threshold ties, int16 saturation, "
         "int32 fallback, tails, offsets, zero work\n",
         arrays, ranges);
  return 0;
} catch (const std::exception &e) {
  fprintf(stderr, "FAIL: %s\n", e.what());
  return 1;
}
