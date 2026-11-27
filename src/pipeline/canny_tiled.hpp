#pragma once
#include "../kernels/gaussian/gaussian_kernel.hpp"

// =====================================================================================
// Fused, tiled Canny: Gaussian -> Sobel -> NMS + threshold per tile, then hysteresis.
//
// 1. Tiles. OpenMP splits the label image into tiles of up to 64 rows x `strip` columns
//    (strip = 64..320, 320 in production). Each worker owns its tiles and its scratch.
//
// 2. One tile, eight label rows per pass (64-row tile = 8 passes):
//
//      image rows ──expand + horiz──▶ 5-row Gaussian ring ──vert──▶ blurred rows (uint16)
//                                                                       │ 12 rows
//                                                                       ▼
//                                                Sobel (SOBEL_ROWS = 10): M, Gx, Gy planes
//                                                                       │ 10 rows
//                                                                       ▼
//                                         NMS + threshold, one call per strip: uint8 labels
//                                                                       │ 8 rows
//                                                                       ▼
//                                                         copied into the label image
//
//    Sobel needs one blurred row above and below its 10 rows, NMS one magnitude row above and
//    below its 8: that is 12 -> 10 -> 8. Consecutive passes share 4 blurred rows, so each pass
//    after the first makes only 8 new ones. The blurred rows of a whole tile (64 + 4 = 68) sit in
//    one buffer and Sobel starts 8 rows lower each pass, so no rows are copied between passes.
//
//    Columns, for strip = 320: NMS works on 320 (a multiple of 64), Sobel on 352 (322 rounded up
//    to 32), its input has 354 (one extra column each side), and Gaussian filters up to 358
//    image columns (two more each side, for its own 5-tap window).
//
// 3. Hysteresis. After every tile has written labels, each worker tracks edges in its own
//    horizontal slab, then one thread finishes the paths that cross slab seams.
// =====================================================================================

// row: tiles in row-major order (production). morton: tiles in Z order.
// staged: blur the whole image first, then run Sobel + NMS per tile (the partly fused version).
enum class FusionMode { row, morton, staged };

// Distinct contiguous image buffers. Writes NMS labels and the final edge image.
// Dimensions >= 5, strip a multiple of 64 in [64, 320], 0 <= low < high <= 32767.
void canny_tiled(const uint8_t *image, uint8_t *labels, uint8_t *edges, int w, int h,
                 GaussQ15 q, int low, int high, int strip, double &filter_ms, double &track_ms,
                 FusionMode mode = FusionMode::row, bool mask_seeds = false);

// Filters a slab padded with four real image rows at each internal MPI boundary.
void canny_slab_labels(const uint8_t *input, uint8_t *labels, int w, int padded_height,
                       int first_owned, int owned_rows, GaussQ15 q);
