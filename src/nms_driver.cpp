// Times the default integer AVX2 NMS hot loop only, with the tested 16-group
// schedule. Hardware core cycles are mandatory. Width/pixel definitions are
// printed explicitly.
#include "nms_kernel.hpp"
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <linux/perf_event.h>
#include <random>
#include <stdexcept>
#include <sys/syscall.h>
#include <unistd.h>
#include <vector>
static constexpr int nms_rows() { return 1; }
static constexpr int nms_step() { return 128; }
template <class T> struct Buffer {
  void *base;
  T *p;
  Buffer(size_t n, size_t offset) {
    if (posix_memalign(&base, 4096, n * sizeof(T) + 4096))
      throw std::bad_alloc();
    p = (T *)((char *)base + offset);
  }
  ~Buffer() { free(base); }
};
struct Counter {
  int fd = -1, other = -1, ref = -1;
  Counter(bool raw, uint64_t event) {
    perf_event_attr a{};
    a.size = sizeof(a);
    a.type = PERF_TYPE_HARDWARE;
    a.config = PERF_COUNT_HW_CPU_CYCLES;
    a.exclude_kernel = 1;
    a.exclude_hv = 1;
    a.pinned = 1;
    a.read_format = PERF_FORMAT_GROUP | PERF_FORMAT_TOTAL_TIME_ENABLED |
                    PERF_FORMAT_TOTAL_TIME_RUNNING;
    fd = int(syscall(__NR_perf_event_open, &a, 0, -1, -1, 0));
    a.pinned = 0;
    a.type = raw ? PERF_TYPE_RAW : PERF_TYPE_HARDWARE;
    a.config = raw ? event : uint64_t(PERF_COUNT_HW_INSTRUCTIONS);
    other = int(syscall(__NR_perf_event_open, &a, 0, -1, fd, 0));
    a.type = PERF_TYPE_HARDWARE;
    a.config = PERF_COUNT_HW_REF_CPU_CYCLES;
    ref = int(syscall(__NR_perf_event_open, &a, 0, -1, fd, 0));
    if (fd < 0 || other < 0 || ref < 0)
      throw std::runtime_error("perf_event_open failed");
  }
  ~Counter() {
    if (ref >= 0)
      close(ref);
    if (other >= 0)
      close(other);
    if (fd >= 0)
      close(fd);
  }
  std::vector<uint64_t> readout() {
    std::vector<uint64_t> b(6);
    if (read(fd, b.data(), 48) != 48 || b[0] != 3)
      throw std::runtime_error("counter read failed");
    return b;
  }
};
static int32_t expected(const int32_t *mag, const int16_t *bins, int stride,
                        int row, int x) {
  int i = (row + 1) * stride + x;
  int d = bins[row * stride + x];
  int delta = d == 0 ? 1 : d == 45 ? stride + 1 : d == 90 ? stride : stride - 1;
  return mag[i] > mag[i - delta] && mag[i] >= mag[i + delta] ? mag[i] : 0;
}
static long check(int n, int pattern, int offset) {
  int rows = nms_rows(), stride = n + 32;
  size_t count = size_t(rows) * stride;
  Buffer<int32_t> mag(size_t(rows + 2) * stride, offset), out(count, 2048);
  Buffer<int32_t> mag2(size_t(rows + 2) * stride, offset + 32);   // same values, 32 bytes off
  Buffer<int16_t> bins(count, 1024);   // canonical bins, for the reference
  Buffer<uint8_t> odd(count / 8 + 64, 3072), hi(count / 8 + 64, 3584);   // the bins as direction bits
  std::mt19937 rng(17 + n + pattern);
  for (int i = 0; i < (rows + 2) * stride; ++i)
    mag.p[i] = pattern == 0   ? 0
               : pattern == 1 ? 2080800
               : pattern == 2 ? int(rng() % 4)
                              : int(rng() % 2080801);
  std::copy(mag.p, mag.p + size_t(rows + 2) * stride, mag2.p);
  for (size_t i = 0; i < count; ++i) {
    bins.p[i] = int16_t((rng() % 4) * 45);
    out.p[i] = -12345;
  }
  nms_pack_dirs(bins.p, 16, n, odd.p, hi.p);
  nms_i32_repeat(mag.p, mag2.p, odd.p, hi.p, out.p, stride, 16, n, 3);
  for (int r = 0; r < rows; ++r)
    for (int x = 0; x < stride; ++x) {
      int32_t want = x >= 16 && x < 16 + n
                         ? expected(mag.p, bins.p, stride, r, x)
                         : -12345;
      if (out.p[r * stride + x] != want)
        throw std::runtime_error("incorrect output or sentinel overwrite");
    }
  return long(rows) * n;
}
static void benchmark(int n, long reps, int samples) {
  int rows = 1, step = nms_step();
  if (n < step || n % step || reps < 1 || samples < 1)
    throw std::runtime_error("width must be a positive multiple of 128; "
                             "repetitions and samples must be positive");
  int stride = n + 32;
  size_t count = size_t(rows) * stride;
  Buffer<int32_t> mag(size_t(rows + 2) * stride, 0), out(count, 2048);
  Buffer<int32_t> mag2(size_t(rows + 2) * stride, 32);   // same values, 32 bytes off
  Buffer<int16_t> bins(count, 1024);   // canonical bins, for the reference
  Buffer<uint8_t> odd(count / 8 + 64, 3072), hi(count / 8 + 64, 3584);   // the bins as direction bits
  std::mt19937 rng(42);
  for (int i = 0; i < (rows + 2) * stride; ++i)
    mag.p[i] = int(rng() % 2080801);
  std::copy(mag.p, mag.p + size_t(rows + 2) * stride, mag2.p);
  for (size_t i = 0; i < count; ++i) {
    bins.p[i] = int16_t((rng() % 4) * 45);
    out.p[i] = -12345;
  }
  nms_pack_dirs(bins.p, 16, n, odd.p, hi.p);
  nms_i32_repeat(mag.p, mag2.p, odd.p, hi.p, out.p, stride, 16, n, 3000);
  for (int x = 16; x < 16 + n; ++x)
    if (out.p[x] != expected(mag.p, bins.p, stride, 0, x))
      throw std::runtime_error("warmup output incorrect");
  Counter ctr(false, 0);
  std::vector<double> timings, frequencies, instructions;
  for (int s = 0; s < samples; ++s) {
    auto a = ctr.readout();
    nms_i32_repeat(mag.p, mag2.p, odd.p, hi.p, out.p, stride, 16, n, reps);
    auto b = ctr.readout();
    if (b[1] - a[1] != b[2] - a[2])
      throw std::runtime_error("counter multiplexing: sample rejected");
    if (b[5] == a[5])
      throw std::runtime_error("reference cycle counter returned zero");
    double px = double(n) * reps;
    timings.push_back(double(b[3] - a[3]) / px);
    frequencies.push_back(2.1 * double(b[3] - a[3]) / double(b[5] - a[5]));
    instructions.push_back(double(b[4] - a[4]) / px);
  }
  for (int x = 0; x < stride; ++x) {
    int32_t want = (x >= 16 && x < 16 + n)
                       ? expected(mag.p, bins.p, stride, 0, x)
                       : -12345;
    if (out.p[x] != want)
      throw std::runtime_error("timed output or sentinel incorrect");
  }
  auto median = [](std::vector<double> a) {
    std::sort(a.begin(), a.end());
    size_t k = a.size() / 2;
    return a.size() % 2 ? a[k] : (a[k - 1] + a[k]) * 0.5;
  };
  const double cpp = median(timings);
  printf("%d\t%d\t%.6f\t1\t(%.6f cycles/pixel, %.2f nominal GHz, %zu bytes, "
         "%.6f instructions/pixel)\n",
         stride, n, 1 / cpp, cpp, median(frequencies), size_t(stride) * 16 + size_t(stride) / 4,
         median(instructions));
}
int main(int argc, char **argv) try {
  long checked = 0;
  for (int groups : {1, 2, 3, 7, 16})
    for (int p = 0; p < 4; ++p)
      for (int off : {0, 4, 16, 32})
        checked += check(groups * nms_step(), p, off);
  if (argc > 1 && !strcmp(argv[1], "test")) {
    printf("PASS %ld pixels including ties, extrema, directions, offsets, "
           "sentinels\n",
           checked);
    return 0;
  }
  printf("NMS: AVX2 vectors + AVX-512VL masks, int32 squared magnitudes, 2 direction bits/pixel, 16 groups / "
         "128 pixels per loop.\n");
  printf("One output row; width includes 32 padding pixels. Median of samples; "
         "setup/warmup excluded.\n");
  printf("Core cycles from perf; nominal GHz uses core/reference cycles x 2.1. "
         "No estimated-cycle fallback.\n");
  printf("Pin to a quiet core and check its SMT sibling. Run make nms-count "
         "for the compiled-code bound.\n");
  printf("width\tpixels\tpixels/cycle\tcorrect\t(cycles/pixel, nominal GHz, "
         "working set, instructions/pixel)\n");
  if (argc > 1)
    benchmark(atoi(argv[1]), argc > 2 ? atol(argv[2]) : 120000,
              argc > 3 ? atoi(argv[3]) : 5);
  else
    for (int n : {128, 256, 512, 768, 1024, 1280, 1536})
      benchmark(n, 120000, 5);
  return 0;
} catch (const std::exception &e) {
  fprintf(stderr, "ERROR: %s\n", e.what());
  return 1;
}
