// Benchmarks the AVX2 Gaussian blur kernels against gaussian_naive on one PGM image.
// Reports cycles from the hardware counter (user mode), wall time, and output agreement.
//   bench_gaussian --input image.pgm [--iterations 50] [--naive-iterations 5]
#include "gaussian_simd.hpp"

#include <linux/perf_event.h>
#include <sys/syscall.h>
#include <unistd.h>

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>

using Clock = std::chrono::steady_clock;

// Same code as canny_scalar_test.cpp, so the reference matches the profiled pipeline.
static inline int reflect(int p, int length) {
    while (p < 0 || p >= length)
        p = p < 0 ? -p : 2 * length - 2 - p;
    return p;
}

__attribute__((noinline))
void make_gaussian_weights(float sigma, float weights[5][5]) {
    float sum = 0;
    for (int y = -2; y <= 2; ++y)
        for (int x = -2; x <= 2; ++x) {
            weights[y + 2][x + 2] = std::exp(-(x * x + y * y) / (2 * sigma * sigma));
            sum += weights[y + 2][x + 2];
        }
    for (int y = 0; y < 5; ++y)
        for (int x = 0; x < 5; ++x)
            weights[y][x] /= sum;
}

__attribute__((noinline))
void gaussian_naive(const uint8_t* image, float* blur, int w, int h, const float weights[5][5]) {
    for (int y = 0; y < h; ++y)
        for (int x = 0; x < w; ++x) {
            float value = 0;
            for (int j = -2; j <= 2; ++j)
                for (int k = -2; k <= 2; ++k)
                    value += weights[j + 2][k + 2] *
                             image[size_t(reflect(y + j, h)) * w + reflect(x + k, w)];
            blur[size_t(y) * w + x] = std::clamp(std::floor(value + 0.5f), 0.0f, 255.0f);
        }
}

// User-mode hardware counter for this process.
struct Counter {
    int fd;
    explicit Counter(uint64_t config) {
        perf_event_attr a{};
        a.type = PERF_TYPE_HARDWARE;
        a.size = sizeof(a);
        a.config = config;
        a.exclude_kernel = 1;
        a.exclude_hv = 1;
        fd = int(syscall(SYS_perf_event_open, &a, 0, -1, -1, 0));
        if (fd < 0) throw std::runtime_error("perf_event_open failed");
    }
    uint64_t read() const {
        uint64_t v = 0;
        if (::read(fd, &v, sizeof(v)) != sizeof(v)) throw std::runtime_error("counter read failed");
        return v;
    }
};

struct Sample { double ms, cycles, instructions; };

template <class F>
static std::vector<Sample> measure(F&& f, int warmup, int iterations, const Counter& cyc, const Counter& ins) {
    std::vector<Sample> out;
    for (int i = -warmup; i < iterations; ++i) {
        uint64_t c0 = cyc.read(), i0 = ins.read();
        auto t0 = Clock::now();
        f();
        auto t1 = Clock::now();
        uint64_t c1 = cyc.read(), i1 = ins.read();
        if (i >= 0)
            out.push_back({std::chrono::duration<double, std::milli>(t1 - t0).count(), double(c1 - c0), double(i1 - i0)});
    }
    return out;
}

static Sample median(std::vector<Sample> s) {
    auto mid = [&](auto key) {
        std::vector<double> v;
        for (auto& x : s) v.push_back(key(x));
        std::nth_element(v.begin(), v.begin() + v.size() / 2, v.end());
        return v[v.size() / 2];
    };
    return {mid([](const Sample& x) { return x.ms; }), mid([](const Sample& x) { return x.cycles; }),
            mid([](const Sample& x) { return x.instructions; })};
}

static std::string token(std::istream& in) {
    std::string s;
    while (in >> s) { if (s[0] != '#') return s; std::getline(in, s); }
    throw std::runtime_error("Invalid PGM header");
}

static float* aligned_floats(size_t n) {
    void* p = std::aligned_alloc(64, (n * sizeof(float) + 63) / 64 * 64);
    if (!p) throw std::bad_alloc();
    std::memset(p, 0, n * sizeof(float));
    return static_cast<float*>(p);
}

