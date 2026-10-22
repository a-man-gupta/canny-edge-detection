// Part 2 (Sobel) benchmark, in the style of the 18-645 assignment drivers (kernel_driver.c):
//   - naive(): the scalar loop from canny_scalar.cpp, used as the baseline and to check results
//   - rdtsc around the kernel, converted to core cycles
//   - one printf row per kernel and image size
//
// Each row prints cycles per pixel, the kernel's peak, and how close we got:
//   peak cycles/pixel = FP-unit instructions per pixel / 2 FP units
//   (the course's peak: units x 1 instruction per cycle; counts from scripts/count_sobel_ops.sh)
//
// Build:  cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
// Run:    taskset -c 0 ./build/sobel_driver        (one core, so the timing is not disturbed)
#include "sobel_kernel.hpp"

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <immintrin.h>
#include <vector>

// ---- Machine: Xeon Silver 4208 (Cascade Lake) ----
#define BASE_FREQ 2.1            // GHz. rdtsc counts at this rate.
#define ADD_LATENCY 4            // vaddps latency in core cycles, used to measure the real clock
#define FP_UNITS 2               // ports 0 and 1: add, sub, mul, FMA, compare
#define MACHINE_PEAK_FLOP 32.0   // FLOP/cycle = 2 units x 8 floats x 2 (FMA)

// ---- Kernels: from scripts/count_sobel_ops.sh (clang -O3 -mavx2). Recount on the Xeon. ----
#define V1_FP_PER_PX (46.0 / 16) // 46 FP-unit instructions per 16 pixels
#define V1_FLOP_PER_PX 21.0
#define V2_FP_PER_PX (20.0 / 8)  // 20 FP-unit instructions per 8 pixels
#define V2_FLOP_PER_PX 18.0
#define SCALAR_FLOP_PER_PX 22.0  // naive(): gx 8, gy 8, magnitude 3, sqrt 1, angle 2 (+ atan2, not counted)

// Timing routine for reading the time stamp counter (same as the assignments).
static __inline__ unsigned long long rdtsc(void) {
    unsigned hi, lo;
    __asm__ __volatile__("rdtsc" : "=a"(lo), "=d"(hi));
    return ((unsigned long long)lo) | (((unsigned long long)hi) << 32);
}

// Core cycles per rdtsc tick. The assignments used MAX_FREQ / BASE_FREQ, but the real clock
// under AVX is not known in advance, so measure it: a chain of dependent vaddps costs
// exactly ADD_LATENCY core cycles per add.
static double core_cycles_per_tick(void) {
    const long loops = 5000000;  // x 8 adds
    __m128 v = _mm_set1_ps(1.0f);
    const __m128 zero = _mm_setzero_ps();
    unsigned long long t0 = rdtsc();
    for (long i = 0; i < loops; ++i) {
        __asm__ __volatile__(
            "vaddps %1, %0, %0\n\t" "vaddps %1, %0, %0\n\t" "vaddps %1, %0, %0\n\t" "vaddps %1, %0, %0\n\t"
            "vaddps %1, %0, %0\n\t" "vaddps %1, %0, %0\n\t" "vaddps %1, %0, %0\n\t" "vaddps %1, %0, %0"
            : "+x"(v) : "x"(zero));
    }
    unsigned long long t1 = rdtsc();
    return (double)ADD_LATENCY * loops * 8 / (double)(t1 - t0);
}

// Baseline: the Part 2 loop from canny_scalar.cpp, unchanged (clamped samples, atan2).
static void naive(int w, int h, const float* blur, float* mag, float* angle) {
    for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
            auto b = [&](int j, int k) {
                int sample_row = std::clamp(y + j, 0, h - 1);
                int sample_col = std::clamp(x + k, 0, w - 1);
                return blur[size_t(sample_row) * w + sample_col];
            };
            float gx = -b(-1, -1) + b(-1, 1)
                     - 2 * b(0, -1) + 2 * b(0, 1)
                     - b(1, -1) + b(1, 1);
            float gy = -b(-1, -1) - 2 * b(-1, 0) - b(-1, 1)
                     + b(1, -1) + 2 * b(1, 0) + b(1, 1);
            size_t i = size_t(y) * w + x;
            mag[i] = std::sqrt(gx * gx + gy * gy);
            float degrees = std::atan2(gy, gx) * 180.0f / 3.14159265358979323846f;
            angle[i] = degrees < 0 ? degrees + 180 : degrees;
        }
    }
}

// Part 3 bin of an angle in degrees, the same if-ladder as canny_scalar.cpp.
static float bin_of(float d) {
    if (d < 22.5f || d >= 157.5f) return 0.f;
    if (d < 67.5f) return 45.f;
    if (d < 112.5f) return 90.f;
    return 135.f;
}

