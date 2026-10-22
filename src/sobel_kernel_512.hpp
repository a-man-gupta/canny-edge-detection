#pragma once

// Part 2, AVX-512 experiment: the same row kernel as sobel_row_avx2 (sobel_kernel.hpp),
// 16 pixels per register. top/mid/bot are blur rows y-1, y, y+1. Writes mag and angle
// (0, 45, 90, 135) for columns x_begin .. x_limit-1 and returns x_limit.
// Never reads outside columns x_begin-1 .. x_limit.
int sobel_row_avx512(const float* top, const float* mid, const float* bot,
                     float* mag_row, float* angle_row, int x_begin, int x_limit);
