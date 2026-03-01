#!/usr/bin/env python3
"""
llm_songs_html.py — LLM-based song HTML generation.

Uses a self-hosted google/gemma-3-27b-it (OpenAI-compatible API) with
few-shot prompting to generate structured HTML for each song's lyrics.

Output  : data/processed/llm/songs/XXX.html
Failed  : data/processed/llm/songs_failed.jsonl

────────────────────────────────────────────────────────────────────────────
SETUP — forward the remote port before running:
    ssh -L 8000:localhost:8000 <user>@cn14-dgx -p 4422

Then run:
    python3 scripts/db/llm_songs_html.py          # full pipeline
    python3 scripts/db/llm_songs_html.py --test   # smoke test only
────────────────────────────────────────────────────────────────────────────
"""

import asyncio
import json
import os
import sys

import aiohttp

# ── Configuration ─────────────────────────────────────────────────────────────

LLM_BASE_URL = "http://localhost:8000/v1"
MODEL        = "google/gemma-3-27b-it"
TIMEOUT      = 120   # seconds per request
MAX_RETRIES  = 3
RETRY_DELAY  = 2
MAX_WORKERS  = 64
MAX_TOKENS   = 1500

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SONGS_DIR    = os.path.join(PROJECT_ROOT, "data", "txt", "songs")
OUT_DIR      = os.path.join(PROJECT_ROOT, "data", "processed", "llm", "songs")
FAILED_LOG   = os.path.join(PROJECT_ROOT, "data", "processed", "llm", "songs_failed.jsonl")

# ── System prompt ─────────────────────────────────────────────────────────────

SYSTEM_PROMPT = """\
You are an expert formatter for a Malayalam Christian hymn book (CSI songbook).
Convert song body lines into structured HTML using ONLY this exact tag vocabulary — \
no classes, no inline styles, no markdown.

TAG VOCABULARY:
  <p><em>text</em></p>   — Raaga/Tala/rhythm notes, style/tune refs (shown in light muted color)
  <h3>label</h3>         — ONLY for named song sections: പല്ലവി, അനുപല്ലവി, ചരണം, ചരണങ്ങള്‍
  <h4>N</h4>             — ALL verse numbers, centered (both standalone "1" lines and "1. text" starts)
  <p>line<br/>...</p>    — Lyric block (multiple lines joined with <br/>)
  <p>&nbsp;</p>          — Section gap between distinct blocks

RULES:
  - Preserve all Malayalam text exactly — do not transliterate or alter
  - Raaga/Tala/rhythm lines (e.g. "ആദിതാളം", "നാട്ട-അടതാളം", contain "താളം" or "- " between words)
    → <p><em>…</em></p>  ← NOT <h3>; these are secondary metadata shown in light color
  - Style/tune refs ending with "- എന്നരീതി" or "- ഈ രീതി" → <p><em>…</em></p>
  - "പല്ലവി", "അനുപല്ലവി", "ചരണം", "ചരണങ്ങള്‍" appearing alone → <h3>…</h3>
  - Any verse number — whether "1" alone on a line, or "1. first lyric text":
      → emit <h4>N</h4> then the verse content in <p>…<br/>…</p>
      → NEVER use <b>N. </b> inside a <p>
  - Continuation lines (indented, same verse) joined with <br/>
  - Parenthetical refrain callbacks like "(ശ്രീ..)" or "(സര്‍വ്വ..)" kept inline at end of last line
  - Blank lines between distinct blocks → <p>&nbsp;</p>
  - Do NOT output leading or trailing <p>&nbsp;</p>
  - Output ONLY the HTML — no explanation, no code fences, no markdown
"""

# ── Few-shot examples ──────────────────────────────────────────────────────────
#
#  1 — Song 001: English title stripped; verses "1. 2. 3." → h4+p (centered numbers)
#  2 — Song 010: Raaga-Tala → em (NOT h3), Pallavi/Charanangal → h3, verse numbers → h4
#  3 — Song 050: Pallavi + Anupallavi + Charanangal → h3 headers; "1. 2." verses → h4+p with refrain