// The kernels we time. groups only matters for v2.
enum Kernel { SCALAR, V1, V2 };

static void run(Kernel k, int groups, int w, int h, const float* blur, float* mag, float* angle) {
    if (k == SCALAR) naive(w, h, blur, mag, angle);
    else if (k == V1) sobel_kernel(w, h, blur, mag, angle);
    else sobel_kernel_v2(w, h, blur, mag, angle, groups);
}

static float* alloc(size_t n) {
    void* p = nullptr;
    if (posix_memalign(&p, 64, n * sizeof(float))) { printf("out of memory\n"); exit(1); }
    memset(p, 0, n * sizeof(float));
    return (float*)p;
}

// Blur values are whole numbers 0..255, like the rounded blur in canny_scalar.cpp.
static void fill(float* blur, size_t n) {
    unsigned s = 18645u;
    for (size_t i = 0; i < n; ++i) { s = s * 1664525u + 1013904223u; blur[i] = (float)(s >> 24); }
}

// One table row: time the kernel on a w x h image and compare with the baseline result.
static void bench(Kernel k, int groups, int w, int h, double cycles_per_tick) {
    const size_t n = size_t(w) * h;
    float *blur = alloc(n), *mag = alloc(n), *angle = alloc(n), *mag_ref = alloc(n), *angle_ref = alloc(n);
    fill(blur, n);
    naive(w, h, blur, mag_ref, angle_ref);

    // Repeat small images so each timing is long enough for rdtsc (~50 million pixels).
    long reps = std::max(1L, (long)(50e6 / n));
    if (k == SCALAR) reps = std::max(1L, reps / 20);   // the baseline is much slower

    run(k, groups, w, h, blur, mag, angle);             // warm-up: caches and page faults
    double best = 1e300;
    for (int trial = 0; trial < 5; ++trial) {
        unsigned long long t0 = rdtsc();
        for (long r = 0; r < reps; ++r)
            run(k, groups, w, h, blur, mag, angle);
        unsigned long long t1 = rdtsc();
        best = std::min(best, (double)(t1 - t0) / reps);  // ticks per call, best of 5
    }
    const double cycles_per_px = best * cycles_per_tick / n;

    // Correctness: magnitude must be bit-exact; count direction bins that differ from atan2
    // (expected only on the 22.5 / 67.5 degree boundary lines).
    long mag_wrong = 0, bin_diff = 0;
    for (size_t i = 0; i < n; ++i) {
        if (memcmp(&mag[i], &mag_ref[i], sizeof(float)) != 0) ++mag_wrong;
        float b = (k == SCALAR) ? bin_of(angle[i]) : angle[i];
        if (b != bin_of(angle_ref[i])) ++bin_diff;
    }

    const double fp_per_px = (k == V1) ? V1_FP_PER_PX : (k == V2) ? V2_FP_PER_PX : 0;
    const double flop_per_px = (k == V1) ? V1_FLOP_PER_PX : (k == V2) ? V2_FLOP_PER_PX : SCALAR_FLOP_PER_PX;
    const double peak = fp_per_px / FP_UNITS;                 // cycles per pixel
    const double flop_per_cycle = flop_per_px / cycles_per_px;

    char name[16];
    if (k == SCALAR) snprintf(name, sizeof name, "scalar");
    else if (k == V1) snprintf(name, sizeof name, "v1");
    else snprintf(name, sizeof name, "v2 G=%d", groups);

    printf("%-8s %5d x %-5d %9.1f %8.3f ", name, w, h, 12.0 * n / 1024, cycles_per_px);
    if (peak > 0) printf("%7.3f %6.0f%% ", peak, 100 * peak / cycles_per_px);
    else          printf("%7s %7s ", "-", "-");
    printf("%8.2f %6.0f%%   %s (bins vs atan2: %ld)\n", flop_per_cycle,
           100 * flop_per_cycle / MACHINE_PEAK_FLOP, mag_wrong ? "WRONG" : "ok", bin_diff);

    free(blur); free(mag); free(angle); free(mag_ref); free(angle_ref);
}

// Column names for the result tables.
static void print_header(void) {
    printf("%-8s %13s %9s %8s %7s %7s %8s %7s   %s\n",
           "kernel", "image", "data KB", "cyc/px", "peak", "%peak", "FLOP/cyc", "%mach", "check");
}

