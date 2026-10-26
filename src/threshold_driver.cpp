// Times the double-threshold hot loop (threshold_i16_repeat) with data in L1, and the whole
// threshold_kernel against the scalar loop of canny_part2.cpp on 1080p and 4K arrays.
// Hardware core cycles are mandatory (perf_event_open); no estimated-cycle fallback.
//
//   threshold_driver.x            hot loop at several widths
//   threshold_driver.x N [reps]   hot loop at width N (a multiple of 64)
//   threshold_driver.x whole      whole arrays, kernel vs scalar
//   threshold_driver.x test       correctness only
#include "perf_counter.hpp"
#include "threshold_kernel.hpp"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <random>
#include <stdexcept>
#include <vector>

static constexpr int64_t LOW_SQ = 2500, HIGH_SQ = 10000;   // --low 50 --high 100, squared

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

// The scalar double threshold of canny_part2.cpp (this file is built with -fno-tree-vectorize).
__attribute__((noinline)) static void scalar_threshold(size_t n, const int32_t *in, uint8_t *out,
                                                       int64_t low_sq, int64_t high_sq) {
  for (size_t i = 0; i < n; ++i)
    out[i] = in[i] > high_sq ? 2 : (in[i] > low_sq ? 1 : 0);
}

// NMS-like values: mostly suppressed (0), most survivors below low, a few weak and strong.
static void fill(int32_t *in, size_t n, uint32_t seed) {
  std::mt19937 rng(seed);
  for (size_t i = 0; i < n; ++i) {
    unsigned r = rng() % 100;
    in[i] = r < 80 ? 0
            : r < 95 ? int32_t(1 + rng() % LOW_SQ)
            : r < 98 ? int32_t(LOW_SQ + 1 + rng() % (HIGH_SQ - LOW_SQ))
                     : int32_t(HIGH_SQ + 1 + rng() % (2080800 - HIGH_SQ));
  }
}

static void verify(const int32_t *in, const uint8_t *out, size_t n) {
  for (size_t i = 0; i < n; ++i)
    if (out[i] != (in[i] > HIGH_SQ ? 2 : (in[i] > LOW_SQ ? 1 : 0)))
      throw std::runtime_error("output incorrect");
}

static void benchmark(long n, long reps, int samples) {
  if (n < 64 || n % 64 || reps < 1 || samples < 1)
    throw std::runtime_error("width must be a positive multiple of 64");
  // Output 2 KB past a page boundary so its stores do not alias the input loads (4K aliasing).
  Buffer<int32_t> in(n, 0);
  Buffer<uint8_t> out(n + 64, 2048);
  fill(in.p, n, 42);
  threshold_i16_repeat(in.p, out.p, n, LOW_SQ, HIGH_SQ, 3000);
  verify(in.p, out.p, n);
  PerfCounter ctr;
  std::vector<double> cpp, ghz, ipp;
  for (int s = 0; s < samples; ++s) {
    auto a = ctr.read_now();
    threshold_i16_repeat(in.p, out.p, n, LOW_SQ, HIGH_SQ, reps);
    auto b = ctr.read_now();
    PerfDelta d(a, b);
    double px = double(n) * reps;
    cpp.push_back(d.cycles / px);
    ghz.push_back(d.ghz);
    ipp.push_back(d.instructions / px);
  }
  verify(in.p, out.p, n);
  printf("%ld\t%.4f\t1\t(%.4f cycles/pixel, %.2f nominal GHz, %ld bytes, %.4f instructions/pixel)\n",
         n, 1 / median(cpp), median(cpp), median(ghz), n * 5, median(ipp));
}

// Whole arrays: one call per sample, median over samples, kernel and scalar on the same data.
static void whole(int w, int h, int samples) {
  size_t n = size_t(w) * h;
  std::vector<int32_t> in(n);
  std::vector<uint8_t> out(n), want(n);
  fill(in.data(), n, 7);
  scalar_threshold(n, in.data(), want.data(), LOW_SQ, HIGH_SQ);
  PerfCounter ctr;
  auto time = [&](auto fn) {
    std::vector<double> cyc, ghz;
    fn();
    for (int s = 0; s < samples; ++s) {
      auto a = ctr.read_now();
      fn();
      auto b = ctr.read_now();
      PerfDelta d(a, b);
      cyc.push_back(d.cycles);
      ghz.push_back(d.ghz);
    }
    double c = median(cyc), g = median(ghz);
    return std::make_pair(c, c / (g * 1e6));
  };
  auto k = time([&] { threshold_kernel(n, in.data(), out.data(), LOW_SQ, HIGH_SQ); });
  if (out != want)
    throw std::runtime_error("whole-array kernel output incorrect");
  auto s = time([&] { scalar_threshold(n, in.data(), want.data(), LOW_SQ, HIGH_SQ); });
  printf("%dx%d\t%.4f\t%.3f\t%.4f\t%.3f\t%.2fx\n", w, h, k.first / n, k.second, s.first / n,
         s.second, s.first / k.first);
}

int main(int argc, char **argv) try {
  for (long n : {64L, 128L, 192L, 1024L, 4096L}) {
    Buffer<int32_t> in(n, 4);
    Buffer<uint8_t> out(n + 64, 100);
    fill(in.p, n, uint32_t(n));
    memset(out.p, 77, n + 64);
    threshold_i16_repeat(in.p, out.p, n, LOW_SQ, HIGH_SQ, 2);
    verify(in.p, out.p, n);
    for (int i = 0; i < 64; ++i)
      if (out.p[n + i] != 77)
        throw std::runtime_error("wrote past the end");
  }
  if (argc > 1 && !strcmp(argv[1], "test")) {
    printf("PASS hot loop: values around both thresholds and the full NMS range\n");
    return 0;
  }
  if (argc > 1 && !strcmp(argv[1], "whole")) {
    printf("Double threshold, whole arrays: threshold_kernel vs the scalar loop of canny_part2.cpp.\n");
    printf("One call per sample, median of 21; arrays reused, so 1080p (10 MB) can sit in L3 and 4K (41 MB) cannot.\n");
    printf("size\tkernel cycles/pixel\tkernel ms\tscalar cycles/pixel\tscalar ms\tspeedup\n");
    whole(1920, 1080, 21);
    whole(3840, 2160, 21);
    return 0;
  }
  printf("Double threshold: AVX2 (256-bit), int32 squared magnitude in, uint8 label out, 64 pixels per loop.\n");
  printf("One row in L1; median of samples; setup/warmup excluded.\n");
  printf("Core cycles from perf; nominal GHz uses core/reference cycles x 2.1.\n");
  printf("Pin to a quiet core and check its SMT sibling. Run make threshold-count for the compiled-code bound.\n");
  printf("width\tpixels/cycle\tcorrect\t(cycles/pixel, nominal GHz, working set, instructions/pixel)\n");
  if (argc > 1)
    benchmark(atol(argv[1]), argc > 2 ? atol(argv[2]) : 200000, 5);
  else
    for (long n : {256L, 512L, 1024L, 2048L, 4096L, 6144L})
      benchmark(n, 4000000 / n * 64, 5);
  return 0;
} catch (const std::exception &e) {
  fprintf(stderr, "ERROR: %s\n", e.what());
  return 1;
}
