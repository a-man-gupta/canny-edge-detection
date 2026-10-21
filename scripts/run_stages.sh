#!/usr/bin/env bash
# Next numbered Sobel/NMS benchmark. One command; timing stays in benchmarks/run.py.
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
PY=${PYTHON:-"$ROOT/.venv/bin/python"}
if [[ ! -f "$ROOT/benchmark_results/run-001/baseline.json" ]]; then
  printf 'Missing baseline pointer: benchmark_results/run-001/baseline.json\n' >&2
  exit 2
fi

RUN_ID=$("$PY" -c '
from pathlib import Path
root = Path("benchmark_results")
n = 1
while (root / f"run-{n:03d}").exists():
    n += 1
print(f"run-{n:03d}")
')
OUT="$ROOT/benchmark_results/$RUN_ID"
if [[ -e "$OUT" ]]; then
  printf 'Output already exists: %s\n' "$OUT" >&2
  exit 2
fi

mapfile -t LAUNCH < <("$PY" benchmarks/stages/compare.py --launch-lines "$@")
SMOKE=0
PHOTO=""
MODE=head
RUNNER=()
for line in "${LAUNCH[@]}"; do
  if [[ "$line" == "smoke" ]]; then SMOKE=1; continue; fi
  if [[ "$line" == photo=* ]]; then PHOTO=${line#photo=}; continue; fi
  if [[ "$line" == "--" ]]; then MODE=runner; continue; fi
  if [[ "$MODE" == runner ]]; then RUNNER+=("$line"); fi
done

export SKIP_GENERIC_PLOTS=1
export OUT
STATUS=0
if [[ "$SMOKE" -eq 1 && -n "$PHOTO" ]]; then
  ./scripts/run_remote.sh --smoke --photo "$PHOTO" -- "${RUNNER[@]}" || STATUS=$?
elif [[ "$SMOKE" -eq 1 ]]; then
  ./scripts/run_remote.sh --smoke -- "${RUNNER[@]}" || STATUS=$?
elif [[ -n "$PHOTO" ]]; then
  ./scripts/run_remote.sh --photo "$PHOTO" -- "${RUNNER[@]}" || STATUS=$?
else
  ./scripts/run_remote.sh -- "${RUNNER[@]}" || STATUS=$?
fi
"$PY" benchmarks/stages/compare.py --run "$OUT" || STATUS=$?
printf '\nComparison view:\n  %s\n  %s\n  %s\n' \
  "$OUT/comparison/sobel_time.png" \
  "$OUT/comparison/nms_time.png" \
  "$OUT/comparison/results.md"
exit "$STATUS"
