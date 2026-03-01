#!/usr/bin/env python3
"""
llm_titles.py — LLM-based song title extraction (standalone).

Uses a self-hosted google/gemma-3-27b-it (OpenAI-compatible API) with
few-shot prompting to extract TWO fields per song:
  • title    — first meaningful lyric line (Malayalam, or English if the
               song has an English title at the top)
  • titleEng — Manglish transliteration of 'title'
               (if title is already English, titleEng is identical)

Output: data/processed/llm_songs_index.jsonl
  Same format as 03_index.py — feed directly into 04_inject.py.

────────────────────────────────────────────────────────────────────────────
SETUP — forward the remote port before running:
    ssh -L 8000:localhost:8000 <user>@cn14-dgx -p 4422

Then run:
    python3 scripts/db/llm_titles.py           # full pipeline
    python3 scripts/db/llm_titles.py --test    # test LLM only, no pipeline
────────────────────────────────────────────────────────────────────────────
"""

import asyncio
import json
import os
import sys
import time

import aiohttp

# ── Configuration ─────────────────────────────────────────────────────────────

LLM_BASE_URL = "http://localhost:8000/v1"
MODEL        = "google/gemma-3-27b-it"
TIMEOUT      = 120   # seconds per request (generous for batched GPU load)
MAX_RETRIES  = 3
RETRY_DELAY  = 2     # seconds between retries
MAX_WORKERS  = 64    # parallel requests (matches GPU batch capacity)

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SONGS_DIR    = os.path.join(PROJECT_ROOT, "data", "txt", "songs")
PROCESSED    = os.path.join(PROJECT_ROOT, "data", "processed")
INDEX_PATH   = os.path.join(PROCESSED, "llm_songs_index.jsonl")

# ── System prompt ─────────────────────────────────────────────────────────────

SYSTEM_PROMPT = """\
You are an expert in Malayalam Christian hymn books (CSI songbook).
Given the opening lines of a hymn, extract two fields and return them as JSON:

  "title"    — first meaningful MALAYALAM lyric line (always Malayalam script)
  "titleEng" — Manglish (Roman-script) transliteration of "title"

━━━ Extracting "title" ━━━
The title MUST be in Malayalam script.  Skip ALL of the following:
  • English lines anywhere at the top  e.g. "Holy, Holy, Holy!", "The Lord's Prayer"
  • Raaga / Tala headers  e.g. "ഭൂപാളം-ഏകതാളം", "ആദിതാളം", "ചായ്പുതാളം"
  • Section markers       e.g. "പല്ലവി", "അനുപല്ലവി", "ചരണം", "ചരണങ്ങള്‍"
  • Standalone numbers    e.g. "1", "2"
  • Style/tune refs       any line ending with "- എന്നരീതി" or "- ഈ രീതി"
  • Quoted tune refs      e.g. 'ഏതെങ്കിലും'- എന്നരീതി

Continue scanning until you find the first line written in Malayalam script that
is an actual lyric.  If a verse starts with "1." or "2." etc, the title is the
Malayalam text that follows the number and dot.

Trim very long titles to the first meaningful phrase (before a dash or comma).

━━━ Producing "titleEng" ━━━
"titleEng" is a Manglish transliteration of "title" — used for keyword search
by people who type Malayalam words in English letters.  It MUST be different
from "title" (which is in Malayalam script).
  • Write each Malayalam syllable with common Roman equivalents, capitalize each word.
  • Preserve hyphens, drop trailing punctuation marks.
  • Examples:  "സ്തുതി" → "Sthuthi",   "യേശു" → "Yeshu",
               "ദൈവം" → "Daivam",     "സ്വര്‍ഗ്ഗം" → "Swargam",
               "സൈന്യങ്ങളിന്‍" → "Sainyangalin"

Return ONLY a JSON object on a single line — no markdown, no explanation:
{"title": "...", "titleEng": "..."}
"""

# ── Few-shot examples ─────────────────────────────────────────────────────────
#
# Three maximally diverse cases:
#
#   A — 015.txt: English title on line 1, raaga-tala follows → preserve English
#   B — 010.txt: Raaga-tala + section markers before Malayalam lyric
#   C — 020.txt: Quoted style reference (not a title) + raaga + section markers

