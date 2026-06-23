# -*- coding: utf-8 -*-
"""Read-only personal-library endpoints for the mobile /api/v1 layer.

Field-mapping notes (Phase 2 — pragmatic choices, no schema changes):
  - `decks` has no cover_color / is_pro / is_favorite / is_archived / tags /
    updated_at / difficulty columns. Until those exist:
      cover_color_hex -> the deck's category color, else a deterministic
                         palette color derived from the deck id
      is_pro, is_favorite, is_archived -> always false
      tags          -> []
      updated_at    -> created_at
      difficulty    -> null
      subject_name  -> the deck's category name
    The `difficulty` and `show_archived` query params are therefore accepted
    but have no effect (documented mismatch).
  - There is no personal "collections" concept — the existing `collections`
    table holds curated marketplace content, not per-user groupings. Mapped
    to the user's own `categories`, which already group decks the same way
    (see dashboard `by_category`). `description` has no backing column (→ "").
"""
import math
import re
from datetime import datetime

from flask import Blueprint, g, jsonify, request

import db

from . import jwt_auth

library_bp = Blueprint("api_v1_library", __name__, url_prefix="/api/v1/library")

_COLOR_PALETTE = ["#6366f1", "#8b5cf6", "#ec4899", "#f59e0b",
                  "#10b981", "#3b82f6", "#ef4444", "#14b8a6"]


def _palette_color(seed_id):
    return _COLOR_PALETTE[(seed_id or 0) % len(_COLOR_PALETTE)]


_HEX_RE = re.compile(r"^#?[0-9a-fA-F]{6}$")


def _clean_color(v):
    """A user-chosen deck colour: a #RRGGBB hex, else None (→ derived palette)."""
    if not isinstance(v, str):
        return None
    v = v.strip()
    if not v:
        return None
    return ("#" + v.lstrip("#")).upper() if _HEX_RE.match(v) else None


def _clean_cover(v):
    """A deck cover: a preset id (e.g. 'cover_07') or an image url, else None."""
    if not isinstance(v, str):
        return None
    v = v.strip()
    return v[:512] if v else None


def _paginate(items, page, page_size):
    total_count = len(items)
    total_pages = max(1, math.ceil(total_count / page_size))
    page = max(1, min(page, total_pages))
    start = (page - 1) * page_size
    return items[start:start + page_size], page, total_pages, total_count


def _user_deck_filter(user):
    if user["org_id"]:
        return "d.org_id=?", user["org_id"]
    return "d.owner_id=?", user["id"]


def _fetch_user_decks(conn, user):
    now_iso = datetime.utcnow().isoformat()
    deck_filter, deck_param = _user_deck_filter(user)
    rows = conn.execute(f"""
        SELECT d.*, cat.name AS category_name, cat.color AS category_color,
            (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS card_count,
            (SELECT COUNT(*) FROM cards crd
                LEFT JOIN user_card_progress p ON p.card_id=crd.id AND p.user_id=?
                WHERE crd.deck_id=d.id AND (p.due_at IS NULL OR p.due_at <= ?)) AS due_count,
            (SELECT MAX(r.reviewed_at) FROM reviews r
                JOIN cards c2 ON c2.id=r.card_id
                WHERE c2.deck_id=d.id AND r.user_id=?) AS last_studied_at
        FROM decks d
        LEFT JOIN categories cat ON cat.id = d.category_id
        WHERE {deck_filter}
        ORDER BY d.created_at DESC
    """, (user["id"], now_iso, user["id"], deck_param)).fetchall()
    return [dict(r) for r in rows]


def _serialize_library_deck(d):
    # Content-type flags drive the mobile deck card badges and the Study/Test
    # gating. They come from the precomputed `decks.has_mcq` / `has_terms`
    # columns (see app.py:_recalc_deck_flags). Fallback: if a non-empty deck was
    # never flagged, assume it has flashcards so the Study action isn't wrongly
    # disabled (an unflagged deck is treated as terms, never MCQ).
    has_tests = bool(d.get("has_mcq"))
    has_flashcards = bool(d.get("has_terms"))
    if (d.get("card_count") or 0) > 0 and not has_tests and not has_flashcards:
        has_flashcards = True
    return {
        "id": str(d["id"]),
        "title": d["name"],
        "icon": (d.get("icon") or "").strip() or "📚",
        "description": d["description"] or "",
        "card_count": d["card_count"] or 0,
        "due_count": d["due_count"] or 0,
        "has_tests": has_tests,
        "has_flashcards": has_flashcards,
        "cover_color_hex": d.get("color") or d["category_color"] or _palette_color(d["id"]),
        "cover_url": d.get("cover") or None,
        "is_pro": False,
        "is_public": bool(d["is_public"]),
        "is_favorite": False,
        "is_archived": False,
        "tags": [],
        "created_at": d["created_at"],
        "updated_at": d["created_at"],
        "difficulty": None,
        "last_studied_at": d["last_studied_at"],
        "subject_name": d["category_name"],
    }


