// Times the hysteresis vector-pass hot loop (hysteresis_rows4_repeat) with data in L1, and the
// whole hysteresis_kernel against the scalar hysteresis() on real images. For whole images the
// labels come from the integer pipeline: scalar blur (as canny_part2.cpp), sobel_kernel,
// nms_kernel, threshold_kernel. Hardware core cycles are mandatory (perf_event_open).
//
//   hysteresis_driver.x                 hot loop at several widths
//   hysteresis_driver.x N [reps]        hot loop at width N (a multiple of 32)
//   hysteresis_driver.x whole A.pgm ... whole images, kernel vs scalar
//   hysteresis_driver.x test            correctness only
#include "hysteresis.hpp"
#include "hysteresis_kernel.hpp"
#include "nms_kernel.hpp"
#include "perf_counter.hpp"
#include "sobel_kernel.hpp"
#include "threshold_kernel.hpp"
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>

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

// Labels with strong (p_strong) and weak (p_weak) pixels, but no weak pixel next to a strong
// one, so the hot loop never takes its seed branch.
static void fill_no_seeds(uint8_t *labels, long stride, int rows, uint32_t seed) {
  std::mt19937 rng(seed);
  for (long i = 0; i < stride * rows; ++i)
    labels[i] = rng() % 100 < 5 ? 2 : 0;
  for (int r = 0; r < rows; ++r)
    for (long x = 0; x < stride; ++x) {
      if (labels[r * stride + x] || rng() % 100 >= 10)
        continue;
      bool strong = false;
      for (int j = -1; j <= 1; ++j)
        for (int k = -1; k <= 1; ++k)
          if (r + j >= 0 && r + j < rows && x + k >= 0 && x + k < stride)
            strong |= labels[(r + j) * stride + x + k] == 2;
      if (!strong)
        labels[r * stride + x] = 1;
    }
}

// Edge rows start this many bytes past the label rows' page offset, chosen as far as possible
// (mod 4096) from every label row, so stores do not alias recent loads (4K aliasing).
static size_t edge_offset(long stride) {
  size_t best = 0, best_distance = 0;
  for (size_t off = 0; off < 4096; off += 64) {
    size_t worst = 4096;
    for (int e = 0; e < 4; ++e)
      for (int l = 0; l < 6; ++l) {
        long d = long((off + e * stride) - l * stride) % 4096;
        d = (d + 4096) % 4096;
        worst = std::min<size_t>(worst, std::min<long>(d, 4096 - d));
      }
    if (worst > best_distance)
      best_distance = worst, best = off;
  }
  return best;
}

static void benchmark(long n, long reps, int samples) {
  if (n < 32 || n % 32 || reps < 1 || samples < 1)
    throw std::runtime_error("width must be a positive multiple of 32");
  // Column 0 and the last 31 columns are padding; pixel 32 starts on a 32-byte boundary.
  const long stride = n + 64, begin = 32;
  Buffer<uint8_t> labels(6 * stride, 0), edges(4 * stride, edge_offset(stride));
  std::vector<uint32_t> hits(n / 32 + 1);
  fill_no_seeds(labels.p, stride, 6, 42);
  const uint8_t *center = labels.p + stride;
  auto check = [&](long found) {
    if (found)
      throw std::runtime_error("unexpected seed hit");
    for (int r = 0; r < 4; ++r)
      for (long x = begin; x < begin + n; ++x)
        if (edges.p[r * stride + x] != (center[r * stride + x] == 2 ? 255 : 0))
          throw std::runtime_error("output incorrect");
  };
  check(hysteresis_rows4_repeat(center, edges.p, stride, begin, n, hits.data(), 3000));
  PerfCounter ctr;
  std::vector<double> cpp, ghz, ipp;
  long found = 0;
  for (int s = 0; s < samples; ++s) {
    auto a = ctr.read_now();
    found = hysteresis_rows4_repeat(center, edges.p, stride, begin, n, hits.data(), reps);
    auto b = ctr.read_now();
    PerfDelta d(a, b);
    double px = 4.0 * n * reps;
    cpp.push_back(d.cycles / px);
    ghz.push_back(d.ghz);
    ipp.push_back(d.instructions / px);
  }
  check(found);
  printf("%ld\t%ld\t%.4f\t1\t(%.4f cycles/pixel, %.2f nominal GHz, %ld bytes, %.4f instructions/pixel)\n",
         stride, 4 * n, 1 / median(cpp), median(cpp), median(ghz), 10 * stride, median(ipp));
}

static std::string token(std::istream &in) {
  std::string s;
  while (in >> s) {
    if (s[0] != '#')
      return s;
    std::getline(in, s);
  }
  throw std::runtime_error("Invalid PGM header");
}

