"""One-off: AI-translate every PUBLIC marketplace card into ru/en/uz and fill
front/back/note (default = ru) + *_en / *_uz. Writes results both to the local
DB and to marketplace_translations.json (keyed by a stable english/source key)
so a seed can replay them on prod without calling the AI there.

Run:  python translate_marketplace.py [--limit N] [--dry]
Idempotent: skips cards that already have front_uz filled.
"""
import json
import sqlite3
import sys

import ai_gen

LIMIT = None
DRY = "--dry" in sys.argv
if "--limit" in sys.argv:
    LIMIT = int(sys.argv[sys.argv.index("--limit") + 1])

_SCHEMA = {
    "type": "array",
    "items": {
        "type": "object",
        "properties": {
            lang: {
                "type": "object",
                "properties": {
                    "front": {"type": "string"},
                    "back": {"type": "string"},
                    "note": {"type": "string"},
                },
                "required": ["front", "back", "note"],
            } for lang in ("ru", "en", "uz")
        },
        "required": ["ru", "en", "uz"],
    },
}

_PROMPT_HEAD = (
    "You translate quiz flashcards into three languages: ru (Russian), "
    "en (English), uz (Uzbek, Latin script). For EACH card return all three.\n"
    "RULES:\n"
    "1. Keep multiple-choice option markers EXACTLY: 'A)', 'B)', 'C)', 'D)' and "
    "the same order; keep the correct-answer letter in `back` unchanged "
    "(e.g. 'B) ...') — translate only the human text after the marker.\n"
    "2. Preserve line breaks (\\n).\n"
    "3. For ENGLISH-language-learning cards, translate the question/instruction "
    "but KEEP the English example words/options in English (they are what's "
    "being learned).\n"
    "4. If a field is empty, return an empty string for it.\n"
    "Return a JSON array in the SAME order as the input cards.\n\nCARDS:\n"
)

BATCH = 8


def translate_batch(cards):
    items = [{"front": c["front"] or "", "back": c["back"] or "",
              "note": c["note"] or ""} for c in cards]
    prompt = _PROMPT_HEAD + json.dumps(items, ensure_ascii=False)
    out = ai_gen._call_gemini(prompt, 8000, _SCHEMA, "mk_translate")
    if not out:
        return None
    try:
        data = json.loads(out)
    except Exception:
        return None
    if not isinstance(data, list) or len(data) != len(cards):
        return None
    return data


def main():
    conn = sqlite3.connect("quizpro.db")
    conn.row_factory = sqlite3.Row
    rows = conn.execute(
        """SELECT crd.id id, crd.front front, crd.back back, crd.note note
           FROM cards crd JOIN decks d ON d.id = crd.deck_id
           WHERE d.is_public = 1
             AND (crd.front_uz IS NULL OR crd.front_uz = '')
           ORDER BY crd.id"""
    ).fetchall()
    cards = [dict(r) for r in rows]
    if LIMIT:
        cards = cards[:LIMIT]
    print(f"[translate] {len(cards)} cards to translate")

    try:
        store = json.load(open("marketplace_translations.json", encoding="utf-8"))
    except Exception:
        store = {}

    done = 0
    for i in range(0, len(cards), BATCH):
        chunk = cards[i:i + BATCH]
        data = translate_batch(chunk)
        if data is None:
            print(f"  batch {i}: FAILED (retry singly)")
            data = []
            for c in chunk:
                d = translate_batch([c])
                data.append(d[0] if d else None)
        for c, tr in zip(chunk, data):
            if not tr:
                print(f"   card {c['id']}: no translation, skipped")
                continue
            def pick(lang, field, fallback):
                v = (tr.get(lang) or {}).get(field)
                return v if (v is not None and v != "") else fallback
            ru = {f: pick("ru", f, c[f] or "") for f in ("front", "back", "note")}
            en = {f: pick("en", f, c[f] or "") for f in ("front", "back", "note")}
            uz = {f: pick("uz", f, c[f] or "") for f in ("front", "back", "note")}
            # store keyed by original english/source front for prod replay
            store[c["front"]] = {"ru": ru, "en": en, "uz": uz}
            if not DRY:
                conn.execute(
                    """UPDATE cards SET front=?, back=?, note=?,
                         front_en=?, back_en=?, note_en=?,
                         front_uz=?, back_uz=?, note_uz=? WHERE id=?""",
                    (ru["front"], ru["back"], ru["note"],
                     en["front"], en["back"], en["note"],
                     uz["front"], uz["back"], uz["note"], c["id"]))
            done += 1
        if not DRY:
            conn.commit()
        json.dump(store, open("marketplace_translations.json", "w", encoding="utf-8"),
                  ensure_ascii=False, indent=1)
        print(f"  progress: {done}/{len(cards)}")
    conn.close()
    print(f"[translate] DONE — {done} cards, store has {len(store)} entries")


if __name__ == "__main__":
    main()
