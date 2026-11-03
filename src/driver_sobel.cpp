// Sobel (L1 magnitude): exact check against a scalar reference, then measured
// executed int16 ops/cycle against the functional-unit peak.
#include "benchmark.hpp"
#include "kernel_sobel.hpp"
#include <random>

// Ports 0/1/5 micro-ops per loop iteration (SOBEL_ROWS rows x 32 columns = 2 groups):
//   each input row-group:  D = R - L, T = R + C, T + T, S = 2T - D   -> 4 add/sub
//   each output row-group: E, Gx, Gy, M = |Gx| + |Gy|                -> 4 add/sub + 2 abs
//   setup: E = D_top + D_mid per group                              -> 1 add
constexpr int INPUT_ROW_GROUPS = (SOBEL_ROWS + 2) * 2;
constexpr int OUTPUT_ROW_GROUPS = SOBEL_ROWS * 2;
constexpr int ADD_SUB = 4 * INPUT_ROW_GROUPS + 4 * OUTPUT_ROW_GROUPS + 2;   // ports 0, 1, 5
constexpr int ABS = 2 * OUTPUT_ROW_GROUPS;                                   // ports 0, 1
constexpr double PORT_CYCLES = double(ADD_SUB + ABS) / 3;          // busiest port group
constexpr int OPS_PER_LOOP = (ADD_SUB + ABS) * 16;                  // executed int16 operations
constexpr double OPS_PER_PIXEL = double(OPS_PER_LOOP) / (SOBEL_ROWS * 32);
constexpr double PEAK = OPS_PER_LOOP / PORT_CYCLES;                 // 3 ports x 16 lanes = 48

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
    // Input page-aligned; output starts 3072 bytes into its page (avoids 4K aliasing with the input).
    uint16_t *input = (uint16_t *)allocate_aligned(2 * (SOBEL_ROWS + 2) * SOBEL_IN_STRIDE + 4096);
    char *output_block = (char *)allocate_aligned(2 * 3 * SOBEL_PLANE + 8192);
    int16_t *output = (int16_t *)(output_block + (4096 - uintptr_t(output_block) % 4096) % 4096 + 3072);

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
    CoreCounter counter;
    std::vector<double> rates;
    for (int t = 0; t < trials; t++) {
        for (uint64_t i = 0; i < runs / 10 + 1; i++) sobel_kernel(input, output, width);
        const auto start = counter.read();
        for (uint64_t i = 0; i < runs; i++) sobel_kernel(input, output, width);
        const auto end = counter.read();
        if (end.enabled - start.enabled != end.running - start.running) {
            std::fputs("Counter was multiplexed\n", stderr); return 2;
        }
        rates.push_back(OPS_PER_PIXEL * SOBEL_ROWS * width * runs / double(end.cycles - start.cycles));
    }
    const double measured = median(rates);
    std::printf("Sobel L1, tile %d rows x 32 columns, width %d\n", SOBEL_ROWS, width);
    std::printf("  ports 0,1,5: (%d add/sub + %d abs) / 3 = %.2f cycles per loop\n", ADD_SUB, ABS, PORT_CYCLES);
    std::printf("  peak     = %d instructions x 16 lanes / %.2f = %.2f ops/cycle\n", ADD_SUB + ABS, PORT_CYCLES, PEAK);
    std::printf("  measured = %.2f ops/cycle (median of %d), %.1f%% of peak, %.3f cycles/pixel\n",
                measured, trials, 100 * measured / PEAK, OPS_PER_PIXEL / measured);
    return 0;
}
