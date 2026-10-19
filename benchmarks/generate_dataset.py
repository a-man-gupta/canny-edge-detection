#!/usr/bin/env python3
"""Deterministic grayscale PGM fixtures; no downloads or timed file I/O."""
import argparse
import hashlib
import json
from pathlib import Path
import cv2
import numpy as np

SIZES = [(640, 480), (1280, 720), (1920, 1080), (3840, 2160), (7680, 4320)]


def synthetic(kind, w, h, seed):
    image = np.zeros((h, w), np.uint8)
    if kind == 'sparse':
        cv2.rectangle(image, (w // 5, h // 5), (w // 2, h // 2), 220, -1)
        cv2.circle(image, (3 * w // 4, h // 2), max(2, h // 7), 160, -1)
    elif kind == 'medium_synthetic':
        # Explicitly procedural, never described as natural photography.
        image[:] = np.linspace(20, 100, w, dtype=np.uint8)
        rng = np.random.default_rng(seed)
        for _ in range(80):
            x, y = int(rng.integers(w)), int(rng.integers(h))
            cv2.circle(image, (x, y), int(rng.integers(max(2, h//100), max(3, h//12))), int(rng.integers(256)), -1)
    elif kind == 'noise':
        image = np.random.default_rng(seed).integers(0, 256, (h, w), dtype=np.uint8)
    elif kind == 'chains':
        # Serpentine contrast ramp: intended stress fixture, not guaranteed worst case.
        for y in range(8, h - 8, 12):
            image[y:y+3, 8:w-8] = np.linspace(255, 45, w-16, dtype=np.uint8)
            x = w-11 if (y//12) % 2 == 0 else 8
            image[y:y+15, x:x+3] = 80
    else:
        raise ValueError(kind)
    return image


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output', type=Path, default=Path('benchmark_data'))
    p.add_argument('--photo', type=Path, help='User-supplied natural photograph; provenance saved, no downloads')
    p.add_argument('--seed', type=int, default=18645)
    p.add_argument('--smoke', action='store_true', help='Only tiny 96x64 fixtures')
    a = p.parse_args()
    a.output.mkdir(parents=True, exist_ok=True)
    photo = None
    source = None
    medium = 'medium_synthetic'
    if a.photo:
        photo = cv2.imread(str(a.photo), cv2.IMREAD_GRAYSCALE)
        if photo is None:
            p.error('Cannot read --photo')
        medium = 'natural'
        source = {'path': str(a.photo.resolve()), 'sha256': hashlib.sha256(a.photo.read_bytes()).hexdigest()}
    sizes = [(96, 64)] if a.smoke else SIZES
    cases = [(f'resolution_{w}x{h}', 'resolution', medium, w, h) for w, h in sizes]
    w, h = (96, 64) if a.smoke else (3840, 2160)
    cases += [(f'density_{kind}_{w}x{h}', 'density', kind, w, h) for kind in ['sparse', medium, 'noise', 'chains']]
    cases += [('sanity_blank', 'sanity', 'blank', 96, 64)]
    entries = []
    for name, axis, kind, w, h in cases:
        image = (cv2.resize(photo, (w, h), interpolation=cv2.INTER_AREA) if kind == 'natural'
                 else np.zeros((h, w), np.uint8) if kind == 'blank'
                 else synthetic(kind, w, h, a.seed))
        path = a.output / f'{name}.pgm'
        if not cv2.imwrite(str(path), image):
            raise RuntimeError(f'Cannot write {path}')
        entries.append({'name': name, 'axis': axis, 'kind': kind, 'width': w, 'height': h,
                        'path': path.name, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()})
    manifest = {'schema_version': 1, 'seed': a.seed, 'photo': source, 'opencv': cv2.__version__, 'cases': entries}
    (a.output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'Wrote {len(entries)} cases to {a.output}; medium source: {medium}')


if __name__ == '__main__':
    main()
