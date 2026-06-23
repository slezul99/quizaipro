# -*- coding: utf-8 -*-
"""Apply en/uz translations for marketplace deck/topic NAMES from
deck_name_translations.json onto decks.name_en / name_uz.

Keyed by the Russian name; idempotent (only fills rows still lacking name_en).
Runs at startup, guarded by a migration key in app.py.
"""
import json
import os

import db

conn = db.get_conn()
c = conn.cursor()

_path = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                     "deck_name_translations.json")
try:
    _store = json.load(open(_path, encoding="utf-8"))
except Exception as e:  # pragma: no cover
    print("[deck_name_i18n] file unavailable:", e)
    _store = {}

_n = 0
for _ru, _tr in _store.items():
    cur = c.execute(
        """UPDATE decks SET name_en=?, name_uz=?
           WHERE name=? AND (name_en IS NULL OR name_en='')""",
        ((_tr.get("en") or _ru), (_tr.get("uz") or _ru), _ru))
    _n += cur.rowcount
conn.commit()
conn.close()
print(f"[deck_name_i18n] applied to {_n} decks ({len(_store)} entries)")
