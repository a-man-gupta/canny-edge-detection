"""Export stage symbols from the linked, optimized ECE024 executable."""
import re
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parents[1]
binary = root / 'build/canny_fast.x'
listing = subprocess.check_output(['objdump', '-dC', '--no-show-raw-insn', binary], universal_newlines=True)
groups = {
    'gaussian': ('gaussian_expand_row(', 'expand_impl(', 'expand_tail(', 'vert_tail(',
                 'gaussian_horiz_row(', 'gaussian_vert_row('),
    'sobel': ('sobel_kernel(',),
    'nms-threshold': ('nms_labels(',),
    'hysteresis': ('hysteresis_slab(', 'seed_mask_row(', 'hysteresis_mask_kernel('),
    'tiled': ('canny_tiled(', 'void (anonymous namespace)::tile<false>'),
}
starts = [m.start() for m in re.finditer(r'^[0-9a-f]+ <', listing, re.MULTILINE)]
sections = [listing[a:b] for a, b in zip(starts, starts[1:] + [len(listing)])]
out = root / 'assembly'
out.mkdir(exist_ok=True)
for stage, prefixes in groups.items():
    selected = []
    for section in sections:
        header = re.match(r'^[0-9a-f]+ <(.+)>:', section)
        if header and header[1].startswith(prefixes):
            selected.append(section.rstrip())
    if not selected:
        raise SystemExit(f'No linked symbols found for {stage}')
    (out / (stage + '.asm')).write_text('\n\n'.join(selected) + '\n')
