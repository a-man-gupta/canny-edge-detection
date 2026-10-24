# Part 2 Sobel kernel: build, run and look at the assembly, like the assignment Makefiles.
# (CMake still builds everything else; this is only for quick kernel experiments.)
#
#   make            build and run the driver (pinned to CORE)
#   make assemble   write the kernel assembly to sobel_kernel.S (objdump, as in the assignment)
#   make count      count the instructions in one loop iteration (and the peak)
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
# The Sobel kernel also uses AVX-512VL/DQ: mask registers and 32 ymm registers, still 256-bit.
SOBEL_FLAGS  = $(KERNEL_FLAGS) -mavx512f -mavx512vl -mavx512dq
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
	@echo "wrote sobel_kernel.S (look for sobel_row)"

count:
	$(CXX) $(SOBEL_FLAGS) $(EXTRA) -DSOBEL_MARK_LOOPS -S src/sobel_kernel.cpp -o sobel_kernel_marked.s
	@awk '/# loop .* begin/ {on=1; px=$$NF; fp=0; mask=0; other=0; next} \
	      /# loop end/ {if (on) printf "loop of %d pixels: %d FP-unit instructions, %d mask compares (port 5), %d other vector instructions -> peak %.3f cycles/pixel\n", px, fp, mask, other, fp/2/px; on=0; next} \
	      on && $$1 ~ /^v(add|sub|mul|sqrt|fn?m)/ {fp++; next} on && $$1 ~ /^v(cmp|ptestm)/ {mask++; next} on && $$1 ~ /^v/ {other++}' sobel_kernel_marked.s

# Part 3 (NMS) kernel.
nms: clean
	$(CXX) $(SOBEL_FLAGS) $(EXTRA) -c src/nms_kernel.cpp -o nms_kernel.o
	$(CXX) $(DRIVER_FLAGS) -o nms_driver.x src/nms_driver.cpp nms_kernel.o
	taskset -c $(CORE) ./nms_driver.x

# Peak of each unit for one NMS loop iteration: loads / 2 (2 load ports), compares into a
# mask / 1 (port 5 only), issue (all instructions) / 4. The largest is the peak.
nms-count:
	$(CXX) $(SOBEL_FLAGS) $(EXTRA) -DSOBEL_MARK_LOOPS -S src/nms_kernel.cpp -o nms_kernel_marked.s
	@awk '/# loop nms begin/ {on=1; px=$$NF; n=0; cmp=0; ld=0; next} \
	      /# loop end/ {if (on) { iss=n/4/px; p5=cmp/px; l=ld/2/px; pk=iss; if (p5>pk) pk=p5; if (l>pk) pk=l; \
	        printf "loop of %d pixels: %d instructions, %d mask compares, %d loads\n", px, n, cmp, ld; \
	        printf "  loads %.3f, port 5 %.3f, issue %.3f cycles/pixel -> peak %.3f cycles/pixel\n", l, p5, iss, pk }; on=0; next} \
	      on && $$1 ~ /^v/ {n++; if ($$0 ~ /\(/ && $$NF ~ /^%ymm/) ld++} \
	      on && $$1 ~ /^vcmp/ {cmp++} \
	      on && $$1 ~ /^(add|sub|cmp|lea|j)/ {n++}' nms_kernel_marked.s

clean:
	rm -f *.x *.o *.S sobel_kernel_marked.s nms_kernel_marked.s
