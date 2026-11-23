#!/bin/sh
# Use actual counted core cycles and the repository drivers' arithmetic model.
set -eu
make -s all assemble
for kernel in sobel nms; do
  for width in 64 128 256 384; do
    SIZE=$width taskset -c 10 ./build/$kernel.x 100000 9
  done
done
