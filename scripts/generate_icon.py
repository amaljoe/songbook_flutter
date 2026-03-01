#!/usr/bin/env python3
"""
Generate a 1024x1024 app icon for CSI Songbook.

Design: Dark navy background with a white cross and music note overlay.
Requires: Pillow  (pip3 install Pillow)

Run from the project root:
    python3 scripts/generate_icon.py
"""

import os

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Pillow not installed. Run: pip3 install Pillow")
    raise

SIZE = 1024
MARGIN = SIZE // 8
OUT_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    'assets', 'icons', 'app_icon.png'
)

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)

img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Rounded-rect background: navy
bg_color = (26, 35, 126)     # #1A237E
radius = SIZE // 6
draw.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=radius, fill=bg_color)

# White cross
cross_color = (255, 255, 255, 230)
arm = SIZE // 10   # arm thickness
cx, cy = SIZE // 2, SIZE // 2

# Vertical bar
draw.rectangle(
    [cx - arm, MARGIN, cx + arm, SIZE - MARGIN],
    fill=cross_color
)
# Horizontal bar (slightly above center for a classic cross)
crossbar_y = int(SIZE * 0.38)
draw.rectangle(
    [MARGIN, crossbar_y - arm, SIZE - MARGIN, crossbar_y + arm],
    fill=cross_color
)

# Small music note (eighth note) in bottom-right quadrant
note_color = (255, 255, 255, 180)
note_x = int(SIZE * 0.62)
note_y = int(SIZE * 0.60)
note_r = int(SIZE * 0.055)   # note head radius
stem_w = int(SIZE * 0.022)
stem_h = int(SIZE * 0.18)
flag_w = int(SIZE * 0.08)

# Note head (ellipse)
draw.ellipse(
    [note_x - note_r, note_y - int(note_r * 0.7),
     note_x + note_r, note_y + int(note_r * 0.7)],
    fill=note_color
)
# Stem (up)
draw.rectangle(
    [note_x + note_r - stem_w, note_y - stem_h,
     note_x + note_r, note_y],
    fill=note_color
)
# Flag
flag_top_x = note_x + note_r
flag_top_y = note_y - stem_h
draw.polygon(
    [
        (flag_top_x, flag_top_y),
        (flag_top_x + flag_w, flag_top_y + flag_w // 2),
        (flag_top_x, flag_top_y + flag_w),
    ],
    fill=note_color
)

img.save(OUT_PATH, 'PNG')
print(f'✓ Icon saved to {OUT_PATH}')
