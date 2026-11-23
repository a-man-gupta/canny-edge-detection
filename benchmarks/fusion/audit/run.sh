#!/bin/bash
# Run from the repository root on ECE024 with the two raw inputs installed.
set -eu
make -s build/canny_fast.x
export OMP_PROC_BIND=close OMP_PLACES=cores CANNY_MASK_SEEDS=1
for width in 1920 3840; do
  height=1080
  image=canny-fusion-inputs/photo-1920.raw
  if [ "$width" = 3840 ]; then
    height=2160
    image=canny-fusion-inputs/canny-apollo-native4k.raw
  fi
  for threads in 1 2 4 8 16; do
    cpus=0,2,4,6,8,10,12,14
    if [ "$threads" = 16 ]; then cpus=0-15; fi
    echo "$width $threads"
    taskset -c "$cpus" build/canny_fast.x "$width" "$height" "$threads" 320 11 "$image" row
  done
done
