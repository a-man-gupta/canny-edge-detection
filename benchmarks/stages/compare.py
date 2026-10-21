#!/usr/bin/env python3
"""Sobel and NMS comparison against the frozen scalar baseline.

The pointer is benchmark_results/run-001/baseline.json. It names run-003, which
is read in place. Writes two line plots and one table under the numbered run's
comparison/ directory. Does not time anything.

Correctness is the timed edge map versus that baseline edge map. When the timed
implementation is part2, that map is build/canny_part2, and the in-run scalar
executable is the reference for magnitude, direction category, NMS, and edges.
The accuracy.csv row that compares scalar with itself is not the verdict.
"""
import csv
import hashlib
import json
import math
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESULTS = ROOT / "benchmark_results"
BASELINE_DIR = RESULTS / "run-001"
BASELINE_JSON = BASELINE_DIR / "baseline.json"
BASELINE_RUN = "run-003"
PREVIOUS_TIMESTAMP = "20261020T235216Z-2233567"
CHECK_FILES = (
    "run/summary.csv",
    "run/raw.csv",
    "run/accuracy.csv",
    "run/status.json",
    "run/metadata.json",
    "dataset/manifest.json",
    "hardware_before.txt",
    "build_provenance/compile_commands.json",
)
STAGE_COLUMNS = (
    ("blur_ms_median", "Blur (ms)"),
    ("sobel_ms_median", "Sobel (ms)"),
    ("nms_ms_median", "NMS (ms)"),
    ("threshold_ms_median", "Threshold (ms)"),
    ("hysteresis_ms_median", "Hysteresis (ms)"),
)


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def read_csv(path):
    if not path.is_file():
        return []
    with path.open(newline="") as handle:
        return list(csv.DictReader(handle))


def find_timestamp(name):
    candidates = [RESULTS / name, RESULTS / "archive" / name]
    found = [path for path in candidates if (path / "run" / "summary.csv").is_file()]
    if not found:
        raise FileNotFoundError(f"Cannot find timestamp run {name}")
    return found[0]


def load_pointer():
    pointer = json.loads(BASELINE_JSON.read_text())
    source = find_timestamp(pointer["timestamp"])
    checksums = {}
    for rel in CHECK_FILES:
        path = source / rel
        if not path.is_file():
            raise FileNotFoundError(f"Baseline file missing: {path}")
        checksums[rel] = sha256(path)
        expected = pointer["checksums"].get(rel)
        if expected != checksums[rel]:
            raise RuntimeError(f"Baseline checksum changed for {rel}")
    return pointer, source


def command_after(lines, prompt):
    for index, line in enumerate(lines):
        if line.strip() == prompt and index + 1 < len(lines):
            return lines[index + 1].strip()
    return None


def command_flags(command):
    kept = []
    skip = 0
    for token in command.split():
        if skip:
            skip -= 1
            continue
        if token in ("-o", "-c"):
            skip = 1
            continue
        kept.append(token)
    return " ".join(kept)


def flags_for(compile_commands, source_name, output_substr=None):
    matches = []
    for row in compile_commands:
        if Path(row.get("file", "")).name != source_name:
            continue
        if output_substr and output_substr not in row.get("output", ""):
            continue
        matches.append(row)
    if not matches and output_substr:
        return flags_for(compile_commands, source_name, None)
    if not matches:
        return None
    return command_flags(matches[0]["command"])


def compiler_flags(compile_commands):
    """Scalar reference flags. Part 2's AVX2 flags are recorded separately."""
    return flags_for(compile_commands, "canny_scalar.cpp")


def extract_settings(run_dir):
    """Settings that must agree before a speedup is a matched comparison."""
    metadata_path = run_dir / "run" / "metadata.json"
    hardware_path = run_dir / "hardware_before.txt"
    compile_path = run_dir / "build_provenance" / "compile_commands.json"
    manifest_path = run_dir / "dataset" / "manifest.json"
    metadata = json.loads(metadata_path.read_text()) if metadata_path.is_file() else {}
    parameters = metadata.get("parameters") or {}
    manifest = json.loads(manifest_path.read_text()) if manifest_path.is_file() else metadata.get("manifest") or {}
    hardware = hardware_path.read_text(errors="replace").splitlines() if hardware_path.is_file() else []
    uname = command_after(hardware, "$ uname -a")
    hostname = uname.split()[1] if uname and uname.startswith("Linux ") and len(uname.split()) > 1 else None
    model = None
    for line in hardware:
        if line.startswith("Model name:"):
            model = line.split(":", 1)[1].strip()
            break
    compiler_version = command_after(hardware, "$ g++ --version")
    flags = None
    part2_kernel_flags = None
    part2_driver_flags = None
    if compile_path.is_file():
        commands = json.loads(compile_path.read_text())
        flags = compiler_flags(commands)
        part2_kernel_flags = flags_for(commands, "sobel_kernel.cpp", "canny_part2")
        part2_driver_flags = flags_for(commands, "canny_part2.cpp")
    cases = []
    for case in manifest.get("cases") or []:
        cases.append({
            "name": case.get("name"),
            "axis": case.get("axis"),
            "kind": case.get("kind"),
            "width": case.get("width"),
            "height": case.get("height"),
            "sha256": case.get("sha256"),
        })
    photo = manifest.get("photo")
    photo_path = photo.get("path") if isinstance(photo, dict) else None
    return {
        "photo": photo_path,
        "seed": manifest.get("seed"),
        "warmup": parameters.get("warmup"),
        "iterations": parameters.get("iterations"),
        "low": parameters.get("low"),
        "high": parameters.get("high"),
        "sigma": parameters.get("sigma"),
        "cases": cases,
        "hostname": hostname,
        "model_name": model,
        "compiler_version": compiler_version,
        "compiler_flags": flags,
        "part2_kernel_flags": part2_kernel_flags,
        "part2_driver_flags": part2_driver_flags,
        "platform": metadata.get("platform"),
    }


