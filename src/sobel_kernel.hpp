#pragma once

#include <cstddef>

// Part 2 kernel. The scalar reference in canny_scalar.cpp stays inline.
// Reads blur, a row-major width*height image.
// Writes mag (gradient strength) and angle.
// angle is one of 0, 45, 90, 135 from the OpenCV-style sector test.
// It is not an atan2 result. Boundary pixels can disagree with canny_scalar.
void sobel_kernel(int w, int h,
                  const float* __restrict blur,
                  float* __restrict mag,
                  float* __restrict angle);

// v2: same outputs as sobel_kernel when blur holds whole numbers (the pipeline's blur
// is quantized to 0..255), fewer instructions per pixel, `groups` x 8 pixels per
// iteration (1, 2, 4 or 8; default 4).
void sobel_kernel_v2(int w, int h,
                     const float* __restrict blur,
                     float* __restrict mag,
                     float* __restrict angle,
                     int groups = 4);

// Interior vector loops for one row, used by the kernels above and by the L1 benchmark.
// top/mid/bot are blur rows y-1, y, y+1. Columns x_begin, x_begin+step, ... are written
// while the whole step fits (v1: 16 pixels, v2: 8*groups, then single groups of 8);
// nothing past column x_limit is read. Returns the first column not written.
int sobel_row_avx2(const float* top, const float* mid, const float* bot,
                   float* mag_row, float* angle_row, int x_begin, int x_limit);
int sobel_row_avx2_v2(const float* top, const float* mid, const float* bot,
                      float* mag_row, float* angle_row, int x_begin, int x_limit, int groups);

// Same sector test as the vector loops. Returns 0, 45, 90, or 135.
float sobel_classify_angle(float gx, float gy);
