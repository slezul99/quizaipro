# -*- coding: utf-8 -*-
"""Read-only marketplace endpoints for the mobile /api/v1 layer.

Field-mapping notes (Phase 2 — pragmatic choices, no schema changes):
  - `decks` has no rating / rating_count / tags / language / is_pro / color
    columns. Until those exist: rating -> 0.0, rating_count -> 0, tags -> [],
    language -> 'ru', is_pro -> false, cover_color_hex -> a deterministic
    palette color derived from the deck id. The `difficulty` and `pro_only`
    filters are accepted but have no effect (documented mismatch); `sort=rating`
    falls back to popularity (clones_count) since there is no rating column.
  - `subject_id` for a deck is resolved through
    collection_decks -> collections.subject_id (first match wins — a deck can
    technically belong to several collections/subjects).
  - DeckDetailDto.full_description / updated_at / like_count / is_cloned_by_user
    have no backing columns — mapped to description / created_at / 0 / false.
  - Localized titles (`mp_subjects.title_<lang>`) are resolved from the JWT
    user's stored `lang`, overridable via a `?lang=` query param (the mobile
    client has no session, unlike the web app's `session["lang"]`).
"""
import math

from flask import Blueprint, g, jsonify, request

import db

from . import jwt_auth

marketplace_bp = Blueprint("api_v1_marketplace", __name__, url_prefix="/api/v1/marketplace")

_COLOR_PALETTE = ["#6366f1", "#8b5cf6", "#ec4899", "#f59e0b",
                  "#10b981", "#3b82f6", "#ef4444", "#14b8a6"]

_SORT_SQL = {
    "popular": "d.clones_count DESC",
    "newest": "d.created_at DESC",
    "rating": "d.clones_count DESC",   # no rating column — fallback to popularity
    "alphabetical": "d.name ASC",
}


def _palette_color(seed_id):
    return _COLOR_PALETTE[(seed_id or 0) % len(_COLOR_PALETTE)]


def _paginate(items, page, page_size):
    total_count = len(items)
    total_pages = max(1, math.ceil(total_count / page_size))
    page = max(1, min(page, total_pages))
    start = (page - 1) * page_size
    return items[start:start + page_size], page, total_pages, total_count


def _resolve_lang(user):
    lang = request.args.get("lang") or (user["lang"] if user else None)
    return lang if lang in ("ru", "en", "uz") else "ru"


def _localized(row, field, lang):
    return row.get(f"{field}_{lang}") or row.get(f"{field}_en") or row.get(f"{field}_ru") or ""


def _deck_localized(d, field, lang):
    """Deck name/description: base column is the RU default, *_en/*_uz override."""
    if lang in ("en", "uz"):
        tr = d.get(f"{field}_{lang}")
        if tr:
            return tr
    return d.get(field) or ""


def _serialize_deck_summary(d, lang="ru"):
    return {
        "id": str(d["id"]),
        "title": _deck_localized(d, "name", lang),
        "description": _deck_localized(d, "description", lang),
        "author_name": d["author"] or "",
        "cover_color_hex": _palette_color(d["id"]),
        "card_count": d["card_count"] or 0,
        "rating": float(d["rating"]) if d.get("rating") is not None else 0.0,
        "rating_count": d.get("rating_count") or 0,
        "clone_count": d["clones_count"] or 0,
        "tags": [],
        "language": "ru",
        "subject_id": str(d["subject_id"]) if d.get("subject_id") else None,
        "is_pro": False,
    }


@marketplace_bp.route("/subjects", methods=["GET"])
@jwt_auth.jwt_required
def get_subjects():
    lang = _resolve_lang(g.current_user)
    conn = db.get_conn()
    try:
        rows = conn.execute("""
            SELECT s.*,
                (SELECT COALESCE(SUM(
                    (SELECT COUNT(*) FROM collection_decks WHERE collection_id=c2.id)
                 ), 0) FROM collections c2
                 WHERE c2.subject_id=s.id AND c2.is_active=1) AS deck_count
            FROM mp_subjects s WHERE s.is_active=1
            ORDER BY s.sort_order ASC
        """).fetchall()
    finally:
        conn.close()

    items = [{
        "id": str(s["id"]),
        "name": _localized(dict(s), "title", lang),
        "icon_code": s["icon"],
        "deck_count": s["deck_count"] or 0,
        "color_hex": s["color"],
    } for s in rows]
    return jsonify({"data": items})


