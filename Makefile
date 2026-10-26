# Part 2 Sobel kernel: build, run and look at the assembly, like the assignment Makefiles.
# (CMake still builds everything else; this is only for quick kernel experiments.)
#
#   make            build and run the driver (pinned to CORE)
#   make assemble   write the kernel assembly to sobel_kernel.S (objdump, as in the assignment)
#   make count      count the Sobel loop's instructions per port and the peak
#   make nms        build and run the Part 3 (NMS) kernel driver
#   make nms-count  count the NMS loop's instructions and the peak of each unit
#   make threshold / threshold-count / threshold-whole     Part 4 (double threshold), same three
#   make hysteresis / hysteresis-count / hysteresis-whole  Part 5 (hysteresis), same three
#   make clean
#
# Run on a quiet core: check `top`, and that the core's hyperthread sibling is idle too
# (cat /sys/devices/system/cpu/cpu10/topology/thread_siblings_list).

CXX          = g++
CORE         = 10
KERNEL_FLAGS = -std=c++17 -O3 -mavx2 -mfma -ffp-contract=off \
               -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store
# Sobel uses AVX2 intrinsics only. GCC forward propagation adds redundant gradient
# arithmetic; disable it for this translation unit. NMS uses the separately tested AVX2-only integer schedule.
SOBEL_FLAGS  = -std=c++17 -O3 -mavx2 -mno-avx512f -mtune=skylake -fno-tree-vectorize -fno-tree-forwprop -fno-unroll-loops \
               -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store -Wall -Wextra -Wpedantic
NMS_FLAGS    = -std=c++17 -O3 -mavx2 -mavx512f -mavx512vl -mavx512dq -mavx512bw -mtune=skylake -fno-tree-vectorize -fno-tree-slp-vectorize -fno-unroll-loops \
               -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store -Wall -Wextra -Wpedantic
# Double threshold: AVX2 only. Hysteresis: AVX2 vectors plus AVX-512VL vpternlogd on ymm (no zmm).
THRESHOLD_FLAGS  = -std=c++17 -O3 -mavx2 -mno-avx512f -mtune=skylake -fno-tree-vectorize -fno-tree-slp-vectorize -fno-unroll-loops \
                   -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store -Wall -Wextra -Wpedantic
HYSTERESIS_FLAGS = -std=c++17 -O3 -mavx2 -mavx512f -mavx512vl -mtune=skylake -fno-tree-vectorize -fno-tree-slp-vectorize -fno-unroll-loops \
                   -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store -Wall -Wextra -Wpedantic
DRIVER_FLAGS = -std=c++17 -O3 -fno-tree-vectorize -Isrc
EXTRA        =

default: run

sobel_driver.x: src/sobel_driver.cpp src/sobel_kernel.cpp src/sobel_kernel.hpp
	$(CXX) $(SOBEL_FLAGS) $(EXTRA) -c src/sobel_kernel.cpp -o sobel_kernel.o
	$(CXX) $(DRIVER_FLAGS) -o sobel_driver.x src/sobel_driver.cpp sobel_kernel.o

run: clean sobel_driver.x
	taskset -c $(CORE) ./sobel_driver.x

assemble: sobel_driver.x
	objdump -d --no-show-raw-insn -C sobel_kernel.o > sobel_kernel.S
	@echo "wrote sobel_kernel.S (look for sobel_i16_row)"

count: sobel_driver.x
	python3 scripts/analyze_sobel.py sobel_kernel.o

# Part 3: exact integer NMS, AVX2 only, 16 groups per hot-loop iteration.
nms_driver.x: src/nms_driver.cpp src/nms_kernel.cpp src/nms_kernel.hpp Makefile
	$(CXX) $(NMS_FLAGS) $(EXTRA) -c src/nms_kernel.cpp -o nms_kernel.o
	$(CXX) $(DRIVER_FLAGS) -Wall -Wextra -Wpedantic -o nms_driver.x src/nms_driver.cpp nms_kernel.o

nms: nms_driver.x
	taskset -c $(CORE) ./nms_driver.x

nms-assemble: nms_driver.x
	objdump -d --no-show-raw-insn -C nms_kernel.o > nms_kernel.S

nms-count: nms_driver.x
	python3 scripts/analyze_nms.py nms_driver.x

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
	$(CXX) $(NMS_FLAGS) -c src/nms_kernel.cpp -o nms_kernel.o
	$(CXX) $(SOBEL_FLAGS) -c src/sobel_kernel.cpp -o sobel_kernel.o
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
	rm -f *.x *.o *.S sobel_kernel_marked.s nms_kernel_marked.s
