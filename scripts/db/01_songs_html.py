#!/usr/bin/env python3
"""
Step 1 — Songs HTML: data/txt/songs/*.txt → data/processed/songs/*.html

Line 0 of each file is the title (skipped; captured in Step 3).
Remaining lines are formatted into verse HTML.

    python3 scripts/db/01_songs_html.py
"""

import os
import re

_NUM_DOT  = re.compile(r'^(\d+)\.\s*(.*)')   # "1. text"
_NUM_ONLY = re.compile(r'^\d{1,3}$')          # "1" alone (standalone verse label)

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SONGS_DIR    = os.path.join(PROJECT_ROOT, 'data', 'txt', 'songs')
OUT_DIR      = os.path.join(PROJECT_ROOT, 'data', 'processed', 'songs')


def lines_of(text):
    return [line.rstrip() for line in text.splitlines()]


def format_song_html(lines):
    """
    Lines matching /^\\d+\\./ start a verse: <p><b>N. </b>rest</p>.
    Continuation lines become <br/>. Blank lines close the paragraph and
    insert a <p>&nbsp;</p> spacer; consecutive blank lines collapse to one.
    """
    html_parts = []
    in_para    = False
    last_spacer = True  # suppress leading spacers

    for line in lines:
        stripped = line.strip()
        if not stripped:
            if in_para:
                html_parts.append('</p>')
                html_parts.append('<p>&nbsp;</p>')
                in_para     = False
                last_spacer = True
            continue
        verse_match = _NUM_DOT.match(stripped)
        num_only    = _NUM_ONLY.match(stripped)

        if verse_match:
            # "1. text" — inline verse label
            if in_para:
                html_parts.append('</p>')
                html_parts.append('<p>&nbsp;</p>')
            num  = verse_match.group(1)
            rest = verse_match.group(2).strip()
            html_parts.append(f'<p><b>{num}. </b>{rest}')
            in_para     = True
            last_spacer = False
        elif num_only:
            # "1" alone — centered verse label on its own line
            if in_para:
                html_parts.append('</p>')
                in_para = False
            html_parts.append(f'<h3>{stripped}</h3>')
            last_spacer = False
        else:
            if in_para:
                html_parts.append(f'<br/>{stripped}')
            else:
                html_parts.append(f'<p>{stripped}')
                in_para     = True
                last_spacer = False

    if in_para:
        html_parts.append('</p>')

    # remove trailing spacer
    if html_parts and html_parts[-1] == '<p>&nbsp;</p>':
        html_parts.pop()

    return ''.join(html_parts)


if __name__ == '__main__':
    os.makedirs(OUT_DIR, exist_ok=True)
    files = sorted(f for f in os.listdir(SONGS_DIR) if f.endswith('.txt'))
    for fname in files:
        song_id = int(os.path.splitext(fname)[0])
        with open(os.path.join(SONGS_DIR, fname), 'r', encoding='utf-8') as f:
            text = f.read()
        all_lines = lines_of(text)
        html = format_song_html(all_lines)
        with open(os.path.join(OUT_DIR, f'{song_id:03d}.html'), 'w', encoding='utf-8') as f:
            f.write(html)
    print(f'✓ {len(files)} song HTML files → {OUT_DIR}')