def case_key(case):
    return (case["name"], case["axis"], case["kind"], case["width"], case["height"], case["sha256"])


def size_text(cases):
    resolution = [case for case in cases if case.get("axis") == "resolution"]
    resolution.sort(key=lambda case: int(case["width"]) * int(case["height"]))
    if not resolution:
        return "none"
    return ", ".join(f'{case["width"]}x{case["height"]}' for case in resolution)


def mismatch_reasons(baseline, current):
    reasons = []
    baseline_cases = sorted(case_key(case) for case in baseline["cases"])
    current_cases = sorted(case_key(case) for case in current["cases"])
    if baseline_cases != current_cases:
        baseline_sizes = size_text(baseline["cases"])
        current_sizes = size_text(current["cases"])
        if baseline_sizes != current_sizes:
            reasons.append(f"image sizes differ (baseline {baseline_sizes}; this run {current_sizes})")
        else:
            reasons.append("image cases differ (same dimensions, different pixels or case list)")
    if baseline["warmup"] != current["warmup"]:
        reasons.append(f'warmup differs (baseline {baseline["warmup"]}, this run {current["warmup"]})')
    if baseline["iterations"] != current["iterations"]:
        reasons.append(f'iterations differ (baseline {baseline["iterations"]}, this run {current["iterations"]})')
    if baseline["compiler_version"] != current["compiler_version"] or baseline["compiler_flags"] != current["compiler_flags"]:
        reasons.append("scalar reference compiler settings differ")
    if baseline["hostname"] != current["hostname"] or baseline["model_name"] != current["model_name"]:
        reasons.append(f'machine differs (baseline {baseline["hostname"]} {baseline["model_name"]}; this run {current["hostname"]} {current["model_name"]})')
    if (baseline["low"], baseline["high"], baseline["sigma"]) != (current["low"], current["high"], current["sigma"]):
        reasons.append("thresholds or sigma differ")
    return reasons


def impl_status(run_dir, implementation):
    path = run_dir / "run" / "status.json"
    if not path.is_file():
        return {}
    statuses = json.loads(path.read_text())
    found = {}
    for row in statuses:
        if row.get("implementation") == implementation:
            found[row.get("case")] = row.get("status")
    return found


def scalar_status(run_dir):
    return impl_status(run_dir, "scalar")


def implementations_of(run_dir):
    metadata_path = run_dir / "run" / "metadata.json"
    if not metadata_path.is_file():
        return []
    try:
        parameters = json.loads(metadata_path.read_text()).get("parameters") or {}
    except (OSError, json.JSONDecodeError, AttributeError):
        return []
    implementations = parameters.get("implementations") or []
    return implementations if isinstance(implementations, list) else []


def timed_implementation(run_dir):
    """Part 2 is the timed kernel when that executable was in the run."""
    if "part2" in implementations_of(run_dir):
        return "part2"
    return "scalar"


def impl_index(run_dir, implementation):
    implementations = implementations_of(run_dir)
    if implementation in implementations:
        return implementations.index(implementation)
    return 0


def edge_path(run_dir, case_name, implementation):
    """PGM for one implementation. Not the accuracy.csv self comparison."""
    return run_dir / "run" / "edges" / f"{case_name}_{impl_index(run_dir, implementation)}.pgm"


def scalar_edge_path(run_dir, case_name):
    return edge_path(run_dir, case_name, timed_implementation(run_dir))


def edges_exact(baseline_path, current_path):
    """True only when both files are the same 0/255 edge map."""
    import cv2
    import numpy as np
    bench = str(ROOT / "benchmarks")
    if bench not in sys.path:
        sys.path.insert(0, bench)
    from run import metrics
    if not baseline_path.is_file() or not current_path.is_file():
        return False
    baseline = cv2.imread(str(baseline_path), cv2.IMREAD_GRAYSCALE)
    current = cv2.imread(str(current_path), cv2.IMREAD_GRAYSCALE)
    if baseline is None or current is None:
        return False
    if baseline.shape != current.shape or baseline.dtype != current.dtype:
        return False
    if not np.isin(baseline, [0, 255]).all() or not np.isin(current, [0, 255]).all():
        return False
    if not np.array_equal(baseline, current):
        return False
    stats = metrics(current, baseline)
    try:
        return math.isclose(float(stats["f1"]), 1.0, abs_tol=1e-9) and math.isclose(float(stats["agreement_pct"]), 100.0, abs_tol=1e-6)
    except (KeyError, TypeError, ValueError):
        return False


