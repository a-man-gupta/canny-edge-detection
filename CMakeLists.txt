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

add_library(sobel_kernel OBJECT src/kernel_sobel.cpp)
add_library(nms_kernel OBJECT src/kernel_nms.cpp)
foreach(kernel sobel_kernel nms_kernel)
  target_compile_options(${kernel} PRIVATE -O3 -mavx2 -mno-avx512f -mtune=skylake
    -fno-unroll-loops -mno-avx256-split-unaligned-load
    -mno-avx256-split-unaligned-store)
endforeach()
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(sobel_kernel PRIVATE
    -fno-tree-forwprop -fschedule-insns -fsched-pressure)
endif()

add_executable(sobel_driver src/driver_sobel.cpp $<TARGET_OBJECTS:sobel_kernel>)
add_executable(nms_driver src/driver_nms.cpp $<TARGET_OBJECTS:nms_kernel>)
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
