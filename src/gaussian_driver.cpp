// Driver for the Part 1 Gaussian kernel (gaussian_kernel.cpp).
//   ./gaussian_driver.x            correctness, per-phase row timings (L1), whole-image timings
//   ./gaussian_driver.x test       correctness only
//   ./gaussian_driver.x rows       per-phase / per-row timings only
//   ./gaussian_driver.x whole      whole-image timings only
// Core cycles come from the CPU counters (perf_counter.hpp). GHz is the average core clock of the
// sample (2.1 * core / reference cycles). Compare cycles/pixel with scripts/gaussian_peak_model.py.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <algorithm>
#include <cmath>
#include <string>
#include <sys/mman.h>
#include <vector>

#include "gaussian_kernel.hpp"
#include "perf_counter.hpp"

static const float SIGMA = 1.4f;

// The float blur of canny_scalar.cpp (5x5 direct, reflect, floor(v + 0.5)).
static void scalar_float_blur(int w, int h, const uint8_t* image, uint8_t* blur, float sigma) {
  float weights[5][5], sum = 0;
  for (int y = -2; y <= 2; ++y)
    for (int x = -2; x <= 2; ++x) {
      weights[y + 2][x + 2] = std::exp(-(x * x + y * y) / (2 * sigma * sigma));
      sum += weights[y + 2][x + 2];
    }
  for (auto& row : weights)
    for (float& x : row) x /= sum;
  auto reflect = [](int p, int length) {
    while (p < 0 || p >= length) p = p < 0 ? -p : 2 * length - 2 - p;
    return p;
  };
  for (int y = 0; y < h; ++y)
    for (int x = 0; x < w; ++x) {
      float value = 0;
      for (int j = -2; j <= 2; ++j)
        for (int k = -2; k <= 2; ++k)
          value += weights[j + 2][k + 2] * image[size_t(reflect(y + j, h)) * w + reflect(x + k, w)];
      blur[size_t(y) * w + x] = (uint8_t)std::clamp(std::floor(value + 0.5f), 0.0f, 255.0f);
    }
}

static uint8_t* alloc_u8(size_t n) {
  void* p = nullptr;
  if (posix_memalign(&p, 4096, n + 4096)) abort();
  return (uint8_t*)p;
}

