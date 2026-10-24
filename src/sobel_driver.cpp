// Driver for the Part 2 Sobel kernel, written like the assignment's kernel_driver.c.
//
// kernel_driver.c printed, for each k:
//     m  n  k  (2*m*n*k) / (rdtsc * MAX_FREQ / BASE_FREQ)  correct
// i.e. FLOPs of the computation / core cycles, and whether the result matched naive().
// This driver prints the same for each row width, with core cycles read from the CPU's
// cycle counter (see below), plus cycles/pixel and the clock of the run:
//     width  pixels  (FLOP_PER_PIXEL * pixels) / core cycles  correct  (cycles/pixel, GHz)
//
// The kernel (sobel_row) runs on 3 rows of an image (all data in L1), so only the kernel
// itself is measured. Build and run with make (pinned to CORE), or with cmake (target
// sobel_driver) on one quiet core, e.g.
//   taskset -c 10 ./build/sobel_driver
// Pick a core whose hyperthread sibling is idle too (cat /sys/devices/system/cpu/cpu10/topology/
// thread_siblings_list, and check top): the two share the same FP units.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <linux/perf_event.h>
#include <algorithm>
#include "sobel_kernel.hpp"

// Core cycles are counted by the CPU's own cycle counter (perf_event_open, user mode only),
// read before and after the timed loop. The clock is not fixed on these machines: it moved
// between 2.1 and 3.0 GHz from run to run and machine to machine (turbo, load on the other
// cores, AVX licence), so one MAX_FREQ cannot convert rdtsc to cycles for every run.
// rdtsc still gives the time; the clock of the run is cycles / (rdtsc ticks / BASE_FREQ).
// BASE_FREQ is the rate rdtsc counts at (the base clock of the Xeon Silver 4208).
// If the counter cannot be opened, fall back to the assignment's conversion:
// core cycles = rdtsc ticks * MAX_FREQ / BASE_FREQ (MAX_FREQ measured on ece024 with perf stat).
#define MAX_FREQ 2.55
#define BASE_FREQ 2.1
#define REPS 500000      // the kernel is fast, so time many calls and divide

// FLOPs per pixel, counted from the math the kernel does (like 2*m*n*k for matrix multiply):
//   a = br - tl, b = tr - bl, dm = mr - ml, dv = bm - tm       -> 4 sub                  = 4
//   gx = 2*dm + (a + b), gy = 2*dv + (a - b)                   -> 1 add + 1 sub + 2 FMA  = 6
//   (an FMA is a multiply and an add: 2 FLOPs in one instruction)
//   mag = sqrt(gx*gx + gy*gy)                                  -> 2 mul + 1 add + 1 sqrt = 4
//   direction: p = (gx^2 + gy^2) * c, then gy^2 < p, gx^2 < p  -> 1 mul                  = 1
//   (the compares and blends are not floating-point arithmetic)
#define FLOP_PER_PIXEL 15.0

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

// Naive Part 2 for the middle row (row 1) of a 3-row image: the canny_scalar.cpp formula,
// with the same direction rule as the kernel (sobel_classify_angle) so both outputs can be checked.
void naive(int w, float* blur, float* mag, float* angle) {
  float* top = blur;
  float* mid = blur + w;
  float* bot = blur + 2 * w;
  for (int x = 1; x != w - 1; ++x) {
    float gx = -top[x - 1] + top[x + 1] - 2 * mid[x - 1] + 2 * mid[x + 1] - bot[x - 1] + bot[x + 1];
    float gy = -top[x - 1] - 2 * top[x] - top[x + 1] + bot[x - 1] + 2 * bot[x] + bot[x + 1];
    mag[w + x] = sqrtf(gx * gx + gy * gy);
    angle[w + x] = sobel_classify_angle(gx, gy);
  }
}

int main(){

  float *blur = NULL, *mag, *angle, *mag_check = NULL, *angle_check = NULL;
  float *mag_mem = NULL, *angle_mem = NULL;
  unsigned long long t0, t1, c0, c1;

  int cycle_fd = open_cycle_counter();
  if (cycle_fd < 0)
    printf("no cycle counter (perf_event_paranoid?): cycles = rdtsc * %.2f / %.2f\n", MAX_FREQ, BASE_FREQ);
  printf("width\t pixels\t FLOP/cycle correct\t (cycles/pixel, GHz)\n");

  // empty loop to warm up the CPU to its full clock before the memory set-up (as in the assignment)
  for (volatile int i = 0; i < 30000000; i++) { }


  for (int w = 130; w <= 1026; w += 128){

    //create memory aligned buffers: 3 image rows (blur) and the outputs for them.
    //4K aliasing: the CPU first compares only the low 12 bits of addresses (the position
    //inside a 4 KB page) to see if a load depends on an earlier store. If the input rows and
    //the output row sit at the same position in their pages, every load looks like it might
    //depend on a store and waits (we measured 2.15 instead of 1.7 cycles/pixel).
    //So start every buffer on a page and shift the outputs by 2 KB and 1 KB.
    posix_memalign((void**) &blur, 4096, 3 * w * sizeof(float));
    posix_memalign((void**) &mag_mem, 4096, 3 * w * sizeof(float) + 4096);
    posix_memalign((void**) &angle_mem, 4096, 3 * w * sizeof(float) + 4096);
    posix_memalign((void**) &mag_check, 64, 3 * w * sizeof(float));
    posix_memalign((void**) &angle_check, 64, 3 * w * sizeof(float));
    mag = mag_mem + 512;       // + 2 KB
    angle = angle_mem + 256;   // + 1 KB

    //initialize blur with whole numbers 0..255, like the rounded blur in canny_scalar.cpp
    for (int i = 0; i != 3 * w; ++i){
      blur[i] = (float) (rand() % 256);
    }
    //initialize outputs
    for (int i = 0; i != 3 * w; ++i){
      mag[i] = 0.0f;
      angle[i] = 0.0f;
      mag_check[i] = 0.0f;
      angle_check[i] = 0.0f;
    }

    naive(w, blur, mag_check, angle_check);

    // the kernel computes the middle row, columns 1 .. w-2
    float* top = blur;
    float* mid = blur + w;
    float* bot = blur + 2 * w;
    sobel_row(top, mid, bot, mag + w, angle + w, 1, w - 1);   // warm-up call
    long pixels = w - 2;

    c0 = read_cycles(cycle_fd);
    t0 = rdtsc();

    for (int r = 0; r != REPS; ++r)
      sobel_row(top, mid, bot, mag + w, angle + w, 1, w - 1);

    t1 = rdtsc();
    c1 = read_cycles(cycle_fd);

    int correct = 1;
    for (int i = w + 1; i != 2 * w - 1; ++i) {
      correct &= (fabs(mag[i] - mag_check[i]) < 1e-6);
      correct &= (angle[i] == angle_check[i]);
    }

    double flops = FLOP_PER_PIXEL * pixels * REPS;
    double cycles = (cycle_fd >= 0) ? (double)(c1 - c0) : (double)(t1 - t0) * MAX_FREQ / BASE_FREQ;
    double ghz = cycles / ((double)(t1 - t0) / BASE_FREQ);
    printf("%d\t %ld\t %lf %d\t (%.3f cycles/pixel, %.2f GHz)\n", w, pixels, flops / cycles, correct,
           cycles / ((double)pixels * REPS), ghz);

    free(blur);
    free(mag_mem);
    free(angle_mem);
    free(mag_check);
    free(angle_check);
  }


  return 0;
}