def _query_public_decks(conn, where, params, order_by, limit=None):
    sql = f"""
        SELECT d.*,
            (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS card_count,
            (SELECT ROUND(AVG(stars), 1) FROM deck_reviews WHERE deck_id=d.id AND is_hidden=0) AS rating,
            (SELECT COUNT(*) FROM deck_reviews WHERE deck_id=d.id AND is_hidden=0) AS rating_count,
            CASE WHEN d.org_id IS NOT NULL
                 THEN (SELECT name FROM organizations WHERE id=d.org_id)
                 ELSE (SELECT username FROM users WHERE id=d.owner_id) END AS author,
            (SELECT c.subject_id FROM collection_decks cd3
                JOIN collections c ON c.id=cd3.collection_id
                WHERE cd3.deck_id=d.id AND c.subject_id IS NOT NULL LIMIT 1) AS subject_id
        FROM decks d
        WHERE {' AND '.join(where)}
        ORDER BY {order_by}
    """
    if limit:
        sql += " LIMIT ?"
        params = list(params) + [limit]
    return [dict(r) for r in conn.execute(sql, params).fetchall()]


@marketplace_bp.route("/collections", methods=["GET"])
@jwt_auth.jwt_required
def get_collections():
    user = g.current_user
    lang = _resolve_lang(user)
    page = request.args.get("page", default=1, type=int) or 1
    page_size = request.args.get("limit", default=20, type=int) or 20
    page_size = max(1, min(page_size, 100))
    subject_id = request.args.get("subject_id")

    where = ["c.is_active=1"]
    params = []
    if subject_id:
        where.append("c.subject_id=?")
        params.append(subject_id)

    conn = db.get_conn()
    try:
        rows = conn.execute(f"""
            SELECT c.*,
                (SELECT COUNT(*) FROM collection_decks WHERE collection_id=c.id) AS deck_count
            FROM collections c
            WHERE {' AND '.join(where)}
            ORDER BY c.sort_order ASC, c.id ASC
        """, params).fetchall()
    finally:
        conn.close()

    items_all = []
    for r in rows:
        d = dict(r)
        title = d.get(f"title_{lang}") or d.get("title_en") or d["title_ru"]
        desc = d.get(f"desc_{lang}") or d.get("desc_en") or d.get("desc_ru") or ""
        items_all.append({
            "id": str(d["id"]),
            "name": title,
            "description": desc,
            "cover_url": f"/static/collections/{d['slug']}.jpg" if d['slug'] else None,
            "cover_color_hex": d["color"] or "#6366f1",
            "deck_count": d["deck_count"] or 0,
            "subject_id": str(d["subject_id"]) if d["subject_id"] else None,
            "curator_name": "QuizAIPro",
        })

    page_items, page, total_pages, total_count = _paginate(items_all, page, page_size)
    return jsonify({"data": {
        "items": page_items,
        "page": page,
        "total_pages": total_pages,
        "total_count": total_count,
    }})


@marketplace_bp.route("/decks", methods=["GET"])
@jwt_auth.jwt_required
def get_decks():
    page = request.args.get("page", default=1, type=int) or 1
    page_size = request.args.get("limit", default=20, type=int) or 20
    page_size = max(1, min(page_size, 100))
    sort_key = request.args.get("sort", default="popular")
    subject_id = request.args.get("subject_id", type=int)
    collection_id = request.args.get("collection_id", type=int)
    # `difficulty` / `pro_only` accepted but ignored — see module docstring.

    where = ["d.is_public=1"]
    params = []
    if subject_id:
        where.append("""EXISTS (
            SELECT 1 FROM collection_decks cd JOIN collections c ON c.id=cd.collection_id
            WHERE cd.deck_id=d.id AND c.subject_id=?)""")
        params.append(subject_id)
    if collection_id:
        where.append("""EXISTS (
            SELECT 1 FROM collection_decks cd2
            WHERE cd2.deck_id=d.id AND cd2.collection_id=?)""")
        params.append(collection_id)

    order_by = _SORT_SQL.get(sort_key, _SORT_SQL["popular"])

    lang = _resolve_lang(g.current_user)
    conn = db.get_conn()
    try:
        rows = _query_public_decks(conn, where, params, order_by)
    finally:
        conn.close()

    items_all = [_serialize_deck_summary(d, lang) for d in rows]
    page_items, page, total_pages, total_count = _paginate(items_all, page, page_size)
    return jsonify({"data": {
        "items": page_items,
        "page": page,
        "total_pages": total_pages,
        "total_count": total_count,
    }})


