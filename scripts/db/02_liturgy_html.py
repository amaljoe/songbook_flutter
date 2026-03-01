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


_ROMAN = re.compile(r'^[IVX]+$')

_RUBRIC = re.compile(r'\[([^\]]*)\]')


def _format_line(text):
    """Apply [rubric] → <em> colouring to a single line of text."""
    return _RUBRIC.sub(r'<em>[\1]</em>', text)


def format_liturgy_html(lines):
    """
    One <p> per non-blank line — preserves every speaker exchange and
    instruction on its own line exactly as in the source.

    Blank lines become a <p>&nbsp;</p> spacer; consecutive blank lines
    collapse to one spacer. Roman-numeral section headers (I, II, III …)
    are bolded. [rubric] text is wrapped in <em>.
    """
    html_parts  = []
    last_spacer = True   # suppress leading spacers

    for line in lines:
        stripped = line.strip()

        if not stripped:
            if not last_spacer:
                html_parts.append('<p>&nbsp;</p>')
                last_spacer = True
            continue

        last_spacer = False

        if _ROMAN.match(stripped):
            html_parts.append(f'<h3>{stripped}</h3>')
        else:
            html_parts.append(f'<p>{_format_line(stripped)}</p>')

    # remove trailing spacer
    if html_parts and html_parts[-1] == '<p>&nbsp;</p>':
        html_parts.pop()

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
