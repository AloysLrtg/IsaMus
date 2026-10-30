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
# Search only the inner 70% of the frame, excluding all rounded corners.
frame_side = min(xs[-1] - xs[0], ys[-1] - ys[0])
cx, cy = (xs[0] + xs[-1]) / 2, (ys[0] + ys[-1]) / 2
inner = round(frame_side * .35)
points = []
def is_symbol(rgb):
    r, g, b = rgb
    return r > 45 and r > b * 1.08 and (g > 50 or r > g * 1.3)

for y in range(round(cy) - inner, round(cy) + inner):
    for x in range(round(cx) - inner, round(cx) + inner):
        if is_symbol(image.getpixel((x, y))):
            points.append((x, y))
if not points:
    raise ValueError('Central symbol not detected.')
x0, x1 = min(x for x, y in points), max(x for x, y in points)
y0, y1 = min(y for x, y in points), max(y for x, y in points)
# The symbol occupies 78% of the square: 11% breathing room on each side.
side = math.ceil(max(x1 - x0 + 1, y1 - y0 + 1) / .78)
left, top = round((x0 + x1 + 1 - side) / 2), round((y0 + y1 + 1 - side) / 2)
box = (left, top, left + side, top + side)
if not (xs[0] < left and ys[0] < top and box[2] < xs[-1] and box[3] < ys[-1]):
    raise ValueError('Symbol crop must remain strictly inside the frame.')
logo = image.crop(box)
# Replace the source's navy gradient by the requested solid navy background.
# Preserve the original warm pixels (gold relief and red card outlines).
background = (11, 18, 33)
for y in range(side):
    for x in range(side):
        if not is_symbol(logo.getpixel((x, y))):
            logo.putpixel((x, y), background)
# Any residual frame would intersect the margin; fail rather than export it.
margin = round(side * .08)
for y in range(side):
    for x in range(side):
        if min(x, y, side - 1 - x, side - 1 - y) < margin:
            if logo.getpixel((x, y)) != background:
                raise ValueError('Unexpected colored pixels in the outer margin.')

def save(im, path, size):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    im.resize((size, size), Image.Resampling.LANCZOS).save(path)

save(logo, 'assets/images/logo_isamus.png', side)
for size in (192, 512):
    save(logo, f'web/icons/Icon-{size}.png', size)
    # Keep the symbol inside the central safe circle of maskable icons.
    maskable = Image.new('RGB', (size, size), '#0B1221')
    inset_size = round(size * .84)
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
