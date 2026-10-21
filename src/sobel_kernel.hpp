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

// Same sector test as the vector loop. Returns 0, 45, 90, or 135.
float sobel_classify_angle(float gx, float gy);
