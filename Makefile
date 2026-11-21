# Sobel and NMS kernels: int16, L1 magnitude, AVX2 (Xeon Silver 4208 / Cascade Lake).
#
#   make            build both drivers and run them (same as make run)
#   make sobel      build and run only Sobel
#   make nms        build and run only NMS
#   make check      correctness checks only, no timing
#   make assemble   write the kernels' disassembly to build/*.S
#   make clean      remove build/
#
# Variables (override on the command line, e.g. make sobel SOBEL_SIZE=384 CORE=4):
#   CORE        core to pin to with taskset (default 10)
#   SOBEL_SIZE  Sobel width: multiple of 32, at most 384 (default 256)
#   NMS_SIZE    NMS width: multiple of 64 (default 768)
#   RUNS        kernel calls per trial (default 100000)
#   TRIALS      timed trials; the median is reported (default 9)

CXX        = g++
CORE       ?= 10
SOBEL_SIZE ?= 256
NMS_SIZE   ?= 768
RUNS       ?= 100000
TRIALS     ?= 9

# Kernels: AVX2 only, no auto-vectorization, so the intrinsics are what runs.
KERNEL_FLAGS = -std=c++17 -O3 -mavx2 -mno-avx512f -mtune=skylake \
               -fno-tree-vectorize -fno-tree-slp-vectorize -fno-unroll-loops \
               -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store \
               -Wall -Wextra -Wpedantic -Isrc
# Sobel also needs these: without them GCC reorders the adds and spills registers (~70% instead of ~80%).
SOBEL_FLAGS  = $(KERNEL_FLAGS) -fno-tree-forwprop -fschedule-insns -fsched-pressure
# Drivers: scalar reference and timing code.
DRIVER_FLAGS = -std=c++17 -O3 -fno-tree-vectorize -fno-tree-slp-vectorize -Wall -Wextra -Wpedantic -Isrc

.PHONY: all run sobel nms check assemble clean
.DEFAULT_GOAL := run

all: build/sobel.x build/nms.x

run: all
	SIZE=$(SOBEL_SIZE) taskset -c $(CORE) ./build/sobel.x $(RUNS) $(TRIALS)
	SIZE=$(NMS_SIZE) taskset -c $(CORE) ./build/nms.x $(RUNS) $(TRIALS)

sobel: build/sobel.x
	SIZE=$(SOBEL_SIZE) taskset -c $(CORE) ./build/sobel.x $(RUNS) $(TRIALS)

nms: build/nms.x
	SIZE=$(NMS_SIZE) taskset -c $(CORE) ./build/nms.x $(RUNS) $(TRIALS)

check: all
	CHECK_ONLY=1 ./build/sobel.x
	CHECK_ONLY=1 ./build/nms.x

assemble: build/kernel_sobel.o build/kernel_nms.o
	objdump -d --no-show-raw-insn -C build/kernel_sobel.o > build/kernel_sobel.S
	objdump -d --no-show-raw-insn -C build/kernel_nms.o > build/kernel_nms.S
	@echo "wrote build/kernel_sobel.S and build/kernel_nms.S"

build:
	mkdir -p build

build/kernel_sobel.o: src/kernel_sobel.cpp src/kernel_sobel.hpp Makefile | build
	$(CXX) $(SOBEL_FLAGS) -c $< -o $@

build/kernel_nms.o: src/kernel_nms.cpp src/kernel_nms.hpp Makefile | build
	$(CXX) $(KERNEL_FLAGS) -c $< -o $@

build/sobel.x: src/driver_sobel.cpp src/benchmark.hpp src/kernel_sobel.hpp build/kernel_sobel.o
	$(CXX) $(DRIVER_FLAGS) $< build/kernel_sobel.o -o $@

build/nms.x: src/driver_nms.cpp src/benchmark.hpp src/kernel_nms.hpp build/kernel_nms.o
	$(CXX) $(DRIVER_FLAGS) $< build/kernel_nms.o -o $@

# Part 1: 5x5 Gaussian blur, AVX2 integer, five-row horizontal ring (gaussian_driver: test, rows, whole).
GAUSSIAN_FLAGS = -std=c++17 -O3 -mavx2 -mno-avx512f -mtune=skylake -fno-tree-vectorize -fno-tree-slp-vectorize -fno-unroll-loops \
                 -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store -Wall -Wextra -Wpedantic
gaussian_driver.x: src/gaussian_driver.cpp src/gaussian_kernel.cpp src/gaussian_kernel.hpp src/perf_counter.hpp Makefile
	$(CXX) $(GAUSSIAN_FLAGS) $(EXTRA) -c src/gaussian_kernel.cpp -o gaussian_kernel.o
	$(CXX) $(DRIVER_FLAGS) -Wall -Wextra -Wpedantic -o gaussian_driver.x src/gaussian_driver.cpp gaussian_kernel.o