def baseline_edge_match(source, run_dir, case_names, timed):
    found = {}
    for name in case_names:
        found[name] = edges_exact(edge_path(source, name, "scalar"), edge_path(run_dir, name, timed))
    return found


def resolution_rows(summary, implementation="scalar"):
    rows = [row for row in summary if row.get("implementation") == implementation and row.get("axis") == "resolution"]
    rows.sort(key=lambda row: int(row["width"]) * int(row["height"]))
    return rows


def nms_category(angle):
    import numpy as np
    d = np.asarray(angle, dtype=np.float32)
    cat = np.full(d.shape, 3, np.uint8)
    cat[d < np.float32(112.5)] = 2
    cat[d < np.float32(67.5)] = 1
    cat[(d < np.float32(22.5)) | (d >= np.float32(157.5))] = 0
    return cat


def read_stages_dump(path):
    import numpy as np
    blob = path.read_bytes()
    if len(blob) < 12:
        return None
    magic, w, h = struct.unpack_from("<4sii", blob, 0)
    if magic != b"C2D1" or w < 1 or h < 1:
        return None
    n = w * h
    if len(blob) != 12 + 3 * n * 4:
        return None
    floats = np.frombuffer(blob, dtype="<f4", offset=12, count=3 * n)
    return floats[:n].copy(), floats[n:2 * n].copy(), floats[2 * n:].copy()


def magnitude_verdict(reference, got):
    """Bitwise, or within 1 float32 ulp.

    vsqrtps and sqrtf are both correctly rounded, so equal gx/gy match exactly.
    One ulp covers a last-bit difference in gx*gx + gy*gy and nothing wider.
    """
    import numpy as np
    if reference.shape != got.shape:
        return False, "shape"
    if np.array_equal(reference, got):
        return True, "bitwise"
    if not np.isfinite(reference).all() or not np.isfinite(got).all():
        return False, "non-finite"
    delta = np.abs(reference.astype(np.float64) - got.astype(np.float64))
    spacing = np.spacing(reference).astype(np.float64)
    if np.all(delta <= spacing):
        return True, "within 1 ulp"
    return False, "exceeds 1 ulp"


def in_run_part2(run_dir):
    """Part 2 versus the scalar executable on the same images.

    Returns (ok, summary, per_case). ok is None when this run did not time part2.
    """
    if "part2" not in implementations_of(run_dir):
        return None, "", {}
    part2_status = impl_status(run_dir, "part2")
    scalar_rows = impl_status(run_dir, "scalar")
    per_case = {}
    problems = []
    mag_kind = None
    for name, status in part2_status.items():
        if status != "ok" or scalar_rows.get(name) != "ok":
            per_case[name] = False
            problems.append(f"{name}: executable status is not ok")
            continue
        scalar_dump = read_stages_dump(run_dir / "run" / "stages" / f"{name}_{impl_index(run_dir, 'scalar')}.bin")
        part2_dump = read_stages_dump(run_dir / "run" / "stages" / f"{name}_{impl_index(run_dir, 'part2')}.bin")
        if scalar_dump is None or part2_dump is None:
            per_case[name] = False
            problems.append(f"{name}: missing magnitude/NMS dump")
            continue
        if scalar_dump[0].shape != part2_dump[0].shape:
            per_case[name] = False
            problems.append(f"{name}: dump shape differs")
            continue
        mag_ok, kind = magnitude_verdict(scalar_dump[0], part2_dump[0])
        categories_ok = bool((nms_category(scalar_dump[1]) == nms_category(part2_dump[1])).all())
        nms_ok = scalar_dump[2].tobytes() == part2_dump[2].tobytes()
        edges_ok = edges_exact(edge_path(run_dir, name, "scalar"), edge_path(run_dir, name, "part2"))
        per_case[name] = mag_ok and categories_ok and nms_ok and edges_ok
        if mag_ok:
            mag_kind = kind if mag_kind in (None, kind) else "mixed"
        if not per_case[name]:
            detail = []
            if not mag_ok:
                detail.append(f"magnitude {kind}")
            if not categories_ok:
                detail.append("direction category")
            if not nms_ok:
                detail.append("NMS")
            if not edges_ok:
                detail.append("edge map")
            problems.append(f"{name}: {', '.join(detail)}")
    if mag_kind is None:
        mag_text = "magnitude was not compared"
    else:
        mag_text = f"magnitude {mag_kind}"
    if problems:
        summary = "In-run Part 2 vs scalar reference failed. " + "; ".join(problems[:6])
        if len(problems) > 6:
            summary += f"; and {len(problems) - 6} more"
        return False, summary, per_case
    summary = (
        f"In-run Part 2 vs the scalar executable: {mag_text}, direction categories exact, "
        "NMS exact, final edge map exact. The scalar-versus-scalar accuracy.csv row is not this check."
    )
    return True, summary, per_case


