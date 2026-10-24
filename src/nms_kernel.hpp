#pragma once

// Part 3 kernel (AVX2 width + AVX-512VL masks): non-maximum suppression, the same rule as
// canny_scalar.cpp (Part 3).
// Reads mag and angle. angle must hold Part 2's direction bins: 0, 45, 90 or 135 degrees
// (the vector loop relies on that; for other angles the result can differ from the scalar code).
// Writes suppressed: mag[i] where the pixel is a ridge along its direction, else 0.
// The first and last rows and columns are 0.
void nms_kernel(int w, int h, const float* mag, const float* angle, float* suppressed);

// The vector loop for 4 interior rows y .. y+3 (used by nms_kernel and timed alone by
// nms_driver). mag, angle and out are whole w-wide images; reads mag rows y-1 .. y+4.
// Writes columns x_begin .. x_limit-1 of the 4 rows (in steps of 8, the last step overlapping),
// never reading past column x_limit. Returns the first column not written.
int nms_rows4(const float* mag, const float* angle, float* out, int w, int y, int x_begin, int x_limit);
