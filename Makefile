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

clean:
	rm -rf build
