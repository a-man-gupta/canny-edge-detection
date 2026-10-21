#!/usr/bin/env bash
# Run from any directory; forwarding arguments after -- to benchmarks/run.py.
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
PY=${PYTHON:-"$ROOT/.venv/bin/python"}
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
OUT=${OUT:-"$ROOT/benchmark_results/$STAMP-$$"}
DATA="$OUT/dataset"
GEN=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --smoke) GEN+=(--smoke); shift ;;
    --photo) GEN+=(--photo "$2"); shift 2 ;;
    --) shift; break ;;
    *) printf 'Unknown wrapper argument: %s (use -- before runner arguments)\n' "$1" >&2; exit 2 ;;
  esac
done
if [[ -e "$OUT" ]]; then printf 'Output already exists: %s\n' "$OUT" >&2; exit 2; fi
mkdir -p "$OUT"
# Preserve the actual harness sources, including uncommitted additions.
tar --exclude='__pycache__' --exclude='*.pyc' -czf "$OUT/source.tar.gz" \
  CMakeLists.txt requirements-bench.txt collect_hw_info.sh src benchmarks scripts \
  README.md .gitignore
PYTHON="$PY" ./collect_hw_info.sh "$OUT/hardware_before.txt"
"$PY" benchmarks/generate_dataset.py --output "$DATA" "${GEN[@]}"
if [[ -d build ]]; then
  mkdir -p "$OUT/build_provenance"
  for f in CMakeCache.txt compile_commands.json python-packages.txt; do
    [[ ! -f "build/$f" ]] || cp "build/$f" "$OUT/build_provenance/"
  done
fi
# Keep results and telemetry even when one backend fails.
STATUS=0
"$PY" benchmarks/run.py --manifest "$DATA/manifest.json" --output "$OUT/run" "$@" || STATUS=$?
PYTHON="$PY" ./collect_hw_info.sh "$OUT/hardware_after.txt"
# Stages runs set SKIP_GENERIC_PLOTS so comparison/ stays limited to its own two plots.
if [[ -f "$OUT/run/summary.csv" && -z "${SKIP_GENERIC_PLOTS:-}" ]]; then "$PY" benchmarks/plot.py "$OUT/run" || STATUS=$?; fi
printf '\nArtifacts: %s\n' "$OUT"
exit "$STATUS"
