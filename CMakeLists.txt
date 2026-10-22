cmake_minimum_required(VERSION 3.18)
project(canny_bench LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# Scalar CPU Canny. The no-vectorize flags below stay as part of this reference build.
# canny_part2 is the same pipeline with the Part 2 Sobel kernel swapped in.
add_executable(canny_scalar src/canny_scalar.cpp)
add_executable(canny_part2 src/canny_part2.cpp src/sobel_kernel.cpp)
# Part 2 benchmark in the assignment-driver style: scalar baseline vs kernel, cycles per pixel vs peak.
add_executable(sobel_driver src/sobel_driver.cpp src/sobel_kernel.cpp)
# AVX2 on the kernel translation unit only. canny_scalar.cpp keeps -fno-tree-vectorize
# and does not get -mavx2. -mfma is not passed. -ffp-contract=off keeps gx*gx + gy*gy
# from contracting into an FMA, so the magnitude stays mul, mul, add, sqrt.
# -mno-avx256-split-unaligned-*: gcc 8's default tuning splits every unaligned 256-bit load and
# store into two 128-bit halves (vinsertf128 / vextractf128). That is only a tuning choice, not
# different math: turning it off keeps AVX2, no FMA, same results, and removes ~50 instructions
# and the register spills from the 32-pixel loop (measured on ece024: 2.49 -> 1.72 cycles/pixel).
set_source_files_properties(src/sobel_kernel.cpp PROPERTIES COMPILE_FLAGS
  "-mavx2 -ffp-contract=off -mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store")
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(canny_scalar PRIVATE -Wall -Wextra -Wpedantic)
  target_compile_options(canny_part2 PRIVATE -Wall -Wextra -Wpedantic)
  target_compile_options(sobel_driver PRIVATE -Wall -Wextra -Wpedantic)
endif()
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  target_compile_options(canny_scalar PRIVATE -fno-vectorize -fno-slp-vectorize)
  target_compile_options(canny_part2 PRIVATE -fno-vectorize -fno-slp-vectorize)
  target_compile_options(sobel_driver PRIVATE -fno-vectorize -fno-slp-vectorize)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(canny_scalar PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
  target_compile_options(canny_part2 PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
  target_compile_options(sobel_driver PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
endif()
# Hysteresis connectivity test, and a bitwise Sobel check against the scalar formula.
include(CTest)
if(BUILD_TESTING)
  add_executable(test_hysteresis src/test_hysteresis.cpp)
  add_test(NAME hysteresis_connectivity COMMAND test_hysteresis)
  add_executable(test_sobel_kernel src/test_sobel_kernel.cpp src/sobel_kernel.cpp)
  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(test_sobel_kernel PRIVATE -Wall -Wextra -Wpedantic)
  endif()
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    target_compile_options(test_sobel_kernel PRIVATE -fno-vectorize -fno-slp-vectorize)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(test_sobel_kernel PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
  endif()
  add_test(NAME sobel_kernel_matches_scalar COMMAND test_sobel_kernel)
endif()
