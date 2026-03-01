#!/usr/bin/env python3
"""
Step 4 — Inject: data/processed/index.jsonl + HTML files → assets/*.db

Reads index.jsonl from Step 3, loads HTML content for each entry, and
writes the two bundled SQLite databases.

    python3 scripts/db/04_inject.py
"""

import json
import os
import sqlite3

PROJECT_ROOT    = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
INDEX_PATH      = os.path.join(PROJECT_ROOT, 'data', 'processed', 'index.jsonl')
LLM_INDEX_PATH  = os.path.join(PROJECT_ROOT, 'data', 'processed', 'llm_songs_index.jsonl')
ASSETS_DIR      = os.path.join(PROJECT_ROOT, 'assets')


def _read_html(rel_path):
    with open(os.path.join(PROJECT_ROOT, rel_path), 'r', encoding='utf-8') as f:
        return f.read()


if __name__ == '__main__':
    if not os.path.exists(INDEX_PATH):
        print(f'ERROR: {INDEX_PATH} not found — run Step 3 first.')
        raise SystemExit(1)

    # Load base index (songs + liturgy from 03_index.py)
    entries = []
    with open(INDEX_PATH, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line:
                entries.append(json.loads(line))

    liturgy = [e for e in entries if e['type'] == 'liturgy']

    # Prefer LLM-generated song titles (llm_songs_index.jsonl) if available
    if os.path.exists(LLM_INDEX_PATH):
        songs = []
        with open(LLM_INDEX_PATH, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line:
                    songs.append(json.loads(line))
        print(f'Using LLM song titles from {LLM_INDEX_PATH} ({len(songs)} songs)')
    else:
        songs = [e for e in entries if e['type'] == 'song']
        print(f'LLM index not found — using basic titles from {INDEX_PATH}')

    os.makedirs(ASSETS_DIR, exist_ok=True)

    # ── songs_database.db ──────────────────────────────────────────────────────
    songs_db = os.path.join(ASSETS_DIR, 'songs_database.db')
    if os.path.exists(songs_db):
        os.remove(songs_db)
    conn = sqlite3.connect(songs_db)
    cur  = conn.cursor()
    cur.execute('''
        CREATE TABLE songs (
            songId   INTEGER PRIMARY KEY,
            title    TEXT NOT NULL,
            titleEng TEXT NOT NULL,
            lyrics   TEXT NOT NULL
        )
    ''')
    for entry in songs:
        cur.execute(
            'INSERT INTO songs (songId, title, titleEng, lyrics) VALUES (?, ?, ?, ?)',
            (entry['id'], entry['title'], entry.get('titleEng', entry['title']), _read_html(entry['html'])),
        )
    conn.commit()
    conn.close()
    print(f'✓ songs_database.db — {len(songs)} songs')

    # ── books_database.db ──────────────────────────────────────────────────────
    books_db = os.path.join(ASSETS_DIR, 'books_database.db')
    if os.path.exists(books_db):
        os.remove(books_db)
    conn = sqlite3.connect(books_db)
    cur  = conn.cursor()
    cur.execute('''
        CREATE TABLE books (
            pageId  INTEGER PRIMARY KEY,
            title   TEXT NOT NULL,
            page    TEXT NOT NULL
        )
    ''')
    for entry in liturgy:
        cur.execute(
            'INSERT INTO books (pageId, title, page) VALUES (?, ?, ?)',
            (entry['id'], entry['title'], _read_html(entry['html'])),
        )
    conn.commit()
    conn.close()
    print(f'✓ books_database.db — {len(liturgy)} liturgy sections')

    print('Done.')
