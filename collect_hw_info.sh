#!/usr/bin/env bash
# Read-only, best effort; missing tools never require root or trigger installation.
set -uo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
OUT_FILE=${1:-hardware_report.txt}
mkdir -p -- "$(dirname -- "$OUT_FILE")"
collect_report() {
section() { printf '\n[%s]\n------------------------------------------------------------\n' "$1"; }
run() { printf '\n$'; printf ' %q' "$@"; printf '\n'; if command -v "$1" >/dev/null 2>&1; then "$@" || printf 'Unavailable or command failed (exit %s)\n' "$?"; else printf 'Not installed: %s\n' "$1"; fi; }
printf 'CANNY HARDWARE / ENVIRONMENT REPORT\nUTC: %s\n' "$(date -u +%FT%TZ)"
section 'OS and toolchain'
run uname -a
[[ ! -r /etc/os-release ]] || cat /etc/os-release
run gcc --version
run g++ --version
run clang --version
run cmake --version
run python3 --version
printf 'CUDA_VISIBLE_DEVICES=%s\nOMP_NUM_THREADS=%s\n' "${CUDA_VISIBLE_DEVICES:-<unset>}" "${OMP_NUM_THREADS:-<unset>}"
section 'CPU topology, caches, SIMD and NUMA'
if command -v lscpu >/dev/null 2>&1; then run lscpu; run lscpu --caches; run numactl --hardware; else run sysctl hw machdep.cpu; fi
if [[ -d /sys/devices/system/cpu/cpu0/cache ]]; then
  for cache in /sys/devices/system/cpu/cpu0/cache/index*; do
    printf '\n%s\n' "$cache"
    for field in level type size coherency_line_size ways_of_associativity shared_cpu_list; do
      [[ ! -r "$cache/$field" ]] || printf '%s: %s\n' "$field" "$(cat "$cache/$field")"
    done
  done
fi
section 'RAM, PCIe, scheduler constraints'
run free -h
run lspci -nn
run lspci -vv -d 10de:
run taskset -pc "$$"
if [[ -r /sys/fs/cgroup/cpu.max ]]; then printf 'cgroup CPU quota: '; cat /sys/fs/cgroup/cpu.max; fi
if [[ -r /sys/fs/cgroup/memory.max ]]; then printf 'cgroup memory limit: '; cat /sys/fs/cgroup/memory.max; fi
section 'GPU state (physical GPU telemetry; may differ from CUDA visibility)'
run nvidia-smi
run nvidia-smi -q
section 'CUDA hardware limits'
if command -v nvcc >/dev/null 2>&1; then
  run nvcc --version
  PROBE_DIR=$(mktemp -d)
  trap 'rm -rf -- "$PROBE_DIR"' EXIT
  if nvcc "$ROOT/src/cuda_probe.cu" -o "$PROBE_DIR/probe"; then run "$PROBE_DIR/probe"; else printf 'Probe compilation failed; diagnostics retained above.\n'; fi
else
  printf 'nvcc unavailable: CUDA limits not probed.\n'
  run clinfo -l
  run rocm-smi
fi
section 'OpenCV configuration'
run pkg-config --modversion opencv4
run "${PYTHON:-python3}" -c 'import cv2; print(cv2.getBuildInformation()); print("OpenCV threads:", cv2.getNumThreads()); print("CUDA devices:", cv2.cuda.getCudaEnabledDeviceCount())'
printf '\nReport: %s\n' "$OUT_FILE"

}
collect_report 2>&1 | tee "$OUT_FILE"
