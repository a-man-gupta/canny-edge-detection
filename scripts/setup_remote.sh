#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
VENV=${VENV:-.venv}
if [[ -z "${PYTHON:-}" ]]; then
  PYTHON=""
  for candidate in python3.14 python3.13 python3.12 python3.11 python3.10 python3; do
    if command -v "$candidate" >/dev/null 2>&1; then
      ver=$("$candidate" -c 'import sys; print(sys.version_info[0] * 100 + sys.version_info[1])')
      if [[ "$ver" -ge 310 && "$ver" -lt 315 ]]; then
        PYTHON=$(command -v "$candidate")
        break
      fi
    fi
  done
  if [[ -z "$PYTHON" ]]; then
    printf 'Python 3.10-3.14 is required. Default python3 is too old for numpy 2.2.6.\n' >&2
    exit 1
  fi
fi
printf 'Using %s (%s)\n' "$PYTHON" "$("$PYTHON" --version)"
"$PYTHON" -m venv "$VENV"
"$VENV/bin/python" -m pip install -r requirements-bench.txt
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "$@"
cmake --build build --parallel
"$VENV/bin/python" -m pip freeze > build/python-packages.txt
ctest --test-dir build --output-on-failure
"$VENV/bin/python" -m unittest discover -s benchmarks -p 'test_*.py' -v
printf '\nReady. Run: ./scripts/run_remote.sh --smoke\n'
