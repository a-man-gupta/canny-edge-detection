#!/usr/bin/env python3
"""Sobel and NMS comparison against the frozen scalar baseline.

The pointer is benchmark_results/run-001/baseline.json. It names run-003, which
is read in place. Writes two line plots and one table under the numbered run's
comparison/ directory. Does not time anything.

Correctness is the timed scalar edge map versus that baseline edge map. The
in-run accuracy.csv row that compares scalar with itself is not the verdict.
"""
import csv
import hashlib
import json
import math
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


def compiler_flags(compile_commands):
    for row in compile_commands:
        if Path(row.get("file", "")).name == "canny_scalar.cpp":
            kept = []
            skip = 0
            for token in row["command"].split():
                if skip:
                    skip -= 1
                    continue
                if token in ("-o", "-c"):
                    skip = 1
                    continue
                kept.append(token)
            return " ".join(kept)
    return None


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
    if compile_path.is_file():
        flags = compiler_flags(json.loads(compile_path.read_text()))
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
        reasons.append("compiler settings differ")
    if baseline["hostname"] != current["hostname"] or baseline["model_name"] != current["model_name"]:
        reasons.append(f'machine differs (baseline {baseline["hostname"]} {baseline["model_name"]}; this run {current["hostname"]} {current["model_name"]})')
    if (baseline["low"], baseline["high"], baseline["sigma"]) != (current["low"], current["high"], current["sigma"]):
        reasons.append("thresholds or sigma differ")
    return reasons


def scalar_status(run_dir):
    path = run_dir / "run" / "status.json"
    if not path.is_file():
        return {}
    statuses = json.loads(path.read_text())
    found = {}
    for row in statuses:
        if row.get("implementation") == "scalar":
            found[row.get("case")] = row.get("status")
    return found


def scalar_edge_path(run_dir, case_name):
    """PGM written for the timed scalar implementation, not the in-run self check."""
    index = 0
    metadata_path = run_dir / "run" / "metadata.json"
    if metadata_path.is_file():
        try:
            parameters = json.loads(metadata_path.read_text()).get("parameters") or {}
        except (OSError, json.JSONDecodeError, AttributeError):
            parameters = {}
        implementations = parameters.get("implementations") or []
        if isinstance(implementations, list) and "scalar" in implementations:
            index = implementations.index("scalar")
    return run_dir / "run" / "edges" / f"{case_name}_{index}.pgm"


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


def baseline_edge_match(source, run_dir, case_names):
    found = {}
    for name in case_names:
        found[name] = edges_exact(scalar_edge_path(source, name), scalar_edge_path(run_dir, name))
    return found


def resolution_rows(summary):
    rows = [row for row in summary if row.get("implementation") == "scalar" and row.get("axis") == "resolution"]
    rows.sort(key=lambda row: int(row["width"]) * int(row["height"]))
    return rows


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


def write_table(path, run_name, baseline_name, baseline_settings, current_settings, reasons, table, any_failed, settings_match):
    if not settings_match:
        verdict = "not a matched speedup"
        headline = "This is not a successful speedup against the full-size baseline."
        correctness = "Correctness: not compared to baseline edge map"
    elif any_failed or not table:
        verdict = "not a successful speedup"
        headline = f"This is not a successful speedup. A scalar case failed, or its edge map does not match the {baseline_name} baseline edge map."
        correctness = f"Correctness: failed against the {baseline_name} edge map. Sobel and NMS speedup are withheld where the timed scalar map is not an exact 0/255 match."
    else:
        verdict = "matched comparison"
        headline = f"Matched comparison against {baseline_name}. Speedup is the baseline median divided by this run's median."
        correctness = f"Correctness: each timed scalar edge map matches the {baseline_name} edge map for the same case (exact 0/255)."
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
        lines.append(f"One or more scalar cases failed, or the edge map does not match the {baseline_name} baseline edge map.")
        lines.append("")
    if reasons:
        lines.append(f"This run does not match {baseline_name} on the comparison settings:")
        lines.extend(f"- {reason}" for reason in reasons)
        lines.append("")
    lines.extend([
        "Speedup cells stay blank of ratios unless the image cases, warmup, iteration count, compiler, machine, and thresholds match, and that size's timed scalar edge map is an exact 0/255 match to the baseline edge map. A different image size is not compared to the baseline edge map.",
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
        f'| Machine | {baseline_settings["hostname"]}, {baseline_settings["model_name"]} | {current_settings["hostname"]}, {current_settings["model_name"]} |',
        "",
        "Median milliseconds for the scalar implementation. Total is `compute_ms_median`.",
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
        "Raw samples, hardware, and the in-run accuracy table stay in this run directory (`run/raw.csv`, `run/summary.csv`, `run/accuracy.csv`, `run/status.json`, `hardware_before.txt`). The stage verdict compares the timed scalar edge map `run/edges/<case>_<scalar index>.pgm` with the same file under the frozen baseline. `accuracy.csv` still records the in-run OpenCV reference; its scalar-versus-scalar row is not this verdict. The stage view is this table plus `sobel_time.png` and `nms_time.png`.",
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


def compare(run_dir):
    run_dir = run_dir.resolve()
    pointer, source = load_pointer()
    if run_dir == source.resolve() or run_dir == BASELINE_DIR.resolve():
        raise SystemExit("Refusing to write a comparison into the baseline")
    baseline_settings = extract_settings(source)
    current_settings = extract_settings(run_dir)
    reasons = mismatch_reasons(baseline_settings, current_settings)
    settings_match = not reasons
    statuses = scalar_status(run_dir)
    if settings_match:
        reference_ok = baseline_edge_match(source, run_dir, list(statuses))
    else:
        reference_ok = {}
    table, any_failed = build_rows(
        resolution_rows(read_csv(source / "run" / "summary.csv")),
        resolution_rows(read_csv(run_dir / "run" / "summary.csv")),
        statuses,
        reference_ok,
        settings_match,
    )
    if settings_match:
        for name, status in statuses.items():
            if status != "ok" or not reference_ok.get(name, False):
                any_failed = True
    comparison = run_dir / "comparison"
    comparison.mkdir(exist_ok=True)
    baseline_name = source.name
    verdict = write_table(
        comparison / "results.md", run_dir.name, baseline_name, baseline_settings, current_settings, reasons, table, any_failed, settings_match,
    )
    write_plots(comparison, run_dir.name, baseline_name, resolution_rows(read_csv(source / "run" / "summary.csv")), table, settings_match)
    print(f"Verdict: {verdict}")
    print(f"Table: {comparison / 'results.md'}")
    print(f"Sobel plot: {comparison / 'sobel_time.png'}")
    print(f"NMS plot: {comparison / 'nms_time.png'}")
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
    for arg in merge_args(recipe_args(settings), forwarded):
        print(arg)
    return 0


def main(argv):
    if not argv or argv[0] in {"-h", "--help"}:
        print("usage: compare.py --run RUN_DIR | --init-baseline | --launch-lines [--smoke] [--photo PATH] [-- runner args]")
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