// Exactly n bytes with an inaccessible page right after them (tail_guard) or right before them: any
// read or write outside [p, p+n) faults. Not freed (tests only).
static uint8_t* guarded(size_t n, bool tail_guard) {
  size_t pages = (n + 4095) / 4096;
  size_t total = (pages + 2) * 4096;
  uint8_t* base = (uint8_t*)mmap(nullptr, total, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  if (base == MAP_FAILED) abort();
  mprotect(base, 4096, PROT_NONE);
  mprotect(base + total - 4096, 4096, PROT_NONE);
  return tail_guard ? base + total - 4096 - n : base + 4096;
}

static void fill_image(uint8_t* a, int w, int h, int kind) {
  for (int y = 0; y < h; ++y)
    for (int x = 0; x < w; ++x) {
      uint8_t v = 0;
      switch (kind) {
        case 0: v = (uint8_t)(rand() & 255); break;
        case 1: v = 255; break;
        case 2: v = 0; break;
        case 3: v = ((x + y) & 1) ? 255 : 0; break;
        case 4: v = (uint8_t)(((x / 7) % 2) * 255); break;
        default: v = (uint8_t)((x * 3 + y * 5) & 255); break;
      }
      a[(size_t)y * w + x] = v;
    }
}

static int run_tests() {
  const GaussQ15 q = gaussian_q15(SIGMA);
  printf("sigma %.2f  Q15 weights c0 %d c1 %d c2 %d  (sum %d)\n", SIGMA, q.c0, q.c1, q.c2, q.c0 + 2 * q.c1 + 2 * q.c2);
  int sizes[][2] = {{5, 5},   {6, 7},   {15, 9},  {16, 8},  {17, 6},   {31, 5},  {32, 5},  {33, 11},
                    {47, 6},  {48, 7},  {63, 9},  {64, 8},  {65, 13},  {100, 17}, {127, 5}, {128, 9},
                    {129, 10}, {255, 12}, {256, 9}, {257, 7}, {641, 30}, {1920, 40}, {1921, 21}};
  int bad = 0, cases = 0;
  long total = 0, diff_float = 0;
  int max_diff_float = 0;
  for (auto& s : sizes) {
    int w = s[0], h = s[1];
    for (int kind = 0; kind < 6; ++kind) {
      // input and output sit flush against an inaccessible page (end guard, then start guard on the next
      // kind), so a vector read or write outside the w*h bytes faults instead of passing silently
      bool tail = kind % 2 == 0;
      uint8_t* in = guarded((size_t)w * h, tail);
      uint8_t* out = guarded((size_t)w * h, tail);
      uint8_t* ref = alloc_u8((size_t)w * h);
      uint8_t* fl = alloc_u8((size_t)w * h);
      fill_image(in, w, h, kind);
      GaussianWork* wk = gaussian_work_create(w);
      gaussian_u8(w, h, in, out, q, wk);
      gaussian_ref_q(w, h, in, ref, q);
      scalar_float_blur(w, h, in, fl, SIGMA);
      size_t mism = 0;
      for (size_t i = 0; i < (size_t)w * h; ++i) mism += out[i] != ref[i];
      ++cases;
      if (mism) { printf("MISMATCH %dx%d kind %d: %zu pixels differ from the integer contract\n", w, h, kind, mism); bad = 1; }
      // column strips (every strip width that leaves a last strip of >= 4 columns)
      for (int strip : {16, 32, 48, 64, 100, 128, 256}) {
        if (strip >= w || w % strip == 0 || w % strip < 4) { if (strip < w && w % strip != 0) continue; if (strip >= w) continue; }
        GaussianWork* sk = gaussian_work_create(strip);
        uint8_t* o2 = guarded((size_t)w * h, tail);
        gaussian_u8_strips(w, h, in, o2, q, sk, strip, strip % 32 ? 0 : 3);
        size_t m2 = 0;
        for (size_t i = 0; i < (size_t)w * h; ++i) m2 += o2[i] != ref[i];
        ++cases;
        if (m2) { printf("MISMATCH strips %d of %dx%d kind %d: %zu pixels\n", strip, w, h, kind, m2); bad = 1; }
        gaussian_work_destroy(sk);
      }
      for (size_t i = 0; i < (size_t)w * h; ++i) {
        int d = std::abs((int)out[i] - (int)fl[i]);
        diff_float += d != 0; max_diff_float = std::max(max_diff_float, d); ++total;
      }
      gaussian_work_destroy(wk);
      free(ref); free(fl);
    }
  }
  printf("correctness vs integer contract (%d cases, guard pages around input and output, strips included): %s\n",
         cases, bad ? "FAIL" : "ok, bit-exact");
  printf("vs the project's float blur: %.3f%% of pixels differ, max |diff| %d  (%ld pixels compared)\n",
         100.0 * diff_float / total, max_diff_float, total);
  return bad;
}

// ---- timing helpers ---------------------------------------------------------------------------------

struct Timing { double cpp, ghz; };

template <class F>
static Timing time_it(PerfCounter& pc, double pixels_per_call, double target_pixels, int samples, F&& f) {
  long reps = std::max(1L, (long)(target_pixels / pixels_per_call));
  f();                                                    // warm-up
  std::vector<double> cpp, ghz;
  for (int s = 0; s < samples; ++s) {
    auto a = pc.read_now();
    for (long r = 0; r != reps; ++r) f();
    auto b = pc.read_now();
    try {
      PerfDelta d(a, b);
      cpp.push_back(d.cycles / (pixels_per_call * reps));
      ghz.push_back(d.ghz);
    } catch (...) {}
  }
  if (cpp.empty()) return {0, 0};
  return {median(cpp), median(ghz)};
}

static void run_rows(PerfCounter& pc) {
  const GaussQ15 q = gaussian_q15(SIGMA);
  // empty loop: bring the core to its full clock first
  for (volatile int i = 0; i < 300000000; i++) {}
  printf("\nPer-phase row timings, buffers hot in L1/L2 (cycles per pixel; model floor for the 5x5 design:\n"
         "single-base 81.25/160 = 0.508, five-pointer 86.25/160 = 0.539 total)\n");
  printf("%6s %8s %8s %8s %8s %8s %6s   %s\n", "width", "expand", "horiz", "vert", "sum", "pipeline", "GHz", "ring+scratch");
  for (int w : {256, 512, 640, 1024, 1280, 1920, 3840, 7680}) {
    uint8_t* in = alloc_u8((size_t)w);
    uint8_t* out = alloc_u8((size_t)w + 64);
    fill_image(in, w, 1, 0);
    GaussianWork* wk = gaussian_work_create(w);
    int16_t* scratch = gaussian_scratch(wk);
    gaussian_expand_row(in, scratch, w);
    for (int s = 0; s < 5; ++s) gaussian_horiz_row(scratch, gaussian_ring_row(wk, s), w, q);
    const int16_t* rows[5];
    for (int j = 0; j < 5; ++j) rows[j] = gaussian_ring_row(wk, j);
    const double T = 2e8;
    Timing te = time_it(pc, w, T, 3, [&] { gaussian_expand_row(in, scratch, w); asm volatile("" ::: "memory"); });
    Timing th = time_it(pc, w, T, 3, [&] { gaussian_horiz_row(scratch, gaussian_ring_row(wk, 0), w, q); asm volatile("" ::: "memory"); });
    Timing tv = time_it(pc, w, T, 3, [&] { gaussian_vert_row(rows, out, w, q); asm volatile("" ::: "memory"); });
    int slot = 0;
    Timing tp = time_it(pc, w, T, 3, [&] {      // one steady-state output row of gaussian_u8
      gaussian_expand_row(in, scratch, w);
      gaussian_horiz_row(scratch, gaussian_ring_row(wk, slot), w, q);
      slot = slot == 4 ? 0 : slot + 1;
      const int16_t* r[5];
      for (int j = 0; j < 5; ++j) r[j] = gaussian_ring_row(wk, (slot + j) % 5);
      gaussian_vert_row(r, out, w, q);
      asm volatile("" ::: "memory");
    });
    double ring_kib = (5.0 * w * 2 + 2.0 * w * 2) / 1024.0;
    printf("%6d %8.4f %8.4f %8.4f %8.4f %8.4f %6.2f   %.1f KiB\n", w, te.cpp, th.cpp, tv.cpp, te.cpp + th.cpp + tv.cpp, tp.cpp, tp.ghz, ring_kib);
    gaussian_work_destroy(wk);
    free(in); free(out);
  }
}

static void run_whole(PerfCounter& pc) {
  const GaussQ15 q = gaussian_q15(SIGMA);
  printf("\nWhole image (uint8 in -> uint8 out, single core), median of 5 samples\n");
  printf("%-10s %10s %10s %6s %10s\n", "size", "cycles/px", "px/cycle", "GHz", "Mpx/s");
  int sizes[][2] = {{1280, 720}, {1920, 1080}, {3840, 2160}, {7680, 4320}};
  for (auto& s : sizes) {
    int w = s[0], h = s[1];
    uint8_t* in = alloc_u8((size_t)w * h);
    uint8_t* out = alloc_u8((size_t)w * h);
    fill_image(in, w, h, 0);
    GaussianWork* wk = gaussian_work_create(w);
    Timing t = time_it(pc, (double)w * h, 6e8, 5, [&] { gaussian_u8(w, h, in, out, q, wk); asm volatile("" ::: "memory"); });
    printf("%dx%-6d %10.4f %10.3f %6.2f %10.1f\n", w, h, t.cpp, 1.0 / t.cpp, t.ghz, t.ghz * 1e3 / t.cpp);
    gaussian_work_destroy(wk);
    free(in); free(out);
  }
  printf("\nHeight sweep at width 1920 (where the image lives changes the cost; 3 rows of ring fill are ~%.3f cyc/px at h=128)\n", 3 * 0.35 / 128);
  printf("%-10s %10s %14s\n", "size", "cycles/px", "in+out bytes");
  for (int h : {16, 64, 128, 256, 512, 1080}) {
    int w = 1920;
    uint8_t* in = alloc_u8((size_t)w * h);
    uint8_t* out = alloc_u8((size_t)w * h);
    fill_image(in, w, h, 0);
    GaussianWork* wk = gaussian_work_create(w);
    Timing t = time_it(pc, (double)w * h, 6e8, 5, [&] { gaussian_u8(w, h, in, out, q, wk); asm volatile("" ::: "memory"); });
    printf("%dx%-6d %10.4f %12.1f KiB\n", w, h, t.cpp, 2.0 * w * h / 1024);
    gaussian_work_destroy(wk);
    free(in); free(out);
  }
  printf("\nColumn strips (strip = columns per pass; pf = input rows prefetched ahead), cycles/px\n");
  printf("%-10s %9s", "size", "full-row");
  int strips[] = {128, 256, 512, 1024, 2048};
  for (int st : strips) printf(" %7d %7s", st, "pf8");
  printf("\n");
  int wide[][2] = {{1920, 1080}, {3840, 2160}, {7680, 4320}};
  for (auto& s : wide) {
    int w = s[0], h = s[1];
    uint8_t* in = alloc_u8((size_t)w * h);
    uint8_t* out = alloc_u8((size_t)w * h);
    fill_image(in, w, h, 0);
    GaussianWork* wk = gaussian_work_create(w);
    Timing t0 = time_it(pc, (double)w * h, 3e8, 3, [&] { gaussian_u8(w, h, in, out, q, wk); asm volatile("" ::: "memory"); });
    printf("%dx%-6d %9.4f", w, h, t0.cpp);
    for (int st : strips) {
      if (st >= w) { printf(" %7s %7s", "-", "-"); continue; }
      GaussianWork* sk = gaussian_work_create(st);
      Timing a = time_it(pc, (double)w * h, 3e8, 3, [&] { gaussian_u8_strips(w, h, in, out, q, sk, st, 0); asm volatile("" ::: "memory"); });
      Timing b = time_it(pc, (double)w * h, 3e8, 3, [&] { gaussian_u8_strips(w, h, in, out, q, sk, st, 8); asm volatile("" ::: "memory"); });
      printf(" %7.4f %7.4f", a.cpp, b.cpp);
      gaussian_work_destroy(sk);
    }
    printf("\n");
    gaussian_work_destroy(wk);
    free(in); free(out);
  }
  {   // the project's scalar float blur for scale (1080p, 3 runs)
    int w = 1920, h = 1080;
    uint8_t* in = alloc_u8((size_t)w * h);
    uint8_t* out = alloc_u8((size_t)w * h);
    fill_image(in, w, h, 0);
    Timing t = time_it(pc, (double)w * h, 1.0, 3, [&] { scalar_float_blur(w, h, in, out, SIGMA); asm volatile("" ::: "memory"); });
    printf("scalar float blur of canny_scalar.cpp at 1920x1080 (compiled -O3 here): %.2f cycles/px\n", t.cpp);
  }
}

// For `perf stat -e <raw events>`: one phase only, steady state, 1000 * 100000 pixels.
//   ./gaussian_driver.x loop expand|horiz|vert|pipe|whole [width]
static int run_loop(const char* which, int w, int out_off) {
  const GaussQ15 q = gaussian_q15(SIGMA);
  std::string m = which;
  uint8_t* in = alloc_u8((size_t)w);
  uint8_t* out = alloc_u8((size_t)w + 64 + 4096) + out_off;
  fill_image(in, w, 1, 0);
  GaussianWork* wk = gaussian_work_create(w);
  int16_t* scratch = gaussian_scratch(wk);
  gaussian_expand_row(in, scratch, w);
  for (int s = 0; s < 5; ++s) gaussian_horiz_row(scratch, gaussian_ring_row(wk, s), w, q);
  const int16_t* rows[5];
  for (int j = 0; j < 5; ++j) rows[j] = gaussian_ring_row(wk, j);
  if (m == "u8") {                        // gaussian_u8 on w x 128 (input+output 480 KiB at w=1920): the whole-image code path
    const int h = 128;
    uint8_t* im = alloc_u8((size_t)w * h);
    uint8_t* om = alloc_u8((size_t)w * h);
    fill_image(im, w, h, 0);
    long n = (long)(1.5e9 / ((double)w * h));
    for (long i = 0; i < n; ++i) { gaussian_u8(w, h, im, om, q, wk); asm volatile("" ::: "memory"); }
    printf("done %ld images of %dx%d\n", n, w, h);
    return 0;
  }
  long reps = (long)(1.5e9 / w);   // long enough that process start-up is noise in perf stat
  int slot = 0;
  for (long i = 0; i < reps; ++i) {
    if (m == "expand") gaussian_expand_row(in, scratch, w);
    else if (m == "horiz") gaussian_horiz_row(scratch, gaussian_ring_row(wk, 0), w, q);
    else if (m == "vert") gaussian_vert_row(rows, out, w, q);
    else {
      gaussian_expand_row(in, scratch, w);
      gaussian_horiz_row(scratch, gaussian_ring_row(wk, slot), w, q);
      slot = slot == 4 ? 0 : slot + 1;
      const int16_t* r[5];
      for (int j = 0; j < 5; ++j) r[j] = gaussian_ring_row(wk, (slot + j) % 5);
      gaussian_vert_row(r, out, w, q);
    }
    asm volatile("" ::: "memory");
  }
  printf("done %ld rows of %d (%.0f pixels)\n", reps, w, (double)reps * w);
  return 0;
}

int main(int argc, char** argv) {
  std::string mode = argc > 1 ? argv[1] : "all";
  if (mode == "loop") return run_loop(argc > 2 ? argv[2] : "pipe", argc > 3 ? atoi(argv[3]) : 1920, argc > 4 ? atoi(argv[4]) : 0);
  int rc = 0;
  if (mode == "all" || mode == "test") rc = run_tests();
  if (mode == "test") return rc;
  try {
    PerfCounter pc;
    if (mode == "all" || mode == "rows") run_rows(pc);
    if (mode == "all" || mode == "whole") run_whole(pc);
  } catch (const std::exception& e) {
    printf("perf counters unavailable: %s\n", e.what());
    return 1;
  }
  return rc;
}
