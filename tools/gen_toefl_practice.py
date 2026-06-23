# -*- coding: utf-8 -*-
"""Generate CONCRETE IELTS practice decks (real exam-style English MCQ, not
strategy talk) for the english-ielts collection. Output: minitopics_toefl.json
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
                   "minitopics_toefl.json")

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
    "TOEFL Reading Comprehension": (
        "Each question embeds a SHORT academic passage (2-3 sentences) followed by "
        "a multiple-choice question about it (main idea, detail, inference or "
        "purpose), TOEFL iBT Reading style." + _BASE),
    "TOEFL Vocabulary in Context": (
        "Each question shows a sentence from an academic passage with one word in "
        "CAPS, then 'The word X is closest in meaning to:' with 4 options — the "
        "classic TOEFL vocabulary-in-context item." + _BASE),
    "TOEFL Listening Comprehension": (
        "Each question gives a SHORT transcript of a campus conversation or a "
        "lecture excerpt (2-3 sentences), then a comprehension question about gist, "
        "detail or the speaker's attitude, 4 options." + _BASE),
    "TOEFL Sentence Simplification": (
        "Each question shows one complex sentence and asks 'Which sentence best "
        "expresses the essential information?' with 4 rewrites; only one keeps the "
        "core meaning without losing or changing it." + _BASE),
    "TOEFL Grammar & Structure": (
        "Each question tests academic grammar and sentence structure (subject-verb "
        "agreement, parallelism, clauses, word order) — fill the gap or pick the "
        "correct/most appropriate option, 4 choices." + _BASE),
    "TOEFL Academic Vocabulary": (
        "Each question tests high-frequency academic vocabulary (Academic Word "
        "List): a sentence with a gap or a definition, choose the best academic "
        "word, 4 options." + _BASE),
}


def gen(prompt):
    out = ai_gen._call_gemini(prompt, 9000, SCHEMA, "toefl_practice")
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
    topics = store.get("english-toefl", {}).get("topics", [])
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
        store["english-toefl"] = {"title": "TOEFL Preparation", "topics": topics}
        json.dump(store, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        time.sleep(2)
    print(f"[toefl] done — {len(topics)} topics")


if __name__ == "__main__":
    main()