// Kernel only: the vector loop on 3 rows of width w, no border code. With w = 1026 the
// 3 input rows and 2 output rows are about 20 KB, so everything stays in L1 and only the
// FP units can limit the speed. This is the number to compare with the peak.
static void bench_row(Kernel k, int groups, int w, double cycles_per_tick) {
    float *blur = alloc(size_t(3) * w), *mag = alloc(size_t(3) * w), *angle = alloc(size_t(3) * w);
    float *mag_ref = alloc(size_t(3) * w), *angle_ref = alloc(size_t(3) * w);
    fill(blur, size_t(3) * w);
    naive(w, 3, blur, mag_ref, angle_ref);          // reference for the middle row
    const float *top = blur, *mid = blur + w, *bot = blur + 2 * w;
    float *mag_row = mag + w, *angle_row = angle + w;

    auto row = [&]() {
        return (k == V1) ? sobel_row_avx2(top, mid, bot, mag_row, angle_row, 1, w - 1)
                         : sobel_row_avx2_v2(top, mid, bot, mag_row, angle_row, 1, w - 1, groups);
    };
    const int end = row();                          // also the warm-up
    const long pixels = end - 1;                    // columns 1 .. end-1 were computed
    const long reps = std::max(1L, (long)(50e6 / pixels));
    double best = 1e300;
    for (int trial = 0; trial < 5; ++trial) {
        unsigned long long t0 = rdtsc();
        for (long r = 0; r < reps; ++r)
            row();
        unsigned long long t1 = rdtsc();
        best = std::min(best, (double)(t1 - t0) / reps);
    }
    const double cycles_per_px = best * cycles_per_tick / pixels;

    long mag_wrong = 0, bin_diff = 0;
    for (int x = 1; x < end; ++x) {
        if (memcmp(&mag[w + x], &mag_ref[w + x], sizeof(float)) != 0) ++mag_wrong;
        if (angle[w + x] != bin_of(angle_ref[w + x])) ++bin_diff;
    }
    const double peak = ((k == V1) ? V1_FP_PER_PX : V2_FP_PER_PX) / FP_UNITS;
    const double flop_per_cycle = ((k == V1) ? V1_FLOP_PER_PX : V2_FLOP_PER_PX) / cycles_per_px;
    char name[16];
    if (k == V1) snprintf(name, sizeof name, "v1");
    else snprintf(name, sizeof name, "v2 G=%d", groups);
    printf("%-8s %5d x %-5d %9.1f %8.3f %7.3f %6.0f%% %8.2f %6.0f%%   %s (bins vs atan2: %ld)\n",
           name, w, 3, 20.0 * w / 1024, cycles_per_px, peak, 100 * peak / cycles_per_px,
           flop_per_cycle, 100 * flop_per_cycle / MACHINE_PEAK_FLOP, mag_wrong ? "WRONG" : "ok", bin_diff);
    free(blur); free(mag); free(angle); free(mag_ref); free(angle_ref);
}

int main() {
    // Empty loop to warm the CPU up to its full clock (same idea as the assignments).
    for (volatile long w = 0; w < 300000000; w++) { }

    const double cycles_per_tick = core_cycles_per_tick();
    printf("core clock: %.2f GHz (rdtsc %.1f GHz x %.3f core cycles per tick)\n",
           BASE_FREQ * cycles_per_tick, BASE_FREQ, cycles_per_tick);
    printf("peak = FP-unit instructions per pixel / %d units. machine peak %.0f FLOP/cycle.\n\n",
           FP_UNITS, MACHINE_PEAK_FLOP);

    // 1. Kernel only, all data in L1: how close the vector loop gets to its peak.
    printf("Kernel only (vector loop, 3 rows, data in L1)\n");
    print_header();
    bench_row(V1, 0, 1026, cycles_per_tick);
    for (int g : {1, 2, 4, 8})
        bench_row(V2, g, 1026, cycles_per_tick);

    // 2. Whole Part 2 on images (border pixels use scalar code), baseline included.
    printf("\nWhole Part 2 (image sizes by where the data fits)\n");
    print_header();
    // Image sizes chosen by where blur + mag + angle (12 bytes per pixel) fit:
    // L1 32 KB, L2 1 MB, L3 11 MB, then main memory.
    const int sizes[][2] = {{258, 8}, {256, 256}, {768, 768}, {1920, 1080}, {3840, 2160}};
    for (const auto& s : sizes) {
        bench(SCALAR, 0, s[0], s[1], cycles_per_tick);
        bench(V1, 0, s[0], s[1], cycles_per_tick);
        for (int g : {1, 2, 4, 8})
            bench(V2, g, s[0], s[1], cycles_per_tick);
        printf("\n");
    }

    // Measure the clock again at the end; if it moved a lot, the core changed speed.
    printf("core clock at the end: %.2f GHz\n", BASE_FREQ * core_cycles_per_tick());
    return 0;
}
