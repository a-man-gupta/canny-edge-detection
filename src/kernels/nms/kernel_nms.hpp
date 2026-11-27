#pragma once
#include <cstddef>
#include <cstdint>

// =====================================================================================
// Non-maximum suppression on Sobel's int16 planes (M = |Gx| + |Gy| <= 2040, Gx, Gy).
//
//   Direction  horizontal if |Gy| <= 0.414|Gx|, vertical if |Gy| > 2.414|Gx|, else diagonal
//              (sign of Gx*Gy picks which). 0.414|Gx| is mulhi(|Gx|, 27146), with no branches.
//   Keep test  c > first AND c >= second  <=>  c > max(first, second - 1)   (exact for integers)
//
//   Input   top: magnitude row ABOVE the first output row, column 0. Rows are read from
//           top - 1 to top + rows + 1, so every magnitude row needs one valid value on each side.
//           gx, gy: the first output row, column 0. Strides are in elements.
//   Width   a positive multiple of 64.
//   Loop    one iteration = 2 rows x 64 columns (four groups of 16 lanes).
//
// nms_kernel   writes int16: M where the pixel is a local maximum, else 0.
// nms_labels   fuses double thresholding and writes uint8 labels: 0 rejected, 1 weak, 2 strong.
//              Used by the tiled pipeline, 8 label rows per Sobel slab (called 2 rows at a time).
// =====================================================================================
void nms_kernel(const int16_t *top, std::ptrdiff_t mag_stride, const int16_t *gx,
                const int16_t *gy, std::ptrdiff_t grad_stride, int16_t *out,
                std::ptrdiff_t out_stride, int width);

void nms_labels(const int16_t *top, std::ptrdiff_t ms, const int16_t *gx, const int16_t *gy,
                std::ptrdiff_t gs, uint8_t *out, std::ptrdiff_t os, int width, int low, int high);

// Same as nms_labels, ten output rows (twelve magnitude rows). Used by the NMS driver.
void nms_labels_ten_rows(const int16_t *top, std::ptrdiff_t ms, const int16_t *gx, const int16_t *gy,
                std::ptrdiff_t gs, uint8_t *out, std::ptrdiff_t os, int width, int low, int high);
