#!/usr/bin/env python3
"""
Full pipeline — runs all five DB-generation steps in order.

    Step 0  db/00_decode.py       data/raw/ → data/txt/
    Step 1  db/01_songs_html.py   data/txt/songs/ → data/processed/songs/
    Step 2  db/02_liturgy_html.py data/txt/liturgy/ → data/processed/liturgy/
    Step 3  db/03_index.py        → data/processed/index.jsonl
    Step 4  db/04_inject.py       index + HTML → assets/*.db

Run individual steps to iterate on one stage, or run this to rebuild all:

    python3 scripts/generate_db.py
"""

import os
import runpy

DB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'db')

for script in ('00_decode', '01_songs_html', '02_liturgy_html', '03_index', '04_inject'):
    print(f'\n── {script} ──')
    runpy.run_path(os.path.join(DB_DIR, f'{script}.py'), run_name='__main__')
