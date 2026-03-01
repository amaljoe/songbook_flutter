#!/usr/bin/env python3
"""
llm_liturgy_html.py — LLM-based liturgy HTML generation.

Uses a self-hosted google/gemma-3-27b-it (OpenAI-compatible API) with
few-shot prompting to generate structured HTML for each liturgy section.

Output  : data/processed/llm/liturgy/XXX.html
Failed  : data/processed/llm/liturgy_failed.jsonl

────────────────────────────────────────────────────────────────────────────
SETUP — forward the remote port before running:
    ssh -L 8000:localhost:8000 <user>@cn14-dgx -p 4422

Then run:
    python3 scripts/db/llm_liturgy_html.py          # full pipeline
    python3 scripts/db/llm_liturgy_html.py --test   # smoke test only
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
TIMEOUT      = 180   # liturgy sections can be large
MAX_RETRIES  = 3
RETRY_DELAY  = 2
MAX_WORKERS  = 32    # fewer concurrent — each request is much larger
MAX_TOKENS   = 4096

PROJECT_ROOT  = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LITURGY_DIR   = os.path.join(PROJECT_ROOT, "data", "txt", "liturgy")
OUT_DIR       = os.path.join(PROJECT_ROOT, "data", "processed", "llm", "liturgy")
FAILED_LOG    = os.path.join(PROJECT_ROOT, "data", "processed", "llm", "liturgy_failed.jsonl")

# ── System prompt ─────────────────────────────────────────────────────────────

SYSTEM_PROMPT = """\
You are an expert formatter for a Malayalam Christian liturgy book (CSI order of service).
Convert liturgy body lines into structured HTML using ONLY this exact tag vocabulary — \
no classes, no inline styles, no markdown.

TAG VOCABULARY:
  <h3>I</h3>                            — Roman numeral section header (I, II, III …)
  <p><em>[Speaker]</em>: text</p>       — Priest / presbyter / leader / joint speaker line
  <p><strong>[Speaker]</strong>: text</p> — Congregation / people / ജനങ്ങള്‍ line
  <p><em>[rubric text]</em></p>         — Stage direction / instruction with NO colon following
  <p>N. text</p>                        — Numbered item within a prayer (1. 2. … 10.)
  <p>text</p>                           — Prose / prayer paragraph
  <p>&nbsp;</p>                         — Section gap between distinct blocks

SPEAKER CLASSIFICATION:
  Priest / leader → em:      [പ്രസ്ബിറ്റര്‍], [ഡീക്കന്‍], [മുഖ്യ ശുശ്രൂഷകന്‍], [ബിഷപ്പ്]
  Congregation → strong:     [ജനങ്ങള്‍], [ജനം], [എല്ലാവരും] (all-together = congregation-class)
  Joint (…ഉം …ഉം) → em:     [പ്രസ്ബിറ്ററും ജനങ്ങളും] and similar joint speakers

RULES:
  - Preserve all Malayalam text exactly — do not alter
  - A line matching /^[IVX]+$/ alone → <h3>text</h3>
  - [Speaker]: text — classify speaker → wrap label in <em> or <strong>, keep ": text" after
  - [Speaker]: alone (no text on same line) → <p><em>[Speaker]</em>:</p>
  - [rubric] with NO colon following → <p><em>[rubric]</em></p>
  - Numbered items "N. text" → <p>N. text</p> (inline, not verse-style)
  - Blank lines → <p>&nbsp;</p>; do not emit leading or trailing spacers
  - Output ONLY the HTML — no explanation, no code fences, no markdown
