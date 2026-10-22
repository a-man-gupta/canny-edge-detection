# Part 2 Sobel kernel: build, run and look at the assembly, like the assignment Makefiles.
# (CMake still builds everything else; this is only for quick kernel experiments.)
#
#   make            build and run the driver (pinned to CORE)
#   make 512        build and run the AVX-512 experiment (sobel_kernel_512.cpp, sobel_driver_512.cpp)
#   make assemble   write the kernel assembly to sobel_kernel.S (objdump, as in the assignment)
#   make count      count the instructions in one loop iteration (and the peak)
#   make clean
#
# Run on a quiet core: check `top`, and that the core's hyperthread sibling is idle too
# (cat /sys/devices/system/cpu/cpu10/topology/thread_siblings_list).

CXX          = g++
CORE         = 10
KERNEL_FLAGS = -std=c++17 -O3 -mavx2 -ffp-contract=off \
               -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store
DRIVER_FLAGS = -std=c++17 -O3 -fno-tree-vectorize -Isrc
EXTRA        =

default: run

sobel_driver.x: src/sobel_driver.cpp src/sobel_kernel.cpp src/sobel_kernel.hpp
	$(CXX) $(KERNEL_FLAGS) $(EXTRA) -c src/sobel_kernel.cpp -o sobel_kernel.o
	$(CXX) $(DRIVER_FLAGS) -o sobel_driver.x src/sobel_driver.cpp sobel_kernel.o

run: clean sobel_driver.x
	taskset -c $(CORE) ./sobel_driver.x

# AVX-512 experiment. The AVX2 kernel object is linked too, for sobel_classify_angle in naive().
512: clean
	$(CXX) $(KERNEL_FLAGS) -c src/sobel_kernel.cpp -o sobel_kernel.o
	$(CXX) $(KERNEL_FLAGS) -mavx512f -mavx512dq -c src/sobel_kernel_512.cpp -o sobel_kernel_512.o
	$(CXX) $(DRIVER_FLAGS) -o sobel_driver_512.x src/sobel_driver_512.cpp sobel_kernel.o sobel_kernel_512.o
	objdump -d --no-show-raw-insn -C sobel_kernel_512.o > sobel_kernel_512.S
	taskset -c $(CORE) ./sobel_driver_512.x

assemble: sobel_driver.x
	objdump -d --no-show-raw-insn -C sobel_kernel.o > sobel_kernel.S
	@echo "wrote sobel_kernel.S (look for sobel_row_avx2)"

count:
	$(CXX) $(KERNEL_FLAGS) $(EXTRA) -DSOBEL_MARK_LOOPS -S src/sobel_kernel.cpp -o sobel_kernel_marked.s
	@awk '/# loop .* begin/ {on=1; px=$$NF; fp=0; other=0; next} \
	      /# loop end/ {if (on) printf "loop of %d pixels: %d FP-unit instructions, %d other vector instructions -> peak %.3f cycles/pixel\n", px, fp, other, fp/2/px; on=0; next} \
	      on && $$1 ~ /^v(add|sub|mul|sqrt|cmp|fn?m)/ {fp++; next} on && $$1 ~ /^v/ {other++}' sobel_kernel_marked.s

clean:
	rm -f *.x *.o *.S sobel_kernel_marked.s
