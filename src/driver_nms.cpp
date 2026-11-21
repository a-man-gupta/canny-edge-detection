// NMS (int16 L1 magnitude): exact check against a scalar reference, then measured
// executed int16 ops/cycle against the functional-unit peak.
#include "benchmark.hpp"
#include "kernel_nms.hpp"
#include <random>

// Micro-ops per row-group (16 pixels, one row):
//   ports 0, 1 only:  2 abs, 1 multiply-high, 2 compares (direction), 1 shift,
//                     4 max (thresholds), 1 compare (final)                      = 11
//   ports 0, 1, 5:    2 adds, 1 xor (direction), 4 subtracts (second - 1),
//                     3 blends x 2 micro-ops, 1 AND (final)                       = 14
// One loop iteration = 2 rows x 64 columns = 8 row-groups.
constexpr int ROW_GROUPS = 8;
constexpr int P01 = 11 * ROW_GROUPS, P015 = 14 * ROW_GROUPS;
constexpr double PORT_CYCLES = double(P01 + P015) / 3;   // P01 / 2 = 44 fits inside this
constexpr int INSTRUCTIONS = P01 + P015 - 3 * ROW_GROUPS;     // each blend is 1 instruction, 2 micro-ops
constexpr int OPS_PER_LOOP = INSTRUCTIONS * 16;               // executed int16 operations
constexpr double OPS_PER_PIXEL = OPS_PER_LOOP / 128.0;
constexpr double PEAK = OPS_PER_LOOP / PORT_CYCLES;

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
    const int width = requested_width() ? requested_width() : 768;
    if (width % 64) { std::fputs("NMS width must be a multiple of 64\n", stderr); return 2; }
    const int s = width + 32;   // stride for magnitude, gradient and output rows
    char *block = (char *)allocate_aligned(16 * 4096 + 10 * s * 2);
    char *base = block + (4096 - uintptr_t(block) % 4096) % 4096;
    int16_t *mag = (int16_t *)base + 16;                             // 4 rows, column -1 valid
    int16_t *gx = (int16_t *)(base + ((4 * s * 2 + 4095) / 4096 + 0) * 4096 + 640);
    int16_t *gy = (int16_t *)((char *)gx + ((2 * s * 2 + 4095) / 4096) * 4096 + 256);
    int16_t *out = (int16_t *)((char *)gy + ((2 * s * 2 + 4095) / 4096) * 4096 + 2112);

    // ==================== CORRECTNESS ====================
    std::mt19937 rng(646);
    for (int t = 0; t < 400; t++) {
        const int gmax = t % 3 == 0 ? 3 : t % 3 == 1 ? 40 : 1020, mmax = t % 2 ? 6 : 2040;
        for (int i = -16; i < 4 * s - 16; i++) mag[i] = rng() % (mmax + 1);
        for (int i = 0; i < 2 * s; i++) {
            gx[i] = int(rng() % (2 * gmax + 1)) - gmax;
            gy[i] = int(rng() % (2 * gmax + 1)) - gmax;
        }
        nms_kernel(mag, s, gx, gy, s, out, s, width);
        for (int r = 0; r < 2; r++)
            for (int x = 0; x < width; x++)
                if (out[r * s + x] != scalar_nms(mag + (r + 1) * s + x, s, gx[r * s + x], gy[r * s + x])) {
                    std::printf("FAIL: row %d column %d\n", r, x);
                    return 1;
                }
    }
    std::puts("Correctness: PASS (400 fills: ties, small and full ranges, both diagonal signs)");
    if (std::getenv("CHECK_ONLY")) return 0;

    // ==================== TIMING ====================
    for (int i = -16; i < 4 * s - 16; i++) mag[i] = rng() % 2041;
    for (int i = 0; i < 2 * s; i++) { gx[i] = int(rng() % 2041) - 1020; gy[i] = int(rng() % 2041) - 1020; }
    CoreCounter counter;
    std::vector<double> rates;
    for (int t = 0; t < trials; t++) {
        for (uint64_t i = 0; i < runs / 10 + 1; i++) nms_kernel(mag, s, gx, gy, s, out, s, width);
        const auto start = counter.read();
        for (uint64_t i = 0; i < runs; i++) nms_kernel(mag, s, gx, gy, s, out, s, width);
        const auto end = counter.read();
        if (end.enabled - start.enabled != end.running - start.running) {
            std::fputs("Counter was multiplexed\n", stderr); return 2;
        }
        rates.push_back(OPS_PER_PIXEL * 2 * width * runs / double(end.cycles - start.cycles));
    }
    const double measured = median(rates);
    std::printf("NMS L1, tile 2 rows x 64 columns, width %d\n", width);
    std::printf("  ports 0,1,5: (%d ports-0/1-only + %d any) / 3 = %.2f cycles per loop\n", P01, P015, PORT_CYCLES);
    std::printf("  peak     = %d instructions x 16 lanes / %.2f = %.2f ops/cycle\n", INSTRUCTIONS, PORT_CYCLES, PEAK);
    std::printf("  measured = %.2f ops/cycle (median of %d), %.1f%% of peak, %.3f cycles/pixel\n",
                measured, trials, 100 * measured / PEAK, OPS_PER_PIXEL / measured);
    return 0;
}
