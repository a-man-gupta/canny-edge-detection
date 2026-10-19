#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
OUT=${OUT:-"benchmark_results/bandwidth-$(date -u +%Y%m%dT%H%M%SZ)-$$"}
if [[ -e "$OUT" ]]; then printf 'Output exists: %s\n' "$OUT" >&2; exit 2; fi
mkdir -p "$OUT"
nvcc --version > "$OUT/nvcc.txt"
# Let nvcc choose its supported default target; no architecture assumed.
nvcc -O3 src/cuda_bandwidth.cu -o "$OUT/cuda_bandwidth" 2> "$OUT/build.log"
"$OUT/cuda_bandwidth" "${1:-256}" "${2:-100}" > "$OUT/raw.csv" 2> "$OUT/summary.txt"
cat "$OUT/summary.txt"
printf 'Bandwidth artifacts: %s\n' "$OUT"
