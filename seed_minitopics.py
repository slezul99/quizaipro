# -*- coding: utf-8 -*-
"""Create mini-topic decks (10 MCQ each) for collections, from
minitopics_<subject>.json files produced by tools/gen_minitopics.py.

Slug-based + idempotent: a topic deck is matched by (collection, name), so the
same topic name in two collections yields two separate decks, and re-runs don't
duplicate. Cards are inserted in the canonical MCQ format (question in `front`,
lettered options in `note`, correct answer in `back`).
"""
import glob
import json
import os

import db

conn = db.get_conn()
c = conn.cursor()

_sys = c.execute("SELECT id FROM users WHERE username='quizaipro_system'").fetchone()
if not _sys:
    print("[minitopics] system user missing — skip"); conn.close(); raise SystemExit
OWNER = _sys[0]


def get_or_create_topic_deck(coll_id, name, icon):
    r = c.execute("""SELECT d.id FROM decks d
        JOIN collection_decks cd ON cd.deck_id=d.id
        WHERE cd.collection_id=? AND d.name=?""", (coll_id, name)).fetchone()
    if r:
        return r[0]
    c.execute("""INSERT INTO decks (owner_id,name,icon,description,is_public,
                 deck_type,created_via,has_mcq,has_terms)
                 VALUES (?,?,?,?,1,'mcq','seed',1,0) RETURNING id""",
              (OWNER, name, icon, ""))
    return c.fetchone()[0]


_n_decks = 0
_n_cards = 0
_dir = os.path.dirname(os.path.abspath(__file__))
for path in sorted(glob.glob(os.path.join(_dir, "minitopics_*.json"))):
    try:
        store = json.load(open(path, encoding="utf-8"))
    except Exception as e:
        print("[minitopics] bad file", path, e); continue
    for coll_slug, info in store.items():
        row = c.execute("SELECT id,icon FROM collections WHERE slug=?",
                        (coll_slug,)).fetchone()
        if not row:
            continue
        coll_id, coll_icon = row[0], (row[1] or "📝")
        for ti, topic in enumerate(info.get("topics", [])):
            name = (topic.get("topic") or "").strip()
            cards = topic.get("cards") or []
            if not name or len(cards) < 8:
                continue
            did = get_or_create_topic_deck(coll_id, name, coll_icon)
            c.execute("""INSERT OR IGNORE INTO collection_decks
                (collection_id,deck_id,sort_order) VALUES (?,?,?)""",
                (coll_id, did, 100 + ti))
            if c.execute("SELECT COUNT(*) FROM cards WHERE deck_id=?",
                         (did,)).fetchone()[0] == 0:
                for card in cards:
                    opts = card["opts"]
                    ci = card["correct"]
                    note = "\n".join(f"{chr(65+i)}) {o}" for i, o in enumerate(opts))
                    back = f"{chr(65+ci)}) {opts[ci]}"
                    c.execute("INSERT INTO cards (deck_id,front,back,note) VALUES (?,?,?,?)",
                              (did, card["q"], back, note))
                    _n_cards += 1
                _n_decks += 1

conn.commit()
conn.close()
print(f"[minitopics] created {_n_decks} decks, {_n_cards} cards")