def show(value):
    if isinstance(value, float) and math.isfinite(value) and value.is_integer():
        return str(int(value))
    return str(value)


def fmt_ms(value):
    if value is None or value == "":
        return ""
    return f"{float(value):.3f}"


def speedup_value(baseline_row, current_row, field):
    if baseline_row is None or current_row is None:
        return None
    try:
        base = float(baseline_row[field])
        new = float(current_row[field])
    except (KeyError, TypeError, ValueError):
        return None
    if not math.isfinite(base) or not math.isfinite(new) or new <= 0:
        return None
    return base / new


def build_rows(baseline_rows, current_rows, statuses, reference_ok, settings_match):
    baseline_by_name = {row["case"]: row for row in baseline_rows}
    table = []
    any_failed = False
    for row in current_rows:
        name = row["case"]
        status = statuses.get(name)
        agreed = reference_ok.get(name, False)
        comparable = status == "ok" and agreed
        if settings_match and not comparable:
            any_failed = True
        base = baseline_by_name.get(name)
        sobel = speedup_value(base, row, "sobel_ms_median")
        nms = speedup_value(base, row, "nms_ms_median")
        if not settings_match:
            sobel_cell, nms_cell = "not matched", "not matched"
            edge_cell = "not compared to baseline edge map"
        elif not comparable or sobel is None or nms is None:
            sobel_cell, nms_cell = "failed", "failed"
            edge_cell = "failed"
        else:
            sobel_cell, nms_cell = f"{sobel:.2f}×", f"{nms:.2f}×"
            edge_cell = "exact"
        pixels = int(row["width"]) * int(row["height"])
        table.append({
            "case": name,
            "width": int(row["width"]),
            "height": int(row["height"]),
            "pixels": pixels,
            "megapixels": pixels / 1e6,
            "label": f'{row["width"]}x{row["height"]} ({pixels / 1e6:.3f} MP)',
            "blur": fmt_ms(row.get("blur_ms_median")),
            "sobel": fmt_ms(row.get("sobel_ms_median")),
            "nms": fmt_ms(row.get("nms_ms_median")),
            "threshold": fmt_ms(row.get("threshold_ms_median")),
            "hysteresis": fmt_ms(row.get("hysteresis_ms_median")),
            "total": fmt_ms(row.get("compute_ms_median")),
            "sobel_cell": sobel_cell,
            "nms_cell": nms_cell,
            "edge_cell": edge_cell,
            "sobel_ms": float(row["sobel_ms_median"]) if row.get("sobel_ms_median") else None,
            "nms_ms": float(row["nms_ms_median"]) if row.get("nms_ms_median") else None,
        })
    return table, any_failed


