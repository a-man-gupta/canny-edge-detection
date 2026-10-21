#pragma once

#include <cstddef>

// Part 2 kernel. The scalar reference in canny_scalar.cpp stays inline.
// Reads blur, a row-major width*height image.
// Writes mag (gradient strength) and angle.
// angle is not a continuous atan2 result. It is one of 0, 45, 90, 135,
// the representative that selects the same Part 3 neighbor pair as the
// reference angle bin (horizontal, 45, vertical, 135).
void sobel_kernel(int w, int h,
                  const float* __restrict blur,
                  float* __restrict mag,
                  float* __restrict angle);

// Same classifier as the scalar tail and the vector fallback.
// Returns 0, 45, 90, or 135. Counts a fallback lane when it calls atan2.
float sobel_classify_angle(float gx, float gy);

unsigned long long sobel_fallback_lanes();
void sobel_reset_fallback_lanes();
