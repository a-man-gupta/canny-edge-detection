#!/bin/bash
# Region-only counts for one thread on ECE024. Run from the repository root.
set -eu
inputs=$1
out=$2
fifo=$(mktemp -d)
trap 'rm -f "$fifo/ctl" "$fifo/ack"; rmdir "$fifo"' EXIT
mkfifo "$fifo/ctl" "$fifo/ack"
export CANNY_PERF_CTL="$fifo/ctl" CANNY_PERF_ACK="$fifo/ack" CANNY_MASK_SEEDS=1
export OMP_PLACES=cores OMP_PROC_BIND=close
for mode in staged row morton; do
  for width in 1920 3840; do
    height=$((width*9/16))
    taskset -c 10 perf stat -D -1 --control "fifo:$fifo/ctl,$fifo/ack" -x, \
      -e cycles:u,instructions:u,L1-dcache-loads:u,L1-dcache-load-misses:u \
      -o "$out/counters-$mode-$width.csv" \
      ./build/canny_tall.x "$width" "$height" 1 320 1 "$inputs/photo-$width.raw" "$mode"
  done
done
