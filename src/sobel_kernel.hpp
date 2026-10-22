#pragma once

#include <cstddef>

// Part 2 kernel (AVX2). The scalar reference in canny_scalar.cpp stays inline.
// Reads blur, a row-major width*height image of whole numbers 0..255 (the pipeline's
// rounded blur). Writes mag (gradient strength) and angle.
// angle is one of 0, 45, 90, 135 from the OpenCV-style sector test, not an atan2 result.
// Pixels exactly on a bin boundary can disagree with canny_scalar.
void sobel_kernel(int w, int h,
                  const float* __restrict blur,
                  float* __restrict mag,
                  float* __restrict angle);

// The vector loop for one interior row (used by sobel_kernel and timed alone by sobel_driver).
// top/mid/bot are blur rows y-1, y, y+1. Writes columns from x_begin in steps of 64, then
// 32, then 8 pixels, never reading past column x_limit. Returns the first column not written.
int sobel_row_avx2(const float* top, const float* mid, const float* bot,
                   float* mag_row, float* angle_row, int x_begin, int x_limit);

// Scalar version of the direction bin. Returns 0, 45, 90, or 135.
float sobel_classify_angle(float gx, float gy);
