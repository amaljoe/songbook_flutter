#!/usr/bin/env python3
"""
Step 2 — Liturgy HTML: data/txt/liturgy/*.txt → data/processed/liturgy/*.html

Line 0 is the section title with a leading "N. " prefix (skipped; captured
in Step 3). Remaining lines are formatted into paragraph HTML with <em> rubrics.

    python3 scripts/db/02_liturgy_html.py
"""

import os
import re

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LITURGY_DIR  = os.path.join(PROJECT_ROOT, 'data', 'txt', 'liturgy')
OUT_DIR      = os.path.join(PROJECT_ROOT, 'data', 'processed', 'liturgy')


def lines_of(text):
    return [line.rstrip() for line in text.splitlines()]


def format_liturgy_html(lines):
    """
    Paragraphs separated by blank lines.
    Bracketed rubrics [text] → <em>[text]</em>.
    """
    html_parts   = []
    current_para = []

    def flush_para():
        if current_para:
            text = ' '.join(current_para).strip()
            text = re.sub(r'\[([^\]]*)\]', r'<em>[\1]</em>', text)
            html_parts.append(f'<p>{text}</p>')
            current_para.clear()

    for line in lines:
        stripped = line.strip()
        if not stripped:
            flush_para()
        else:
            current_para.append(stripped)

    flush_para()
    return ''.join(html_parts)


if __name__ == '__main__':
    os.makedirs(OUT_DIR, exist_ok=True)
    files = sorted(f for f in os.listdir(LITURGY_DIR) if f.endswith('.txt'))
    for fname in files:
        page_id = int(os.path.splitext(fname)[0])
        with open(os.path.join(LITURGY_DIR, fname), 'r', encoding='utf-8') as f:
            text = f.read()
        all_lines = lines_of(text)
        body_lines = all_lines[1:] if len(all_lines) > 1 else []
        html = format_liturgy_html(body_lines)
        with open(os.path.join(OUT_DIR, f'{page_id:03d}.html'), 'w', encoding='utf-8') as f:
            f.write(html)
    print(f'✓ {len(files)} liturgy HTML files → {OUT_DIR}')