_SORT_KEYS = {
    "createdAt": (lambda d: d["created_at"] or "", True),
    "name": (lambda d: (d["name"] or "").lower(), False),
    "recentlyStudied": (lambda d: d["last_studied_at"] or "", True),
    "cardCount": (lambda d: d["card_count"] or 0, True),
    "dueCards": (lambda d: d["due_count"] or 0, True),
}


def _sort_decks(decks, sort_key):
    key_fn, reverse = _SORT_KEYS.get(sort_key, _SORT_KEYS["createdAt"])
    return sorted(decks, key=key_fn, reverse=reverse)


@library_bp.route("/decks", methods=["GET"])
@jwt_auth.jwt_required
def get_decks():
    user = g.current_user
    page = request.args.get("page", default=1, type=int) or 1
    page_size = request.args.get("page_size", default=20, type=int) or 20
    page_size = max(1, min(page_size, 100))
    sort_key = request.args.get("sort", default="createdAt")
    has_due_only = (request.args.get("has_due_only", default="false") or "").lower() == "true"
    # `difficulty` / `show_archived` are accepted but ignored — see module docstring.

    conn = db.get_conn()
    try:
        decks = _fetch_user_decks(conn, user)
    finally:
        conn.close()

    if has_due_only:
        decks = [d for d in decks if (d["due_count"] or 0) > 0]
    decks = _sort_decks(decks, sort_key)

    page_items, page, total_pages, total_count = _paginate(decks, page, page_size)
    return jsonify({"data": {
        "items": [_serialize_library_deck(d) for d in page_items],
        "page": page,
        "total_pages": total_pages,
        "total_count": total_count,
    }})


@library_bp.route("/collections", methods=["GET"])
@jwt_auth.jwt_required
def get_collections():
    user = g.current_user
    page = request.args.get("page", default=1, type=int) or 1
    page_size = request.args.get("page_size", default=20, type=int) or 20
    page_size = max(1, min(page_size, 100))

    conn = db.get_conn()
    try:
        if user["org_id"]:
            cat_filter, cat_param = "cat.org_id=?", user["org_id"]
            deck_filter, deck_param = "d.org_id=?", user["org_id"]
        else:
            cat_filter, cat_param = "cat.owner_id=?", user["id"]
            deck_filter, deck_param = "d.owner_id=?", user["id"]

        rows = conn.execute(f"""
            SELECT cat.*,
                (SELECT COUNT(*) FROM decks d
                    WHERE d.category_id=cat.id AND {deck_filter}) AS deck_count
            FROM categories cat
            WHERE {cat_filter}
            ORDER BY cat.name
        """, (deck_param, cat_param)).fetchall()
    finally:
        conn.close()

    items_all = [{
        "id": str(c["id"]),
        "name": c["name"],
        "description": "",
        "cover_color_hex": c["color"] or _palette_color(c["id"]),
        "deck_count": c["deck_count"] or 0,
        "created_at": c["created_at"],
    } for c in rows]

    page_items, page, total_pages, total_count = _paginate(items_all, page, page_size)
    return jsonify({"data": {
        "items": page_items,
        "page": page,
        "total_pages": total_pages,
        "total_count": total_count,
    }})


@library_bp.route("/search", methods=["GET"])
@jwt_auth.jwt_required
def search_library():
    user = g.current_user
    q = (request.args.get("q") or "").strip()
    page = request.args.get("page", default=1, type=int) or 1
    page_size = request.args.get("page_size", default=20, type=int) or 20
    page_size = max(1, min(page_size, 100))

    conn = db.get_conn()
    try:
        decks = _fetch_user_decks(conn, user)
    finally:
        conn.close()

    if q:
        ql = q.lower()
        decks = [d for d in decks
                 if ql in (d["name"] or "").lower() or ql in (d["description"] or "").lower()]

    page_items, page, total_pages, total_count = _paginate(decks, page, page_size)
    return jsonify({"data": {
        "items": [_serialize_library_deck(d) for d in page_items],
        "page": page,
        "total_pages": total_pages,
        "total_count": total_count,
    }})


