#!/usr/bin/env python3
"""
Generate SQLite database assets for the CSI Songbook Flutter app.

Reads URL-encoded .txt files from:
  - data/songs/001.txt .. 550.txt
  - data/litergy/001.txt .. 044.txt

Outputs:
  - assets/songs_database.db  (table: songs)
  - assets/books_database.db  (table: books, now with title column)

Run from the project root:
    python3 scripts/generate_db.py
"""

import os
import re
import sqlite3
from urllib.parse import unquote_plus

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SONGS_DIR = os.path.join(PROJECT_ROOT, 'data', 'songs')
LITURGY_DIR = os.path.join(PROJECT_ROOT, 'data', 'litergy')
ASSETS_DIR = os.path.join(PROJECT_ROOT, 'assets')


def decode_file(path):
    """Read a URL-encoded text file and return clean unicode string."""
    with open(path, 'r', encoding='utf-8') as f:
        raw = f.read()
    # URL-decode: + → space, %XX → byte
    decoded = unquote_plus(raw)
    # Strip BOM
    decoded = decoded.lstrip('\ufeff')
    # Replace NBSP with regular space
    decoded = decoded.replace('\xa0', ' ')
    return decoded


def lines_of(text):
    """Return stripped lines, preserving empty lines as empty strings."""
    return [line.rstrip() for line in text.splitlines()]


# ── Song HTML formatter ────────────────────────────────────────────────────────

def format_song_html(lines):  # type: ignore
    """
    Convert song body lines (after title) to HTML.

    Lines matching /^\\d+\\./ start a new verse paragraph <p><b>N. </b>rest</p>.
    Continuation lines are appended as <br/> inside the current paragraph.
    Empty lines separate paragraphs (closing current <p> if open).
    """
    html_parts = []
    in_para = False

    for line in lines:
        stripped = line.strip()

        if not stripped:
            # Empty line → close paragraph if open
            if in_para:
                html_parts.append('</p>')
                in_para = False
            continue

        verse_match = re.match(r'^(\d+)\.\s*(.*)', stripped)
        if verse_match:
            # Close previous paragraph
            if in_para:
                html_parts.append('</p>')
            num = verse_match.group(1)
            rest = verse_match.group(2).strip()
            html_parts.append(f'<p><b>{num}. </b>{rest}')
            in_para = True
        else:
            if in_para:
                html_parts.append(f'<br/>{stripped}')
            else:
                # Continuation before a verse header — treat as new para
                html_parts.append(f'<p>{stripped}')
                in_para = True

    if in_para:
        html_parts.append('</p>')

    return ''.join(html_parts)


# ── Liturgy HTML formatter ─────────────────────────────────────────────────────

def format_liturgy_html(lines):
    """
    Convert liturgy body lines (after title line) to HTML.

    Paragraphs are separated by blank lines.
    Bracketed rubrics [text] → <em>[text]</em>
    """
    html_parts = []
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


# ── Songs database ─────────────────────────────────────────────────────────────

def build_songs_db():
    db_path = os.path.join(ASSETS_DIR, 'songs_database.db')
    if os.path.exists(db_path):
        os.remove(db_path)

    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE songs (
            songId   INTEGER PRIMARY KEY,
            title    TEXT NOT NULL,
            titleEng TEXT NOT NULL,
            lyrics   TEXT NOT NULL
        )
    ''')

    files = sorted(f for f in os.listdir(SONGS_DIR) if f.endswith('.txt'))
    for fname in files:
        song_id = int(os.path.splitext(fname)[0])
        text = decode_file(os.path.join(SONGS_DIR, fname))
        all_lines = lines_of(text)

        # Line 0 is the title
        title_line = all_lines[0].strip() if all_lines else ''
        body_lines = all_lines[1:] if len(all_lines) > 1 else []

        lyrics_html = format_song_html(body_lines)

        cur.execute(
            'INSERT INTO songs (songId, title, titleEng, lyrics) VALUES (?, ?, ?, ?)',
            (song_id, title_line, title_line, lyrics_html)
        )

    conn.commit()
    conn.close()
    print(f'✓ songs_database.db — {len(files)} songs')


# ── Books database ─────────────────────────────────────────────────────────────

def build_books_db():
    db_path = os.path.join(ASSETS_DIR, 'books_database.db')
    if os.path.exists(db_path):
        os.remove(db_path)

    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE books (
            pageId  INTEGER PRIMARY KEY,
            title   TEXT NOT NULL,
            page    TEXT NOT NULL
        )
    ''')

    files = sorted(f for f in os.listdir(LITURGY_DIR) if f.endswith('.txt'))
    for fname in files:
        page_id = int(os.path.splitext(fname)[0])
        text = decode_file(os.path.join(LITURGY_DIR, fname))
        all_lines = lines_of(text)

        # Line 0: "1. [Malayalam title]" — strip the leading "N. " prefix
        raw_title = all_lines[0].strip() if all_lines else ''
        title = re.sub(r'^\d+\.\s*', '', raw_title).strip()
        body_lines = all_lines[1:] if len(all_lines) > 1 else []

        page_html = format_liturgy_html(body_lines)

        cur.execute(
            'INSERT INTO books (pageId, title, page) VALUES (?, ?, ?)',
            (page_id, title, page_html)
        )

    conn.commit()
    conn.close()
    print(f'✓ books_database.db — {len(files)} liturgy sections')


if __name__ == '__main__':
    os.makedirs(ASSETS_DIR, exist_ok=True)
    build_songs_db()
    build_books_db()
    print('Done.')
