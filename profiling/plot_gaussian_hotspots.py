#!/usr/bin/env python3
"""Draw gaussian_naive() source with curly brackets showing perf annotate cycle shares."""
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

HERE = Path(__file__).resolve().parent
SRC = HERE.parent / 'src/canny_scalar_test.cpp'
FIRST, LAST = 31, 68  # reflect(), make_gaussian_weights(), gaussian_naive()

# perf annotate -l gaussian_naive on perf_stages_synthetic.data (share of gaussian_naive samples).
# (first line, last line, percent, label, detail, color)
BRACES = [
    (33, 34, 11.96, '12.0%', 'reflect(): border checks, inlined 30x per pixel', '#e8590c'),
    (41, 50, None, '~0%', 'runs once, before the timed loop', '#868e96'),
    (58, 60, 4.49, '4.5%', 'outer loops, per-pixel setup, other', '#f08c00'),
    (61, 62, 2.48, '2.5%', 'tap-loop counters and branches', '#f08c00'),
    (63, 63, 51.28, '51.3%', 'u8->float, mulss, addss (one serial accumulator)', '#c92a2a'),
    (64, 64, 13.70, '13.7%', 'index math: row * w + col', '#e8590c'),
    (65, 66, 16.09, '16.1%', 'round + floor (10.6) + clamp (3.6) + store (1.8)', '#e8590c'),
]
OUTER = (61, 64, f'{51.3 + 2.5 + 13.7:.1f}%', '(Target for kernel)', '#a61e4d')
# Two-line source comments drawn as one line; None drops the line. Source line numbers are kept.
COMMENTS = {
    38: '// Builds the 5x5 Gaussian weights from sigma, normalized to sum to 1.',
    39: None,
    53: '// Naive 5x5 Gaussian blur: reflected borders, output quantized to 0..255.',
    54: None,
}

FONT = 11                  # code font size, points
CHAR_W = 0.6 * FONT / 72   # inches per monospace character
LINE_H = 1.55 * FONT / 72  # inches per code line
CODE_X, BRACE_X, LABEL_X, OUTER_X, OUTER_LABEL_X, X_END = 6, 98, 101.5, 157, 160.5, 190
HEADER, FOOTER = 0.8, 0.8  # in line units


def brace(ax, x, top, bottom, width, color, lw=2.0):
    """Right-facing curly brace from y=top to y=bottom (data units, y grows downward)."""
    span = bottom - top
    beta = max(6.0, 10.0 / span) if span < 2 else 6.0
    u = np.linspace(0, span / 2, 200)
    half = 1 / (1 + np.exp(-beta * u)) + 1 / (1 + np.exp(-beta * (u - u[-1])))
    half = (half - half[0]) / (half[-1] - half[0])
    xs = x + width * np.concatenate([half, half[-2::-1]])
    ys = top + np.concatenate([u, span - u[-2::-1]])
    ax.plot(xs, ys, color=color, lw=lw, solid_capstyle='round')


def main():
    source = SRC.read_text().splitlines()
    lines = [(ln, COMMENTS.get(ln, source[ln - 1])) for ln in range(FIRST, LAST + 1)]
    lines = [(ln, text) for ln, text in lines if text is not None]
    index = {ln: i for i, (ln, _) in enumerate(lines)}
    n = len(lines)
    fig_w = X_END * CHAR_W
    fig_h = (n + HEADER + FOOTER) * LINE_H
    fig = plt.figure(figsize=(fig_w, fig_h), dpi=200)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, X_END)
    ax.set_ylim(n + FOOTER - 0.5, -HEADER - 0.5)
    ax.axis('off')
    row = lambda line_no: index[line_no]

    shade = {}
    for first, last, pct, *_ , color in BRACES:
        for ln in range(first, last + 1):
            shade[ln] = (pct or 0, color)
    for i, (ln, text) in enumerate(lines):
        pct, color = shade.get(ln, (0, None))
        if pct:
            alpha = 0.06 + 0.30 * min(pct, 52) / 52
            ax.add_patch(plt.Rectangle((CODE_X - 0.6, i - 0.5), BRACE_X - CODE_X - 0.4, 1,
                                       color=color, alpha=alpha, lw=0))
        ax.text(CODE_X - 1.5, i, str(ln), ha='right', va='center', family='DejaVu Sans Mono',
                fontsize=FONT - 1, color='#adb5bd')
        is_comment = text.strip().startswith('//')
        ax.text(CODE_X, i, text, va='center', family='DejaVu Sans Mono', fontsize=FONT,
                color='#868e96' if is_comment else '#212529')

    for first, last, pct, label, detail, color in BRACES:
        top, bottom = row(first) - 0.36, row(last) + 0.36
        brace(ax, BRACE_X, top, bottom, 1.8, color)
        mid = (top + bottom) / 2
        size = 14 if (pct or 0) > 40 else 12.5
        ax.text(LABEL_X, mid - 0.05, label, va='center', fontsize=size, weight='bold',
                color=color, family='DejaVu Sans')
        ax.text(LABEL_X + 10, mid, detail, va='center', fontsize=10,
                color='#343a40', family='DejaVu Sans')

    first, last, label, title, color = OUTER
    top, bottom = row(first) - 0.45, row(last) + 0.45
    brace(ax, OUTER_X, top, bottom, 2.2, color, lw=2.4)
    mid = (top + bottom) / 2
    ax.text(OUTER_LABEL_X, mid - 0.55, label, va='center', fontsize=20, weight='bold',
            color=color, family='DejaVu Sans')
    ax.text(OUTER_LABEL_X, mid + 0.9, title, va='center', fontsize=11, weight='bold',
            color='#343a40', family='DejaVu Sans')

    out = HERE / 'gaussian_hotspots.png'
    fig.savefig(out, facecolor='white')
    print(out)


if __name__ == '__main__':
    main()
