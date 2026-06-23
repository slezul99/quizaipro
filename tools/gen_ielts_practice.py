# -*- coding: utf-8 -*-
"""Generate CONCRETE IELTS practice decks (real exam-style English MCQ, not
strategy talk) for the english-ielts collection. Output: minitopics_ielts.json
in the same shape the mini-topics seed consumes.

Run:  python tools/gen_ielts_practice.py
"""
import json
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import ai_gen  # noqa: E402

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "minitopics_ielts.json")

SCHEMA = {
    "type": "ARRAY",
    "items": {
        "type": "OBJECT",
        "properties": {
            "question": {"type": "STRING"},
            "options": {"type": "ARRAY", "items": {"type": "STRING"}},
            "correct": {"type": "INTEGER"},
        },
        "required": ["question", "options", "correct"],
    },
}

_BASE = (" Write REAL, concrete IELTS practice — actual English questions a "
         "student answers, NOT advice or strategy descriptions. Academic IELTS, "
         "Band 6.5–8.0 level. Each item: a clear question, EXACTLY 4 options, and "
         "`correct` = index 0..3 of the right one. Unambiguous, one correct "
         "answer, plausible distractors. English. Return a JSON array of 10.")

TOPICS = {
    "IELTS Reading Comprehension": (
        "Each question embeds a SHORT academic passage (2–3 sentences) followed by "
        "a comprehension question about it (main idea, detail or inference)." + _BASE),
    "IELTS Academic Synonyms": (
        "Each question: a sentence with one word in CAPS, then 'The word X is "
        "closest in meaning to:' — 4 academic synonym options." + _BASE),
    "IELTS Collocations": (
        "Each question tests a common academic collocation — complete the phrase/"
        "sentence with the word that naturally collocates, 4 options." + _BASE),
    "IELTS Paraphrasing": (
        "Each question gives one sentence and asks 'Which option best paraphrases "
        "it?' with 4 rewrites; only one keeps the exact meaning." + _BASE),
    "IELTS Grammar for High Bands": (
        "Each question tests advanced grammar used in Writing (conditionals, "
        "inversion, passive, relative clauses, articles, complex tenses) — fill the "
        "gap or pick the correct form, 4 options." + _BASE),
    "IELTS Word Formation": (
        "Each question gives a base word and a sentence with a gap; choose the "
        "correct derived form (noun/verb/adjective/adverb), 4 options." + _BASE),
}


def gen(prompt):
    out = ai_gen._call_gemini(prompt, 9000, SCHEMA, "ielts_practice")
    if not out:
        return None
    try:
        data = json.loads(out)
    except Exception:
        return None
    good = []
    for c in (data if isinstance(data, list) else []):
        q = (c.get("question") or "").strip()
        opts = c.get("options") or []
        corr = c.get("correct")
        if (q and isinstance(opts, list) and len(opts) == 4
                and all(isinstance(o, str) and o.strip() for o in opts)
                and isinstance(corr, int) and 0 <= corr <= 3):
            good.append({"q": q, "opts": [o.strip() for o in opts], "correct": corr})
    return good if len(good) >= 8 else None


def main():
    store = {}
    if os.path.exists(OUT):
        store = json.load(open(OUT, encoding="utf-8"))
    topics = store.get("english-ielts", {}).get("topics", [])
    have = {t["topic"] for t in topics}
    for name, prompt in TOPICS.items():
        if name in have:
            print(f"  {name}: skip"); continue
        cards = None
        for _ in range(2):
            cards = gen(prompt)
            if cards:
                break
        if cards:
            topics.append({"topic": name, "cards": cards[:10]})
            print(f"  {name}: {len(cards)} cards")
        else:
            print(f"  {name}: FAILED")
        store["english-ielts"] = {"title": "IELTS Preparation", "topics": topics}
        json.dump(store, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        time.sleep(2)
    print(f"[ielts] done — {len(topics)} topics")


if __name__ == "__main__":
    main()