@marketplace_bp.route("/decks/<int:deck_id>", methods=["GET"])
@jwt_auth.jwt_required
def get_deck_detail(deck_id):
    conn = db.get_conn()
    try:
        row = conn.execute("""
            SELECT d.*,
                (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS card_count,
                (SELECT ROUND(AVG(stars), 1) FROM deck_reviews WHERE deck_id=d.id AND is_hidden=0) AS rating,
                (SELECT COUNT(*) FROM deck_reviews WHERE deck_id=d.id AND is_hidden=0) AS rating_count,
                CASE WHEN d.org_id IS NOT NULL
                     THEN (SELECT name FROM organizations WHERE id=d.org_id)
                     ELSE (SELECT username FROM users WHERE id=d.owner_id) END AS author,
                (SELECT username FROM users WHERE id=d.owner_id) AS author_username
            FROM decks d
            WHERE d.id=? AND d.is_public=1
        """, (deck_id,)).fetchone()
    finally:
        conn.close()

    if row is None:
        return jsonify({"error": {"code": "not_found", "message": "Колода не найдена"}}), 404

    d = dict(row)
    lang = _resolve_lang(g.current_user)
    card_count = d["card_count"] or 0
    _name = _deck_localized(d, "name", lang)
    _desc = _deck_localized(d, "description", lang)
    data = {
        "id": str(d["id"]),
        "title": _name,
        "description": _desc,
        "full_description": _desc,
        "author_name": d["author"] or "",
        "author_username": d["author_username"] or "",
        "author_avatar_url": None,
        "cover_color_hex": _palette_color(d["id"]),
        "card_count": card_count,
        "rating": float(d["rating"]) if d.get("rating") is not None else 0.0,
        "rating_count": d.get("rating_count") or 0,
        "clone_count": d["clones_count"] or 0,
        "like_count": 0,
        "tags": [],
        "language": "ru",
        "subject_id": None,
        "is_pro": False,
        "preview_cards_count": min(card_count, 5),
        "is_cloned_by_user": False,
        "created_at": d["created_at"],
        "updated_at": d["created_at"],
    }
    return jsonify({"data": data})


@marketplace_bp.route("/decks/<int:deck_id>/cards", methods=["GET"])
@jwt_auth.jwt_required
def get_deck_cards(deck_id):
    """Cards of a public deck — powers the in-app preview (first N) and the
    trial Study/Test sessions launched straight from the marketplace.

    Query params:
      - ``limit``   (int, default 10, max 500) — how many cards to return.
      - ``shuffle`` (int 0/1) — randomise the order (used by trial sessions).
    """
    limit = request.args.get("limit", default=10, type=int) or 10
    limit = max(1, min(limit, 500))
    shuffle = request.args.get("shuffle", default=0, type=int)
    conn = db.get_conn()
    try:
        deck = conn.execute(
            "SELECT id FROM decks WHERE id=? AND is_public=1", (deck_id,)
        ).fetchone()
        if deck is None:
            return jsonify({"error": {"code": "not_found",
                                      "message": "Колода не найдена"}}), 404
        order = "RANDOM()" if shuffle else "id"
        rows = conn.execute(
            f"SELECT id, front, back, note FROM cards "
            f"WHERE deck_id=? ORDER BY {order} LIMIT ?",
            (deck_id, limit),
        ).fetchall()
    finally:
        conn.close()

    cards = [
        {
            "id": str(r["id"]),
            "front": r["front"] or "",
            "back": r["back"] or "",
            "hint": (r["note"] or None),
        }
        for r in rows
    ]
    return jsonify({"data": cards})