// Labels of an image through the integer pipeline, with the default sigma 1.4, low 50, high 100.
static std::vector<uint8_t> labels_of(const std::string &path, int &w, int &h) {
  std::ifstream in(path, std::ios::binary);
  if (token(in) != "P5")
    throw std::runtime_error("Expected binary PGM: " + path);
  w = std::stoi(token(in));
  h = std::stoi(token(in));
  if (token(in) != "255")
    throw std::runtime_error("Expected uint8 PGM");
  char separator;
  in.get(separator);
  size_t n = size_t(w) * h;
  std::vector<uint8_t> image(n), blur(n), bin(n), labels(n);
  in.read(reinterpret_cast<char *>(image.data()), std::streamsize(n));
  const float sigma = 1.4f;
  float weights[5][5], sum = 0;
  for (int y = -2; y <= 2; ++y)
    for (int x = -2; x <= 2; ++x) {
      weights[y + 2][x + 2] = std::exp(-(x * x + y * y) / (2 * sigma * sigma));
      sum += weights[y + 2][x + 2];
    }
  for (auto &row : weights)
    for (float &x : row)
      x /= sum;
  auto reflect = [](int p, int length) {
    while (p < 0 || p >= length)
      p = p < 0 ? -p : 2 * length - 2 - p;
    return p;
  };
  for (int y = 0; y < h; ++y)
    for (int x = 0; x < w; ++x) {
      float value = 0;
      for (int j = -2; j <= 2; ++j)
        for (int k = -2; k <= 2; ++k)
          value += weights[j + 2][k + 2] * image[size_t(reflect(y + j, h)) * w + reflect(x + k, w)];
      blur[size_t(y) * w + x] = uint8_t(std::clamp(std::floor(value + 0.5f), 0.0f, 255.0f));
    }
  std::vector<int32_t> mag_sq(n), suppressed(n);
  sobel_kernel(w, h, blur.data(), mag_sq.data(), bin.data());
  nms_kernel(w, h, mag_sq.data(), bin.data(), suppressed.data());
  threshold_kernel(n, suppressed.data(), labels.data(), 2500, 10000);
  return labels;
}

static void whole(const std::string &path, int samples) {
  int w, h;
  std::vector<uint8_t> labels = labels_of(path, w, h);
  size_t n = size_t(w) * h;
  std::vector<uint8_t> edges(n), want(n);
  std::vector<size_t> queue, queue_ref;
  queue.reserve(n);
  queue_ref.reserve(n);
  hysteresis(labels, w, h, want, queue_ref);
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
  auto k = time([&] { hysteresis_kernel(w, h, labels.data(), edges.data(), queue); });
  if (edges != want)
    throw std::runtime_error("whole-image kernel output incorrect: " + path);
  auto s = time([&] { hysteresis(labels, w, h, want, queue_ref); });
  size_t strong = std::count(labels.begin(), labels.end(), 2);
  std::string name = path.substr(path.find_last_of('/') + 1);
  printf("%s\t%dx%d\t%zu\t%zu\t%.4f\t%.3f\t%.4f\t%.3f\t%.2fx\n", name.c_str(), w, h, strong,
         queue.size(), k.first / n, k.second, s.first / n, s.second, s.first / k.first);
}

int main(int argc, char **argv) try {
  for (long n : {32L, 64L, 96L, 512L, 1024L}) {
    const long stride = n + 64;
    Buffer<uint8_t> labels(6 * stride, 0), edges(4 * stride, edge_offset(stride));
    std::vector<uint32_t> hits(n / 32 + 1);
    fill_no_seeds(labels.p, stride, 6, uint32_t(n));
    memset(edges.p, 77, 4 * stride);
    if (hysteresis_rows4_repeat(labels.p + stride, edges.p, stride, 32, n, hits.data(), 2))
      throw std::runtime_error("unexpected seed hit");
    for (int r = 0; r < 4; ++r)
      for (long x = 0; x < stride; ++x) {
        uint8_t c = labels.p[(r + 1) * stride + x];
        uint8_t want = x >= 32 && x < 32 + n ? (c == 2 ? 255 : 0) : 77;
        if (edges.p[r * stride + x] != want)
          throw std::runtime_error("hot-loop output or sentinel incorrect");
      }
  }
  if (argc > 1 && !strcmp(argv[1], "test")) {
    printf("PASS hot loop: edges, no false seed hits, sentinels\n");
    return 0;
  }
  if (argc > 1 && !strcmp(argv[1], "whole")) {
    printf("Hysteresis, whole images: hysteresis_kernel (vector pass + seed queue) vs scalar hysteresis().\n");
    printf("Labels from the integer pipeline (blur, sobel_kernel, nms_kernel, threshold_kernel; low 50, high 100).\n");
    printf("One call per sample, median of 21. queue = seeds + weak pixels they reach (kernel).\n");
    printf("image\tsize\tstrong\tqueue\tkernel cycles/pixel\tkernel ms\tscalar cycles/pixel\tscalar ms\tspeedup\n");
    for (int a = 2; a < argc; ++a)
      whole(argv[a], 21);
    return 0;
  }
  printf("Hysteresis vector pass: AVX2 (256-bit) + AVX-512VL vpternlogd, uint8 labels in, uint8 edges out,\n");
  printf("4 rows x 32 columns per loop. 6 label rows + 4 edge rows in L1; no seeds, so the seed branch is never taken.\n");
  printf("Median of samples; setup/warmup excluded. Core cycles from perf; nominal GHz = core/reference x 2.1.\n");
  printf("Pin to a quiet core and check its SMT sibling. Run make hysteresis-count for the compiled-code bound.\n");
  printf("width\tpixels\tpixels/cycle\tcorrect\t(cycles/pixel, nominal GHz, working set, instructions/pixel)\n");
  if (argc > 1)
    benchmark(atol(argv[1]), argc > 2 ? atol(argv[2]) : 200000, 5);
  else
    for (long n : {256L, 512L, 1024L, 1536L, 2048L, 2944L})
      benchmark(n, 2000000 / n * 64, 5);
  return 0;
} catch (const std::exception &e) {
  fprintf(stderr, "ERROR: %s\n", e.what());
  return 1;
}
