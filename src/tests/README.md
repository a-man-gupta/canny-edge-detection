# Tests

These CMake tests exercise connectivity and compare whole-image kernel outputs against scalar expectations. The modern Sobel and NMS correctness checks also run through their standalone drivers. On x86 Linux configure CMake with BUILD_TESTING enabled, build, then run ctest from that build directory.