FEW_SHOT = [
    {
        # 001.txt — English title on line 0 (stripped by pre-processor); body has "1. 2. 3." inline verses
        "input": (
            "1. സൈന്യങ്ങളിന്‍ ദൈവം ആയ യഹോവേ\n"
            "   നീ വിശുദ്ധന്‍, നീ പരിശുദ്ധന്‍, നിര്‍മ്മലന്‍;\n"
            "   സ്വര്‍ഗ്ഗം ഭൂമി എങ്ങും നിന്‍ മഹത്വം തിങ്ങും\n"
            "   താതസുതാത്മാ ഭാഗ്യത്രിത്വമേ.\n"
            "\n"
            "2. സര്‍വ്വശക്ത ദൈവം ആയ യഹോവേ\n"
            "   നീ വിശുദ്ധന്‍, നീ പരിശുദ്ധന്‍, നിര്‍മ്മലന്‍;\n"
            "   ഇരുന്നവന്‍ നീയേ ആയിരിക്കുന്നോനേ\n"
            "   നീ വരുന്നോന്‍ താന്‍ നിത്യദൈവമേ.\n"
            "\n"
            "3. ഹാലേലൂയാ ആമേന്‍ ദൈവ പിതാവേ\n"
            "   ഹാലേലൂയാ യേശുവേ ദൈവജാതനേ\n"
            "   ഹാലേലൂയാ ആമേന്‍ ദൈവശുദ്ധാത്മാവേ\n"
            "   സ്തോത്രം സദാ ത്രിയേക ദൈവമേ"
        ),
        "output": (
            "<h4>1</h4>"
            "<p>സൈന്യങ്ങളിന്‍ ദൈവം ആയ യഹോവേ<br/>"
            "നീ വിശുദ്ധന്‍, നീ പരിശുദ്ധന്‍, നിര്‍മ്മലന്‍;<br/>"
            "സ്വര്‍ഗ്ഗം ഭൂമി എങ്ങും നിന്‍ മഹത്വം തിങ്ങും<br/>"
            "താതസുതാത്മാ ഭാഗ്യത്രിത്വമേ.</p>"
            "<p>&nbsp;</p>"
            "<h4>2</h4>"
            "<p>സര്‍വ്വശക്ത ദൈവം ആയ യഹോവേ<br/>"
            "നീ വിശുദ്ധന്‍, നീ പരിശുദ്ധന്‍, നിര്‍മ്മലന്‍;<br/>"
            "ഇരുന്നവന്‍ നീയേ ആയിരിക്കുന്നോനേ<br/>"
            "നീ വരുന്നോന്‍ താന്‍ നിത്യദൈവമേ.</p>"
            "<p>&nbsp;</p>"
            "<h4>3</h4>"
            "<p>ഹാലേലൂയാ ആമേന്‍ ദൈവ പിതാവേ<br/>"
            "ഹാലേലൂയാ യേശുവേ ദൈവജാതനേ<br/>"
            "ഹാലേലൂയാ ആമേന്‍ ദൈവശുദ്ധാത്മാവേ<br/>"
            "സ്തോത്രം സദാ ത്രിയേക ദൈവമേ</p>"
        ),
        "checks": ["<h4>1</h4>", "<h4>2</h4>", "<h4>3</h4>"],
    },
    {
        # 010.txt — Raaga-Tala → em, Pallavi/Charanangal → h3, standalone verse numbers → h4
        "input": (
            "        നാട്ട-അടതാളം\n"
            "          പല്ലവി\n"
            "സര്‍വ്വ മാനുഷരേ പരന്നു-പാടി\n"
            "സന്തോഷത്തോടു വന്ദിച്ചീടുവിന്‍\n"
            "         ചരണങ്ങള്‍\n"
            "            1\n"
            "സേവിപ്പിന്‍ ആനന്ദിച്ചവനെ-ഗീതം\n"
            "ചേലോടു പാടി തന്‍ മുന്‍-വരുവിന്‍\n"
            "സര്‍വ്വലോകനാഥന്‍ യഹോവാ-ഇതു\n"
            "ചന്തമോടാര്‍ത്തു വന്ദിച്ചീടുവിന്‍ -- (സര്‍വ്വ..)\n"
            "            2\n"
            "നമ്മുടെ നിര്‍മ്മിതാവെഹോവ-എന്നാല്‍\n"
            "നാമവനാടും ജനങ്ങളുമാം\n"
            "തന്മഹത്വത്തെ പാടി  നിങ്ങള്‍ - ഇന്നു\n"
            "തന്‍ഗൃഹവാതില്‍ക്കകത്തു വരീന്‍ -- (സര്‍വ്വ..)"
        ),
        "output": (
            "<p><em>നാട്ട-അടതാളം</em></p>"
            "<h3>പല്ലവി</h3>"
            "<p>സര്‍വ്വ മാനുഷരേ പരന്നു-പാടി<br/>"
            "സന്തോഷത്തോടു വന്ദിച്ചീടുവിന്‍</p>"
            "<p>&nbsp;</p>"
            "<h3>ചരണങ്ങള്‍</h3>"
            "<h4>1</h4>"
            "<p>സേവിപ്പിന്‍ ആനന്ദിച്ചവനെ-ഗീതം<br/>"
            "ചേലോടു പാടി തന്‍ മുന്‍-വരുവിന്‍<br/>"
            "സര്‍വ്വലോകനാഥന്‍ യഹോവാ-ഇതു<br/>"
            "ചന്തമോടാര്‍ത്തു വന്ദിച്ചീടുവിന്‍ -- (സര്‍വ്വ..)</p>"
            "<p>&nbsp;</p>"
            "<h4>2</h4>"
            "<p>നമ്മുടെ നിര്‍മ്മിതാവെഹോവ-എന്നാല്‍<br/>"
            "നാമവനാടും ജനങ്ങളുമാം<br/>"
            "തന്മഹത്വത്തെ പാടി  നിങ്ങള്‍ - ഇന്നു<br/>"
            "തന്‍ഗൃഹവാതില്‍ക്കകത്തു വരീന്‍ -- (സര്‍വ്വ..)</p>"
        ),
        "checks": ["<p><em>", "<h3>പല്ലവി</h3>", "<h4>1</h4>", "<h4>2</h4>"],
    },
    {
        # 050.txt — Pallavi + Anupallavi + Charanangal → three h3 headers; "1. 2." inline verses
        "input": (
            "                    പല്ലവി\n"
            "  ശ്രീയേശു നാഥനെന്നും - ജയമംഗളം സത്യ\n"
            "  ത്രിലോക ദേവനെന്നും - ശുഭമംഗളം\n"
            "                   അനുപല്ലവി\n"
            "  ഭൂലോകത്തെ ചമച്ച-ത്രിലോക ദൈവസുതാ\n"
            "  ക്രിസ്തേശുനാഥനെന്നും - സംസ്തുതി ഭവിക്ക ആമേന്‍ (ശ്രീ..)\n"
            "                   ചരണങ്ങള്‍\n"
            "1. ആദിയുടന്‍ അന്തവുമി-ല്ലാത്തവന്നു മംഗളം\n"
            "  ആധിയോ ദുരിതമോയില്ലാത്തവന്നു മംഗളം - ശുഭ\n"
            "  നീതിസൂര്യനായവന്നു-ജോതിര്‍മയനായവന്നു\n"
            "  ഖേദഹരം ചെയ്തവന്നു-ഭൂതലത്തിലിന്നുമെന്നും- (ശ്രീ..)\n"
            "\n"
            "2. പാതക നിവാരണന്ന-നാരതവും മംഗളം\n"
            "  നീതിയെ നിവൃത്തി ചെയ്ത-കര്‍ത്തനെന്നും മംഗളം - ശുഭ\n"
            "  ആദിമാനുഷന്‍ പിഴച്ച പാതകത്തെ ഓഹരിച്ച\n"
            "  ഭൂതലത്തിന്നായിക്കഷ്ട-വേദനയെല്ലാം സഹിച്ച- (ശ്രീ..)"
        ),
        "output": (
            "<h3>പല്ലവി</h3>"
            "<p>ശ്രീയേശു നാഥനെന്നും - ജയമംഗളം സത്യ<br/>"
            "ത്രിലോക ദേവനെന്നും - ശുഭമംഗളം</p>"
            "<p>&nbsp;</p>"
            "<h3>അനുപല്ലവി</h3>"
            "<p>ഭൂലോകത്തെ ചമച്ച-ത്രിലോക ദൈവസുതാ<br/>"
            "ക്രിസ്തേശുനാഥനെന്നും - സംസ്തുതി ഭവിക്ക ആമേന്‍ (ശ്രീ..)</p>"
            "<p>&nbsp;</p>"
            "<h3>ചരണങ്ങള്‍</h3>"
            "<h4>1</h4>"
            "<p>ആദിയുടന്‍ അന്തവുമി-ല്ലാത്തവന്നു മംഗളം<br/>"
            "ആധിയോ ദുരിതമോയില്ലാത്തവന്നു മംഗളം - ശുഭ<br/>"
            "നീതിസൂര്യനായവന്നു-ജോതിര്‍മയനായവന്നു<br/>"
            "ഖേദഹരം ചെയ്തവന്നു-ഭൂതലത്തിലിന്നുമെന്നും- (ശ്രീ..)</p>"
            "<p>&nbsp;</p>"
            "<h4>2</h4>"
            "<p>പാതക നിവാരണന്ന-നാരതവും മംഗളം<br/>"
            "നീതിയെ നിവൃത്തി ചെയ്ത-കര്‍ത്തനെന്നും മംഗളം - ശുഭ<br/>"
            "ആദിമാനുഷന്‍ പിഴച്ച പാതകത്തെ ഓഹരിച്ച<br/>"
            "ഭൂതലത്തിന്നായിക്കഷ്ട-വേദനയെല്ലാം സഹിച്ച- (ശ്രീ..)</p>"
        ),
        "checks": [
            "<h3>പല്ലവി</h3>",
            "<h3>അനുപല്ലവി</h3>",
            "<h3>ചരണങ്ങള്‍</h3>",
            "<h4>1</h4>",
            "<h4>2</h4>",
        ],
    },
]

