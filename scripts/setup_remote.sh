#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
VENV=${VENV:-.venv}
"${PYTHON:-python3}" -m venv "$VENV"
"$VENV/bin/python" -m pip install -r requirements-bench.txt
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "$@"
cmake --build build --parallel
"$VENV/bin/python" -m pip freeze > build/python-packages.txt
ctest --test-dir build --output-on-failure
"$VENV/bin/python" -m unittest discover -s benchmarks -p 'test_*.py' -v
printf '\nReady. Run: ./scripts/run_remote.sh --smoke\n'
