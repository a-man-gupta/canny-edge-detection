#pragma once

#include <cstdint>

// Part 2 kernel (sobel_kernel.cpp), integer: the same numbers as OpenCV's Canny with
// apertureSize=3 and L2gradient=true.
//   blur:   uint8 image (what cv2.GaussianBlur gives for a uint8 input), row-major, width w.
//   mag_sq: int32 gx*gx + gy*gy. OpenCV never takes the square root: it squares the two thresholds
//           instead, so the double-threshold stage must compare against low*low and high*high.
//   bin:    uint8 direction bin 0, 45, 90 or 135, from OpenCV's integer test (TG22 = 13573).
// Border pixels repeat the nearest edge pixel (OpenCV's BORDER_REPLICATE for the Sobel step).
void sobel_kernel(int w, int h, const uint8_t* blur, int32_t* mag_sq, uint8_t* bin);

// Spill-free AVX2 row kernel, also timed directly by sobel_driver.
// Inputs are int16 values in 0..255; output bins are int16 values 0/45/90/135.
// Writes [begin,end), with a readable one-pixel halo on either side.
// Buffers must not overlap. Empty ranges and arbitrary tails are supported.
// Main loop: 64 pixels (unrolled by hand), AVX2 YMM registers only; guards/fill/drain/tails are outside it.
void sobel_i16_row(const int16_t* top, const int16_t* mid, const int16_t* bot,
                   int32_t* mag_sq_row, int16_t* bin_row, int begin, int end);

// Scalar direction bin, exactly OpenCV's test. Returns 0, 45, 90 or 135.
uint8_t sobel_bin(int gx, int gy);
