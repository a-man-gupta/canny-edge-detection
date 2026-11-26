cmake_minimum_required(VERSION 3.18)
project(canny_bench LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Match the final AVX2 kernels and flags built by the Makefile.
# Drivers use Linux perf_event_open for actual core-cycle measurements.
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
  message(FATAL_ERROR "The benchmark drivers require x86 Linux (run on an ECE machine).")
endif()
if(NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|AMD64|amd64)$")
  message(FATAL_ERROR "The kernels require an x86-64 CPU with AVX2 support.")
endif()

add_library(sobel_kernel OBJECT src/kernels/sobel/kernel_sobel.cpp)
add_library(nms_kernel OBJECT src/kernels/nms/kernel_nms.cpp)
foreach(kernel sobel_kernel nms_kernel)
  target_compile_options(${kernel} PRIVATE -O3 -mavx2 -mno-avx512f -mtune=skylake
    -fno-unroll-loops -mno-avx256-split-unaligned-load
    -mno-avx256-split-unaligned-store)
endforeach()
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(sobel_kernel PRIVATE
    -fno-tree-forwprop -fschedule-insns -fsched-pressure)
endif()

add_executable(sobel_driver src/drivers/driver_sobel.cpp $<TARGET_OBJECTS:sobel_kernel>)
target_compile_definitions(sobel_kernel PRIVATE SOBEL_ROWS=10)
target_compile_definitions(sobel_driver PRIVATE SOBEL_ROWS=10)
add_executable(nms_driver src/drivers/driver_nms.cpp $<TARGET_OBJECTS:nms_kernel>)
foreach(target sobel_kernel nms_kernel sobel_driver nms_driver)
  target_include_directories(${target} PRIVATE src)
  target_compile_options(${target} PRIVATE -O3 -Wall -Wextra -Wpedantic)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(${target} PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    target_compile_options(${target} PRIVATE -fno-vectorize -fno-slp-vectorize)
  endif()
endforeach()

include(CTest)
if(BUILD_TESTING)
  add_test(NAME sobel_matches_scalar COMMAND sobel_driver)
  add_test(NAME nms_matches_scalar COMMAND nms_driver)
  set_tests_properties(sobel_matches_scalar nms_matches_scalar
    PROPERTIES ENVIRONMENT "CHECK_ONLY=1")
endif()

# Existing whole-image pipeline and stages 4/5 retain their original interfaces.
# Scalar CPU Canny. The no-vectorize flags below stay as part of this reference build.
# canny_part2 is the same pipeline with the Part 2 Sobel kernel swapped in.
add_executable(canny_scalar src/reference/canny_scalar.cpp)
add_executable(canny_part2 src/legacy/canny_part2.cpp src/legacy/sobel_kernel.cpp)
# Part 2 benchmark in the assignment-driver style: scalar baseline vs kernel, cycles per pixel vs peak.
add_executable(legacy_sobel_driver src/legacy/sobel_driver.cpp src/legacy/sobel_kernel.cpp)
# Part 3 benchmark, same style.
add_executable(legacy_nms_driver src/legacy/nms_driver.cpp src/legacy/nms_kernel.cpp)
# Vector flags on the kernel translation units only; canny_scalar.cpp keeps -fno-tree-vectorize.
# Sobel uses the tested AVX2-only flags; no AVX-512 mask registers or instructions.
set_source_files_properties(src/legacy/sobel_kernel.cpp PROPERTIES COMPILE_FLAGS
  "-mavx2 -mno-avx512f -mtune=skylake -fno-unroll-loops -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store")
# Avoid GCC expanding the shared gradient expressions into extra arithmetic.
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set_property(SOURCE src/legacy/sobel_kernel.cpp APPEND_STRING PROPERTY COMPILE_FLAGS " -fno-tree-forwprop")
endif()
# Exact integer NMS: AVX2 only, with the tested 16-group C++ schedule.
# NMS: 256-bit AVX2 vectors plus AVX-512VL mask registers (kmovb, 1-uop masked selects); no zmm.
set_source_files_properties(src/legacy/nms_kernel.cpp PROPERTIES COMPILE_FLAGS
  "-O3 -mavx2 -mavx512f -mavx512vl -mavx512dq -mavx512bw -mtune=skylake -fno-unroll-loops -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store")
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set_property(SOURCE src/legacy/nms_kernel.cpp APPEND_STRING PROPERTY COMPILE_FLAGS " -fno-tree-vectorize -fno-tree-slp-vectorize")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set_property(SOURCE src/legacy/nms_kernel.cpp APPEND_STRING PROPERTY COMPILE_FLAGS " -fno-vectorize -fno-slp-vectorize")
endif()
# Part 4 double threshold (AVX2 only) and Part 5 hysteresis (AVX2 + AVX-512VL vpternlogd on ymm).
add_executable(threshold_driver src/drivers/threshold_driver.cpp src/kernels/threshold/threshold_kernel.cpp)
add_executable(hysteresis_driver src/drivers/hysteresis_driver.cpp src/kernels/hysteresis/hysteresis_kernel.cpp
  src/kernels/threshold/threshold_kernel.cpp src/legacy/nms_kernel.cpp src/legacy/sobel_kernel.cpp)
set_source_files_properties(src/kernels/threshold/threshold_kernel.cpp PROPERTIES COMPILE_FLAGS
  "-O3 -mavx2 -mno-avx512f -mtune=skylake -fno-unroll-loops -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store")
set_source_files_properties(src/kernels/hysteresis/hysteresis_kernel.cpp PROPERTIES COMPILE_FLAGS
  "-O3 -mavx2 -mavx512f -mavx512vl -mtune=skylake -fno-unroll-loops -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store")
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set_property(SOURCE src/kernels/threshold/threshold_kernel.cpp src/kernels/hysteresis/hysteresis_kernel.cpp APPEND_STRING PROPERTY COMPILE_FLAGS " -fno-tree-vectorize -fno-tree-slp-vectorize")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set_property(SOURCE src/kernels/threshold/threshold_kernel.cpp src/kernels/hysteresis/hysteresis_kernel.cpp APPEND_STRING PROPERTY COMPILE_FLAGS " -fno-vectorize -fno-slp-vectorize")
endif()
foreach(t threshold_driver hysteresis_driver)
  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(${t} PRIVATE -Wall -Wextra -Wpedantic)
  endif()
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    target_compile_options(${t} PRIVATE -fno-vectorize -fno-slp-vectorize)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(${t} PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
  endif()
endforeach()
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(canny_scalar PRIVATE -Wall -Wextra -Wpedantic)
  target_compile_options(canny_part2 PRIVATE -Wall -Wextra -Wpedantic)
  target_compile_options(legacy_sobel_driver PRIVATE -Wall -Wextra -Wpedantic)
  target_compile_options(legacy_nms_driver PRIVATE -Wall -Wextra -Wpedantic)
endif()
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  target_compile_options(canny_scalar PRIVATE -fno-vectorize -fno-slp-vectorize)
  target_compile_options(canny_part2 PRIVATE -fno-vectorize -fno-slp-vectorize)
  target_compile_options(legacy_sobel_driver PRIVATE -fno-vectorize -fno-slp-vectorize)
  target_compile_options(legacy_nms_driver PRIVATE -fno-vectorize -fno-slp-vectorize)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(canny_scalar PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
  target_compile_options(canny_part2 PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
  target_compile_options(legacy_sobel_driver PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
  target_compile_options(legacy_nms_driver PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
endif()
# Hysteresis connectivity test, and a bitwise Sobel check against the scalar OpenCV formulas.
include(CTest)
if(BUILD_TESTING)
  add_executable(test_hysteresis src/tests/test_hysteresis.cpp)
  add_test(NAME hysteresis_connectivity COMMAND test_hysteresis)
  add_executable(test_sobel_kernel src/tests/test_sobel_kernel.cpp src/legacy/sobel_kernel.cpp)
  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(test_sobel_kernel PRIVATE -Wall -Wextra -Wpedantic)
  endif()
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    target_compile_options(test_sobel_kernel PRIVATE -fno-vectorize -fno-slp-vectorize)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(test_sobel_kernel PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
  endif()
  add_test(NAME sobel_kernel_matches_scalar COMMAND test_sobel_kernel)
  # Part 3 kernel against the scalar NMS loop, bit for bit.
  add_executable(test_nms_kernel src/tests/test_nms_kernel.cpp src/legacy/nms_kernel.cpp)
  add_test(NAME nms_kernel_matches_scalar COMMAND test_nms_kernel)
  # Parts 4 and 5 against the scalar double threshold and hysteresis(), bit for bit.
  add_executable(test_threshold_kernel src/tests/test_threshold_kernel.cpp src/kernels/threshold/threshold_kernel.cpp)
  add_test(NAME threshold_kernel_matches_scalar COMMAND test_threshold_kernel)
  add_executable(test_hysteresis_kernel src/tests/test_hysteresis_kernel.cpp src/kernels/hysteresis/hysteresis_kernel.cpp)
  add_test(NAME hysteresis_kernel_matches_scalar COMMAND test_hysteresis_kernel)
endif()

add_executable(gaussian_driver src/drivers/gaussian_driver.cpp src/kernels/gaussian/gaussian_kernel.cpp)
target_compile_options(gaussian_driver PRIVATE -O3 -Wall -Wextra -Wpedantic)
set_source_files_properties(src/kernels/gaussian/gaussian_kernel.cpp PROPERTIES COMPILE_FLAGS
  "-O3 -mavx2 -mno-avx512f -mtune=skylake -fno-unroll-loops -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store")
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(gaussian_driver PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
endif()
if(BUILD_TESTING)
  add_test(NAME gaussian_matches_scalar COMMAND gaussian_driver test)
endif()
