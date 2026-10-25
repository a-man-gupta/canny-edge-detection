// Driver for the Part 2 Sobel kernel (sobel_i16_row in sobel_kernel.cpp, integer), written like the
// assignment's kernel_driver.c. For each row width (3 int16 rows, all data in L1) it prints:
//   width  pixels  ops/cycle  correct  (GHz)
// correct = mag_sq and bin match naive() (OpenCV's formulas) exactly at every pixel.
// The kernel is integer. Useful scalar-equivalent ops use the experiment's 19-op convention.
// Core cycles are measured directly. GHz is an estimate using a nominal 2.1 GHz TSC.
// Conversion/allocation is outside this row-only benchmark.
//
// Run with make (pinned to CORE), or with cmake (target sobel_driver) on one quiet core, e.g.
//   taskset -c 10 ./build/sobel_driver
// Pick a core whose hyperthread sibling is idle too (cat /sys/devices/system/cpu/cpu10/topology/
// thread_siblings_list, and check top): the two share the same execution ports.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <linux/perf_event.h>
#include <algorithm>
#include <vector>
#include <atomic>
#include <x86intrin.h>
#include "sobel_kernel.hpp"

#define PIXELS_PER_SAMPLE 200000000.0   // each timed sample does about this many pixels
#define SAMPLES 3                       // timed samples per width; the median is printed
#define BASE_FREQ 2.1                   // nominal TSC GHz; this is not the maximum AVX2 core clock

// Same useful-operation convention as experiments/integer_avx2_spillfree:
// 10 gradient arithmetic + 3 magnitude + 6 direction operations = 19/pixel.
// This excludes loads, stores, comparisons and selections; it is not machine uop count.
#define OPS_PER_PIXEL 19.0

static inline unsigned long long rdtsc() { return __rdtsc(); }

// Core cycles and instructions from the CPU's counters: one pinned perf group, read with
// time_enabled / time_running. A sample where the counters were not running the whole time
// (shared with another program) is rejected instead of being scaled.
static int cyc_fd = -1, ins_fd = -1;
static int open_counters(void) {
  struct perf_event_attr a;
  memset(&a, 0, sizeof(a));
  a.size = sizeof(a);
  a.type = PERF_TYPE_HARDWARE;
  a.config = PERF_COUNT_HW_CPU_CYCLES;
  a.exclude_kernel = 1;
  a.exclude_hv = 1;
  a.pinned = 1;
  a.read_format = PERF_FORMAT_GROUP | PERF_FORMAT_TOTAL_TIME_ENABLED | PERF_FORMAT_TOTAL_TIME_RUNNING;
  cyc_fd = (int)syscall(__NR_perf_event_open, &a, 0, -1, -1, 0);
  a.pinned = 0;
  a.config = PERF_COUNT_HW_INSTRUCTIONS;
  ins_fd = (int)syscall(__NR_perf_event_open, &a, 0, -1, cyc_fd, 0);
  return cyc_fd >= 0 && ins_fd >= 0;
}
struct Reading { uint64_t enabled, running, cycles, instructions; };
static int read_counters(Reading* r) {
  uint64_t buf[5];
  if (read(cyc_fd, buf, sizeof(buf)) != (ssize_t)sizeof(buf) || buf[0] != 2) return 0;
  r->enabled = buf[1]; r->running = buf[2]; r->cycles = buf[3]; r->instructions = buf[4];
  return 1;
}

// Naive Part 2 for the middle row of a 3-row band: OpenCV's 3x3 Sobel and direction test.
void naive(int w, const int16_t* blur, int32_t* mag_sq, int16_t* bin) {
  const int16_t* t = blur;
  const int16_t* m = blur + w;
  const int16_t* d = blur + 2 * w;
  for (int x = 1; x != w - 1; ++x) {
    int gx = -t[x - 1] + t[x + 1] - 2 * m[x - 1] + 2 * m[x + 1] - d[x - 1] + d[x + 1];
    int gy = -t[x - 1] - 2 * t[x] - t[x + 1] + d[x - 1] + 2 * d[x] + d[x + 1];
    mag_sq[x] = gx * gx + gy * gy;
    bin[x] = sobel_bin(gx, gy);
  }
}

