# -*- coding: utf-8 -*-
"""SQLite->SQLite self-test for the Stage-5 copier (the PG-agnostic core).

Verifies FK-safe ordering, the self-referential two-pass (categories.parent_id,
refresh_tokens.replaced_by), id preservation, and row-count validation — all on
SQLite, since the build env has no Postgres.  Run:  python test_migrate_copier.py
"""
import os
import sqlite3
import tempfile
from pathlib import Path

os.environ.pop("DATABASE_URL", None)
import db
import migrate_sqlite_to_pg as mig


def _build_source(path):
    db.DB_PATH = path
    db.init_db()
    c = db.get_conn()
    uid = c.execute("INSERT INTO users (org_id,username,full_name,password_hash,role) "
                    "VALUES (NULL,?,?,?,?) RETURNING id", ("u@x", "U", "h", "student")).fetchone()[0]
    # self-ref chain: child.parent_id -> root.id
    root = c.execute("INSERT INTO categories (owner_id,name) VALUES (?,?) RETURNING id", (uid, "Root")).fetchone()[0]
    child = c.execute("INSERT INTO categories (owner_id,name,parent_id) VALUES (?,?,?) RETURNING id",
                      (uid, "Child", root)).fetchone()[0]
    # FK chain decks -> cards
    did = c.execute("INSERT INTO decks (owner_id,name,icon) VALUES (?,?,?) RETURNING id", (uid, "D", "x")).fetchone()[0]
    c.execute("INSERT INTO cards (deck_id,front,back) VALUES (?,?,?)", (did, "f", "b"))
    # self-ref chain: tok2.replaced_by -> tok1.id
    t1 = c.execute("INSERT INTO refresh_tokens (user_id,token_hash,expires_at) VALUES (?,?,?) RETURNING id",
                   (uid, "h1", "2030-01-01")).fetchone()[0]
    c.execute("INSERT INTO refresh_tokens (user_id,token_hash,expires_at,replaced_by) VALUES (?,?,?,?)",
              (uid, "h2", "2030-01-01", t1))
    c.commit(); c.close()
    return {"uid": uid, "root": root, "child": child, "did": did, "t1": t1}


def main():
    s_dir = Path(tempfile.mkdtemp()) / "quizpro.db"
    d_dir = Path(tempfile.mkdtemp()) / "quizpro.db"
    ids = _build_source(s_dir)
    db.DB_PATH = d_dir
    db.init_db()                      # empty target schema

    src = sqlite3.connect(str(s_dir)); src.row_factory = sqlite3.Row
    dst = sqlite3.connect(str(d_dir)); dst.row_factory = sqlite3.Row

    print("=== copy ===")
    copied, order = mig.run_copy(src, dst, "?", is_pg=False, id_tables=mig._id_tables())
    # ordering check: parents precede children
    pos = {t: i for i, t in enumerate(order)}
    assert pos["users"] < pos["categories"] < pos["decks"] or pos["users"] < pos["decks"], order
    assert pos["organizations"] < pos["users"], "FK order: organizations before users"
    assert pos["decks"] < pos["cards"], "FK order: decks before cards"
    assert pos["users"] < pos["refresh_tokens"], "FK order: users before refresh_tokens"

    mism = mig.verify(src, dst, order)
    assert not mism, "row-count mismatches: %s" % mism

    # self-ref + id preservation
    child = dst.execute("SELECT id,parent_id FROM categories WHERE name='Child'").fetchone()
    assert child["id"] == ids["child"] and child["parent_id"] == ids["root"], dict(child)
    tok2 = dst.execute("SELECT replaced_by FROM refresh_tokens WHERE token_hash='h2'").fetchone()
    assert tok2["replaced_by"] == ids["t1"], dict(tok2)
    card = dst.execute("SELECT deck_id FROM cards").fetchone()
    assert card["deck_id"] == ids["did"], dict(card)

    src.close(); dst.close()
    print("\nSELF-REF: categories.parent_id and refresh_tokens.replaced_by preserved")
    print("IDS preserved; FK order correct; row counts match.")
    print("COPIER SELF-TEST: PASS")


if __name__ == "__main__":
    main()
