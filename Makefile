# Part 2 Sobel kernel: build, run and look at the assembly, like the assignment Makefiles.
# (CMake still builds everything else; this is only for quick kernel experiments.)
#
#   make            build and run the driver (pinned to CORE)
#   make assemble   write the kernel assembly to sobel_kernel.S (objdump, as in the assignment)
#   make count      count the Sobel loop's instructions per port and the peak
#   make nms        build and run the Part 3 (NMS) kernel driver
#   make nms-count  count the NMS loop's instructions and the peak of each unit
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

clean:
	rm -f *.x *.o *.S sobel_kernel_marked.s nms_kernel_marked.s
