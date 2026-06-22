# -*- coding: utf-8 -*-
"""Generate extra mini-topic decks (10 MCQ each) for every collection of a
subject, via Gemini. Saves to minitopics_<subject>.json so a seed can replay
on prod without calling the AI.

Run:  python tools/gen_minitopics.py <subject_slug> [n_topics]
"""
import json
import os
import sqlite3
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import ai_gen  # noqa: E402

N_TOPICS = int(sys.argv[2]) if len(sys.argv) > 2 else 5

SCHEMA = {
    "type": "ARRAY",
    "items": {
        "type": "OBJECT",
        "properties": {
            "topic": {"type": "STRING"},
            "cards": {
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
            },
        },
        "required": ["topic", "cards"],
    },
}


def gen_collection(subject_title, coll_title):
    prompt = (
        f"Ты — опытный методист-предметник. Составь {N_TOPICS} разных мини-тем "
        f"для модуля «{coll_title}» предмета «{subject_title}». "
        f"Для КАЖДОЙ мини-темы дай короткое русское название (topic) и РОВНО 10 "
        f"тестовых вопросов (cards). У каждого вопроса: поле question (текст), "
        f"options (РОВНО 4 варианта-строки) и correct (индекс правильного варианта, "
        f"целое 0..3). Требования: вопросы фактически ВЕРНЫ и однозначны, "
        f"варианты правдоподобны, без повторов, разной сложности, на русском языке. "
        f"Темы должны покрывать «{coll_title}» с разных сторон. Верни JSON-массив "
        f"из {N_TOPICS} объектов."
    )
    out = ai_gen._call_gemini(prompt, 16000, SCHEMA, "minitopics")
    if not out:
        return None
    try:
        data = json.loads(out)
    except Exception:
        return None
    if not isinstance(data, list):
        return None
    valid = []
    for t in data:
        topic = (t.get("topic") or "").strip()
        good = []
        for c in (t.get("cards") or []):
            q = (c.get("question") or "").strip()
            opts = c.get("options") or []
            corr = c.get("correct")
            if (q and isinstance(opts, list) and len(opts) == 4
                    and all(isinstance(o, str) and o.strip() for o in opts)
                    and isinstance(corr, int) and 0 <= corr <= 3):
                good.append({"q": q, "opts": [o.strip() for o in opts], "correct": corr})
        if topic and len(good) >= 8:
            valid.append({"topic": topic, "cards": good[:10]})
    return valid or None


def main():
    if len(sys.argv) < 2:
        print("usage: gen_minitopics.py <subject_slug> [n_topics]"); return
    subj_slug = sys.argv[1]
    conn = sqlite3.connect("quizpro.db"); conn.row_factory = sqlite3.Row
    subj = conn.execute("SELECT id,title_ru FROM mp_subjects WHERE slug=?",
                        (subj_slug,)).fetchone()
    if not subj:
        print("no subject"); return
    colls = conn.execute("""SELECT slug,title_ru FROM collections
        WHERE subject_id=? AND is_active=1 ORDER BY sort_order""",
        (subj["id"],)).fetchall()
    conn.close()

    path = f"minitopics_{subj_slug}.json"
    store = {}
    if os.path.exists(path):
        store = json.load(open(path, encoding="utf-8"))

    for co in colls:
        if co["slug"] in store:
            print(f"  {co['slug']}: already done, skip"); continue
        topics = None
        for attempt in range(2):
            topics = gen_collection(subj["title_ru"], co["title_ru"])
            if topics:
                break
        if topics:
            store[co["slug"]] = {"title": co["title_ru"], "topics": topics}
            n = sum(len(t["cards"]) for t in topics)
            print(f"  {co['slug']}: {len(topics)} topics, {n} cards")
            json.dump(store, open(path, "w", encoding="utf-8"),
                      ensure_ascii=False, indent=1)
        else:
            print(f"  {co['slug']}: FAILED")
    print(f"[minitopics] {subj_slug}: {len(store)} collections in {path}")


if __name__ == "__main__":
    main()
