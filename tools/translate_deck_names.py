# -*- coding: utf-8 -*-
"""Translate marketplace deck/topic NAMES (the titles shown on cards) from
Russian to en/uz and store them in deck_name_translations.json, keyed by the
Russian name, so seed_deck_name_i18n.py can replay onto decks.name_en/name_uz.

Run:  python tools/translate_deck_names.py
"""
import json
import os
import sqlite3
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import ai_gen  # noqa: E402

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "deck_name_translations.json")
BATCH = 25
SCHEMA = {
    "type": "ARRAY",
    "items": {
        "type": "OBJECT",
        "properties": {"en": {"type": "STRING"}, "uz": {"type": "STRING"}},
        "required": ["en", "uz"],
    },
}


def translate(names):
    prompt = (
        "Translate these short quiz-deck / topic titles into English (en) and "
        "Uzbek in Latin script (uz). They are study topics. Keep titles concise "
        "and natural; keep English terms that are already English (e.g. 'Present "
        "Perfect', 'If clauses'); translate the rest. Return a JSON array in the "
        "SAME order, one {en, uz} per title.\n\nTITLES:\n"
        + json.dumps(names, ensure_ascii=False)
    )
    out = ai_gen._call_gemini(prompt, 8000, SCHEMA, "deck_names")
    if not out:
        return None
    try:
        data = json.loads(out)
    except Exception:
        return None
    if not isinstance(data, list) or len(data) != len(names):
        return None
    return data


def main():
    conn = sqlite3.connect("quizpro.db")
    rows = conn.execute("""
        SELECT DISTINCT d.name FROM decks d
        JOIN collection_decks cd ON cd.deck_id=d.id
        JOIN collections co ON co.id=cd.collection_id
        WHERE co.is_active=1 AND (d.name_en IS NULL OR d.name_en='')
          AND d.name IS NOT NULL AND d.name<>''
    """).fetchall()
    conn.close()
    names = [r[0] for r in rows]
    print(f"[deck_names] {len(names)} names to translate")

    store = {}
    if os.path.exists(OUT):
        store = json.load(open(OUT, encoding="utf-8"))
    todo = [n for n in names if n not in store]
    print(f"[deck_names] {len(todo)} not yet in store")

    for i in range(0, len(todo), BATCH):
        chunk = todo[i:i + BATCH]
        data = translate(chunk)
        if not data:
            # retry once smaller
            data = []
            for n in chunk:
                d = translate([n])
                data.append(d[0] if d else {"en": n, "uz": n})
        for n, tr in zip(chunk, data):
            store[n] = {"en": (tr.get("en") or n).strip(),
                        "uz": (tr.get("uz") or n).strip()}
        json.dump(store, open(OUT, "w", encoding="utf-8"),
                  ensure_ascii=False, indent=1)
        print(f"  {min(i+BATCH, len(todo))}/{len(todo)}")
    print(f"[deck_names] done — {len(store)} entries")


if __name__ == "__main__":
    main()