# ── LLM helpers ───────────────────────────────────────────────────────────────

def _build_messages(song_body: str) -> list:
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    for ex in FEW_SHOT:
        messages.append({"role": "user",      "content": f"Song body:\n{ex['input']}"})
        messages.append({"role": "assistant", "content": ex["output"]})
    messages.append({"role": "user", "content": f"Song body:\n{song_body}"})
    return messages


async def generate_html_async(session: aiohttp.ClientSession, song_body: str) -> str:
    """Async LLM call — returns HTML string. Raises on persistent failure."""
    payload = {
        "model":       MODEL,
        "messages":    _build_messages(song_body),
        "max_tokens":  MAX_TOKENS,
        "temperature": 0.1,
    }
    timeout = aiohttp.ClientTimeout(total=TIMEOUT)
    last_err = None

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            async with session.post(
                f"{LLM_BASE_URL}/chat/completions",
                json=payload,
                timeout=timeout,
            ) as resp:
                if resp.status == 400:
                    raise ValueError("context_overflow")
                resp.raise_for_status()
                data = await resp.json()
                raw  = data["choices"][0]["message"]["content"].strip()
                # Strip any accidental markdown fences
                if raw.startswith("```"):
                    raw = raw.split("```")[1].lstrip("html").strip()
                if not raw.startswith("<"):
                    raise ValueError(f"bad_response: does not start with '<': {raw[:80]!r}")
                return raw

        except ValueError:
            raise  # don't retry semantic errors

        except (aiohttp.ClientError, asyncio.TimeoutError) as e:
            last_err = e
            if attempt == MAX_RETRIES:
                raise asyncio.TimeoutError("timeout") from e
            await asyncio.sleep(RETRY_DELAY)

    raise RuntimeError("unreachable")


