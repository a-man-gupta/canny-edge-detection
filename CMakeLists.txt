cmake_minimum_required(VERSION 3.18)
project(canny_bench LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# Scalar CPU Canny. The no-vectorize flags below stay as part of this reference build.
add_executable(canny_scalar src/canny_scalar.cpp)
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(canny_scalar PRIVATE -Wall -Wextra -Wpedantic)
endif()
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  target_compile_options(canny_scalar PRIVATE -fno-vectorize -fno-slp-vectorize)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(canny_scalar PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
endif()
# Profiling copy of the scalar pipeline with the blur split into functions.
# Same flags as canny_scalar, plus debug info for perf annotate.
add_executable(canny_scalar_test src/canny_scalar_test.cpp)
target_compile_options(canny_scalar_test PRIVATE -g -fno-omit-frame-pointer)
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  target_compile_options(canny_scalar_test PRIVATE -fno-vectorize -fno-slp-vectorize)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(canny_scalar_test PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
endif()
# AVX2 Gaussian blur kernels vs gaussian_naive. AVX2/FMA are enabled per function
# in gaussian_simd.hpp, so the naive reference keeps the same scalar code as canny_scalar.
add_executable(bench_gaussian src/bench_gaussian.cpp)
# GCC's generic tuning splits unaligned 256-bit loads/stores into two 128-bit halves.
target_compile_options(bench_gaussian PRIVATE -g
  $<$<CXX_COMPILER_ID:GNU>:-mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store>)
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  target_compile_options(bench_gaussian PRIVATE -fno-vectorize -fno-slp-vectorize)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(bench_gaussian PRIVATE -fno-tree-vectorize -fno-tree-slp-vectorize)
endif()
# Hysteresis connectivity test.
include(CTest)
if(BUILD_TESTING)
  add_executable(test_hysteresis src/test_hysteresis.cpp)
  add_test(NAME hysteresis_connectivity COMMAND test_hysteresis)
endif()
