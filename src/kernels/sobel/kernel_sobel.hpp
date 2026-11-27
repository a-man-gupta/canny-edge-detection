#pragma once
#include <cstdint>

// =====================================================================================
// Sobel 3x3, exact int16, L1 magnitude M = |Gx| + |Gy|.
//
//   Input   SOBEL_ROWS + 2 rows of blurred pixels, uint16 in [0, 255], row stride SOBEL_IN_STRIDE.
//           Column 0 is the pixel left of the first output; width + 2 columns are read.
//   Output  three int16 planes in one buffer, SOBEL_ROWS rows each, row stride SOBEL_OUT_STRIDE:
//             M  at output,  Gx at output + SOBEL_PLANE,  Gy at output + 2 * SOBEL_PLANE.
//           |Gx|, |Gy| <= 1020 and M <= 2040, so int16 is exact.
//   Width   a positive multiple of 32, at most SOBEL_MAX_WIDTH.
//   Loop    one iteration = SOBEL_ROWS rows x 32 columns (two independent groups of 16 lanes).
//
// SOBEL_ROWS is 6 in the standalone kernel and 10 in the tiled pipeline (8 label rows + 2 halo).
// Fixed strides let every load and store use a constant offset from one pointer.
// =====================================================================================
#ifndef SOBEL_ROWS
#define SOBEL_ROWS 6
#endif
constexpr int SOBEL_MAX_WIDTH = 384;
constexpr int SOBEL_IN_STRIDE = 480;   // uint16 elements per input row
constexpr int SOBEL_OUT_STRIDE = 480;  // int16 elements per output row
constexpr int SOBEL_PLANE = SOBEL_ROWS * SOBEL_OUT_STRIDE;

void sobel_kernel(const uint16_t *input, int16_t *output, int width);
