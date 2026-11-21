#pragma once
#include <cstdint>

// Sobel with L1 magnitude on a fixed-layout strip buffer.
// Input: SOBEL_ROWS + 2 rows of pre-widened uint16 pixels in [0,255], row stride SOBEL_IN_STRIDE.
// Output: three int16 planes in one buffer, row stride SOBEL_OUT_STRIDE:
//   M = |Gx| + |Gy| at output, Gx at output + SOBEL_PLANE, Gy at output + 2 * SOBEL_PLANE.
// Width is a positive multiple of 32 and at most SOBEL_MAX_WIDTH. Buffers are disjoint.
// Fixed strides let every load and store use a constant offset from one pointer.
#ifndef SOBEL_ROWS
#define SOBEL_ROWS 6
#endif
constexpr int SOBEL_MAX_WIDTH = 384;
constexpr int SOBEL_IN_STRIDE = 448;   // uint16 elements per input row
constexpr int SOBEL_OUT_STRIDE = 416;  // int16 elements per output row
constexpr int SOBEL_PLANE = SOBEL_ROWS * SOBEL_OUT_STRIDE;

void sobel_kernel(const uint16_t *input, int16_t *output, int width);