int main(int argc, char** argv) try {
    std::string input;
    int iterations = 50, naive_iterations = 5;
    for (int a = 1; a + 1 < argc; a += 2) {
        std::string k = argv[a], v = argv[a + 1];
        if (k == "--input") input = v;
        else if (k == "--iterations") iterations = std::stoi(v);
        else if (k == "--naive-iterations") naive_iterations = std::stoi(v);
        else throw std::runtime_error("Unknown option " + k);
    }
    std::ifstream in(input, std::ios::binary);
    if (token(in) != "P5") throw std::runtime_error("Expected binary PGM");
    int w = std::stoi(token(in)), h = std::stoi(token(in));
    if (token(in) != "255" || w < 8 || h < 8 || w > gsimd::MAX_W)
        throw std::runtime_error("Expected uint8 PGM, 8 <= width <= " + std::to_string(gsimd::MAX_W) + ", height >= 8");
    in.get();
    const size_t n = size_t(w) * h;
    std::vector<uint8_t> image(n);
    in.read(reinterpret_cast<char*>(image.data()), std::streamsize(n));
    if (size_t(in.gcount()) != n) throw std::runtime_error("Truncated image");

    float weights[5][5];
    make_gaussian_weights(1.4f, weights);
    float* strip = aligned_floats(gsimd::STRIP_FLOATS);
    std::vector<float> ref(n), exact(n), fma(n);
    Counter cyc(PERF_COUNT_HW_CPU_CYCLES), ins(PERF_COUNT_HW_INSTRUCTIONS);

    // Whole-image blur: pack + kernel + tiling, the drop-in replacement for gaussian_naive.
    Sample s_naive = median(measure([&] { gaussian_naive(image.data(), ref.data(), w, h, weights); },
                                    1, naive_iterations, cyc, ins));
    Sample s_exact = median(measure([&] { gsimd::gaussian_simd(gsimd::blur_strip_exact, image.data(), exact.data(), w, h, weights, strip); },
                                    3, iterations, cyc, ins));
    Sample s_fma = median(measure([&] { gsimd::gaussian_simd(gsimd::blur_strip_fma, image.data(), fma.data(), w, h, weights, strip); },
                                  3, iterations, cyc, ins));

    // Kernel alone on one packed strip, repeated so the data stays in cache.
    // Narrow strip (64 px): inputs and outputs fit in L1. Full strip: inputs ~92 KB, in L2.
    gsimd::pack_strip(image.data(), w, h, h / 2, strip);
    std::vector<float> out(size_t(gsimd::ROWS) * w);
    const int narrow = 64, narrow_reps = 200000, full_reps = 2000;
    auto kernel_only = [&](gsimd::StripFn fn, int cols, int reps) {
        return median(measure([&] { for (int i = 0; i < reps; ++i) fn(strip, &weights[0][0], out.data(), size_t(w), cols); },
                              1, 9, cyc, ins));
    };
    Sample k_fma_l1 = kernel_only(gsimd::blur_strip_fma, narrow, narrow_reps);
    Sample k_fma_l2 = kernel_only(gsimd::blur_strip_fma, w, full_reps);
    Sample k_exact_l1 = kernel_only(gsimd::blur_strip_exact, narrow, narrow_reps);
    Sample k_exact_l2 = kernel_only(gsimd::blur_strip_exact, w, full_reps);

    // Agreement with the naive reference.
    size_t exact_diff = 0, fma_diff = 0;
    float fma_max = 0;
    for (size_t i = 0; i < n; ++i) {
        exact_diff += std::memcmp(&exact[i], &ref[i], sizeof(float)) != 0;
        fma_diff += fma[i] != ref[i];
        fma_max = std::max(fma_max, std::fabs(fma[i] - ref[i]));
    }

    const double px = double(n);
    std::printf("image %dx%d (%zu px)\n\n", w, h, n);
    std::printf("Whole-image blur (median)       ms/frame   cycles/px   GHz    speedup\n");
    auto row = [&](const char* name, const Sample& s) {
        std::printf("  %-28s %9.3f %11.3f %6.2f %8.1fx\n", name, s.ms, s.cycles / px,
                    s.cycles / (s.ms * 1e6), s_naive.ms / s.ms);
    };
    row("naive (scalar)", s_naive);
    row("SIMD exact (mul + add)", s_exact);
    row("SIMD FMA", s_fma);

    std::printf("\nKernel only, 8x8 block (median)  cycles/block  cycles/px  IPC   %% of peak\n");
    auto krow = [&](const char* name, const Sample& s, int cols, int reps, double peak_cycles) {
        double blocks = double(reps) * ((cols + 7) / 8);
        double cpb = s.cycles / blocks;
        std::printf("  %-30s %10.1f %10.3f %5.2f %8.1f%%\n", name, cpb, cpb / 64, s.instructions / s.cycles,
                    100 * peak_cycles / cpb);
    };
    krow("FMA,   L1-resident (64 px)", k_fma_l1, narrow, narrow_reps, 100);
    krow("FMA,   L2-resident (full row)", k_fma_l2, w, full_reps, 100);
    krow("exact, L1-resident (64 px)", k_exact_l1, narrow, narrow_reps, 200);
    krow("exact, L2-resident (full row)", k_exact_l2, w, full_reps, 200);
    std::printf("  peak: FMA 100 cycles/block (2 FMA/cycle), exact 200 cycles/block (2 mul|add/cycle)\n");

    std::printf("\nCorrectness vs naive\n");
    std::printf("  SIMD exact: %zu of %zu pixels differ %s\n", exact_diff, n, exact_diff ? "(FAIL)" : "(bit-identical)");
    std::printf("  SIMD FMA:   %zu of %zu pixels differ (%.4f%%), max |diff| = %.0f gray level\n",
                fma_diff, n, 100.0 * fma_diff / n, fma_max);
    std::free(strip);
    return exact_diff ? 2 : 0;
} catch (const std::exception& e) {
    std::fprintf(stderr, "%s\n", e.what());
    return 1;
}
