"""Generate identical raw grayscale inputs for every benchmark variant."""
from pathlib import Path
import argparse
from PIL import Image, ImageOps
from matplotlib import cbook
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('out', type=Path)
parser.add_argument('--photo', type=Path, default=cbook.get_sample_data('grace_hopper.jpg', asfileobj=False))
args = parser.parse_args()
args.out.mkdir(parents=True, exist_ok=True)
photo = Image.open(args.photo).convert('L')
for w, h in [(1920,1080),(3840,2160)]:
    crop = ImageOps.fit(photo,(w,h),method=Image.Resampling.BICUBIC,centering=(0.5,0.35))
    (args.out / f'photo-{w}.raw').write_bytes(crop.tobytes())
    noise = np.random.default_rng(18645).integers(0,256,(h,w),dtype=np.uint8)
    (args.out / f'noise-{w}.raw').write_bytes(noise.tobytes())
