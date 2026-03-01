#!/usr/bin/env python3
"""
Generate a 1024x1024 app icon for CSI Songbook.

Source: data/icon.png (scaled to 1024x1024 if needed).
Requires: Pillow  (pip3 install Pillow)

Run from the project root:
    python3 scripts/generate_icon.py
"""

import os

try:
    from PIL import Image
except ImportError:
    print("Pillow not installed. Run: pip3 install Pillow")
    raise

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_PATH = os.path.join(ROOT, 'data', 'icon.png')
OUT_PATH = os.path.join(ROOT, 'assets', 'icons', 'app_icon.png')

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)

img = Image.open(SRC_PATH).convert('RGBA')
if img.size != (1024, 1024):
    img = img.resize((1024, 1024), Image.LANCZOS)

img.save(OUT_PATH, 'PNG')
print(f'✓ Icon saved to {OUT_PATH}')