FEW_SHOT = [
    {
        # 001.txt — English title on line 1 (SKIP it); first Malayalam lyric is
        #           inside verse "1." — title is the Malayalam text after "1."
        "input": (
            "      Holy, Holy, Holy!\n"
            "1. സൈന്യങ്ങളിന്‍ ദൈവം ആയ യഹോവേ\n"
            "   നീ വിശുദ്ധന്‍, നീ പരിശുദ്ധന്‍, നിര്‍മ്മലന്‍;\n"
            "   സ്വര്‍ഗ്ഗം ഭൂമി എങ്ങും നിന്‍ മഹത്വം തിങ്ങും\n"
            "   താതസുതാത്മാ ഭാഗ്യത്രിത്വമേ."
        ),
        "output": '{"title": "സൈന്യങ്ങളിന്‍ ദൈവം ആയ യഹോവേ", "titleEng": "Sainyangalin Daivam Aaya Yahove"}',
    },
    {
        # 010.txt — Raaga-tala on line 1, section marker on line 2, lyric on line 3
        "input": (
            "        നാട്ട-അടതാളം\n"
            "          പല്ലവി\n"
            "സര്‍വ്വ മാനുഷരേ പരന്നു-പാടി\n"
            "സന്തോഷത്തോടു വന്ദിച്ചീടുവിന്‍\n"
            "         ചരണങ്ങള്‍"
        ),
        "output": '{"title": "സര്‍വ്വ മാനുഷരേ പരന്നു-പാടി", "titleEng": "Sarva Manushare Parannu Paadi"}',
    },
    {
        # 020.txt — Quoted STYLE REFERENCE (has "- എന്നരീതി" → NOT a title),
        #           then raaga-tala, section marker, then the real Malayalam lyric
        "input": (
            "'യേശുമഹേശനെ ഞാന്‍'- എന്നരീതി\n"
            "       തോടി-ആദിതാളം\n"
            "            പല്ലവി\n"
            "അനുദിനം തിരുനാമം എന്‍ ധ്യാനമെ\n"
            "അതിശയങ്കരന്‍ ഈശോ!\n"
            "          ചരണങ്ങള്‍"
        ),
        "output": '{"title": "അനുദിനം തിരുനാമം എന്‍ ധ്യാനമെ", "titleEng": "Anudinam Thirunamam En Dhyaname"}',
    },
]

# ── LLM helpers ───────────────────────────────────────────────────────────────

def _build_messages(song_preview: str) -> list:
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    for ex in FEW_SHOT:
        messages.append({"role": "user",      "content": f"Song:\n{ex['input']}"})
        messages.append({"role": "assistant", "content": ex["output"]})
    messages.append({"role": "user", "content": f"Song:\n{song_preview}"})
    return messages


def _parse_llm_response(raw: str):
    """Parse the JSON blob the LLM returns into (title, titleEng)."""
    raw = raw.strip().strip("`").strip()
    if raw.startswith("json"):
        raw = raw[4:].strip()
    obj       = json.loads(raw)
    title     = str(obj.get("title",    "")).strip().strip("\"'")
    title_eng = str(obj.get("titleEng", "")).strip().strip("\"'")
    return title, title_eng


async def extract_titles_async(session: aiohttp.ClientSession, song_preview: str):
    """Async LLM call — returns (title, titleEng). Retries on transient errors."""
    payload = {
        "model":       MODEL,
        "messages":    _build_messages(song_preview),
        "max_tokens":  120,
        "temperature": 0.1,
    }
    timeout = aiohttp.ClientTimeout(total=TIMEOUT)
    raw = ""
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            async with session.post(
                f"{LLM_BASE_URL}/chat/completions",
                json=payload,
                timeout=timeout,
            ) as resp:
                resp.raise_for_status()
                data = await resp.json()
                raw  = data["choices"][0]["message"]["content"].strip()
                return _parse_llm_response(raw)

        except (json.JSONDecodeError, KeyError) as e:
            if attempt == MAX_RETRIES:
                raise ValueError(f"Bad LLM JSON: {e!r} — raw={raw!r}")
            await asyncio.sleep(RETRY_DELAY)

        except (aiohttp.ClientError, asyncio.TimeoutError) as e:
            if attempt == MAX_RETRIES:
                raise
            await asyncio.sleep(RETRY_DELAY)

    raise RuntimeError("unreachable")


# ── Connection test ───────────────────────────────────────────────────────────