def write_table(path, run_name, baseline_name, baseline_settings, current_settings, reasons, table, any_failed, settings_match, timed="scalar", stage_summary=""):
    timed_name = "part2" if timed == "part2" else "scalar"
    if not settings_match:
        verdict = "not a matched speedup"
        headline = "This is not a successful speedup against the full-size baseline."
        correctness = "Correctness: not compared to baseline edge map"
    elif any_failed or not table:
        verdict = "not a successful speedup"
        if timed_name == "part2":
            headline = f"This is not a successful speedup. Part 2 failed, its edge map does not match the {baseline_name} baseline, or it does not match the scalar reference."
            correctness = "Correctness: failed. Sobel and NMS speedup are withheld."
        else:
            headline = f"This is not a successful speedup. A scalar case failed, or its edge map does not match the {baseline_name} baseline edge map."
            correctness = f"Correctness: failed against the {baseline_name} edge map. Sobel and NMS speedup are withheld where the timed scalar map is not an exact 0/255 match."
    else:
        verdict = "matched comparison"
        if timed_name == "part2":
            headline = f"Matched comparison against {baseline_name}. Speedup is the baseline median divided by the part2 median."
            correctness = f"Correctness: each part2 edge map matches the {baseline_name} edge map for the same case (exact 0/255)."
        else:
            headline = f"Matched comparison against {baseline_name}. Speedup is the baseline median divided by this run's median."
            correctness = f"Correctness: each timed scalar edge map matches the {baseline_name} edge map for the same case (exact 0/255)."
    if stage_summary:
        correctness = correctness + " " + stage_summary
    photo = lambda settings: settings["photo"] or "none (procedural images)"
    lines = [
        "# Sobel and NMS",
        "",
        f"Verdict: `{verdict}`",
        "",
        headline,
        "",
        correctness,
        "",
    ]
    if any_failed:
        if timed_name == "part2":
            lines.append(f"Part 2 failed, or its edge map does not match the {baseline_name} baseline or the in-run scalar reference.")
        else:
            lines.append(f"One or more scalar cases failed, or the edge map does not match the {baseline_name} baseline edge map.")
        lines.append("")
    if reasons:
        lines.append(f"This run does not match {baseline_name} on the comparison settings:")
        lines.extend(f"- {reason}" for reason in reasons)
        lines.append("")
    timed_subject = "part2 edge map" if timed_name == "part2" else "timed scalar edge map"
    lines.extend([
        f"Speedup cells stay blank of ratios unless the image cases, warmup, iteration count, scalar reference compiler, machine, and thresholds match, and that size's {timed_subject} is an exact 0/255 match to the baseline edge map. A different image size is not compared to the baseline edge map.",
        "",
        f"| Setting | {baseline_name} | this run |",
        "| --- | --- | --- |",
        f'| Run | {baseline_name} | {run_name} |',
        f'| Photo | {photo(baseline_settings)} | {photo(current_settings)} |',
        f'| Resolution sizes | {size_text(baseline_settings["cases"])} | {size_text(current_settings["cases"])} |',
        f'| Warmup | {show(baseline_settings["warmup"])} | {show(current_settings["warmup"])} |',
        f'| Iterations | {show(baseline_settings["iterations"])} | {show(current_settings["iterations"])} |',
        f'| Thresholds | low {show(baseline_settings["low"])}, high {show(baseline_settings["high"])}, sigma {show(baseline_settings["sigma"])} | low {show(current_settings["low"])}, high {show(current_settings["high"])}, sigma {show(current_settings["sigma"])} |',
        f'| Compiler | {baseline_settings["compiler_version"]} | {current_settings["compiler_version"]} |',
        f'| Flags | `{baseline_settings["compiler_flags"]}` | `{current_settings["compiler_flags"]}` |',
    ])
    if timed_name == "part2":
        lines.extend([
            f'| Part 2 driver flags | not in the baseline | `{current_settings.get("part2_driver_flags")}` |',
            f'| Part 2 kernel flags | not in the baseline | `{current_settings.get("part2_kernel_flags")}` |',
            "| AVX2 note | | Intentional difference on sobel_kernel.cpp only: `-mavx2 -ffp-contract=off`. FMA is not contracted into the Sobel math. The scalar reference flags are the row above. This is not a machine mismatch. |",
        ])
    timing_line = "Median milliseconds for the scalar implementation. Total is `compute_ms_median`."
    if timed_name == "part2":
        timing_line = "Median milliseconds for the part2 implementation. Total is `compute_ms_median`. The scalar executable is the correctness reference and is not this timing row."
    lines.extend([
        f'| Machine | {baseline_settings["hostname"]}, {baseline_settings["model_name"]} | {current_settings["hostname"]}, {current_settings["model_name"]} |',
        "",
        timing_line,
        "",
        "| Image | Blur (ms) | Sobel (ms) | NMS (ms) | Threshold (ms) | Hysteresis (ms) | Total (ms) | Sobel vs baseline | NMS vs baseline | Edge map vs baseline |",
        "| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |",
    ])
    if not table:
        withheld = "not matched" if not settings_match else "failed"
        edge = "not compared to baseline edge map" if not settings_match else "failed"
        lines.append(f"|  |  |  |  |  |  |  | {withheld} | {withheld} | {edge} |")
    for row in table:
        lines.append(
            f'| {row["label"]} | {row["blur"]} | {row["sobel"]} | {row["nms"]} | {row["threshold"]} | {row["hysteresis"]} | {row["total"]} | {row["sobel_cell"]} | {row["nms_cell"]} | {row["edge_cell"]} |'
        )
    lines.extend([
        "",
        "Raw samples, hardware, and the in-run accuracy table stay in this run directory (`run/raw.csv`, `run/summary.csv`, `run/accuracy.csv`, `run/status.json`, `hardware_before.txt`). The stage verdict compares the timed edge map `run/edges/<case>_<implementation index>.pgm` with the baseline scalar map. When Part 2 is timed, that file is the optimized executable, and `run/stages/` holds the magnitude, angle, and NMS dumps compared with the scalar executable on the same images. `accuracy.csv` still records the in-run OpenCV reference; its scalar-versus-scalar row compares the reference with itself and is not this verdict. The stage view is this table plus `sobel_time.png` and `nms_time.png`.",
        "",
    ])
    path.write_text("\n".join(lines))
    return verdict


def write_plots(directory, run_name, baseline_name, baseline_rows, table, settings_match):
    import os
    import tempfile
    cache = tempfile.TemporaryDirectory(prefix="canny-matplotlib-")
    os.environ.setdefault("MPLCONFIGDIR", cache.name)
    os.environ.setdefault("XDG_CACHE_HOME", cache.name)
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    try:
        _write_plot_figures(directory, run_name, baseline_name, baseline_rows, table, settings_match, plt)
    finally:
        cache.cleanup()