"""

# ── Few-shot examples ──────────────────────────────────────────────────────────
#
#  1 — Liturgy 030: rubrics + mixed speakers (em rubrics, em/strong/joint speakers)
#  2 — Liturgy 005: Roman numeral section + litany (priest em vs congregation strong)
#  3 — Liturgy 010: joint speaker + numbered list (Ten Commandments)

FEW_SHOT = [
    {
        # 030.txt body — prayer with rubrics and speaker differentiation
        "input": (
            "കര്‍ത്താവിന്‍റെ പ്രാര്‍ത്ഥന:\n"
            "[ഇപ്പോള്‍ പ്രസ്ബിറ്റര്‍ മുട്ടുകുത്തുന്നു.]\n"
            "നമ്മുടെ രക്ഷിതാവായ യേശുക്രിസ്തു പഠിപ്പിച്ചതുപോലെ നാം പ്രാര്‍ത്ഥിക്കുന്നത്:-\n"
            "സ്വര്‍ഗ്ഗസ്ഥനായ ഞങ്ങളുടെ പിതാവേ, തിരുനാമം വിശുദ്ധീകരിക്കപ്പെടേണമേ.\n"
            "\n"
            "[മുട്ടിന്മേല്‍ എല്ലാരും മൗനമായിരിക്കുന്നു.]\n"
            "[എല്ലാരും]: കൃപാലുവായ കര്‍ത്താവേ, ഞങ്ങള്‍ അവിടുത്തെ കരുണയിലല്ലാതെ വരുവാന്‍ തുനിയുന്നില്ല.\n"
            "[പ്രസ്ബിറ്റര്‍]: നാം ഈ അപ്പം നുറുക്കുമ്പോള്‍ ക്രിസ്തുവിന്‍റെ ശരീരത്തിന്‍റെ പങ്കാളികളാകുന്നുവല്ലോ.\n"
            "[ജനങ്ങള്‍]: കരുണയുള്ള കര്‍ത്താവേ, ഞങ്ങളെ അങ്ങയുടെ ജീവന്‍റെ പങ്കാളികളാക്കേണമേ."
        ),
        "output": (
            "<p>കര്‍ത്താവിന്‍റെ പ്രാര്‍ത്ഥന:</p>"
            "<p><em>[ഇപ്പോള്‍ പ്രസ്ബിറ്റര്‍ മുട്ടുകുത്തുന്നു.]</em></p>"
            "<p>നമ്മുടെ രക്ഷിതാവായ യേശുക്രിസ്തു പഠിപ്പിച്ചതുപോലെ നാം പ്രാര്‍ത്ഥിക്കുന്നത്:-</p>"
            "<p>സ്വര്‍ഗ്ഗസ്ഥനായ ഞങ്ങളുടെ പിതാവേ, തിരുനാമം വിശുദ്ധീകരിക്കപ്പെടേണമേ.</p>"
            "<p>&nbsp;</p>"
            "<p><em>[മുട്ടിന്മേല്‍ എല്ലാരും മൗനമായിരിക്കുന്നു.]</em></p>"
            "<p><em>[എല്ലാരും]</em>: കൃപാലുവായ കര്‍ത്താവേ, ഞങ്ങള്‍ അവിടുത്തെ കരുണയിലല്ലാതെ വരുവാന്‍ തുനിയുന്നില്ല.</p>"
            "<p><em>[പ്രസ്ബിറ്റര്‍]</em>: നാം ഈ അപ്പം നുറുക്കുമ്പോള്‍ ക്രിസ്തുവിന്‍റെ ശരീരത്തിന്‍റെ പങ്കാളികളാകുന്നുവല്ലോ.</p>"
            "<p><strong>[ജനങ്ങള്‍]</strong>: കരുണയുള്ള കര്‍ത്താവേ, ഞങ്ങളെ അങ്ങയുടെ ജീവന്‍റെ പങ്കാളികളാക്കേണമേ.</p>"
        ),
        "checks": [
            "<p><em>[ഇപ്പോള്‍ പ്രസ്ബിറ്റര്‍ മുട്ടുകുത്തുന്നു.]</em></p>",
            "<p><em>[പ്രസ്ബിറ്റര്‍]</em>:",
            "<p><strong>[ജനങ്ങള്‍]</strong>:",
        ],
    },
    {
        # 005.txt body — litany with Roman numeral section + priest/congregation alternation
        "input": (
            "[താഴെ വരുന്ന ലിത്താനികളില്‍ ഏതെങ്കിലും ഒന്നു ഉപയോഗിക്കണം]\n"
            "[പ്രസ്ബിറ്റര്‍]: നമുക്കു ദൈവത്തെ മഹത്വപ്പെടുത്താം.\n"
            "\n"
            "           I\n"
            "[പ്രസ്ബിറ്റര്‍]: ദൈവമേ, സീയോനില്‍ സ്തുതി അങ്ങേയ്ക്കു യോഗ്യം; "
            "അങ്ങേയ്ക്കു തന്നെ നേര്‍ച്ച കഴിക്കുന്നു.\n"
            "[ജനങ്ങള്‍]: പ്രാര്‍ത്ഥന കേള്‍ക്കുന്ന ദൈവമേ, സകല ജഡവും "
            "അങ്ങയുടെ അടുക്കലേയ്ക്കു വരുന്നു.\n"
            "[പ്രസ്ബിറ്റര്‍]: യഹോവയുടെ വാതിലുകളില്‍ സ്തോത്രത്തോടും "
            "അവിടുത്തെ പ്രാകാരങ്ങളില്‍ സ്തുതിയോടും കൂടെ വരുവിന്‍.\n"
            "[ജനങ്ങള്‍]: യഹോവ നല്ലവനല്ലോ, അവിടുത്തെ ദയ എന്നേയ്ക്കുമുള്ളത്."
        ),
        "output": (
            "<p><em>[താഴെ വരുന്ന ലിത്താനികളില്‍ ഏതെങ്കിലും ഒന്നു ഉപയോഗിക്കണം]</em></p>"
            "<p><em>[പ്രസ്ബിറ്റര്‍]</em>: നമുക്കു ദൈവത്തെ മഹത്വപ്പെടുത്താം.</p>"
            "<p>&nbsp;</p>"
            "<h3>I</h3>"
            "<p><em>[പ്രസ്ബിറ്റര്‍]</em>: ദൈവമേ, സീയോനില്‍ സ്തുതി അങ്ങേയ്ക്കു യോഗ്യം; "
            "അങ്ങേയ്ക്കു തന്നെ നേര്‍ച്ച കഴിക്കുന്നു.</p>"
            "<p><strong>[ജനങ്ങള്‍]</strong>: പ്രാര്‍ത്ഥന കേള്‍ക്കുന്ന ദൈവമേ, സകല ജഡവും "
            "അങ്ങയുടെ അടുക്കലേയ്ക്കു വരുന്നു.</p>"
            "<p><em>[പ്രസ്ബിറ്റര്‍]</em>: യഹോവയുടെ വാതിലുകളില്‍ സ്തോത്രത്തോടും "
            "അവിടുത്തെ പ്രാകാരങ്ങളില്‍ സ്തുതിയോടും കൂടെ വരുവിന്‍.</p>"
            "<p><strong>[ജനങ്ങള്‍]</strong>: യഹോവ നല്ലവനല്ലോ, അവിടുത്തെ ദയ എന്നേയ്ക്കുമുള്ളത്.</p>"
        ),
        "checks": [
            "<h3>I</h3>",
            "<p><em>[പ്രസ്ബിറ്റര്‍]</em>:",
            "<p><strong>[ജനങ്ങള്‍]</strong>:",
        ],
    },
    {
        # 010.txt body — Ten Commandments: joint speaker + numbered list
        "input": (
            "പത്തു കല്‍പനകള്‍\n"
            "  നമ്മുടെ ദൈവമായ കര്‍ത്താവ് കൊടുത്തു പറഞ്ഞതെന്തെന്നാല്‍:-\n"
            "[പ്രസ്ബിറ്ററും ജനങ്ങളും]:\n"
            "1. യഹോവയായ ഞാന്‍ നിന്‍റെ ദൈവമാകുന്നു; "
            "എന്‍റെ മുമ്പാകെ അന്യദൈവങ്ങള്‍ നിനക്കുണ്ടായിരിക്കരുത്.\n"
            "2. നിനക്കായി ഒരു വിഗ്രഹത്തെ ഉണ്ടാക്കി നീ അതിനെ കുമ്പിടരുത്.\n"
            "3. നിന്‍റെ ദൈവമായ യഹോവയുടെ നാമം വൃഥാ എടുക്കരുത്.\n"
            "  പ്രാര്‍ത്ഥന\n"
            "[എല്ലാവരും]: ദൈവമേ, ഈ കല്‍പനകള്‍ അനുസരിക്കാന്‍ സഹായിക്കേണമേ. -ആമേന്‍."
        ),
        "output": (
            "<p>പത്തു കല്‍പനകള്‍</p>"
            "<p>നമ്മുടെ ദൈവമായ കര്‍ത്താവ് കൊടുത്തു പറഞ്ഞതെന്തെന്നാല്‍:-</p>"
            "<p><em>[പ്രസ്ബിറ്ററും ജനങ്ങളും]</em>:</p>"
            "<p>1. യഹോവയായ ഞാന്‍ നിന്‍റെ ദൈവമാകുന്നു; "
            "എന്‍റെ മുമ്പാകെ അന്യദൈവങ്ങള്‍ നിനക്കുണ്ടായിരിക്കരുത്.</p>"
            "<p>2. നിനക്കായി ഒരു വിഗ്രഹത്തെ ഉണ്ടാക്കി നീ അതിനെ കുമ്പിടരുത്.</p>"
            "<p>3. നിന്‍റെ ദൈവമായ യഹോവയുടെ നാമം വൃഥാ എടുക്കരുത്.</p>"
            "<p>പ്രാര്‍ത്ഥന</p>"
            "<p><em>[എല്ലാവരും]</em>: ദൈവമേ, ഈ കല്‍പനകള്‍ അനുസരിക്കാന്‍ സഹായിക്കേണമേ. -ആമേന്‍.</p>"
        ),
        "checks": [
            "<p><em>[പ്രസ്ബിറ്ററും ജനങ്ങളും]</em>:</p>",
            "<p>1.",
            "<p>2.",
            "<p>3.",
        ],
    },
]

# ── LLM helpers ───────────────────────────────────────────────────────────────

def _build_messages(body: str) -> list:
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    for ex in FEW_SHOT:
        messages.append({"role": "user",      "content": f"Liturgy body:\n{ex['input']}"})
        messages.append({"role": "assistant", "content": ex["output"]})
    messages.append({"role": "user", "content": f"Liturgy body:\n{body}"})
    return messages


async def generate_html_async(session: aiohttp.ClientSession, body: str) -> str:
    """Async LLM call — returns HTML string. Raises on persistent failure."""
    payload = {
        "model":       MODEL,
        "messages":    _build_messages(body),
        "max_tokens":  MAX_TOKENS,
        "temperature": 0.1,
    }
    timeout = aiohttp.ClientTimeout(total=TIMEOUT)

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
                if raw.startswith("```"):
                    raw = raw.split("```")[1].lstrip("html").strip()
                if not raw.startswith("<"):
                    raise ValueError(f"bad_response: does not start with '<': {raw[:80]!r}")
                return raw

        except ValueError:
            raise

        except (aiohttp.ClientError, asyncio.TimeoutError) as e:
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
                print(f"        {'✓' if present else '✗'}  {check!r}")
            if not ok:
                all_pass = False
                print(f"        Preview: {res[:200]!r}")

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

def _load_format_liturgy_html():
    import importlib.util
    path = os.path.join(os.path.dirname(__file__), "02_liturgy_html.py")
    spec = importlib.util.spec_from_file_location("_liturgy_html", path)
    mod  = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.format_liturgy_html


# ── Main pipeline ─────────────────────────────────────────────────────────────

async def run_pipeline_async():
    os.makedirs(OUT_DIR, exist_ok=True)
    os.makedirs(os.path.dirname(FAILED_LOG), exist_ok=True)

    format_liturgy_html = _load_format_liturgy_html()

    liturgy_files = sorted(f for f in os.listdir(LITURGY_DIR) if f.endswith(".txt"))
    total         = len(liturgy_files)
    done_ids      = load_done_ids()
    remaining     = [f for f in liturgy_files if int(os.path.splitext(f)[0]) not in done_ids]

    print(f"Liturgy total : {total}")
    print(f"Already done  : {len(done_ids)}")
    print(f"To process    : {len(remaining)}")
    print(f"Concurrency   : {MAX_WORKERS}")
    print(f"Output        : {OUT_DIR}")
    print()

    if not remaining:
        print("Nothing to do — all liturgy sections already processed.")
        return

    jobs = []
    for fname in remaining:
        page_id = int(os.path.splitext(fname)[0])
        with open(os.path.join(LITURGY_DIR, fname), "r", encoding="utf-8") as f:
            all_lines = [line.rstrip() for line in f.read().splitlines()]
        body_lines = all_lines[1:] if len(all_lines) > 1 else []
        body_text  = "\n".join(body_lines)
        jobs.append((page_id, body_lines, body_text))

    processed   = 0
    errors      = 0
    semaphore   = asyncio.Semaphore(MAX_WORKERS)
    failed_file = open(FAILED_LOG, "a", encoding="utf-8")

    async def process_one(session, page_id, body_lines, body_text):
        nonlocal processed, errors
        async with semaphore:
            try:
                html = await generate_html_async(session, body_text)
                out_path = os.path.join(OUT_DIR, f"{page_id:03d}.html")
                with open(out_path, "w", encoding="utf-8") as f:
                    f.write(html)
                processed += 1
                n_done = len(done_ids) + processed
                print(f"  [{n_done:3}/{total}] #{page_id:03d}  [llm] ✓")

            except ValueError as e:
                err_type = str(e).split(":")[0]
                entry = {
                    "id":         page_id,
                    "error":      err_type,
                    "char_count": len(body_text),
                }
                failed_file.write(json.dumps(entry, ensure_ascii=False) + "\n")
                failed_file.flush()
                errors += 1
                print(f"  #{page_id:03d}  [FAIL] {err_type}")

            except asyncio.TimeoutError:
                entry = {"id": page_id, "error": "timeout", "char_count": len(body_text)}
                failed_file.write(json.dumps(entry, ensure_ascii=False) + "\n")
                failed_file.flush()
                errors += 1
                print(f"  #{page_id:03d}  [FAIL] timeout")

            except Exception as e:
                entry = {"id": page_id, "error": f"unexpected:{e}", "char_count": len(body_text)}
                failed_file.write(json.dumps(entry, ensure_ascii=False) + "\n")
                failed_file.flush()
                errors += 1
                print(f"  #{page_id:03d}  [FAIL] {e}")

    connector = aiohttp.TCPConnector(limit=MAX_WORKERS)
    async with aiohttp.ClientSession(connector=connector) as session:
        await asyncio.gather(*[
            process_one(session, pid, bl, bt)
            for pid, bl, bt in jobs
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
    print("llm_liturgy_html.py — LLM Liturgy HTML Generator")
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
