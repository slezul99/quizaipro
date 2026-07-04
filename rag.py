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
import hashlib
import json
import threading

import ai_gen

# Cards are embedded in batches of this many per pass. Embedding is a network
# round-trip per 100 texts, so a cold library (thousands of cards) costs tens of
# seconds — which is why it must NOT happen on the tutor request path.
_MAX_INDEX_PER_CALL = 300
# Cards embedded SYNCHRONOUSLY inside retrieve() before answering. Kept tiny so a
# question never blocks: the tutor answers from whatever is already embedded (+
# all uploaded docs, which are embedded at upload time) and the rest of the
# library warms up in a background thread (`_warm_cards_async`).
_SYNC_INDEX_LIMIT = 0
_DEFAULT_K = 8
# Cosine floor for a card to count as "relevant" — keeps off-topic questions from
# dragging in unrelated cards (then the tutor answers from general knowledge).
_MIN_SCORE = 0.35


def _ensure_table(conn):
    # Portable across SQLite (dev) and Postgres (prod, via db.py's compat layer):
    # the vector is stored as a JSON TEXT array — avoids the SQLite-only BLOB type
    # and psycopg BYTEA/memoryview handling. Compact enough at library scale.
    conn.execute(
        """CREATE TABLE IF NOT EXISTS card_embeddings (
               card_id    INTEGER PRIMARY KEY,
               deck_id    INTEGER NOT NULL,
               text_hash  TEXT    NOT NULL,
               vec        TEXT    NOT NULL
           )""")
    conn.execute(
        "CREATE INDEX IF NOT EXISTS idx_card_emb_deck ON card_embeddings(deck_id)")


def _card_text(front, back, note):
    return f"{front or ''}\n{back or ''}\n{note or ''}".strip()


def _text_hash(front, back, note):
    return hashlib.sha1(_card_text(front, back, note).encode("utf-8")).hexdigest()


def _pack(vec):
    return json.dumps([float(x) for x in vec])


def _unpack(blob):
    return json.loads(blob)


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


def _ensure_indexed(conn, deck_ids, limit=_MAX_INDEX_PER_CALL):
    """Embed & cache any cards in `deck_ids` that are new or whose text changed
    (detected via text_hash), at most `limit` per call. Returns how many were
    embedded (0 ⇒ nothing stale, i.e. fully warm)."""
    if not deck_ids or limit <= 0:
        return 0
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
            if len(stale) >= limit:
                break
    if not stale:
        return 0

    vecs = ai_gen._embed_texts([s[3] for s in stale])
    if not vecs:
        return 0
    for (cid, did, h, _txt), v in zip(stale, vecs):
        # Portable upsert: ON CONFLICT works on SQLite 3.24+ AND Postgres.
        conn.execute(
            "INSERT INTO card_embeddings (card_id, deck_id, text_hash, vec) "
            "VALUES (?,?,?,?) "
            "ON CONFLICT (card_id) DO UPDATE SET "
            "deck_id=excluded.deck_id, text_hash=excluded.text_hash, vec=excluded.vec",
            (cid, did, h, _pack(v)))
    conn.commit()
    return len(stale)


# Track which deck-sets are already warming so overlapping tutor questions don't
# spawn duplicate indexing threads. Per-process; on prod the embeddings land in
# the shared DB so every worker benefits regardless of which one warmed them.
_warm_lock = threading.Lock()
_warming = set()


def _warm_cards_async(deck_ids):
    """Embed the rest of a user's cards OFF the request path so the tutor never
    blocks on cold indexing. Best-effort, idempotent (text_hash-gated), daemon."""
    if not deck_ids:
        return
    key = tuple(sorted(deck_ids))
    with _warm_lock:
        if key in _warming:
            return
        _warming.add(key)

    def _run():
        try:
            import db  # local import: avoid any import cycle at module load
            c = db.get_conn()
            try:
                for _ in range(200):  # safety bound (~300 cards/pass)
                    if _ensure_indexed(c, deck_ids, limit=_MAX_INDEX_PER_CALL) == 0:
                        break
            finally:
                c.close()
        except Exception as e:
            print(f"[rag warm] {type(e).__name__}: {e}")
        finally:
            with _warm_lock:
                _warming.discard(key)

    threading.Thread(target=_run, daemon=True).start()


# ── Documents (Phase 1b): user-uploaded source material, chunked + embedded ──

