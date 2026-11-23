#pragma once
#include "../kernels/gaussian/gaussian_kernel.hpp"
enum class FusionMode { row, morton, staged };

// Distinct contiguous image buffers. Writes NMS labels and the final edge image.
// Dimensions >=5, strip a multiple of 64 in [64,320], 0 <= low < high <= 32767.
void canny_tiled(const uint8_t *image, uint8_t *labels, uint8_t *edges, int w, int h,
                 GaussQ15 q, int low, int high, int strip, double &filter_ms, double &track_ms,
                 FusionMode mode = FusionMode::row, bool mask_seeds = false);

// Filters a slab padded with four real image rows at each internal MPI boundary.
void canny_slab_labels(const uint8_t *input, uint8_t *labels, int w, int padded_height,
                       int first_owned, int owned_rows, GaussQ15 q);