@marketplace_bp.route("/search", methods=["GET"])
@jwt_auth.jwt_required
def search_decks():
    q = (request.args.get("q") or "").strip()
    page = request.args.get("page", default=1, type=int) or 1
    page_size = request.args.get("limit", default=20, type=int) or 20
    page_size = max(1, min(page_size, 100))
    sort_key = request.args.get("sort", default="popular")
    subject_id = request.args.get("subject_id", type=int)
    # `difficulty` / `pro_only` accepted but ignored — see module docstring.

    where = ["d.is_public=1"]
    params = []
    if q:
        like = f"%{q}%"
        where.append("(d.name LIKE ? OR d.description LIKE ?)")
        params += [like, like]
    if subject_id:
        where.append("""EXISTS (
            SELECT 1 FROM collection_decks cd JOIN collections c ON c.id=cd.collection_id
            WHERE cd.deck_id=d.id AND c.subject_id=?)""")
        params.append(subject_id)

    order_by = _SORT_SQL.get(sort_key, _SORT_SQL["popular"])

    lang = _resolve_lang(g.current_user)
    conn = db.get_conn()
    try:
        rows = _query_public_decks(conn, where, params, order_by, limit=200)
    finally:
        conn.close()

    items_all = [_serialize_deck_summary(d, lang) for d in rows]
    page_items, page, total_pages, total_count = _paginate(items_all, page, page_size)
    return jsonify({"data": {
        "items": page_items,
        "page": page,
        "total_pages": total_pages,
        "total_count": total_count,
    }})


# ---------------------------------------------------------------------------
# POST /api/v1/marketplace/decks/<id>/clone   (P0-4)
# ---------------------------------------------------------------------------
# The mobile client (MarketplaceRemoteDataSource.cloneDeck) calls this path,
# but it was never registered on this blueprint — only the web/session routes
# (`/deck/<id>/clone`, `/marketplace/clone/<id>` in app.py) existed, so every
# clone returned 404. This is the JWT-authed, JSON-returning equivalent that
# reuses the same clone logic (deck + cards copy, clones_count bump, author
# notification). Any authenticated user may clone any public deck.
@marketplace_bp.route("/decks/<int:deck_id>/clone", methods=["POST"])
@jwt_auth.jwt_required
def clone_deck(deck_id):
    user = g.current_user
    conn = db.get_conn()
    try:
        src = conn.execute(
            "SELECT * FROM decks WHERE id=? AND is_public=1", (deck_id,)
        ).fetchone()
        if src is None:
            return jsonify({"error": {
                "code": "not_found",
                "message": "Колода не найдена или не публичная",
            }}), 404

        if user["org_id"]:
            cur = conn.execute(
                "INSERT INTO decks (org_id, name, icon, description) VALUES (?, ?, ?, ?)",
                (user["org_id"], src["name"], src["icon"], src["description"]))
        else:
            cur = conn.execute(
                "INSERT INTO decks (owner_id, name, icon, description) VALUES (?, ?, ?, ?)",
                (user["id"], src["name"], src["icon"], src["description"]))
        new_deck_id = cur.lastrowid

        cards = conn.execute(
            "SELECT front, back, note, image_url FROM cards WHERE deck_id=?", (deck_id,)
        ).fetchall()
        for c in cards:
            conn.execute(
                "INSERT INTO cards (deck_id, front, back, note, image_url) VALUES (?, ?, ?, ?, ?)",
                (new_deck_id, c["front"], c["back"], c["note"], c["image_url"] or ""))

        conn.execute("UPDATE decks SET clones_count = clones_count + 1 WHERE id=?", (deck_id,))

        # Notify the source author (skip self-clones) — mirrors app._notify.
        if src["owner_id"] and src["owner_id"] != user["id"]:
            conn.execute(
                "INSERT INTO notifications (user_id, type, message, link) VALUES (?, ?, ?, ?)",
                (src["owner_id"], "deck_clone",
                 f"@{user['username']} скопировал вашу колоду «{src['name']}»",
                 f"/u/{user['username']}"))

        conn.commit()
    finally:
        conn.close()

    return jsonify({"data": {"deck_id": str(new_deck_id)}}), 201


# ── Deck reviews (ratings) ─────────────────────────────────────────────────
_REVIEW_AUTO_HIDE = 3
_REVIEW_TEXT_MAX = 1000