def _ensure_doc_tables(conn):
    # AUTOINCREMENT is translated to a Postgres IDENTITY by db.translate_sql.
    conn.execute(
        """CREATE TABLE IF NOT EXISTS documents (
               id         INTEGER PRIMARY KEY AUTOINCREMENT,
               user_id    INTEGER NOT NULL,
               name       TEXT    NOT NULL,
               created_at TEXT    NOT NULL
           )""")
    conn.execute(
        """CREATE TABLE IF NOT EXISTS doc_chunks (
               id      INTEGER PRIMARY KEY AUTOINCREMENT,
               doc_id  INTEGER NOT NULL,
               user_id INTEGER NOT NULL,
               page    INTEGER,
               ord     INTEGER,
               text    TEXT    NOT NULL,
               vec     TEXT    NOT NULL
           )""")
    conn.execute(
        "CREATE INDEX IF NOT EXISTS idx_doc_chunks_user ON doc_chunks(user_id)")


def _chunk_text(text, max_len=800, min_len=100):
    """Split a page's text into ~max_len-char chunks on sentence / blank-line
    boundaries; drop tiny fragments (but never lose a whole short page)."""
    import re
    text = (text or "").strip()
    if not text:
        return []
    parts = re.split(r"(?<=[.!?])\s+|\n{2,}", text)
    chunks, cur = [], ""
    for p in parts:
        p = p.strip()
        if not p:
            continue
        if len(cur) + len(p) + 1 <= max_len:
            cur = (cur + " " + p).strip()
        else:
            if cur:
                chunks.append(cur)
            cur = p if len(p) <= max_len else p[:max_len]
    if cur:
        chunks.append(cur)
    kept = [c for c in chunks if len(c) >= min_len]
    return kept or ([text[:max_len]] if len(text) >= 40 else [])


def index_document(conn, user_id, name, pages, max_chunks=400):
    """Chunk + embed a document's `pages` [(page_no, text), …] and store it.
    Returns (doc_id, chunk_count); (None, 0) if embeddings are off / no text."""
    if not ai_gen.vertex_enabled():
        return None, 0
    _ensure_doc_tables(conn)
    items = []  # (page_no, chunk_text)
    for page_no, ptext in pages:
        for ch in _chunk_text(ptext):
            items.append((page_no, ch))
            if len(items) >= max_chunks:
                break
        if len(items) >= max_chunks:
            break
    if not items:
        return None, 0
    vecs = ai_gen._embed_texts([t for _p, t in items])
    if not vecs:
        return None, 0
    import datetime as _dt
    now = _dt.datetime.utcnow().isoformat(sep=" ", timespec="seconds")
    cur = conn.execute(
        "INSERT INTO documents (user_id, name, created_at) VALUES (?,?,?) RETURNING id",
        (user_id, (name or "document")[:200], now))
    doc_id = cur.fetchone()[0]
    for i, ((page_no, ch), v) in enumerate(zip(items, vecs)):
        conn.execute(
            "INSERT INTO doc_chunks (doc_id, user_id, page, ord, text, vec) "
            "VALUES (?,?,?,?,?,?)",
            (doc_id, user_id, page_no, i, ch, _pack(v)))
    conn.commit()
    return doc_id, len(items)


