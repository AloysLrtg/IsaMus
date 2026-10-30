#!/usr/bin/env python3
"""Crop the official logo and regenerate icons. Requires Pillow.

Run from any directory: python3 scripts/generate_app_icons.py [source.png]
"""
import json
import math
from pathlib import Path
import sys
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
source = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / 'IsaMus.png'
image = Image.open(source).convert('RGB')
w, h = image.size
# The frame's long straight gold strokes occupy over 40% of a row/column.
# This separates the frame from the gold symbol and card outlines inside it.
rows, cols = [0] * h, [0] * w
for y in range(h):
    for x in range(w):
        r, g, b = image.getpixel((x, y))
        if r > 140 and g > 100 and r > b * 1.35 and g > b * 1.2:
            rows[y] += 1
            cols[x] += 1
ys = [y for y, count in enumerate(rows) if count > min(w, h) * .4]
xs = [x for x, count in enumerate(cols) if count > min(w, h) * .4]
if not xs or not ys:
    raise ValueError('Gold frame not detected; inspect source before cropping.')
# Include the outer blue bevel beyond the gold stroke and a small margin.
margin = math.ceil(min(w, h) * .018)
side = max(xs[-1] - xs[0] + 1, ys[-1] - ys[0] + 1) + 2 * margin
left = round((xs[0] + xs[-1] + 1 - side) / 2)
top = round((ys[0] + ys[-1] + 1 - side) / 2)
box = (left, top, left + side, top + side)
if left < 0 or top < 0 or box[2] > w or box[3] > h:
    raise ValueError('Detected frame crop exceeds source bounds.')
logo = image.crop(box)

def save(im, path, size):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    im.resize((size, size), Image.Resampling.LANCZOS).save(path)

save(logo, 'assets/images/logo_isamus.png', side)
for size in (192, 512):
    save(logo, f'web/icons/Icon-{size}.png', size)
    # Keep the entire frame inside the central safe circle of maskable icons.
    maskable = Image.new('RGB', (size, size), '#0B1221')
    inset_size = round(size * .54)
    inset = logo.resize((inset_size, inset_size), Image.Resampling.LANCZOS)
    maskable.paste(inset, ((size - inset_size) // 2,) * 2)
    save(maskable, f'web/icons/Icon-maskable-{size}.png', size)
save(logo, 'web/favicon.png', 32)
for density, size in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
    save(logo, f'android/app/src/main/res/mipmap-{density}/ic_launcher.png', size)
for platform in ('ios', 'macos'):
    directory = Path(platform) / 'Runner/Assets.xcassets/AppIcon.appiconset'
    data = json.loads((ROOT / directory / 'Contents.json').read_text())
    for entry in data['images']:
        if 'filename' in entry:
            size = round(float(entry['size'].split('x')[0]) * float(entry['scale'].removesuffix('x')))
            save(logo, directory / entry['filename'], size)
# Windows embeds a multi-resolution ICO in its runner.
logo.save(ROOT / 'windows/runner/resources/app_icon.ico', sizes=[(s, s) for s in (16, 24, 32, 48, 64, 128, 256)])
print(f'Cropped {w}x{h} at {box} -> {side}x{side}; regenerated Web, Android, iOS, macOS and Windows icons.')
