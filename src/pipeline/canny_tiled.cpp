#include "canny_tiled.hpp"
#include "../kernels/sobel/kernel_sobel.hpp"
#include "../kernels/nms/kernel_nms.hpp"
#include "../kernels/nms/detail/nms_impl.hpp"
#include "../kernels/hysteresis/hysteresis_kernel.hpp"
#include <algorithm>
#include <cstring>
#include <immintrin.h>
#include <omp.h>
#include <vector>
#include <memory>
#include <stdexcept>

// How the stages connect and what sizes they use: see canny_tiled.hpp.
namespace {
constexpr int TILE_ROWS = 64;                  // label rows per tile
constexpr int PASS_ROWS = SOBEL_ROWS - 2;      // label rows per Sobel + NMS pass (8)
constexpr int BLUR_ROWS = TILE_ROWS + 4;       // blurred rows one tile can need (68)
constexpr int PREFETCH_ROWS = PASS_ROWS;       // fetch image rows one pass ahead
static_assert(PASS_ROWS > 0 && PASS_ROWS % 2 == 0 && TILE_ROWS % PASS_ROWS == 0);

// Per-worker buffers, reused for every tile the worker runs.
struct Scratch {
    std::unique_ptr<GaussianWork, decltype(&gaussian_work_destroy)> gaussian;  // expand row + ring
    // Sobel input for the whole tile: row j is blurred image row (tile_y - 2 + j). Pass p hands
    // Sobel the 12 rows starting at row 8p, so rows shared by two passes are never copied.
    alignas(64) uint16_t blur[BLUR_ROWS * SOBEL_IN_STRIDE]{};
    alignas(64) int16_t gradient[3 * SOBEL_PLANE]{};   // M, Gx, Gy for SOBEL_ROWS rows
    // One label row per interior Sobel row. NMS and both thresholds fill this before the strip is reused.
    alignas(64) uint8_t labels[PASS_ROWS * SOBEL_MAX_WIDTH]{};
    explicit Scratch(int width): gaussian(gaussian_work_create(width + 64), gaussian_work_destroy) {}
};

int reflect(int y, int h) {
    int period = 2 * (h - 1);
    int t = y % period;
    if (t < 0) t += period;
    return std::min(t, period - t);
}

unsigned long long morton_key(unsigned x, unsigned y) {
    unsigned long long key = 0;
    for (int i=0; x || y; ++i, x>>=1, y>>=1)
        key |= (static_cast<unsigned long long>((x&1) | ((y&1)<<1)) << (2*i));
    return key;
}

// Asks the cache for `bytes` bytes starting at p, one request per 64-byte line.
void prefetch(const uint8_t *p, int bytes) {
    for (int c = 0; c < bytes; c += 64) _mm_prefetch(reinterpret_cast<const char*>(p + c), _MM_HINT_T0);
    _mm_prefetch(reinterpret_cast<const char*>(p + bytes - 1), _MM_HINT_T0);
}

// One tile: label rows [y, y + height), columns [x, x + width) of `out`.
// staged = false: Gaussian runs here, from `image`. staged = true: `image` is already blurred.
template<bool staged>
void tile(const uint8_t *image, uint8_t *out, int w, int h, int x, int y,
          int width, int height, GaussQ15 q, int low, int high, Scratch &s) {
    // ==================== COLUMNS ====================
    const int nms_cols = (width + 63) / 64 * 64;                // NMS works in 64-column steps
    const int sobel_cols = (nms_cols + 2 + 31) / 32 * 32;       // + NMS halo, in 32-column steps
    const int input_cols = sobel_cols + 2;                      // + Sobel halo
    const int left = std::max(0, x - 4), right = std::min(w, x + sobel_cols + 2);
    const int gauss_cols = right - left;                        // + Gaussian halo, inside the image
    // Sobel input column i is image column x - 2 + i, i.e. Gaussian column offset + i.
    // Columns outside the image repeat the edge pixel: [begin, end) are real, the rest are filled.
    const int offset = x - 2 - left;
    const int begin = std::max(0, -offset), end = std::min(input_cols, gauss_cols - offset);

    // ==================== GAUSSIAN RING ====================
    // Ring row i holds the horizontal filter of image row reflect(first + i).
    GaussianWork *work = s.gaussian.get();
    const int first = std::clamp(y - 2, 0, h - 1) - 2;
    int latest = -1;                                            // last ring row computed
    [[maybe_unused]] auto image_row = [&](int i) { return image + size_t(reflect(first + i, h)) * w + left; };
    if constexpr (!staged)
        for (int i = 0; i < PREFETCH_ROWS; ++i) prefetch(image_row(i), gauss_cols);

    // Fills Sobel input row j with blurred image row (y - 2 + j), clamped to the image.
    auto blurred_row = [&](int j) {
        const int row = std::clamp(y - 2 + j, 0, h - 1);
        uint16_t *dst = s.blur + j * SOBEL_IN_STRIDE;
        if constexpr (staged) {
            const uint8_t *src = image + size_t(row) * w + left + offset;
            for (int i = begin; i < end; ++i) dst[i] = src[i];
        } else {
            // Advance the ring to image row (row + 2), prefetching one pass ahead as it goes.
            const int last = row + 2 - first;
            while (latest < last) {
                ++latest;
                int16_t *expanded = gaussian_scratch(work);
                gaussian_expand_row(image_row(latest), expanded, gauss_cols);
                gaussian_horiz_row(expanded, gaussian_ring_row(work, latest % 5), gauss_cols, q);
                prefetch(image_row(latest + PREFETCH_ROWS), gauss_cols);
            }
            // Vertical filter of rows (row - 2 .. row + 2), written straight into Sobel's input.
            const int16_t *rows[5];
            for (int i = 0; i < 5; ++i)
                rows[i] = gaussian_ring_row(work, (last - 4 + i) % 5) + offset + begin;
            gaussian_vert_row_u16(rows, dst + begin, end - begin, q);
        }
        std::fill(dst, dst + begin, dst[begin]);
        std::fill(dst + end, dst + input_cols, dst[end - 1]);
    };
    // ==================== PASSES: 12 BLURRED -> 10 GRADIENT -> 8 LABEL ROWS ====================
    for (int j = 0; j < 4; ++j) blurred_row(j);                 // rows shared with the first pass
    for (int r = 0; r < height; r += PASS_ROWS) {
        for (int j = r + 4; j < r + SOBEL_ROWS + 2; ++j) blurred_row(j);   // 8 new rows
        sobel_kernel(s.blur + r * SOBEL_IN_STRIDE, s.gradient, sobel_cols);
        // Gradient row 0 is the halo above the first label; label column 0 is Sobel column 1.
        // Classify every interior row in one pass: NMS and both thresholds write 0/1/2.
        const int16_t *top = s.gradient + 1;
        const int16_t *gx = top + SOBEL_OUT_STRIDE + SOBEL_PLANE;
        nms_labels_rows<PASS_ROWS>(top, SOBEL_OUT_STRIDE, gx, gx + SOBEL_PLANE, SOBEL_OUT_STRIDE,
                                   s.labels, nms_cols, nms_cols, low, high);
        const int n = std::min(PASS_ROWS, height - r);
        for (int k = 0; k < n; ++k)
            std::memcpy(out + size_t(y + r + k) * w + x, s.labels + size_t(k) * nms_cols, width);
    }
}
}  // namespace

