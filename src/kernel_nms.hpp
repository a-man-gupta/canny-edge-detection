#pragma once
#include <cstddef>
#include <cstdint>

// NMS on the int16 L1 magnitude M = |Gx| + |Gy| (at most 2040). Two output rows.
// top points at column 0 of the magnitude row above the first output row; every magnitude
// row has one valid value on each side. gx, gy and out point at column 0 of the first output row.
// Strides are in elements. Width is a positive multiple of 64. Output buffer is disjoint.
// Output is M where the pixel is a local maximum along its gradient direction, else 0.
void nms_kernel(const int16_t *top, std::ptrdiff_t mag_stride, const int16_t *gx,
                const int16_t *gy, std::ptrdiff_t grad_stride, int16_t *out,
                std::ptrdiff_t out_stride, int width);
