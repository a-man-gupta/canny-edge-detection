// Part 2 for a whole image: the AVX2 row kernel (sobel_kernel.cpp) on the interior of each
// row, and scalar code for the border pixels, where the 3x3 window falls outside the image.
#include "sobel_kernel.hpp"

#include <cmath>
#include <cstddef>

// One blur sample. A coordinate outside the image is clamped to the edge.
static float sample(const float* blur, int w, int h, int y, int x) {
    if (y < 0)
        y = 0;
    if (y >= h)
        y = h - 1;
    if (x < 0)
        x = 0;
    if (x >= w)
        x = w - 1;
    return blur[size_t(y) * w + x];
}

// One border pixel. gx and gy are written in the same order as canny_scalar.cpp.
static void scalar_at(const float* blur, int w, int h, int y, int x,
                      float* mag, float* angle) {
    float gx = -sample(blur, w, h, y - 1, x - 1) + sample(blur, w, h, y - 1, x + 1)
             - 2 * sample(blur, w, h, y, x - 1) + 2 * sample(blur, w, h, y, x + 1)
             - sample(blur, w, h, y + 1, x - 1) + sample(blur, w, h, y + 1, x + 1);
    float gy = -sample(blur, w, h, y - 1, x - 1) - 2 * sample(blur, w, h, y - 1, x) - sample(blur, w, h, y - 1, x + 1)
             + sample(blur, w, h, y + 1, x - 1) + 2 * sample(blur, w, h, y + 1, x) + sample(blur, w, h, y + 1, x + 1);
    size_t i = size_t(y) * w + x;
    mag[i] = std::sqrt(gx * gx + gy * gy);
    angle[i] = sobel_classify_angle(gx, gy);
}

// Whole image. Top and bottom rows clamp in y, so they stay scalar.
// Left and right borders clamp in x, so they stay scalar. The interior of each
// other row is sobel_row_avx2.
void sobel_kernel(int w, int h,
                  const float* __restrict blur,
                  float* __restrict mag,
                  float* __restrict angle) {
    for (int y = 0; y < h; ++y) {
        if (y == 0 || y == h - 1) {
            for (int x = 0; x < w; ++x)
                scalar_at(blur, w, h, y, x, mag, angle);
            continue;
        }

        scalar_at(blur, w, h, y, 0, mag, angle);
        const float* top = blur + size_t(y - 1) * w;
        const float* mid = blur + size_t(y) * w;
        const float* bot = blur + size_t(y + 1) * w;
        int x = sobel_row_avx2(top, mid, bot, mag + size_t(y) * w, angle + size_t(y) * w, 1, w - 1);
        for (; x < w; ++x)
            scalar_at(blur, w, h, y, x, mag, angle);
    }
}
