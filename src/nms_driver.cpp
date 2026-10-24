// Driver for the Part 3 NMS kernel, written like sobel_driver.cpp (assignment kernel_driver.c style).
//
// For each row width it prints, with core cycles read from the CPU's cycle counter (see below):
//     width  pixels  pixels/cycle  correct  (cycles/pixel, GHz)
// NMS only compares and selects (no floating-point arithmetic), so there is no FLOP count:
// the speed is in pixels per cycle, against the peak in cycles per pixel.
//
// The kernel runs on 4 rows of a 6-row image (mag, angle and output all in L1: widths up to 578,
// 14 rows of up to 2.3 KB in the 32 KB L1), so only the kernel is measured.
// Run on a quiet core whose hyperthread sibling is idle too (make nms CORE=<n>).
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <linux/perf_event.h>
#include "nms_kernel.hpp"

// Core cycles are counted by the CPU's own cycle counter (perf_event_open, user mode only),
// read before and after the timed loop, as in sobel_driver.cpp: the clock moves between about
// 2.0 and 3.0 GHz with turbo and load, so one MAX_FREQ cannot convert rdtsc to cycles.
// rdtsc still gives the time; the clock of the run is cycles / (rdtsc ticks / BASE_FREQ).
// If the counter cannot be opened, fall back to core cycles = rdtsc * MAX_FREQ / BASE_FREQ.
#define MAX_FREQ 2.55
#define BASE_FREQ 2.1
#define REPS 200000
#define ROWS 4   // nms_rows4 does 4 rows

//timing routine for reading the time stamp counter
static __inline__ unsigned long long rdtsc(void) {
  unsigned hi, lo;
  __asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
  return ( (unsigned long long)lo)|( ((unsigned long long)hi)<<32 );
}

//core cycle counter of this thread (user mode only). Returns -1 if not available.
static int open_cycle_counter(void) {
  struct perf_event_attr attr;
  memset(&attr, 0, sizeof(attr));
  attr.size = sizeof(attr);
  attr.type = PERF_TYPE_HARDWARE;
  attr.config = PERF_COUNT_HW_CPU_CYCLES;
  attr.exclude_kernel = 1;
  attr.exclude_hv = 1;
  return (int)syscall(__NR_perf_event_open, &attr, 0, -1, -1, 0);
}

static unsigned long long read_cycles(int fd) {
  unsigned long long c = 0;
  if (fd < 0 || read(fd, &c, sizeof(c)) != sizeof(c)) return 0;
  return c;
}

// Naive Part 3 for rows 1 .. ROWS of a (ROWS + 2)-row image: the canny_scalar.cpp loop.
void naive(int w, const float* mag, const float* angle, float* out) {
  for (int y = 1; y <= ROWS; ++y)
    for (int x = 1; x != w - 1; ++x) {
      int i = y * w + x;
      float d = angle[i];
      int a, b;
      if (d < 22.5f || d >= 157.5f) { a = i - 1;     b = i + 1; }
      else if (d < 67.5f)           { a = i - w - 1; b = i + w + 1; }
      else if (d < 112.5f)          { a = i - w;     b = i + w; }
      else                          { a = i - w + 1; b = i + w - 1; }
      out[i] = (mag[i] > mag[a] && mag[i] >= mag[b]) ? mag[i] : 0.0f;
    }
}

// 4K aliasing: a load whose address matches a recent store in the low 12 bits (same place in
// a 4 KB page) waits for that store. The output rows are stored while the input rows are read,
// so pick the output start (in 64-byte steps) that keeps every output row furthest, within its
// page, from every input row. mag and angle both start on a page.
static int out_offset(int w) {
  int best = 0, best_dist = -1;
  for (int off = 0; off < 4096; off += 64) {
    int dist = 4096;
    for (int i = 0; i < ROWS + 2; ++i)
      for (int j = 0; j < ROWS + 2; ++j) {
        int d = ((off + (j - i) * w * 4) % 4096 + 4096) % 4096;
        if (d > 2048) d = 4096 - d;
        if (d < dist) dist = d;
      }
    if (dist > best_dist) { best_dist = dist; best = off; }
  }
  return best / 4;   // in floats
}

int main(){
  float *mag = NULL, *angle = NULL, *out, *check = NULL;
  float *out_mem = NULL;
  unsigned long long t0, t1, c0, c1;

  int cycle_fd = open_cycle_counter();
  if (cycle_fd < 0)
    printf("no cycle counter (perf_event_paranoid?): cycles = rdtsc * %.2f / %.2f\n", MAX_FREQ, BASE_FREQ);
  printf("width\t pixels\t pixels/cycle correct\t (cycles/pixel, GHz)\n");

  // empty loop to warm up the CPU to its full clock before the memory set-up (as in the assignment)
  for (volatile int i = 0; i < 300000000; i++) { }

  for (int w = 66; w <= 578; w += 64){
    int n = (ROWS + 2) * w;   // ROWS rows plus the row above and below
    posix_memalign((void**) &mag, 4096, n * sizeof(float));
    posix_memalign((void**) &angle, 4096, n * sizeof(float));
    posix_memalign((void**) &out_mem, 4096, n * sizeof(float) + 4096);
    posix_memalign((void**) &check, 64, n * sizeof(float));
    out = out_mem + out_offset(w);

    //magnitudes 0..15 (many ties) and Part 2's direction bins 0 / 45 / 90 / 135
    for (int i = 0; i != n; ++i){
      mag[i] = (float) (rand() % 16);
      angle[i] = 45.0f * (float) (rand() % 4);
      out[i] = 0.0f;
      check[i] = 0.0f;
    }

    naive(w, mag, angle, check);

    nms_rows4(mag, angle, out, w, 1, 1, w - 1);   // warm-up call
    long pixels = (long)ROWS * (w - 2);

    c0 = read_cycles(cycle_fd);
    t0 = rdtsc();
    for (int r = 0; r != REPS; ++r)
      nms_rows4(mag, angle, out, w, 1, 1, w - 1);
    t1 = rdtsc();
    c1 = read_cycles(cycle_fd);

    int correct = 1;
    for (int i = 0; i != n; ++i)
      correct &= (out[i] == check[i]);

    double cycles = (cycle_fd >= 0) ? (double)(c1 - c0) : (double)(t1 - t0) * MAX_FREQ / BASE_FREQ;
    double ghz = cycles / ((double)(t1 - t0) / BASE_FREQ);
    printf("%d\t %ld\t %lf %d\t (%.3f cycles/pixel, %.2f GHz)\n", w, pixels, (double)pixels * REPS / cycles, correct,
           cycles / ((double)pixels * REPS), ghz);

    free(mag);
    free(angle);
    free(out_mem);
    free(check);
  }
  return 0;
}