def retrieve(conn, user, query, deck_id=None, k=_DEFAULT_K, doc_id=None):
    """Top-k sources most relevant to `query`, merging the user's CARDS and
    uploaded DOCUMENTS. Each hit is tagged with `type` ('card' | 'doc') plus the
    metadata that type needs. [] if embeddings unavailable.

    doc_id: FOCUS mode — restrict retrieval to a single uploaded document (skip
    cards and every other doc). Makes "what's in this file?" meta-questions work,
    since semantic search alone can't match a question to "which file"."""
    if not query or not ai_gen.vertex_enabled():
        return []
    qv = ai_gen._embed_texts([query])
    if not qv:
        return []
    qv = qv[0]

    hits = []

    # FOCUS mode: only the chosen document's chunks (user-scoped), nothing else.
    if doc_id:
        _ensure_doc_tables(conn)
        for r in conn.execute(
            """SELECT dc.id AS chunk_id, dc.doc_id, dc.page, dc.text, dc.vec,
                      d.name AS doc_name
                 FROM doc_chunks dc JOIN documents d ON d.id = dc.doc_id
                WHERE dc.user_id = ? AND dc.doc_id = ?""",
            (user["id"], doc_id)).fetchall():
            hits.append({"type": "doc", "chunk_id": r["chunk_id"], "doc_id": r["doc_id"],
                         "doc_name": r["doc_name"], "page": r["page"], "text": r["text"],
                         "score": ai_gen._cosine(qv, _unpack(r["vec"]))})
        hits.sort(key=lambda h: h["score"], reverse=True)
        top = hits[:k]
        for h in top:
            h["score"] = round(float(h["score"]), 3)
        return top

    # Cards (deck-scoped if a deck is in context, else the user's whole library).
    deck_ids = _user_deck_ids(conn, user, deck_id)
    if deck_ids:
        # Do NOT block the answer on cold embedding (thousands of cards = tens of
        # seconds). Embed at most a tiny sync batch, then warm the rest in the
        # background; this question grounds on whatever is already embedded plus
        # all uploaded docs (which are embedded at upload time).
        _ensure_indexed(conn, deck_ids, limit=_SYNC_INDEX_LIMIT)
        _warm_cards_async(deck_ids)
        ph = ",".join("?" * len(deck_ids))
        for r in conn.execute(
            f"""SELECT e.card_id, e.deck_id, e.vec, c.front, c.back, c.note
                  FROM card_embeddings e JOIN cards c ON c.id = e.card_id
                 WHERE e.deck_id IN ({ph})""", deck_ids).fetchall():
            hits.append({"type": "card", "card_id": r["card_id"],
                         "deck_id": r["deck_id"], "front": r["front"],
                         "back": r["back"], "note": r["note"],
                         "score": ai_gen._cosine(qv, _unpack(r["vec"]))})

    # Documents the user uploaded (user-scoped, not deck-scoped).
    _ensure_doc_tables(conn)
    for r in conn.execute(
        """SELECT dc.id AS chunk_id, dc.doc_id, dc.page, dc.text, dc.vec,
                  d.name AS doc_name
             FROM doc_chunks dc JOIN documents d ON d.id = dc.doc_id
            WHERE dc.user_id = ?""", (user["id"],)).fetchall():
        hits.append({"type": "doc", "chunk_id": r["chunk_id"], "doc_id": r["doc_id"],
                     "doc_name": r["doc_name"], "page": r["page"], "text": r["text"],
                     "score": ai_gen._cosine(qv, _unpack(r["vec"]))})

    hits.sort(key=lambda h: h["score"], reverse=True)
    top = hits[:k]
    for h in top:
        h["score"] = round(float(h["score"]), 3)
    return top


# Citation labels per UI language — MUST match the frontend chip labels
# (templates/tutor_v2.html SRC_LABELS) so the answer's "[Card 2]" tokens line up
# with the rendered source chips.
_LABELS = {
    "ru": {"card": "Карточка", "doc": "Документ", "page": "стр."},
    "en": {"card": "Card", "doc": "Document", "page": "p."},
    "uz": {"card": "Karta", "doc": "Hujjat", "page": "b."},
}


def _labels(lang):
    return _LABELS.get(lang, _LABELS["ru"])


def format_context(hits, lang="ru", min_score=_MIN_SCORE):
    """Turn retrieval `hits` into (context_string, used_hits): the citation-
    labelled prompt block plus the filtered hits IN THE SAME [Label N] order, so
    the caller can expose matching, clickable sources (index+1 == N). Labels are
    localised to `lang`."""
    used = [h for h in (hits or []) if h["score"] >= min_score]
    if not used:
        return "", []
    L = _labels(lang)
    lines = []
    for i, h in enumerate(used, 1):
        if h.get("type") == "doc":
            page = f", {L['page']} {h['page']}" if h.get("page") else ""
            txt = (h.get("text") or "").strip().replace("\n", " ")[:400]
            lines.append(f"[{L['doc']} {i}] «{h.get('doc_name')}»{page}: {txt}")
        else:
            note = (h.get("note") or "").strip()
            note = f" — {note[:200]}" if note else ""
            front = (h.get("front") or "").strip().replace("\n", " ")[:300]
            back = (h.get("back") or "").strip().replace("\n", " ")[:300]
            lines.append(f"[{L['card']} {i}] {front} → {back}{note}")
    return "\n".join(lines), used


def build_tutor_context(conn, user, query, deck_id=None, k=_DEFAULT_K,
                        lang="ru", min_score=_MIN_SCORE):
    """Convenience: citation-labelled context string only (see format_context)."""
    ctx, _ = format_context(
        retrieve(conn, user, query, deck_id=deck_id, k=k),
        lang=lang, min_score=min_score)
    return ctx
