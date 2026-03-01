#!/usr/bin/env python3
"""
Step 3 — Index: data/txt/ + data/processed/ → data/processed/index.jsonl

Reads titles from the plain-text files (line 0) and pairs each entry with
its processed HTML path. Warns if an HTML file is missing (run Steps 1 & 2
first).

Output — one JSON object per line:
    {"type": "song",    "id": 1,  "title": "...", "html": "data/processed/songs/001.html"}
    {"type": "liturgy", "id": 1,  "title": "...", "html": "data/processed/liturgy/001.html"}

    python3 scripts/db/03_index.py
"""

import json
import os
import re

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SONGS_DIR    = os.path.join(PROJECT_ROOT, 'data', 'txt', 'songs')
LITURGY_DIR  = os.path.join(PROJECT_ROOT, 'data', 'txt', 'liturgy')
PROCESSED    = os.path.join(PROJECT_ROOT, 'data', 'processed')
INDEX_PATH   = os.path.join(PROCESSED, 'index.jsonl')


def lines_of(text):
    return [line.rstrip() for line in text.splitlines()]


def _check_html(rel_path):
    if not os.path.exists(os.path.join(PROJECT_ROOT, rel_path)):
        print(f'  WARN missing {rel_path} — run Steps 1 & 2 first')
        return False
    return True


if __name__ == '__main__':
    os.makedirs(PROCESSED, exist_ok=True)

    song_files    = sorted(f for f in os.listdir(SONGS_DIR)   if f.endswith('.txt'))
    liturgy_files = sorted(f for f in os.listdir(LITURGY_DIR) if f.endswith('.txt'))

    written = 0
    with open(INDEX_PATH, 'w', encoding='utf-8') as out:

        for fname in song_files:
            song_id = int(os.path.splitext(fname)[0])
            with open(os.path.join(SONGS_DIR, fname), 'r', encoding='utf-8') as f:
                text = f.read()
            title = lines_of(text)[0].strip() if text else ''
            html  = f'data/processed/songs/{song_id:03d}.html'
            if not _check_html(html):
                continue
            out.write(json.dumps(
                {'type': 'song', 'id': song_id, 'title': title, 'html': html},
                ensure_ascii=False,
            ) + '\n')
            written += 1

        for fname in liturgy_files:
            page_id   = int(os.path.splitext(fname)[0])
            with open(os.path.join(LITURGY_DIR, fname), 'r', encoding='utf-8') as f:
                text = f.read()
            all_lines = lines_of(text)
            raw_title = all_lines[0].strip() if all_lines else ''
            title     = re.sub(r'^\d+\.\s*', '', raw_title).strip()
            html      = f'data/processed/liturgy/{page_id:03d}.html'
            if not _check_html(html):
                continue
            out.write(json.dumps(
                {'type': 'liturgy', 'id': page_id, 'title': title, 'html': html},
                ensure_ascii=False,
            ) + '\n')
            written += 1

    print(f'✓ index.jsonl — {written} entries '
          f'({len(song_files)} songs + {len(liturgy_files)} liturgy) → {INDEX_PATH}')