// Caller supplies disjoint buffers and dimensions >= 5. Outer NMS border is zero.
void canny_tiled(const uint8_t *image, uint8_t *labels, uint8_t *edges, int w, int h,
                 GaussQ15 q, int low, int high, int strip, double &filter_ms, double &track_ms,
                 FusionMode mode, bool mask_seeds) {
    if (w < 5 || h < 5 || strip < 64 || strip > 320 || strip % 64 ||
        low < 0 || high <= low || high > 32767) throw std::invalid_argument("Canny dimensions or thresholds");
    double begin = omp_get_wtime();
    int workers = std::min(h, omp_get_max_threads());
    std::vector<size_t> frontier;

    // Tiles cover label rows/columns 1 .. h-2 / w-2 (the outer border stays 0).
    const int nx = (w - 3) / strip + 1, ny = (h - 3) / TILE_ROWS + 1;
    struct Tile { unsigned long long key; int x, y; };
    std::vector<Tile> order;
    if (mode == FusionMode::morton) {
        for (int y = 0; y < ny; ++y) for (int x = 0; x < nx; ++x)
            order.push_back({morton_key(x, y), x, y});
        std::sort(order.begin(), order.end(), [](auto a, auto b) { return a.key < b.key; });
    }
    // Staged mode only: the whole blurred image, and the horizontal Gaussian rows it is made from.
    const int pitch = (w + 31) / 32 * 32;
    std::vector<uint8_t> full_blur;
    std::vector<int16_t> horizontal;
    int16_t *aligned = nullptr;
    if (mode == FusionMode::staged) {
        full_blur.resize(size_t(w) * h);
        horizontal.resize(size_t(pitch) * h + 16);
        aligned = horizontal.data() + ((32 - reinterpret_cast<uintptr_t>(horizontal.data()) % 32) % 32) / 2;
    }

#pragma omp parallel num_threads(workers)
    {
        Scratch scratch(mode == FusionMode::staged ? w : strip);

        // ==================== STAGED ONLY: BLUR THE WHOLE IMAGE ====================
        if (mode == FusionMode::staged) {
            auto *row = gaussian_scratch(scratch.gaussian.get());
#pragma omp for schedule(static)
            for (int y = 0; y < h; ++y) {
                gaussian_expand_row(image + size_t(y) * w, row, w);
                gaussian_horiz_row(row, aligned + size_t(y) * pitch, w, q);
            }
#pragma omp for schedule(static)
            for (int y = 0; y < h; ++y) {
                const int16_t *rows[5];
                for (int j = 0; j < 5; ++j) rows[j] = aligned + size_t(reflect(y + j - 2, h)) * pitch;
                gaussian_vert_row(rows, full_blur.data() + size_t(y) * w, w, q);
            }
        }

        // ==================== FILTERS: ONE TILE AT A TIME ====================
#pragma omp for schedule(static)
        for (int i = 0; i < nx * ny; ++i) {
            int x = 1 + (order.empty() ? i % nx : order[i].x) * strip;
            int y = 1 + (order.empty() ? i / nx : order[i].y) * TILE_ROWS;
            int width = std::min(strip, w - 1 - x), height = std::min(TILE_ROWS, h - 1 - y);
            if (mode == FusionMode::staged)
                tile<true>(full_blur.data(), labels, w, h, x, y, width, height, q, low, high, scratch);
            else
                tile<false>(image, labels, w, h, x, y, width, height, q, low, high, scratch);
        }
#pragma omp master
        {
            std::fill_n(labels, w, 0);
            std::fill_n(labels + size_t(h - 1) * w, w, 0);
            for (int y = 1; y < h - 1; ++y) labels[size_t(y) * w] = labels[size_t(y + 1) * w - 1] = 0;
            filter_ms = (omp_get_wtime() - begin) * 1000;
        }
#pragma omp barrier

        // ==================== HYSTERESIS: ONE SLAB PER WORKER ====================
        const int id = omp_get_thread_num();
        const int n = omp_get_num_threads();
        const int first = int(int64_t(id) * h / n);
        const int end = int(int64_t(id + 1) * h / n);
        std::vector<size_t> queue;
        auto track = mask_seeds ? hysteresis_slab : hysteresis_kernel;
        track(w, end - first, labels + size_t(first) * w, edges + size_t(first) * w, queue);
#pragma omp barrier
        // Weak pixels on a slab edge that touch an edge in the neighbouring slab.
        queue.clear();
        for (int side = 0; side < 2; ++side) {
            int row = side ? end - 1 : first, other = row + (side ? 1 : -1);
            if (other < 0 || other >= h) continue;
            for (int x = 1; x < w - 1; ++x) {
                size_t p = size_t(row) * w + x, neighbor = size_t(other) * w + x;
                if (labels[p] == 1 && !edges[p] &&
                    (edges[neighbor - 1] || edges[neighbor] || edges[neighbor + 1])) queue.push_back(p);
            }
        }
#pragma omp critical(canny_seams)
        frontier.insert(frontier.end(), queue.begin(), queue.end());
    }

    // ==================== SEAMS: ONE THREAD FINISHES CROSS-SLAB PATHS ====================
    for (size_t p : frontier) edges[p] = 255;
    // Every candidate is interior because the NMS border is zero.
    for (size_t i = 0; i < frontier.size(); ++i)
        for (int dy = -1; dy <= 1; ++dy)
            for (int dx = -1; dx <= 1; ++dx) {
                size_t p = frontier[i] + dy * std::ptrdiff_t(w) + dx;
                if (labels[p] == 1 && !edges[p]) { edges[p] = 255; frontier.push_back(p); }
            }
    track_ms = (omp_get_wtime() - begin) * 1000 - filter_ms;
}

void canny_slab_labels(const uint8_t *input, uint8_t *labels, int w, int padded_height,
                       int first_owned, int owned_rows, GaussQ15 q) {
    constexpr int strip = 320;
    const int begin = std::max(first_owned, 1);
    const int end = std::min(first_owned + owned_rows, padded_height - 1);
    std::fill_n(labels, size_t(w) * padded_height, 0);
#pragma omp parallel
    {
        Scratch scratch(strip);
#pragma omp for collapse(2) schedule(static)
        for (int y = begin; y < end; y += TILE_ROWS)
            for (int x = 1; x < w - 1; x += strip)
                tile<false>(input, labels, w, padded_height, x, y, std::min(strip, w - 1 - x),
                            std::min(TILE_ROWS, end - y), q, 60, 120, scratch);
    }
}
