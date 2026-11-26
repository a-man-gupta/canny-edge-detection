// Benchmark the production gradient and L1-magnitude object against scalar Sobel.
#include "l1_rows.hpp"
#include "../kernels/sobel/kernel_sobel.hpp"
#include <random>

// Four row-preparation ops per source row, six gradient/magnitude ops per
// output row and one initial adjacent difference sum, all on int16 lanes.
constexpr int OPS_PER_GROUP = (4 * (SOBEL_ROWS + 2) + 6 * SOBEL_ROWS + 1) * 16;

static int scalar_gx(const uint16_t *p) {   // p = top-left of the 3x3 neighbourhood
    const int s = SOBEL_IN_STRIDE;
    return (p[2] - p[0]) + 2 * (p[s + 2] - p[s]) + (p[2 * s + 2] - p[2 * s]);
}
static int scalar_gy(const uint16_t *p) {
    const int s = SOBEL_IN_STRIDE;
    return (p[2 * s] + 2 * p[2 * s + 1] + p[2 * s + 2]) - (p[0] + 2 * p[1] + p[2]);
}

int main(int argc, char **argv) {
    uint64_t runs; int trials;
    arguments(argc, argv, runs, trials);
    const int width = requested_width() ? requested_width() : 256;
    if (width % 32 || width > SOBEL_MAX_WIDTH) {
        std::fprintf(stderr, "Sobel width must be a multiple of 32, at most %d\n", SOBEL_MAX_WIDTH);
        return 2;
    }
    // Match the pipeline scratch layout: the three output planes follow the input rows.
    constexpr size_t input_words = (SOBEL_ROWS + 2) * SOBEL_IN_STRIDE;
    auto *input = static_cast<uint16_t*>(allocate_aligned(
        (input_words + 3 * SOBEL_PLANE) * sizeof(uint16_t)));
    auto *output = reinterpret_cast<int16_t*>(input + input_words);

    // ==================== CORRECTNESS ====================
    std::mt19937 rng(645);
    for (int t = 0; t < 100; t++) {
        for (int i = 0; i < (SOBEL_ROWS + 2) * SOBEL_IN_STRIDE; i++)
            input[i] = t == 0 ? 0 : t == 1 ? 255 : t == 2 ? (i % 2) * 255
                     : t == 3 ? ((i / SOBEL_IN_STRIDE) % 2) * 255 : rng() % 256;
        sobel_kernel(input, output, width);
        for (int r = 0; r < SOBEL_ROWS; r++)
            for (int x = 0; x < width; x++) {
                const uint16_t *p = input + r * SOBEL_IN_STRIDE + x;
                const int gx = scalar_gx(p), gy = scalar_gy(p), o = r * SOBEL_OUT_STRIDE + x;
                if (output[o] != std::abs(gx) + std::abs(gy) || output[SOBEL_PLANE + o] != gx ||
                    output[2 * SOBEL_PLANE + o] != gy) {
                    std::printf("FAIL: row %d column %d\n", r, x);
                    return 1;
                }
            }
    }
    std::puts("Correctness: PASS (exact Gx, Gy, |Gx|+|Gy|; zero, 255, stripes, 96 random fills)");
    if (std::getenv("CHECK_ONLY")) return 0;

    // ==================== TIMING ====================
    HotLines hot;
    for (int r = 0; r < SOBEL_ROWS + 2; ++r)
        hot.row(input + r * SOBEL_IN_STRIDE, 2 * (width + 2));
    for (int p = 0; p < 3; ++p)
        for (int r = 0; r < SOBEL_ROWS; ++r)
            hot.row(output + p * SOBEL_PLANE + r * SOBEL_OUT_STRIDE, 2 * width);
    std::printf("Sobel %d rows, width %d. Functional-unit model: %d lane-ops per 16 columns / %.3f p015 cycles = 48.00 lane-ops/cycle.\n",
                SOBEL_ROWS, width, OPS_PER_GROUP, OPS_PER_GROUP / 48.0);
    measure_rows([&] { sobel_kernel(input, output, width); }, hot,
                 SOBEL_ROWS * width, OPS_PER_GROUP * (width / 16), runs, trials);
}
