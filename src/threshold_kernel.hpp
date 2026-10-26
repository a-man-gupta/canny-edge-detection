#pragma once
#include <cstddef>
#include <cstdint>

// Double threshold on NMS output: label 2 where mag_sq > high_sq, 1 where mag_sq > low_sq,
// else 0. mag_sq is the int32 squared magnitude NMS writes (nonnegative); low_sq and high_sq
// are the squared thresholds (floor(low^2), floor(high^2)). Arrays have n elements and do not
// overlap. Same result as the scalar loop in canny_part2.cpp for every input.
void threshold_kernel(size_t n, const int32_t *mag_sq, uint8_t *labels, int64_t low_sq,
                      int64_t high_sq);

// Hot loop (256-bit AVX2): 64 pixels per iteration. The int32 inputs are packed to int16 with
// signed saturation before the compares, which keeps every comparison exact as long as
// 0 <= low_sq < high_sq <= 32766 and the inputs are nonnegative (threshold_kernel checks the
// thresholds and uses the int32 path otherwise). n is a multiple of 64; repetition is inside
// the function so benchmark timing has no per-call overhead.
extern "C" void threshold_i16_repeat(const int32_t *mag_sq, uint8_t *labels, long n,
                                     int low_sq, int high_sq, long reps);