_REVIEW_SELECT = """
    SELECT r.id, r.stars, r.text, r.created_at, r.user_id,
           COALESCE(NULLIF(u.full_name,''), u.username) AS author
    FROM deck_reviews r JOIN users u ON u.id=r.user_id
"""


def _serialize_review(r, current_user_id):
    return {
        "id": str(r["id"]),
        "author": r["author"] or "",
        "stars": r["stars"],
        "text": r["text"] or "",
        "created_at": r["created_at"],
        "is_mine": r["user_id"] == current_user_id,
    }


@marketplace_bp.route("/decks/<int:deck_id>/reviews", methods=["GET"])
@jwt_auth.jwt_required
def get_deck_reviews(deck_id):
    user = g.current_user
    conn = db.get_conn()
    try:
        agg = conn.execute(
            "SELECT ROUND(AVG(stars),1) AS rating, COUNT(*) AS count "
            "FROM deck_reviews WHERE deck_id=? AND is_hidden=0", (deck_id,)).fetchone()
        rows = conn.execute(
            _REVIEW_SELECT +
            " WHERE r.deck_id=? AND r.is_hidden=0 ORDER BY (r.user_id=?) DESC, r.updated_at DESC LIMIT 100",
            (deck_id, user["id"])).fetchall()
    finally:
        conn.close()
    reviews = [_serialize_review(r, user["id"]) for r in rows]
    my_review = next((rv for rv in reviews if rv["is_mine"]), None)
    return jsonify({"data": {
        "rating": float(agg["rating"]) if agg and agg["rating"] is not None else 0.0,
        "rating_count": (agg["count"] if agg else 0) or 0,
        "my_review": my_review,
        "reviews": reviews,
    }})


@marketplace_bp.route("/decks/<int:deck_id>/reviews", methods=["POST"])
@jwt_auth.jwt_required
def post_deck_review(deck_id):
    user = g.current_user
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return jsonify({"error": {"code": "validation_error", "message": "Ожидается JSON-тело"}}), 400
    try:
        stars = int(body.get("stars"))
    except (TypeError, ValueError):
        stars = 0
    if stars < 1 or stars > 5:
        return jsonify({"error": {"code": "validation_error", "message": "stars must be 1..5"}}), 400
    text = (body.get("text") or "").strip()[:_REVIEW_TEXT_MAX]
    conn = db.get_conn()
    try:
        if conn.execute("SELECT 1 FROM decks WHERE id=? AND is_public=1", (deck_id,)).fetchone() is None:
            return jsonify({"error": {"code": "not_found", "message": "Колода не найдена"}}), 404
        conn.execute("""
            INSERT INTO deck_reviews (deck_id, user_id, stars, text) VALUES (?, ?, ?, ?)
            ON CONFLICT(deck_id, user_id)
            DO UPDATE SET stars=excluded.stars, text=excluded.text, updated_at=CURRENT_TIMESTAMP
        """, (deck_id, user["id"], stars, text))
        conn.commit()
        row = conn.execute(_REVIEW_SELECT + " WHERE r.deck_id=? AND r.user_id=?",
                           (deck_id, user["id"])).fetchone()
    finally:
        conn.close()
    return jsonify({"data": _serialize_review(row, user["id"])}), 201


@marketplace_bp.route("/decks/<int:deck_id>/reviews", methods=["DELETE"])
@jwt_auth.jwt_required
def delete_deck_review(deck_id):
    user = g.current_user
    conn = db.get_conn()
    try:
        conn.execute("DELETE FROM deck_reviews WHERE deck_id=? AND user_id=?", (deck_id, user["id"]))
        conn.commit()
    finally:
        conn.close()
    return "", 204


@marketplace_bp.route("/reviews/<int:review_id>/report", methods=["POST"])
@jwt_auth.jwt_required
def report_review(review_id):
    conn = db.get_conn()
    try:
        conn.execute("UPDATE deck_reviews SET reports = reports + 1 WHERE id=?", (review_id,))
        conn.execute("UPDATE deck_reviews SET is_hidden=1 WHERE id=? AND reports >= ?",
                     (review_id, _REVIEW_AUTO_HIDE))
        conn.commit()
    finally:
        conn.close()
    return "", 204