int main(){
  if (!open_counters()) { printf("no cycle counter (perf_event_paranoid?)\n"); return 1; }
  printf("width\t pixels\t cycles/pixel ops/cycle correct\t (estimated GHz)\n");

  // empty loop to warm up the CPU to its full clock before the memory set-up (as in the assignment)
  for (volatile int i = 0; i < 300000000; i++) { }

  for (int w = 130; w <= 1026; w += 128){
    //4K aliasing: start every buffer on a page and shift the outputs by 1 KB and 2 KB, so the
    //input rows and the output rows do not sit at the same place in their 4 KB pages
    int16_t *blur = NULL, *bin_mem = NULL; int32_t* mag_mem = NULL;
    posix_memalign((void**)&blur, 4096, 3 * w * sizeof(int16_t));
    posix_memalign((void**)&bin_mem, 4096, w * sizeof(int16_t) + 4096);
    posix_memalign((void**)&mag_mem, 4096, w * 4 + 4096);
    int16_t* bin = bin_mem + 512;     // + 1 KB
    int32_t* mag_sq = mag_mem + 512;   // + 2 KB
    std::vector<int32_t> mag_check(w);
    std::vector<int16_t> bin_check(w);

    //blur: 0..255, like the uint8 blur from cv2.GaussianBlur
    for (int i = 0; i != 3 * w; ++i) blur[i] = (uint8_t)(rand() % 256);
    naive(w, blur, mag_check.data(), bin_check.data());

    const long pixels = w - 2;
    const long reps = (long)(PIXELS_PER_SAMPLE / pixels);
    std::vector<double> flop, ghz, cpp;
    int correct = 1, rejected = 0;
    sobel_i16_row(blur, blur + w, blur + 2 * w, mag_sq, bin, 1, w - 1);   // warm-up call
    for (int s = 0; s < SAMPLES; ++s) {
      for (int x = 0; x < w; ++x) { mag_sq[x] = -1; bin[x] = 255; }   // so a missed pixel fails
      Reading r0, r1;
      if (!read_counters(&r0)) return 1;
      unsigned long long t0 = rdtsc();
      for (long r = 0; r != reps; ++r) {
        sobel_i16_row(blur, blur + w, blur + 2 * w, mag_sq, bin, 1, w - 1);
        std::atomic_signal_fence(std::memory_order_seq_cst);
      }
      unsigned long long t1 = rdtsc();
      if (!read_counters(&r1)) return 1;
      for (int x = 1; x != w - 1; ++x) correct &= (mag_sq[x] == mag_check[x]) & (bin[x] == bin_check[x]);
      if (r1.enabled - r0.enabled != r1.running - r0.running) { rejected++; continue; }
      double cycles = (double)(r1.cycles - r0.cycles);
      cpp.push_back(cycles / ((double)pixels * reps));
      flop.push_back(OPS_PER_PIXEL * (double)pixels * reps / cycles);
      ghz.push_back(cycles / ((double)(t1 - t0) / BASE_FREQ));
    }
    std::sort(cpp.begin(), cpp.end());
    std::sort(flop.begin(), flop.end());
    std::sort(ghz.begin(), ghz.end());
    if (flop.empty()) printf("%d\t %ld\t all samples rejected (counters shared)\t %d\n", w, pixels, correct);
    else printf("%d\t %ld\t %.4f %.3f %d\t (%.2f GHz estimate)%s\n", w, pixels, cpp[cpp.size() / 2], flop[flop.size() / 2], correct, ghz[ghz.size() / 2],
                rejected ? "  (some samples rejected: counters shared)" : "");

    free(blur); free(bin_mem); free(mag_mem);
  }
  return 0;
}
