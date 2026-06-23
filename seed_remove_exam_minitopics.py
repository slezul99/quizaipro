# -*- coding: utf-8 -*-
"""Remove the auto-generated mini-topic decks from the IELTS / TOEFL collections.

These came out as generic "exam strategy" tests rather than concrete practice,
so they're deleted (the original curated decks in those collections are kept).
Matched by collection slug + deck name → safe across environments; idempotent.
"""
import db

conn = db.get_conn()
c = conn.cursor()

REMOVE = {
    "english-ielts": [
        "Аудирование: стратегии и типы заданий",
        "Чтение: академические тексты и поиск информации",
        "Письменная часть: структура и критерии",
        "Устная часть: формат и беглость речи",
        "Лексика и грамматика для высокого балла",
    ],
    "english-toefl": [
        "TOEFL Reading: Стратегии и типы вопросов",
        "TOEFL Listening: Понимание на слух и конспектирование",
        "TOEFL Speaking: Структура устных ответов",
        "TOEFL Writing: Интегрированное и академическое эссе",
        "TOEFL Grammar & Vocabulary: Академическая лексика и грамматика",
    ],
}

_ids = set()
for slug, names in REMOVE.items():
    row = c.execute("SELECT id FROM collections WHERE slug=?", (slug,)).fetchone()
    if not row:
        continue
    coll_id = row[0]
    for nm in names:
        for r in c.execute(
            """SELECT d.id FROM decks d
               JOIN collection_decks cd ON cd.deck_id=d.id
               WHERE cd.collection_id=? AND d.name=? AND d.created_via='seed'""",
            (coll_id, nm)):
            _ids.add(r[0])

for did in _ids:
    c.execute("DELETE FROM user_card_progress WHERE card_id IN (SELECT id FROM cards WHERE deck_id=?)", (did,))
    c.execute("DELETE FROM reviews WHERE card_id IN (SELECT id FROM cards WHERE deck_id=?)", (did,))
    c.execute("DELETE FROM cards WHERE deck_id=?", (did,))
    c.execute("DELETE FROM collection_decks WHERE deck_id=?", (did,))
    c.execute("DELETE FROM decks WHERE id=?", (did,))

conn.commit()
conn.close()
print(f"[remove_exam_minitopics] removed {len(_ids)} decks")
