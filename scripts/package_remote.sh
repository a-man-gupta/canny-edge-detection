#!/usr/bin/env bash
# Package current sources without git history, build outputs, environments or datasets.
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
ARCHIVE=${1:-"/tmp/canny-benchmark-kit-$(date -u +%Y%m%dT%H%M%SZ)-$$.tar.gz"}
if [[ -e "$ARCHIVE" ]]; then printf 'Archive already exists: %s\n' "$ARCHIVE" >&2; exit 2; fi
mkdir -p -- "$(dirname -- "$ARCHIVE")"
tar --exclude='__pycache__' --exclude='*.pyc' -czf "$ARCHIVE" \
  CMakeLists.txt requirements-bench.txt collect_hw_info.sh src benchmarks scripts \
  README.md .gitignore
printf 'Remote source kit: %s\n' "$ARCHIVE"
