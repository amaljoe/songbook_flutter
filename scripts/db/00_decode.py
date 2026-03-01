#!/usr/bin/env python3
"""
Step 0 — Decode: data/raw/songs/*.txt + data/raw/liturgy/*.txt
                   → data/txt/songs/ + data/txt/liturgy/

Applies URL-decoding, BOM stripping, and NBSP normalisation.
All subsequent steps read plain UTF-8 from data/txt/.

    python3 scripts/db/00_decode.py
"""

import os
from urllib.parse import unquote_plus

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

SOURCES = [
    (
        os.path.join(PROJECT_ROOT, 'data', 'raw', 'songs'),
        os.path.join(PROJECT_ROOT, 'data', 'txt', 'songs'),
    ),
    (
        os.path.join(PROJECT_ROOT, 'data', 'raw', 'liturgy'),
        os.path.join(PROJECT_ROOT, 'data', 'txt', 'liturgy'),
    ),
]


def decode_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        raw = f.read()
    decoded = unquote_plus(raw)
    decoded = decoded.lstrip('\ufeff')      # strip BOM
    decoded = decoded.replace('\xa0', ' ')  # NBSP → space
    return decoded


if __name__ == '__main__':
    for src_dir, out_dir in SOURCES:
        os.makedirs(out_dir, exist_ok=True)
        files = sorted(f for f in os.listdir(src_dir) if f.endswith('.txt'))
        for fname in files:
            text = decode_file(os.path.join(src_dir, fname))
            with open(os.path.join(out_dir, fname), 'w', encoding='utf-8') as f:
                f.write(text)
        label = os.path.basename(out_dir)
        print(f'✓ {len(files)} {label} files → {out_dir}')