def _write_plot_figures(directory, run_name, baseline_name, baseline_rows, table, settings_match, plt):

    baseline_points = []
    for row in baseline_rows:
        pixels = int(row["width"]) * int(row["height"])
        baseline_points.append({
            "megapixels": pixels / 1e6,
            "tick": f'{pixels / 1e6:.3f} MP\n{row["width"]}×{row["height"]}',
            "sobel_ms": float(row["sobel_ms_median"]),
            "nms_ms": float(row["nms_ms_median"]),
        })
    for stage, field, filename in (
        ("Sobel", "sobel_ms", "sobel_time.png"),
        ("NMS", "nms_ms", "nms_time.png"),
    ):
        fig, (ax, side) = plt.subplots(
            1, 2, figsize=(10.2, 4.8), gridspec_kw={"width_ratios": [4.3, 1.6]}, constrained_layout=True,
        )
        if baseline_points:
            ax.plot(
                [point["megapixels"] for point in baseline_points],
                [point[field] for point in baseline_points],
                "o--", color="#4c566a", label=f"{baseline_name} baseline",
            )
        current = [row for row in table if row[field] is not None]
        if current:
            ax.plot(
                [row["megapixels"] for row in current],
                [row[field] for row in current],
                "s-", color="#1f4e79", label=run_name,
            )
        ticks = {}
        for point in baseline_points:
            ticks[round(point["megapixels"], 6)] = point["tick"]
        for row in current:
            ticks[round(row["megapixels"], 6)] = f'{row["megapixels"]:.3f} MP\n{row["width"]}×{row["height"]}'
        ordered = sorted(ticks)
        positive = [point[field] for point in baseline_points] + [row[field] for row in current]
        if ordered and max(ordered) / min(ordered) > 5:
            ax.set_xscale("log")
        if len(positive) >= 2 and min(positive) > 0 and max(positive) / min(positive) > 8:
            ax.set_yscale("log")
        if ordered:
            ax.set_xticks(ordered, [ticks[value] for value in ordered])
            ax.tick_params(axis="x", labelsize=7)
            ax.minorticks_off()
        ax.set_xlabel("Image size (megapixels)")
        ax.set_ylabel("Median time (ms)")
        ax.set_title(f"{stage} time versus image size")
        ax.grid(alpha=0.3)
        if ax.lines:
            ax.legend()
        side.axis("off")
        column = ["baseline / this run", ""]
        if not settings_match:
            column.append("not matched")
            note = "Not a matched comparison. Speedup is not shown."
        else:
            cell = "sobel_cell" if stage == "Sobel" else "nms_cell"
            for row in table:
                column.append(f'{row["width"]}x{row["height"]}  {row[cell]}')
            note = f"Speedup = {baseline_name} median / this run median."
        side.set_title("Speedup")
        side.text(0.0, 1.0, "\n".join(column), va="top", ha="left", family="monospace", fontsize=8, transform=side.transAxes)
        fig.suptitle(note, fontsize=10)
        fig.savefig(directory / filename, dpi=140)
        plt.close(fig)


CLOCK_COLUMNS = (
    "sobel_rdtsc_cycles_median",
    "sobel_turbo_cycles_median",
    "sobel_cycles_per_pixel_median",
    "sobel_flops_per_cycle_median",
    "sobel_threshold_cycles_per_pixel_median",
    "sobel_threshold_flops_per_cycle_median",
)


def write_clock_threshold(directory, rows):
    """Cycles per pixel from the lab RDTSC formula, with the peak drawn.

    Rows come from summary.csv. Scalar runs omit the columns, and then this
    writes nothing. The millisecond plots are unchanged.
    """
    usable = [row for row in rows if row.get("sobel_cycles_per_pixel_median")]
    if not usable:
        return None
    directory.mkdir(exist_ok=True)
    csv_path = directory / "sobel_cycles.csv"
    with csv_path.open("w", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            ["case", "width", "height", "pixels", *CLOCK_COLUMNS],
        )
        writer.writeheader()
        for row in usable:
            pixels = int(row["width"]) * int(row["height"])
            writer.writerow({
                "case": row.get("case", ""),
                "width": row["width"],
                "height": row["height"],
                "pixels": pixels,
                **{column: row.get(column, "") for column in CLOCK_COLUMNS},
            })
    import os
    import tempfile
    cache = tempfile.TemporaryDirectory(prefix="canny-matplotlib-")
    os.environ.setdefault("MPLCONFIGDIR", cache.name)
    os.environ.setdefault("XDG_CACHE_HOME", cache.name)
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    try:
        points = []
        for row in usable:
            pixels = int(row["width"]) * int(row["height"])
            points.append({
                "megapixels": pixels / 1e6,
                "tick": f'{pixels / 1e6:.3f} MP\n{row["width"]}×{row["height"]}',
                "cycles": float(row["sobel_cycles_per_pixel_median"]),
                "threshold": float(row["sobel_threshold_cycles_per_pixel_median"]),
            })
        threshold = points[0]["threshold"]
        fig, ax = plt.subplots(figsize=(8.4, 4.8), constrained_layout=True)
        ax.plot(
            [point["megapixels"] for point in points],
            [point["cycles"] for point in points],
            "s-", color="#1f4e79", label="Sobel cycles/pixel",
        )
        ax.axhline(
            threshold,
            color="#c0392b",
            linestyle="--",
            linewidth=1.5,
            label=f"threshold {threshold:.4f} cycles/pixel",
        )
        ordered = sorted({round(point["megapixels"], 6) for point in points})
        ticks = {round(point["megapixels"], 6): point["tick"] for point in points}
        if len(ordered) >= 2 and max(ordered) / min(ordered) > 5:
            ax.set_xscale("log")
        if ordered:
            ax.set_xticks(ordered, [ticks[value] for value in ordered])
            ax.tick_params(axis="x", labelsize=7)
            ax.minorticks_off()
        measured = [point["cycles"] for point in points]
        top = max(max(measured), threshold) * 1.15
        ax.set_ylim(0, top)
        ax.set_xlabel("Image size (megapixels)")
        ax.set_ylabel("Cycles per pixel")
        ax.set_title("Sobel RDTSC cycles per pixel")
        ax.grid(alpha=0.3)
        ax.legend(loc="best")
        fig.suptitle(
            "cycles/pixel = rdtsc * 3.4/2.4 / pixels; threshold = 23 flop/pixel / 16 flop/cycle",
            fontsize=9,
        )
        plot_path = directory / "sobel_threshold.png"
        fig.savefig(plot_path, dpi=140)
        plt.close(fig)
    finally:
        cache.cleanup()
    return directory / "sobel_threshold.png"


