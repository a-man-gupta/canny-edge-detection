// Benchmark the production fused NMS + threshold loop against scalar byte labels.
#include "l1_rows.hpp"
#include "../kernels/nms/kernel_nms.hpp"
#include <random>

// The ordered label loop executes 200 arithmetic vector operations for 128 pixels.
constexpr int OPS_PER_PIXEL = 25;

// Scalar reference: direction from Gx, Gy; keep c if c > first and c >= second.
static int scalar_nms(const int16_t *mid, std::ptrdiff_t ms, int gx, int gy) {
    const int16_t *up = mid - ms, *down = mid + ms;
    const int ax = std::abs(gx), ay = std::abs(gy), t = (ax * 27146) >> 16, c = mid[0];
    int first, second;
    if (ay <= t) { first = mid[-1]; second = mid[1]; }                   // horizontal
    else if (ay > t + 2 * ax) { first = up[0]; second = down[0]; }        // vertical
    else if ((gx ^ gy) >= 0) { first = up[-1]; second = down[1]; }        // same signs
    else { first = up[1]; second = down[-1]; }                            // opposite signs
    return c > first && c >= second ? c : 0;
}

int main(int argc, char **argv) {
    uint64_t runs; int trials;
    arguments(argc, argv, runs, trials);
    const int width = requested_width() ? requested_width() : 256;
    if (width % 64) { std::fputs("NMS width must be a multiple of 64\n", stderr); return 2; }
    const int s = width + 32;   // stride for magnitude, gradient and output rows
    // Match the ten-row Sobel tile at the shared benchmark width.
    const int rows = width == 256 ? 10 : 2;
    const size_t mag_bytes = size_t(rows + 2) * s * sizeof(int16_t);
    const size_t grad_bytes = size_t(rows) * s * sizeof(int16_t);
    const auto page_round = [](size_t n) { return (n + 4095) / 4096 * 4096; };
    const size_t gx_offset = page_round(mag_bytes) + 640;
    const size_t gy_offset = gx_offset + page_round(grad_bytes) + 256;
    const size_t out_offset = gy_offset + page_round(grad_bytes) + 2112;
    char *block = (char *)allocate_aligned(4096 + out_offset + size_t(rows) * s);
    char *base = block + (4096 - uintptr_t(block) % 4096) % 4096;
    auto *mag = reinterpret_cast<int16_t*>(base) + 16;
    auto *gx = reinterpret_cast<int16_t*>(base + gx_offset);
    auto *gy = reinterpret_cast<int16_t*>(base + gy_offset);
    auto *out = reinterpret_cast<uint8_t*>(base + out_offset);
    auto run_tile = [&](int low, int high) {
        if (rows == 10)
            nms_labels_ten_rows(mag, s, gx, gy, s, out, s, width, low, high);
        else
            nms_labels(mag, s, gx, gy, s, out, s, width, low, high);
    };

    // ==================== CORRECTNESS ====================
    std::mt19937 rng(646);
    for (int t = 0; t < 400; t++) {
        const int gmax = t % 3 == 0 ? 3 : t % 3 == 1 ? 40 : 1020, mmax = t % 2 ? 6 : 2040;
        for (int i = -16; i < (rows + 2) * s - 16; i++) mag[i] = rng() % (mmax + 1);
        for (int i = 0; i < rows * s; i++) {
            gx[i] = int(rng() % (2 * gmax + 1)) - gmax;
            gy[i] = int(rng() % (2 * gmax + 1)) - gmax;
        }
        const int low = t % 2 ? 60 : 2, high = t % 2 ? 120 : 4;
        std::memset(out, 0xa5, size_t(rows) * s);
        run_tile(low, high);
        for (int r = 0; r < rows; ++r)
            for (int x = width; x < s; ++x)
                if (out[r*s+x] != 0xa5) {
                    std::fprintf(stderr, "FAIL: wrote into row %d padding\n", r);
                    return 1;
                }
        for (int r = 0; r < rows; r++)
            for (int x = 0; x < width; x++) {
                int kept = scalar_nms(mag + (r + 1) * s + x, s, gx[r * s + x], gy[r * s + x]);
                if (out[r * s + x] != (kept > low) + (kept > high)) {
                    std::printf("FAIL: row %d column %d\n", r, x);
                    return 1;
                }
            }
    }
    std::puts("Correctness: PASS (400 fills: ties, small and full ranges, both diagonal signs)");
    if (std::getenv("CHECK_ONLY")) return 0;

    // ==================== TIMING ====================
    for (int i = -16; i < (rows + 2) * s - 16; i++) mag[i] = rng() % 2041;
    for (int i = 0; i < rows * s; i++) { gx[i] = int(rng() % 2041) - 1020; gy[i] = int(rng() % 2041) - 1020; }
    HotLines hot;
    for (int r = 0; r < rows + 2; ++r) hot.row(mag + r*s - 1, 2*(width + 2));
    for (int r = 0; r < rows; ++r) {
        hot.row(gx + r*s, 2*width);
        hot.row(gy + r*s, 2*width);
        hot.row(out + r*s, width);
    }
    std::puts("Production fused NMS + threshold: 3200 lane-ops per 128 outputs / (232 p015 uops / 3) = 41.38 lane-ops/cycle.");
    measure_rows([&] { run_tile(60, 120); },
                 hot, rows * width, OPS_PER_PIXEL * rows * width, runs, trials);
    std::free(block);
}