# ── Connection / smoke test ────────────────────────────────────────────────────

async def test_connection_async() -> bool:
    print(f"Endpoint : {LLM_BASE_URL}")
    print(f"Model    : {MODEL}")
    print()

    async with aiohttp.ClientSession() as session:
        print("1. Checking server reachability...")
        try:
            async with session.get(
                f"{LLM_BASE_URL}/models",
                timeout=aiohttp.ClientTimeout(total=10),
            ) as r:
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

        print()
        print("2. Running few-shot smoke tests (concurrent)...")
        tasks   = [generate_html_async(session, ex["input"]) for ex in FEW_SHOT]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        all_pass = True

        for i, (ex, res) in enumerate(zip(FEW_SHOT, results), 1):
            if isinstance(res, Exception):
                print(f"   [{i}] ERROR: {res}")
                all_pass = False
                continue
            ok   = res.startswith("<") and all(c in res for c in ex["checks"])
            icon = "✓" if ok else "~"
            print(f"   [{i}] {icon}  starts with '<': {res.startswith('<')}")
            for check in ex["checks"]:
                present = check in res
                print(f"        {'✓' if present else '✗'}  {check!r} in output")
            if not ok:
                all_pass = False
                print(f"        Full output preview: {res[:200]!r}")

    print()
    if all_pass:
        print("   All smoke tests passed ✓")
    else:
        print("   Some checks failed — review output above.")
    return True


# ── Resume support ─────────────────────────────────────────────────────────────

def load_done_ids() -> set:
    done = set()
    if not os.path.exists(OUT_DIR):
        return done
    for fname in os.listdir(OUT_DIR):
        if fname.endswith(".html"):
            try:
                done.add(int(os.path.splitext(fname)[0]))
            except ValueError:
                pass
    return done


# ── Fallback ──────────────────────────────────────────────────────────────────