# ---------------------------------------------------------------------------
# Deck write endpoints (Library add/edit/delete) — the read-only contract of
# this blueprint is extended here so the mobile Library can manage its own
# decks. Card-level CRUD lives in study.py (decks_bp).
# ---------------------------------------------------------------------------

_DECK_TITLE_MAX_LEN = 100
_DECK_DESC_MAX_LEN = 2000


def _err(code, message, status):
    return jsonify({"error": {"code": code, "message": message}}), status


def _user_owns_deck(user, deck):
    if user["org_id"]:
        return deck["org_id"] == user["org_id"]
    return deck["owner_id"] == user["id"]


def _fetch_one_serialized(conn, user, deck_id):
    for d in _fetch_user_decks(conn, user):
        if str(d["id"]) == str(deck_id):
            return _serialize_library_deck(d)
    return None


@library_bp.route("/decks", methods=["POST"])
@jwt_auth.jwt_required
def create_deck():
    user = g.current_user
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Invalid JSON body", 400)
    title = (body.get("title") or "").strip()
    if not title:
        return _err("validation_error", "title is required", 400)
    if len(title) > _DECK_TITLE_MAX_LEN:
        return _err("validation_error", f"title must be at most {_DECK_TITLE_MAX_LEN} characters", 400)
    desc = body.get("description")
    desc = (desc or "").strip()[:_DECK_DESC_MAX_LEN] if isinstance(desc, str) else ""
    color = _clean_color(body.get("color"))
    cover = _clean_cover(body.get("cover"))

    conn = db.get_conn()
    try:
        if user["org_id"]:
            cur = conn.execute(
                "INSERT INTO decks (org_id, name, description, icon, color, cover, created_via) VALUES (?, ?, ?, '📚', ?, ?, 'mobile')",
                (user["org_id"], title, desc, color, cover))
        else:
            cur = conn.execute(
                "INSERT INTO decks (owner_id, name, description, icon, color, cover, created_via) VALUES (?, ?, ?, '📚', ?, ?, 'mobile')",
                (user["id"], title, desc, color, cover))
        conn.commit()
        data = _fetch_one_serialized(conn, user, cur.lastrowid)
    finally:
        conn.close()
    return jsonify({"data": data}), 201


@library_bp.route("/decks/<int:deck_id>", methods=["PUT", "PATCH"])
@jwt_auth.jwt_required
def update_deck(deck_id):
    user = g.current_user
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Invalid JSON body", 400)
    sets = {}
    if "title" in body:
        title = (body.get("title") or "").strip()
        if not title:
            return _err("validation_error", "title cannot be empty", 400)
        if len(title) > _DECK_TITLE_MAX_LEN:
            return _err("validation_error", f"title must be at most {_DECK_TITLE_MAX_LEN} characters", 400)
        sets["name"] = title
    if "description" in body:
        desc = body.get("description")
        sets["description"] = (desc or "").strip()[:_DECK_DESC_MAX_LEN] if isinstance(desc, str) else ""
    if "color" in body:
        sets["color"] = _clean_color(body.get("color"))
    if "cover" in body:
        sets["cover"] = _clean_cover(body.get("cover"))
    if not sets:
        return _err("validation_error", "no fields to update", 400)

    conn = db.get_conn()
    try:
        deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
        if deck is None:
            return _err("not_found", "Колода не найдена", 404)
        if not _user_owns_deck(user, deck):
            return _err("forbidden", "Нет доступа к этой колоде", 403)
        clause = ", ".join(f"{k}=?" for k in sets)
        conn.execute(f"UPDATE decks SET {clause} WHERE id=?", (*sets.values(), deck_id))
        conn.commit()
        data = _fetch_one_serialized(conn, user, deck_id)
    finally:
        conn.close()
    return jsonify({"data": data})


@library_bp.route("/decks/<int:deck_id>", methods=["DELETE"])
@jwt_auth.jwt_required
def delete_deck(deck_id):
    user = g.current_user
    conn = db.get_conn()
    try:
        deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
        if deck is None:
            return _err("not_found", "Колода не найдена", 404)
        if not _user_owns_deck(user, deck):
            return _err("forbidden", "Нет доступа к этой колоде", 403)
        conn.execute("DELETE FROM decks WHERE id=?", (deck_id,))  # cascades to cards
        conn.commit()
    finally:
        conn.close()
    return jsonify({"data": {"deleted": True}})
