#pragma once
// Core cycles, instructions and reference cycles of this thread, read as one perf group
// (same counters as nms_driver.cpp). Reference cycles tick at the 2.1 GHz nominal clock, so
// 2.1 * core / reference is the average core GHz over a sample.
#include <algorithm>
#include <cstdint>
#include <linux/perf_event.h>
#include <stdexcept>
#include <sys/syscall.h>
#include <unistd.h>
#include <vector>

struct PerfCounter {
  int fd = -1, instructions = -1, ref = -1;
  PerfCounter() {
    perf_event_attr a{};
    a.size = sizeof(a);
    a.type = PERF_TYPE_HARDWARE;
    a.config = PERF_COUNT_HW_CPU_CYCLES;
    a.exclude_kernel = 1;
    a.exclude_hv = 1;
    a.pinned = 1;
    a.read_format = PERF_FORMAT_GROUP | PERF_FORMAT_TOTAL_TIME_ENABLED |
                    PERF_FORMAT_TOTAL_TIME_RUNNING;
    fd = int(syscall(__NR_perf_event_open, &a, 0, -1, -1, 0));
    a.pinned = 0;
    a.config = PERF_COUNT_HW_INSTRUCTIONS;
    instructions = int(syscall(__NR_perf_event_open, &a, 0, -1, fd, 0));
    a.config = PERF_COUNT_HW_REF_CPU_CYCLES;
    ref = int(syscall(__NR_perf_event_open, &a, 0, -1, fd, 0));
    if (fd < 0 || instructions < 0 || ref < 0)
      throw std::runtime_error("perf_event_open failed");
  }
  ~PerfCounter() {
    if (ref >= 0) close(ref);
    if (instructions >= 0) close(instructions);
    if (fd >= 0) close(fd);
  }
  PerfCounter(const PerfCounter &) = delete;
  PerfCounter &operator=(const PerfCounter &) = delete;

  struct Sample { uint64_t enabled, running, cycles, instructions, ref; };
  Sample read_now() const {
    uint64_t b[6];
    if (::read(fd, b, sizeof(b)) != ssize_t(sizeof(b)) || b[0] != 3)
      throw std::runtime_error("counter read failed");
    return {b[1], b[2], b[3], b[4], b[5]};
  }
};

// Counts between two reads. Rejects multiplexed samples, as nms_driver.cpp does.
struct PerfDelta {
  double cycles, instructions, ghz;
  PerfDelta(const PerfCounter::Sample &a, const PerfCounter::Sample &b) {
    if (b.enabled - a.enabled != b.running - a.running)
      throw std::runtime_error("counter multiplexing: sample rejected");
    if (b.ref == a.ref)
      throw std::runtime_error("reference cycle counter returned zero");
    cycles = double(b.cycles - a.cycles);
    instructions = double(b.instructions - a.instructions);
    ghz = 2.1 * cycles / double(b.ref - a.ref);
  }
};

inline double median(std::vector<double> a) {
  std::sort(a.begin(), a.end());
  size_t k = a.size() / 2;
  return a.size() % 2 ? a[k] : (a[k - 1] + a[k]) * 0.5;
}
