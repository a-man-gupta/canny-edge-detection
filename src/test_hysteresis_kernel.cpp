#include "hysteresis.hpp"
#include "hysteresis_kernel.hpp"
#include <cstdio>
#include <random>
#include <stdexcept>
#include <vector>

// Random labels: p_strong and p_weak per pixel. Long weak runs make chains that cross blocks,
// rows and the scalar / vector column boundary.
static void fill(std::vector<uint8_t> &labels, std::mt19937 &rng, int w, int pattern) {
  const double p[][2] = {{0, 0}, {0.01, 0.05}, {0.05, 0.4}, {0.3, 0.3}, {0.0005, 0.7}, {1, 0}};
  std::uniform_real_distribution<double> u(0, 1);
  for (auto &v : labels) {
    double r = u(rng);
    v = r < p[pattern][0] ? 2 : r < p[pattern][0] + p[pattern][1] ? 1 : 0;
  }
  if (pattern == 0 && !labels.empty()) {
    // One strong pixel at the start of a weak serpentine through the whole image.
    for (size_t i = 0; i < labels.size(); ++i)
      labels[i] = (i / w) % 2 == 0 || i % w == ((i / w) % 4 == 1 ? size_t(w - 1) : 0) ? 1 : 0;
    labels[0] = 2;
  }
}
int main() try {
  std::mt19937 rng(18645);
  long images = 0, ranges = 0;
  std::vector<int> widths;
  for (int w = 1; w < 40; ++w)
    widths.push_back(w);
  for (int w : {63, 64, 65, 66, 67, 97, 98, 99, 130, 255, 256, 257, 1026, 1027})
    widths.push_back(w);
  std::vector<size_t> queue, queue_ref;
  for (int w : widths)
    for (int h : {1, 2, 3, 4, 5, 6, 7, 9, 10, 13})
      for (int pattern = 0; pattern < 6; ++pattern) {
        size_t n = size_t(w) * h;
        std::vector<uint8_t> labels(n), edges(n, 77), want(n, 77);
        fill(labels, rng, w, pattern);
        hysteresis(labels, w, h, want, queue_ref);
        hysteresis_kernel(w, h, labels.data(), edges.data(), queue);
        if (edges != want) {
          fprintf(stderr, "image mismatch %dx%d pattern=%d\n", w, h, pattern);
          return 1;
        }
        ++images;
      }
  // Direct hot-loop calls: edges and seed hits for 4-row and 1-row blocks.
  for (int rows : {1, 4})
    for (long begin : {1L, 2L, 31L})
      for (long n : {0L, 32L, 64L, 320L})
        for (long reps : {0L, 1L, 3L})
          for (int pattern = 1; pattern < 5; ++pattern) {
            const long stride = begin + n + 1;
            std::vector<uint8_t> labels(size_t(stride) * (rows + 2)), edges_storage(size_t(stride) * rows, 77);
            fill(labels, rng, int(stride), pattern);
            std::vector<uint32_t> hits(n / 32 + 1, 0xFFFFFFFF);
            const uint8_t *center = labels.data() + stride;
            long found = rows == 4 ? hysteresis_rows4_repeat(center, edges_storage.data(), stride, begin, n, hits.data(), reps)
                                   : hysteresis_rows1_repeat(center, edges_storage.data(), stride, begin, n, hits.data(), reps);
            long want_found = 0;
            for (long x = begin; reps > 0 && x < begin + n; x += 32) {
              bool any = false;
              for (int r = 0; r < rows; ++r)
                for (long c = x; c < x + 32; ++c) {
                  const uint8_t *p = center + r * stride + c;
                  bool strong_near = false;
                  for (int j = -1; j <= 1; ++j)
                    for (int k = -1; k <= 1; ++k)
                      strong_near |= p[j * stride + k] == 2;
                  any |= *p == 1 && strong_near;
                }
              if (any && hits[want_found++] != uint32_t(x))
                throw std::runtime_error("hot-loop seed hit missing or out of order");
            }
            if (found != want_found)
              throw std::runtime_error("hot-loop hit count mismatch");
            for (int r = 0; r < rows; ++r)
              for (long x = 0; x < stride; ++x) {
                uint8_t want = reps > 0 && x >= begin && x < begin + n
                                   ? (center[r * stride + x] == 2 ? 255 : 0)
                                   : 77;
                if (edges_storage[size_t(r) * stride + x] != want)
                  throw std::runtime_error("hot-loop edge/sentinel mismatch");
              }
            ++ranges;
          }
  printf("PASS: %ld images and %ld hot-loop ranges; serpentine chains, dense / sparse / noise "
         "labels, borders, tails, block remainders, zero work\n",
         images, ranges);
  return 0;
} catch (const std::exception &e) {
  fprintf(stderr, "FAIL: %s\n", e.what());
  return 1;
}
