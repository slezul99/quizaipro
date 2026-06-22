"""Apply AI-generated marketplace card translations (ru/en/uz) from
marketplace_translations.json onto the live cards.

Mirrors how the other seeds run (imported for its side effect on startup,
guarded by a migration key in app.py). Idempotent: only fills cards that still
lack a front_uz, matched by their original (source) front text — which is the
JSON key — so it works regardless of differing card ids between environments.
"""
import json
import os

import db

conn = db.get_conn()
c = conn.cursor()

_path = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                     "marketplace_translations.json")
try:
    _store = json.load(open(_path, encoding="utf-8"))
except Exception as e:  # pragma: no cover
    print("[i18n_auto] translations file unavailable:", e)
    _store = {}

_n = 0
for _orig, _tr in _store.items():
    _ru = _tr.get("ru", {}) or {}
    _en = _tr.get("en", {}) or {}
    _uz = _tr.get("uz", {}) or {}
    cur = c.execute(
        """UPDATE cards SET front=?, back=?, note=?,
             front_en=?, back_en=?, note_en=?,
             front_uz=?, back_uz=?, note_uz=?
           WHERE front=? AND (front_uz IS NULL OR front_uz='')""",
        (_ru.get("front") or _orig, _ru.get("back") or "", _ru.get("note") or "",
         _en.get("front") or _orig, _en.get("back") or "", _en.get("note") or "",
         _uz.get("front") or _orig, _uz.get("back") or "", _uz.get("note") or "",
         _orig))
    _n += cur.rowcount
conn.commit()
conn.close()
print(f"[i18n_auto] applied translations to {_n} cards ({len(_store)} entries)")