def part2_flag_reasons(current):
    """AVX2 on sobel_kernel.cpp is intentional. A missing or different kernel build is not."""
    reasons = []
    kernel = current.get("part2_kernel_flags") or ""
    tokens = kernel.split()
    if not kernel:
        reasons.append("Part 2 kernel flags were not recorded")
    elif "-mavx2" not in tokens or "-ffp-contract=off" not in tokens:
        reasons.append("Part 2 kernel flags are not the intentional -mavx2 -ffp-contract=off build")
    if "-ffast-math" in tokens or "-mfma" in tokens:
        reasons.append("Part 2 kernel was built with fast-math or FMA")
    driver = (current.get("part2_driver_flags") or "").split()
    if not current.get("part2_driver_flags"):
        reasons.append("Part 2 driver flags were not recorded")
    elif "-mavx2" in driver or "-ffast-math" in driver or "-mfma" in driver:
        reasons.append("Part 2 driver flags include AVX2, FMA, or fast-math; those stay off canny_part2.cpp")
    return reasons


def compare(run_dir):
    run_dir = run_dir.resolve()
    pointer, source = load_pointer()
    if run_dir == source.resolve() or run_dir == BASELINE_DIR.resolve():
        raise SystemExit("Refusing to write a comparison into the baseline")
    baseline_settings = extract_settings(source)
    current_settings = extract_settings(run_dir)
    timed = timed_implementation(run_dir)
    reasons = mismatch_reasons(baseline_settings, current_settings)
    if timed == "part2":
        reasons.extend(part2_flag_reasons(current_settings))
    settings_match = not reasons
    statuses = impl_status(run_dir, timed)
    stage_ok, stage_summary, stage_cases = in_run_part2(run_dir)
    if settings_match:
        reference_ok = baseline_edge_match(source, run_dir, list(statuses), timed)
        if stage_ok is False:
            for name in list(reference_ok):
                if not stage_cases.get(name, False):
                    reference_ok[name] = False
    else:
        reference_ok = {}
    table, any_failed = build_rows(
        resolution_rows(read_csv(source / "run" / "summary.csv"), "scalar"),
        resolution_rows(read_csv(run_dir / "run" / "summary.csv"), timed),
        statuses,
        reference_ok,
        settings_match,
    )
    if settings_match:
        for name, status in statuses.items():
            if status != "ok" or not reference_ok.get(name, False):
                any_failed = True
        if stage_ok is False:
            any_failed = True
    comparison = run_dir / "comparison"
    comparison.mkdir(exist_ok=True)
    baseline_name = source.name
    verdict = write_table(
        comparison / "results.md", run_dir.name, baseline_name, baseline_settings, current_settings, reasons, table, any_failed, settings_match, timed, stage_summary,
    )
    write_plots(comparison, run_dir.name, baseline_name, resolution_rows(read_csv(source / "run" / "summary.csv"), "scalar"), table, settings_match)
    current_resolution = resolution_rows(read_csv(run_dir / "run" / "summary.csv"), timed)
    clock_plot = write_clock_threshold(comparison, current_resolution)
    print(f"Verdict: {verdict}")
    print(f"Table: {comparison / 'results.md'}")
    print(f"Sobel plot: {comparison / 'sobel_time.png'}")
    print(f"NMS plot: {comparison / 'nms_time.png'}")
    if clock_plot is not None:
        print(f"Sobel threshold plot: {clock_plot}")
    print(f"Baseline source: {source}")
    print(f"Baseline pointer checksums verified against {pointer['timestamp']}")
    return 0


