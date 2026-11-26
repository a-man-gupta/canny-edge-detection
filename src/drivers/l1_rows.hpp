#pragma once
#include "../common/benchmark.hpp"
#include <memory>
#include <set>

// Count the actual 64-byte cache lines touched, including halos and row padding.
struct HotLines {
    std::set<uintptr_t> lines;
    void row(const void *p, size_t bytes) {
        uintptr_t begin = reinterpret_cast<uintptr_t>(p);
        for (uintptr_t line = begin / 64; line <= (begin + bytes - 1) / 64; ++line)
            lines.insert(line);
    }
};

template<class Kernel>
void measure_rows(Kernel run, const HotLines &hot, int pixels, int lane_ops,
                  uint64_t runs, int trials) {
    size_t bytes = 64 * hot.lines.size();
    if (bytes > l1_capacity()) {
        std::fprintf(stderr, "Touched buffers exceed L1: %zu bytes\n", bytes);
        std::exit(2);
    }
    CoreCounter cycles;
    const char *event = std::getenv("CANNY_RAW_EVENT");
    std::unique_ptr<CoreCounter> counter;
    if (event) counter.reset(new CoreCounter(PERF_TYPE_RAW, std::strtoull(event, nullptr, 16)));
    std::vector<double> cpp;
    for (int trial = 0; trial < trials; ++trial) {
        for (uint64_t r = 0; r < runs / 10 + 1; ++r) run();
        auto before = counter ? counter->read() : CoreCounter::Sample{};
        auto start = cycles.read();
        for (uint64_t r = 0; r < runs; ++r) run();
        auto end = cycles.read();
        auto after = counter ? counter->read() : CoreCounter::Sample{};
        if (end.running-start.running != end.enabled-start.enabled ||
            after.running-before.running != after.enabled-before.enabled) {
            std::fprintf(stderr, "Multiplexed event\n"); std::exit(2);
        }
        double clocks = end.cycles - start.cycles;
        cpp.push_back(clocks / (double(runs) * pixels));
        std::printf("trial %d cpp %.8f event_per_cycle %.7f\n", trial, cpp.back(),
                    double(after.cycles-before.cycles) / clocks);
    }
    const double elapsed = median(cpp);
    std::printf("hot_bytes %zu cpp %.8f int_ops_per_cycle %.5f hot_FLOPs 0\n",
                bytes, elapsed, double(lane_ops) / pixels / elapsed);
}