async def test_connection_async() -> bool:
    """Check server reachability and run smoke tests on the few-shot examples."""
    print(f"Endpoint : {LLM_BASE_URL}")
    print(f"Model    : {MODEL}")
    print()

    async with aiohttp.ClientSession() as session:
        # ── reachability ──
        print("1. Checking server reachability...")
        try:
            async with session.get(f"{LLM_BASE_URL}/models", timeout=aiohttp.ClientTimeout(total=10)) as r:
                r.raise_for_status()
                data      = await r.json()
                model_ids = [m["id"] for m in data.get("data", [])]
            print(f"   ✓ Server up. Models: {model_ids}")
        except Exception as e:
            print(f"   ✗ Server unreachable: {e}")
            print()
            print("   Make sure you have forwarded the port:")
            print("     ssh -L 8000:localhost:8000 <user>@cn14-dgx -p 4422")
            return False

        # ── smoke tests (run all 3 concurrently) ──
        print()
        print("2. Running few-shot smoke tests (concurrent)...")
        tasks    = [extract_titles_async(session, ex["input"]) for ex in FEW_SHOT]
        results  = await asyncio.gather(*tasks, return_exceptions=True)
        all_pass = True
        for i, (ex, res) in enumerate(zip(FEW_SHOT, results), 1):
            expected = json.loads(ex["output"])
            if isinstance(res, Exception):
                print(f"   [{i}] ERROR: {res}")
                all_pass = False
                continue
            got_title, got_eng = res
            ok   = got_title == expected["title"] and got_eng == expected["titleEng"]
            icon = "✓" if ok else "~"
            print(f"   [{i}] {icon}  title    expected : {expected['title']}")
            print(f"             got      : {got_title}")
            print(f"        titleEng expected : {expected['titleEng']}")
            print(f"             got      : {got_eng}")
            if not ok:
                all_pass = False

    print()
    if all_pass:
        print("   All smoke tests passed ✓")
    else:
        print("   Some differences — minor variation is usually fine.")
    return True


# ── Resume support ────────────────────────────────────────────────────────────

def load_done_ids() -> set:
    done = set()
    if not os.path.exists(INDEX_PATH):
        return done
    with open(INDEX_PATH, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    obj = json.loads(line)
                    if obj.get("type") == "song":
                        done.add(obj["id"])
                except json.JSONDecodeError:
                    pass
    return done


# ── Main pipeline ─────────────────────────────────────────────────────────────

async def run_pipeline_async():
    os.makedirs(PROCESSED, exist_ok=True)

    song_files = sorted(f for f in os.listdir(SONGS_DIR) if f.endswith(".txt"))
    total      = len(song_files)

    done_ids  = load_done_ids()
    remaining = [f for f in song_files if int(os.path.splitext(f)[0]) not in done_ids]

    print(f"Songs total   : {total}")
    print(f"Already done  : {len(done_ids)}")
    print(f"To process    : {len(remaining)}")
    print(f"Concurrency   : {MAX_WORKERS}")
    print(f"Output        : {INDEX_PATH}")
    print()

    if not remaining:
        print("Nothing to do — all songs already indexed.")
        return

    # Pre-load all previews (fast, local)
    jobs = []
    for fname in remaining:
        song_id  = int(os.path.splitext(fname)[0])
        html_rel = f"data/processed/songs/{song_id:03d}.html"
        if not os.path.exists(os.path.join(PROJECT_ROOT, html_rel)):
            print(f"  [{song_id:03d}] WARN  HTML missing — run 01_songs_html.py first")
            continue
        with open(os.path.join(SONGS_DIR, fname), "r", encoding="utf-8") as f:
            preview = "\n".join(f.read().splitlines()[:8])
        jobs.append((song_id, html_rel, preview))

    processed = 0
    errors    = 0
    semaphore = asyncio.Semaphore(MAX_WORKERS)

    mode = "a" if done_ids else "w"
    out_file = open(INDEX_PATH, mode, encoding="utf-8")

    async def process_one(session, song_id, html_rel, preview):
        nonlocal processed, errors
        async with semaphore:
            try:
                title, title_eng = await extract_titles_async(session, preview)
            except Exception as e:
                print(f"  #{song_id:03d}  ERROR: {e}")
                errors += 1
                return
            entry = {
                "type":     "song",
                "id":       song_id,
                "title":    title,
                "titleEng": title_eng,
                "html":     html_rel,
            }
            out_file.write(json.dumps(entry, ensure_ascii=False) + "\n")
            out_file.flush()
            processed += 1
            n_done = len(done_ids) + processed
            print(f"  [{n_done:3}/{total}] #{song_id:03d}  {title}  |  {title_eng}")

    connector = aiohttp.TCPConnector(limit=MAX_WORKERS)
    async with aiohttp.ClientSession(connector=connector) as session:
        await asyncio.gather(*[
            process_one(session, sid, html, preview)
            for sid, html, preview in jobs
        ])

    out_file.close()
    print()
    print(f"✓ Done — {processed} processed, {errors} errors")
    print(f"  Output : {INDEX_PATH}")


# ── Entry point ───────────────────────────────────────────────────────────────

async def main():
    test_only = "--test" in sys.argv

    print("=" * 60)
    print("llm_titles.py — LLM Song Title Extractor")
    print("=" * 60)
    print()

    ok = await test_connection_async()
    if not ok:
        sys.exit(1)

    if test_only:
        print("(--test mode: skipping full pipeline)")
        return

    print("-" * 60)
    print("Starting pipeline...")
    print("-" * 60)
    print()
    await run_pipeline_async()


if __name__ == "__main__":
    asyncio.run(main())
