// Driver for the Part 2 Sobel kernel, written like the assignment's kernel_driver.c.
//
// kernel_driver.c printed, for each k:
//     m  n  k  (2*m*n*k) / (rdtsc * MAX_FREQ / BASE_FREQ)  correct
// i.e. FLOPs of the computation / core cycles, and whether the result matched naive().
// This driver prints the same for each row width:
//     width  pixels  (FLOP_PER_PIXEL * pixels) / (rdtsc * MAX_FREQ / BASE_FREQ)  correct
//
// The kernel runs on 3 rows of an image (all data in L1), so only the kernel itself is measured.
// Build with cmake (target sobel_driver). Run on one quiet core, e.g.
//   taskset -c 10 ./build/sobel_driver
// Pick a core whose hyperthread sibling is idle too (cat /sys/devices/system/cpu/cpu10/topology/
// thread_siblings_list, and check top): the two share the same FP units.
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <algorithm>
#include "sobel_kernel.hpp"

// Same conversion as the assignment: core cycles = rdtsc ticks * MAX_FREQ / BASE_FREQ.
// BASE_FREQ is the rate rdtsc counts at (the base clock of the Xeon Silver 4208).
// MAX_FREQ is the clock the core really runs at while this kernel runs. It is NOT the 3.2 GHz
// on the spec sheet: AVX2 code makes this Xeon lower its clock (AVX frequency licence).
// Measured on ece024 with perf stat -e cycles,ref-cycles around the kernel:
// cycles / ref-cycles x 2.1 = about 2.55 GHz. Remeasure it if you use another machine.
#define MAX_FREQ 2.55
#define BASE_FREQ 2.1
#define REPS 500000      // the kernel is fast, so time many calls and divide

// FLOPs per pixel, counted from the math the kernel does (like 2*m*n*k for matrix multiply):
//   a = br - tl, b = tr - bl, dm = mr - ml, dv = bm - tm       -> 4 sub                  = 4
//   gx = 2*dm + (a + b), gy = 2*dv + (a - b)                   -> 1 add + 1 sub + 2 FMA  = 6
//   (an FMA is a multiply and an add: 2 FLOPs in one instruction)
//   mag = sqrt(gx*gx + gy*gy)                                  -> 2 mul + 1 add + 1 sqrt = 4
//   direction: |gx| * tan22.5, |gy| * tan22.5                  -> 2 mul                  = 2
//   (the 2 compares and the blends are not floating-point arithmetic, so not FLOPs)
#define FLOP_PER_PIXEL 16.0

//timing routine for reading the time stamp counter
static __inline__ unsigned long long rdtsc(void) {
  unsigned hi, lo;
  __asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
  return ( (unsigned long long)lo)|( ((unsigned long long)hi)<<32 );
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

  float *blur, *mag, *angle, *mag_check, *angle_check;
  float *mag_mem, *angle_mem;
  unsigned long long t0, t1;

  // empty loop to warm up the CPU to its full clock before the memory set-up (as in the assignment)
  for (volatile int i = 0; i < 300000000; i++) { }


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
    sobel_row_avx2(top, mid, bot, mag + w, angle + w, 1, w - 1);   // warm-up call
    long pixels = w - 2;

    t0 = rdtsc();

    for (int r = 0; r != REPS; ++r)
      sobel_row_avx2(top, mid, bot, mag + w, angle + w, 1, w - 1);

    t1 = rdtsc();

    int correct = 1;
    for (int i = w + 1; i != 2 * w - 1; ++i) {
      correct &= (fabs(mag[i] - mag_check[i]) < 1e-6);
      correct &= (angle[i] == angle_check[i]);
    }

    double flops = FLOP_PER_PIXEL * pixels * REPS;
    double cycles = (double)(t1 - t0) * MAX_FREQ / BASE_FREQ;
    printf("%d\t %ld\t %lf %d\t (%.3f cycles/pixel)\n", w, pixels, flops / cycles, correct,
           cycles / ((double)pixels * REPS));

    free(blur);
    free(mag_mem);
    free(angle_mem);
    free(mag_check);
    free(angle_check);
  }


  return 0;
}