gaussian: gaussian_driver.x
	taskset -c $(CORE) ./gaussian_driver.x

gaussian-test: gaussian_driver.x
	./gaussian_driver.x test

gaussian-assemble: gaussian_driver.x
	objdump -d --no-show-raw-insn -C gaussian_kernel.o > gaussian_kernel.S

# Preserve the existing threshold/hysteresis pipeline targets.
# Double threshold: AVX2 only. Hysteresis: AVX2 vectors plus AVX-512VL vpternlogd on ymm (no zmm).
THRESHOLD_FLAGS  = -std=c++17 -O3 -mavx2 -mno-avx512f -mtune=skylake -fno-tree-vectorize -fno-tree-slp-vectorize -fno-unroll-loops \
                   -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store -Wall -Wextra -Wpedantic
HYSTERESIS_FLAGS = -std=c++17 -O3 -mavx2 -mavx512f -mavx512vl -mtune=skylake -fno-tree-vectorize -fno-tree-slp-vectorize -fno-unroll-loops \
                   -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store -Wall -Wextra -Wpedantic

SOBEL_LEGACY_FLAGS  = -std=c++17 -O3 -mavx2 -mno-avx512f -mtune=skylake -fno-tree-vectorize -fno-tree-forwprop -fno-unroll-loops \
               -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store -Wall -Wextra -Wpedantic

NMS_LEGACY_FLAGS    = -std=c++17 -O3 -mavx2 -mavx512f -mavx512vl -mavx512dq -mavx512bw -mtune=skylake -fno-tree-vectorize -fno-tree-slp-vectorize -fno-unroll-loops \
               -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store -Wall -Wextra -Wpedantic

# Part 4: double threshold, AVX2 only, 64 pixels per hot-loop iteration.
threshold_driver.x: src/threshold_driver.cpp src/threshold_kernel.cpp src/threshold_kernel.hpp src/perf_counter.hpp Makefile
	$(CXX) $(THRESHOLD_FLAGS) $(EXTRA) -c src/threshold_kernel.cpp -o threshold_kernel.o
	$(CXX) $(DRIVER_FLAGS) -Wall -Wextra -Wpedantic -o threshold_driver.x src/threshold_driver.cpp threshold_kernel.o

threshold: threshold_driver.x
	taskset -c $(CORE) ./threshold_driver.x

threshold-whole: threshold_driver.x
	taskset -c $(CORE) ./threshold_driver.x whole

threshold-count: threshold_driver.x
	python3 scripts/analyze_threshold.py threshold_driver.x

# Part 5: hysteresis vector pass, AVX2 + AVX-512VL vpternlogd, 4 rows x 32 pixels per iteration.
# hysteresis-whole builds labels with the Sobel, NMS and threshold kernels, so it links all four.
hysteresis_driver.x: src/hysteresis_driver.cpp src/hysteresis_kernel.cpp src/hysteresis_kernel.hpp src/hysteresis.hpp \
                     src/threshold_kernel.cpp src/nms_kernel.cpp src/sobel_kernel.cpp src/perf_counter.hpp Makefile
	$(CXX) $(HYSTERESIS_FLAGS) $(EXTRA) -c src/hysteresis_kernel.cpp -o hysteresis_kernel.o
	$(CXX) $(THRESHOLD_FLAGS) $(EXTRA) -c src/threshold_kernel.cpp -o threshold_kernel.o
	$(CXX) $(NMS_LEGACY_FLAGS) -c src/nms_kernel.cpp -o nms_kernel.o
	$(CXX) $(SOBEL_LEGACY_FLAGS) -c src/sobel_kernel.cpp -o sobel_kernel.o
	$(CXX) $(DRIVER_FLAGS) -Wall -Wextra -Wpedantic -o hysteresis_driver.x src/hysteresis_driver.cpp \
	  hysteresis_kernel.o threshold_kernel.o nms_kernel.o sobel_kernel.o

hysteresis: hysteresis_driver.x
	taskset -c $(CORE) ./hysteresis_driver.x

# Whole images from the newest benchmark dataset (override with WHOLE_IMAGES=...).
DATASET      = $(lastword $(sort $(wildcard benchmark_results/*/dataset)))
WHOLE_IMAGES = $(wildcard $(addprefix $(DATASET)/,resolution_1920x1080.pgm resolution_3840x2160.pgm \
               density_sparse_3840x2160.pgm density_noise_3840x2160.pgm density_chains_3840x2160.pgm))
hysteresis-whole: hysteresis_driver.x
	taskset -c $(CORE) ./hysteresis_driver.x whole $(WHOLE_IMAGES)

hysteresis-count: hysteresis_driver.x
	python3 scripts/analyze_hysteresis.py hysteresis_driver.x


clean:
	rm -rf build
