# -*- coding: utf-8 -*-
"""Retrieval layer for the grounded AI-tutor — Phase 1: the user's own cards.

Design (see the QuizAIPro AI-architecture plan):
  * Storage-agnostic + SQLite-compatible. Card embeddings are cached in a plain
    `card_embeddings` table (the 768-d vector packed as a float32 BLOB) and the
    similarity search is brute-force cosine in Python. At our scale (a user's
    library = hundreds, low-thousands of cards) this is effectively instant.
  * Reuses the SAME Vertex multilingual embeddings the app already calls for
    semantic dedup (`ai_gen._embed_texts`, `text-multilingual-embedding-002`).
  * Behind a small public API (`retrieve` / `build_tutor_context`) so the whole
    store can be swapped for **pgvector** once the Postgres cutover lands — the
    callers don't change. Do NOT couple callers to the table shape.

The tutor route builds its `deck_context` from `build_tutor_context()`; on any
failure (embeddings disabled, nothing indexed) it returns "" and the caller
falls back to its previous naive behaviour.
"""
import array
import hashlib

import ai_gen

# Bound the work done on a single (synchronous) tutor request: embed at most this
# many not-yet-indexed cards per call. A big library fills in over a few queries
# instead of stalling the first one. Deck-scoped queries are almost always well
# under this.
_MAX_INDEX_PER_CALL = 300
_DEFAULT_K = 8
# Cosine floor for a card to count as "relevant" — keeps off-topic questions from
# dragging in unrelated cards (then the tutor answers from general knowledge).
_MIN_SCORE = 0.35


def _ensure_table(conn):
    conn.execute(
        """CREATE TABLE IF NOT EXISTS card_embeddings (
               card_id    INTEGER PRIMARY KEY,
               deck_id    INTEGER NOT NULL,
               text_hash  TEXT    NOT NULL,
               vec        BLOB    NOT NULL
           )""")
    conn.execute(
        "CREATE INDEX IF NOT EXISTS idx_card_emb_deck ON card_embeddings(deck_id)")


def _card_text(front, back, note):
    return f"{front or ''}\n{back or ''}\n{note or ''}".strip()


def _text_hash(front, back, note):
    return hashlib.sha1(_card_text(front, back, note).encode("utf-8")).hexdigest()


def _pack(vec):
    return array.array("f", vec).tobytes()


def _unpack(blob):
    a = array.array("f")
    a.frombytes(blob)
    return a


def _user_deck_ids(conn, user, deck_id=None):
    """Deck ids whose cards may ground the tutor: one deck if scoped, else all
    decks the user owns (org member -> org decks, individual -> own decks)."""
    if deck_id:
        return [deck_id]
    if user.get("org_id"):
        rows = conn.execute(
            "SELECT id FROM decks WHERE org_id=?", (user["org_id"],)).fetchall()
    else:
        rows = conn.execute(
            "SELECT id FROM decks WHERE owner_id=?", (user["id"],)).fetchall()
    return [r["id"] for r in rows]


def _ensure_indexed(conn, deck_ids):
    """Embed & cache any cards in `deck_ids` that are new or whose text changed
    (detected via text_hash). Bounded to _MAX_INDEX_PER_CALL cards per call."""
    if not deck_ids:
        return
    _ensure_table(conn)
    ph = ",".join("?" * len(deck_ids))
    cards = conn.execute(
        f"""SELECT c.id, c.deck_id, c.front, c.back, c.note, e.text_hash AS ehash
              FROM cards c
              LEFT JOIN card_embeddings e ON e.card_id = c.id
             WHERE c.deck_id IN ({ph})""",
        deck_ids).fetchall()

    stale = []
    for c in cards:
        h = _text_hash(c["front"], c["back"], c["note"])
        if c["ehash"] != h:
            stale.append((c["id"], c["deck_id"], h,
                          _card_text(c["front"], c["back"], c["note"])))
            if len(stale) >= _MAX_INDEX_PER_CALL:
                break
    if not stale:
        return

    vecs = ai_gen._embed_texts([s[3] for s in stale])
    if not vecs:
        return
    for (cid, did, h, _txt), v in zip(stale, vecs):
        conn.execute(
            "INSERT OR REPLACE INTO card_embeddings "
            "(card_id, deck_id, text_hash, vec) VALUES (?,?,?,?)",
            (cid, did, h, _pack(v)))
    conn.commit()


def retrieve(conn, user, query, deck_id=None, k=_DEFAULT_K):
    """Top-k cards most relevant to `query`, each a dict
    {card_id, deck_id, front, back, note, score}. [] if embeddings unavailable."""
    if not query or not ai_gen.vertex_enabled():
        return []
    deck_ids = _user_deck_ids(conn, user, deck_id)
    if not deck_ids:
        return []
    _ensure_indexed(conn, deck_ids)

    qv = ai_gen._embed_texts([query])
    if not qv:
        return []
    qv = qv[0]

    ph = ",".join("?" * len(deck_ids))
    rows = conn.execute(
        f"""SELECT e.card_id, e.deck_id, e.vec, c.front, c.back, c.note
              FROM card_embeddings e
              JOIN cards c ON c.id = e.card_id
             WHERE e.deck_id IN ({ph})""",
        deck_ids).fetchall()

    scored = [(ai_gen._cosine(qv, _unpack(r["vec"])), r) for r in rows]
    scored.sort(key=lambda t: t[0], reverse=True)
    return [
        {"card_id": r["card_id"], "deck_id": r["deck_id"], "front": r["front"],
         "back": r["back"], "note": r["note"], "score": round(float(s), 3)}
        for s, r in scored[:k]
    ]


def build_tutor_context(conn, user, query, deck_id=None, k=_DEFAULT_K,
                        min_score=_MIN_SCORE):
    """Citation-labelled context string for the tutor prompt, or "" when nothing
    relevant / embeddings off (caller then falls back to its naive dump)."""
    hits = [h for h in retrieve(conn, user, query, deck_id=deck_id, k=k)
            if h["score"] >= min_score]
    if not hits:
        return ""
    lines = []
    for i, h in enumerate(hits, 1):
        note = (h["note"] or "").strip()
        note = f" — {note[:200]}" if note else ""
        front = (h["front"] or "").strip().replace("\n", " ")[:300]
        back = (h["back"] or "").strip().replace("\n", " ")[:300]
        lines.append(f"[Карточка {i}] {front} → {back}{note}")
    return "\n".join(lines)
