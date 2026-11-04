#!/usr/bin/env python3
"""Figure 2, using the rates already stated in docs/report.tex.

The dashed line is that kernel's design floor (pixels/cycle), and the labels are
percent of that floor. Gaussian is the whole-image table. Double threshold and
hysteresis are the L1 results, which the report gives as a flat band over width.
"""
import os

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

BLUE = "#1f77b4"
GRAY = "#7f7f7f"
ORANGE = "#ff7f0e"


def panel(ax, title, widths, avx_y, avx_pct, scalar_y, scalar_pct, peak, peak_name, ylabel, legend_y):
    x = list(range(len(widths)))
    ax.plot(x, avx_y, color=BLUE, marker="o", markersize=5.5, linewidth=1.6, label="AVX2 kernel")
    if scalar_y:
        ax.plot(x, scalar_y, color=GRAY, marker="s", markersize=5, linewidth=1.4, label="Scalar baseline")
    ax.axhline(peak, color=ORANGE, linestyle="--", linewidth=1.4, label=peak_name)
    for i, (y, p) in enumerate(zip(avx_y, avx_pct)):
        ax.annotate("%d%%" % p, (x[i], y), textcoords="offset points", xytext=(0, 5),
                    ha="center", va="bottom", color=BLUE, fontsize=8)
    for i, (y, p) in enumerate(zip(scalar_y, scalar_pct)):
        ax.annotate("%d%%" % p, (x[i], y), textcoords="offset points", xytext=(0, 5),
                    ha="center", va="bottom", color=GRAY, fontsize=8)
    ax.set_title(title, fontsize=12)
    ax.set_xlabel("Image width (pixels)")
    ax.set_ylabel(ylabel)
    ax.set_xticks(x)
    ax.set_xticklabels([str(w) for w in widths])
    ax.set_ylim(0, peak * 1.22)
    ax.set_xlim(-0.45, len(widths) - 0.55)
    ax.legend(loc="center", bbox_to_anchor=(0.5, legend_y), frameon=True, fontsize=8)
    ax.tick_params(labelsize=9)


def main():
    # Useful ops per pixel: Gaussian 14, threshold 3, hysteresis 5.5.
    # Whole-image table: 0.68, 0.70, 0.90, 1.04 cycles/pixel. Floor 0.492.
    # 14/0.70 = 20.0 integer ops/cycle, 70% of 14/0.492.
    gauss_w = [1280, 1920, 3840, 7680]
    gauss_cpp = [0.68, 0.70, 0.90, 1.04]
    gauss_floor = 14.0 / 0.492
    gauss_y = [14.0 / c for c in gauss_cpp]
    gauss_pct = [int(100.0 * y / gauss_floor + 0.5) for y in gauss_y]

    # L1 band in the report: 0.146--0.153 cycles/pixel. Midpoint 0.1495 is 84% of 24.
    thr_w = [256, 512, 1024, 2048, 4096, 6144]
    thr_peak = 3.0 / 0.125
    thr_y = [3.0 / 0.1495] * len(thr_w)
    thr_pct = [84] * len(thr_w)
    thr_sc = [3.0 / 2.05] * len(thr_w)
    thr_sc_pct = [int(100.0 * thr_sc[0] / thr_peak + 0.5)] * len(thr_w)

    # L1 band in the report: 0.118--0.123. Midpoint 0.1205 is 88% of 52.1.
    hys_w = [256, 512, 1024, 1536, 2048, 2944]
    hys_peak = 5.5 / 0.1055
    hys_y = [5.5 / 0.1205] * len(hys_w)
    hys_pct = [88] * len(hys_w)
    hys_sc = [5.5 / 10.66] * len(hys_w)
    hys_sc_pct = [int(100.0 * hys_sc[0] / hys_peak + 0.5)] * len(hys_w)

    fig, axes = plt.subplots(1, 3, figsize=(12.8, 4.15))
    panel(axes[0], "Gaussian blur (whole image)", gauss_w, gauss_y, gauss_pct,
          [], [], gauss_floor, "Design floor (28.5)", "integer ops/cycle", 0.22)
    panel(axes[1], "Double threshold (64-wide)", thr_w, thr_y, thr_pct,
          thr_sc, thr_sc_pct, thr_peak, "Design floor (24)", "integer ops/cycle", 0.42)
    panel(axes[2], "Hysteresis (4×32 tile)", hys_w, hys_y, hys_pct,
          hys_sc, hys_sc_pct, hys_peak, "Design floor (52.1)", "byte ops/cycle", 0.42)
    fig.tight_layout()
    out = os.path.join(os.path.dirname(__file__), "..", "docs", "fig_performance_rest.png")
    fig.savefig(out, dpi=160)
    print("gaussian", list(zip(gauss_w, ["%.2f" % y for y in gauss_y], gauss_pct)))
    print("threshold", thr_y[0], thr_pct[0], "scalar", thr_sc_pct[0])
    print("hysteresis", hys_y[0], hys_pct[0], "scalar", hys_sc_pct[0])


if __name__ == "__main__":
    main()