def init_baseline():
    if BASELINE_JSON.exists():
        raise SystemExit(f"Refusing to overwrite {BASELINE_JSON}")
    source = find_timestamp(BASELINE_RUN)
    checksums = {rel: sha256(source / rel) for rel in CHECK_FILES}
    settings = extract_settings(source)
    resolution = [case for case in settings["cases"] if case["axis"] == "resolution"]
    if not resolution or not any(int(case["width"]) == 7680 and int(case["height"]) == 4320 for case in resolution):
        raise SystemExit("Selected baseline does not include 7680x4320")
    statuses = scalar_status(source)
    if any(statuses.get(case["name"]) != "ok" for case in resolution):
        raise SystemExit("Selected baseline scalar status is not ok for every resolution case")
    BASELINE_DIR.mkdir(parents=True, exist_ok=False)
    pointer = {
        "run_id": BASELINE_RUN,
        "timestamp": BASELINE_RUN,
        "source_dir_at_freeze": str(source.relative_to(ROOT)),
        "previous_baseline": {
            "timestamp": PREVIOUS_TIMESTAMP,
            "source_dir_at_freeze": f"benchmark_results/archive/{PREVIOUS_TIMESTAMP}",
            "note": "Previous default. The archive directory is unchanged and is no longer the default baseline.",
        },
        "checksums": checksums,
        "note": "Pointer only. Read run-003 in place. Do not edit that directory.",
    }
    BASELINE_JSON.write_text(json.dumps(pointer, indent=2) + "\n")
    (BASELINE_DIR / "README.md").write_text(
        "run-001 is a pointer. The default baseline is run-003.\n\n"
        f"Source: {source.relative_to(ROOT)}\n"
        "Checksums and the source path are in baseline.json. The timing files stay in that directory and are read in place.\n\n"
        f"The previous baseline was benchmark_results/archive/{PREVIOUS_TIMESTAMP}. That archive is unchanged and is no longer the default.\n"
    )
    print(f"Wrote {BASELINE_JSON}")
    print(f"Source: {source}")
    return 0


def recipe_args(settings):
    return [
        "--implementations", "scalar",
        "--warmup", str(settings["warmup"]),
        "--iterations", str(settings["iterations"]),
        "--low", str(settings["low"]),
        "--high", str(settings["high"]),
        "--sigma", str(settings["sigma"]),
    ]


def merge_args(recipe, forwarded):
    user_flags = {arg for arg in forwarded if arg.startswith("--")}
    merged = []
    index = 0
    while index < len(recipe):
        flag = recipe[index]
        if flag in user_flags:
            index += 1
            while index < len(recipe) and not str(recipe[index]).startswith("--"):
                index += 1
            continue
        merged.append(flag)
        index += 1
        while index < len(recipe) and not str(recipe[index]).startswith("--"):
            merged.append(recipe[index])
            index += 1
    merged.extend(forwarded)
    return merged


def launch_lines(argv):
    smoke = False
    photo = None
    photo_set = False
    kernel = "scalar"
    forwarded = []
    index = 0
    while index < len(argv):
        arg = argv[index]
        if arg == "--smoke":
            smoke = True
            index += 1
        elif arg == "--photo":
            if index + 1 >= len(argv):
                raise SystemExit("--photo needs a path")
            photo = argv[index + 1]
            photo_set = True
            index += 2
        elif arg == "--kernel":
            if index + 1 >= len(argv):
                raise SystemExit("--kernel needs scalar or part2")
            kernel = argv[index + 1]
            if kernel not in ("scalar", "part2"):
                raise SystemExit("--kernel must be scalar or part2")
            index += 2
        elif arg == "--":
            forwarded = argv[index + 1:]
            break
        else:
            raise SystemExit(f"Unknown wrapper argument: {arg} (use -- before runner arguments)")
    _pointer, source = load_pointer()
    settings = extract_settings(source)
    if not photo_set:
        photo = settings["photo"]
    if smoke:
        print("smoke")
    print(f"photo={photo or ''}")
    print("--")
    recipe = recipe_args(settings)
    if kernel == "part2":
        # Time canny_part2 and run canny_scalar on the same images. Do not rename
        # part2 to scalar: that made accuracy.csv compare the optimized map with itself.
        recipe = [
            "--implementations", "scalar", "part2",
            "--part2-bin", str(ROOT / "build" / "canny_part2"),
            "--stages-dump",
            "--warmup", str(settings["warmup"]),
            "--iterations", str(settings["iterations"]),
            "--low", str(settings["low"]),
            "--high", str(settings["high"]),
            "--sigma", str(settings["sigma"]),
        ]
    for arg in merge_args(recipe, forwarded):
        print(arg)
    return 0


def main(argv):
    if not argv or argv[0] in {"-h", "--help"}:
        print("usage: compare.py --run RUN_DIR | --init-baseline | --launch-lines [--smoke] [--photo PATH] [--kernel scalar|part2] [-- runner args]")
        return 0
    if argv[0] == "--init-baseline":
        return init_baseline()
    if argv[0] == "--launch-lines":
        return launch_lines(argv[1:])
    if argv[0] == "--run" and len(argv) == 2:
        return compare(Path(argv[1]))
    raise SystemExit("usage: compare.py --run RUN_DIR | --init-baseline | --launch-lines ...")


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
