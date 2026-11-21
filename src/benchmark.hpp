#pragma once
#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <linux/perf_event.h>
#include <sched.h>
#include <sys/syscall.h>
#include <unistd.h>

// User-selected acceptance cutoff; keep the analytical peak unchanged.
constexpr double PERFORMANCE_CUTOFF = 0.75;

// Assignment-style work/cycles timing, using actual core cycles rather than
// RDTSC ticks multiplied by an assumed turbo/base frequency ratio.
struct CoreCounter {
    struct Sample { uint64_t cycles, enabled, running; };
    int fd;
    CoreCounter() {
        perf_event_attr event{};
        event.size = sizeof(event);
        event.type = PERF_TYPE_HARDWARE;
        event.config = PERF_COUNT_HW_CPU_CYCLES;
        event.exclude_kernel = 1;
        event.exclude_hv = 1;
        event.pinned = 1;
        event.read_format = PERF_FORMAT_TOTAL_TIME_ENABLED | PERF_FORMAT_TOTAL_TIME_RUNNING;
        fd = syscall(__NR_perf_event_open, &event, 0, -1, -1, 0);
        if (fd < 0) { std::perror("core-cycle counter"); std::exit(2); }
    }
    Sample read() const {
        Sample sample{};
        if (::read(fd, &sample, sizeof(sample)) != sizeof(sample)) {
            std::perror("read core-cycle counter"); std::exit(2);
        }
        return sample;
    }
    ~CoreCounter() { ::close(fd); }
};

static inline void* allocate_aligned(std::size_t bytes) {
    void* p = nullptr;
    if (posix_memalign(&p, 64, bytes)) {
        std::fprintf(stderr, "64-byte-aligned allocation failed\n"); std::exit(2);
    }
    std::memset(p, 0, bytes);
    return p;
}
static inline std::size_t cache_bytes(std::size_t bytes) {
    return (bytes + 63) & ~std::size_t(63);
}
static inline std::size_t l1_capacity() {
    char path[160], type[32] = {};
    std::snprintf(path, sizeof(path), "/sys/devices/system/cpu/cpu%d/cache/index0/type", sched_getcpu());
    FILE* f = std::fopen(path, "r");
    if (!f || std::fscanf(f, "%31s", type) != 1) {
        std::fprintf(stderr, "Cannot read L1 cache type\n"); std::exit(2);
    }
    std::fclose(f);
    if (std::strcmp(type, "Data") != 0) {
        std::fprintf(stderr, "Cache index0 is not L1 data\n"); std::exit(2);
    }
    std::snprintf(path, sizeof(path), "/sys/devices/system/cpu/cpu%d/cache/index0/size", sched_getcpu());
    f = std::fopen(path, "r");
    std::size_t size = 0; char unit = 0;
    if (!f || std::fscanf(f, "%zu%c", &size, &unit) != 2) {
        std::fprintf(stderr, "Cannot read L1 cache capacity\n"); std::exit(2);
    }
    std::fclose(f);
    return unit == 'K' ? size * 1024 : size;
}
static inline void arguments(int argc, char** argv, uint64_t& runs, int& trials) {
    runs = argc > 1 ? std::strtoull(argv[1], nullptr, 10) : 100000;
    trials = argc > 2 ? std::atoi(argv[2]) : 9;
    if (argc > 3 || !runs || trials < 1) {
        std::fprintf(stderr, "Usage: %s [runs>0] [trials>0]\n", argv[0]); std::exit(2);
    }
}
// make run sets these. SIZE=0 means every standard width. BRIEF=1 prints only
// size, the peak calculation, and measured integer ops/cycle.
static inline int requested_width() {
    const char* text = std::getenv("SIZE");
    if (!text || !text[0]) return 0;
    char* end = nullptr;
    long width = std::strtol(text, &end, 10);
    if (end == text || *end || width <= 0) {
        std::fprintf(stderr, "SIZE must be a positive width, got '%s'\n", text);
        std::exit(2);
    }
    return int(width);
}
static inline bool brief_report() {
    const char* text = std::getenv("BRIEF");
    return text && text[0] == '1';
}
static inline double median(std::vector<double>& samples) {
    std::sort(samples.begin(), samples.end());
    std::size_t n = samples.size();
    return n % 2 ? samples[n / 2] : (samples[n / 2 - 1] + samples[n / 2]) / 2;
}

// Distributions use fixed reference integer operations per actual core cycle.
static inline void print_samples(const char* name, std::vector<double> samples) {
    std::sort(samples.begin(), samples.end());
    const std::size_t last=samples.size()-1;
    double med=median(samples);
    std::printf("%-14s reference integer ops/cycle: min %.6f, p10 %.6f, median %.6f, p90 %.6f, max %.6f\n",
        name,samples.front(),samples[last/10],med,samples[9*last/10],samples.back());
}