def _fallback_html(lines: list) -> str:
    """Rule-based fallback — imported from 01_songs_html.py."""
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        "songs_html",
        os.path.join(os.path.dirname(__file__), "01_songs_html.py"),
    )
    mod = importlib.util.load_from_spec(spec) if hasattr(importlib.util, 'load_from_spec') else None
    # Simple inline import via exec path
    sys.path.insert(0, os.path.dirname(__file__))
    from songs_html_import import format_song_html as _fmt  # noqa — see below
    return _fmt(lines)


def _load_format_song_html():
    """Load format_song_html from 01_songs_html.py at runtime."""
    import importlib.util
    path = os.path.join(os.path.dirname(__file__), "01_songs_html.py")
    spec = importlib.util.spec_from_file_location("_songs_html", path)
    mod  = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.format_song_html


# ── Main pipeline ─────────────────────────────────────────────────────────────

async def run_pipeline_async():
    os.makedirs(OUT_DIR, exist_ok=True)
    os.makedirs(os.path.dirname(FAILED_LOG), exist_ok=True)

    format_song_html = _load_format_song_html()

    song_files = sorted(f for f in os.listdir(SONGS_DIR) if f.endswith(".txt"))
    total      = len(song_files)
    done_ids   = load_done_ids()
    remaining  = [f for f in song_files if int(os.path.splitext(f)[0]) not in done_ids]

    print(f"Songs total   : {total}")
    print(f"Already done  : {len(done_ids)}")
    print(f"To process    : {len(remaining)}")
    print(f"Concurrency   : {MAX_WORKERS}")
    print(f"Output        : {OUT_DIR}")
    print()

    if not remaining:
        print("Nothing to do — all songs already processed.")
        return

    # Pre-load bodies
    jobs = []
    for fname in remaining:
        song_id = int(os.path.splitext(fname)[0])
        with open(os.path.join(SONGS_DIR, fname), "r", encoding="utf-8") as f:
            all_lines = [line.rstrip() for line in f.read().splitlines()]
        # Skip line 0 only if it is entirely ASCII (English-only title like "Holy, Holy, Holy!").
        # Malayalam lines on line 0 (Raaga/Tala, first lyric) must be preserved.
        if all_lines and all_lines[0].strip().isascii():
            body_lines = all_lines[1:]
        else:
            body_lines = all_lines
        body_text  = "\n".join(body_lines)
        jobs.append((song_id, body_lines, body_text))

    processed = 0
    errors    = 0
    semaphore = asyncio.Semaphore(MAX_WORKERS)
    failed_file = open(FAILED_LOG, "a", encoding="utf-8")

    async def process_one(session, song_id, body_lines, body_text):
        nonlocal processed, errors
        async with semaphore:
            try:
                html = await generate_html_async(session, body_text)
                out_path = os.path.join(OUT_DIR, f"{song_id:03d}.html")
                with open(out_path, "w", encoding="utf-8") as f:
                    f.write(html)
                processed += 1
                n_done = len(done_ids) + processed
                print(f"  [{n_done:3}/{total}] #{song_id:03d}  [llm] ✓")

            except ValueError as e:
                err_type = str(e).split(":")[0]
                entry = {
                    "id":         song_id,
                    "error":      err_type,
                    "char_count": len(body_text),
                }
                failed_file.write(json.dumps(entry, ensure_ascii=False) + "\n")
                failed_file.flush()
                errors += 1
                print(f"  #{song_id:03d}  [FAIL] {err_type}")

            except asyncio.TimeoutError:
                entry = {"id": song_id, "error": "timeout", "char_count": len(body_text)}
                failed_file.write(json.dumps(entry, ensure_ascii=False) + "\n")
                failed_file.flush()
                errors += 1
                print(f"  #{song_id:03d}  [FAIL] timeout")

            except Exception as e:
                entry = {"id": song_id, "error": f"unexpected:{e}", "char_count": len(body_text)}
                failed_file.write(json.dumps(entry, ensure_ascii=False) + "\n")
                failed_file.flush()
                errors += 1
                print(f"  #{song_id:03d}  [FAIL] {e}")

    connector = aiohttp.TCPConnector(limit=MAX_WORKERS)
    async with aiohttp.ClientSession(connector=connector) as session:
        await asyncio.gather(*[
            process_one(session, sid, bl, bt)
            for sid, bl, bt in jobs
        ])

    failed_file.close()
    print()
    print(f"✓ Done — {processed} processed, {errors} failed")
    print(f"  Output  : {OUT_DIR}")
    print(f"  Failed  : {FAILED_LOG}")


# ── Entry point ────────────────────────────────────────────────────────────────

async def main():
    test_only = "--test" in sys.argv

    print("=" * 60)
    print("llm_songs_html.py — LLM Song HTML Generator")
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
