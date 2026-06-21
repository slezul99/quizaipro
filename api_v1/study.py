# -*- coding: utf-8 -*-
"""Flashcard study endpoints for the mobile /api/v1 layer — Phase 3.

Ownership model (approved SM-2 architecture decision — see audit report):
  The mobile client is the canonical source of truth for SM-2 scheduling.
  It computes ease factor / interval / repetitions locally (offline-first,
  Drift/SQLite) and submits the *results* of that computation. The backend
  VALIDATES and PERSISTS those values — it never re-runs `sm2.calc_sm2` for
  mobile-originated grades, so there is exactly one scheduling calculation
  per review (no duplicate engines, no server/client divergence).

  This intentionally reuses the existing `user_card_progress`/`reviews`
  tables (per the "reuse existing tables" requirement):
    - ef / interval_days / due_at / last_grade / last_reviewed are shared
      with the legacy web flow (sm2.py) — whichever platform graded most
      recently determines the row's due-date, exactly like a multi-device
      spaced-repetition app.
    - reviews / lapses keep their existing lifetime-counter semantics
      (reviews always +1, lapses +1 on an "again"/lapse grade).
    - `repetitions` is a NEW column: the mobile-canonical "consecutive
      success" counter. The web flow never writes it; only mobile grading
      (this endpoint) does — mobile is the sole owner of that field.
    - `again_count` (required by the mobile FlashcardDto) has no dedicated
      column; mobile only ever sends grade=1 ("again") for its lapse path,
      which is exactly the condition that increments `lapses` — so `lapses`
      is reused as the again-count without adding a redundant column.

Field-mapping notes (documented mismatches, no schema redesign):
  - `hint` (mobile) <- `cards.note` (no dedicated hint column).
  - `updated_at` (mobile, required non-null) <- last_reviewed, falling back
    to the card's created_at for never-reviewed cards.
  - A card graded only via the legacy web flow (never via mobile) reports
    `repetitions=0` even if it has review history — mobile will treat it as
    "not yet started its mobile-tracked streak" the first time it's graded
    there. This is a one-time, self-correcting edge case for cross-platform
    users; flagged in the verification report as a known mismatch.
"""
import re
from datetime import datetime, timedelta, timezone

from flask import Blueprint, g, jsonify, request

import db
import achievements as ach_mod

from . import jwt_auth

# MCQ detection mirrored from app.py (_MCQ_OPTION_RE / _card_is_mcq /
# refresh_deck_content_flags) so card mutations here keep decks.has_mcq /
# has_terms in sync without importing the Flask app into this blueprint.
_MCQ_OPTION_RE = re.compile(r"^\s*([A-Da-dА-Гa-г1-4])\s*[\)\.\:\-]\s*\S", re.MULTILINE)


def _has_mcq_options(text):
    if not text:
        return False
    matches = _MCQ_OPTION_RE.findall(text)
    return len({m.upper() for m in matches}) >= 2


def _card_is_mcq(front, back, note):
    return _has_mcq_options(note) or _has_mcq_options(back) or _has_mcq_options(front)


def _recalc_deck_flags(conn, deck_id):
    """Recompute decks.has_mcq / has_terms after a card mutation."""
    cards = conn.execute(
        "SELECT front, back, note FROM cards WHERE deck_id=?", (deck_id,)
    ).fetchall()
    has_mcq = 0
    has_terms = 0
    for c in cards:
        if _card_is_mcq(c["front"], c["back"], c["note"]):
            has_mcq = 1
        else:
            has_terms = 1
        if has_mcq and has_terms:
            break
    conn.execute(
        "UPDATE decks SET has_mcq=?, has_terms=? WHERE id=?",
        (has_mcq, has_terms, deck_id),
    )

decks_bp = Blueprint("api_v1_decks", __name__, url_prefix="/api/v1/decks")
study_bp = Blueprint("api_v1_study", __name__, url_prefix="/api/v1/study")

# Bounds mirrored from the mobile client's own constants (AppConstants.srs*) —
# see mobile/lib/core/config/app_constants.dart. Validation checks the client's
# *output* against the same envelope the client itself enforces; it does not
# recompute or second-guess the SM-2 math.
_VALID_GRADES = (1, 3, 4, 5)
_EF_MIN, _EF_MAX = 1.3, 5.0
# interval 0 is valid: FSRS (and SM-2 lapses) schedule an "Again" card for the
# same day. The old min of 1 wrongly rejected every "Again" grade.
_INTERVAL_MIN, _INTERVAL_MAX = 0, 36500
_FUTURE_TOLERANCE = timedelta(minutes=5)
_PAST_TOLERANCE = timedelta(days=90)


def _err(code, message, status):
    return jsonify({"error": {"code": code, "message": message}}), status


def _parse_iso(value):
    """Parse an ISO-8601 timestamp (as sent by Dio/json_serializable) to naive UTC."""
    if not isinstance(value, str) or not value.strip():
        return None
    v = value.strip()
    if v.endswith("Z"):
        v = v[:-1] + "+00:00"
    try:
        dt = datetime.fromisoformat(v)
    except ValueError:
        return None
    if dt.tzinfo is not None:
        dt = dt.astimezone(timezone.utc).replace(tzinfo=None)
    return dt


def _user_owns_deck(user, deck):
    if deck["org_id"]:
        return user["org_id"] == deck["org_id"]
    return user["id"] == deck["owner_id"]


def _resolve_lang(user):
    """Mirrors api_v1.marketplace._resolve_lang — mobile has no session, so
    language comes from an optional ?lang= override or the user's stored pref."""
    lang = request.args.get("lang") or (user["lang"] if user else None)
    return lang if lang in ("ru", "en", "uz") else "ru"


# ---------------------------------------------------------------------------
# GET /api/v1/decks/<id>/cards
# ---------------------------------------------------------------------------

def _serialize_card(row, lang="ru"):
    front, back, note = row["front"], row["back"], row["note"]
    if lang in ("en", "uz"):
        front = row[f"front_{lang}"] or front
        back = row[f"back_{lang}"] or back
        note = row[f"note_{lang}"] or note
    return {
        "id": str(row["id"]),
        "deck_id": str(row["deck_id"]),
        "front": front,
        "back": back,
        "hint": note or None,
        "ease_factor": row["ef"] if row["ef"] is not None else 2.5,
        "interval": row["interval_days"] or 0,
        "repetitions": row["repetitions"] or 0,
        "next_review_at": row["due_at"],
        "last_studied_at": row["last_reviewed"],
        "is_favorite": bool(row["is_favorite"]),
        "is_difficult": bool(row["is_difficult"]),
        "again_count": row["lapses"] or 0,
        "updated_at": row["last_reviewed"] or row["created_at"],
    }


@decks_bp.route("/<int:deck_id>/cards", methods=["GET"])
@jwt_auth.jwt_required
def get_deck_cards(deck_id):
    user = g.current_user
    conn = db.get_conn()
    try:
        deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
        if deck is None:
            return _err("not_found", "Колода не найдена", 404)
        if not _user_owns_deck(user, deck) and not deck["is_public"]:
            return _err("forbidden", "Нет доступа к этой колоде", 403)

        rows = conn.execute("""
            SELECT c.*, p.ef, p.interval_days, p.repetitions, p.due_at, p.last_reviewed,
                   p.is_favorite, p.is_difficult, p.lapses
            FROM cards c
            LEFT JOIN user_card_progress p ON p.card_id = c.id AND p.user_id = ?
            WHERE c.deck_id = ?
            ORDER BY c.id
        """, (user["id"], deck_id)).fetchall()
    finally:
        conn.close()

    lang = _resolve_lang(user)
    return jsonify({"data": [_serialize_card(r, lang) for r in rows]})


# ---------------------------------------------------------------------------
# GET /api/v1/decks · POST /api/v1/decks · POST /api/v1/decks/<id>/cards/bulk
#
# Added for Phase 6 (AI Generation): the mobile AI Studio flow needs to list
# the user's own decks (save-to-deck sheet), create a fresh deck on the fly,
# and bulk-insert AI-picked cards into either. These mirror the existing web
# `/ai` route's deck lookup/creation/`INSERT INTO cards` pattern (see
# `save_fn` closures in app.py) — same ownership rules, same tables, just a
# JSON/mobile-shaped surface. `_DeckSummaryDto` only needs {id, title, card_count}
# so `name` is surfaced as `title` (mobile's field name) without renaming the
# underlying column — same "DTO field-mapping, no schema redesign" approach as
# Phase 3's card serialization.
# ---------------------------------------------------------------------------

_DECK_TITLE_MAX_LEN = 100
_BULK_CARDS_MAX = 100


def _serialize_deck_summary(row):
    return {
        "id": str(row["id"]),
        "title": row["name"],
        "card_count": row["card_count"],
    }


@decks_bp.route("", methods=["GET"])
@jwt_auth.jwt_required
def get_user_decks():
    user = g.current_user
    conn = db.get_conn()
    try:
        if user["org_id"]:
            rows = conn.execute("""
                SELECT d.*, (SELECT COUNT(*) FROM cards c WHERE c.deck_id = d.id) AS card_count
                FROM decks d WHERE d.org_id = ? ORDER BY d.created_at DESC
            """, (user["org_id"],)).fetchall()
        else:
            rows = conn.execute("""
                SELECT d.*, (SELECT COUNT(*) FROM cards c WHERE c.deck_id = d.id) AS card_count
                FROM decks d WHERE d.owner_id = ? ORDER BY d.created_at DESC
            """, (user["id"],)).fetchall()
    finally:
        conn.close()
    return jsonify({"data": [_serialize_deck_summary(r) for r in rows]})


@decks_bp.route("", methods=["POST"])
@jwt_auth.jwt_required
def post_create_deck():
    user = g.current_user
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Invalid JSON body", 400)

    title = (body.get("title") or "").strip()
    if not title:
        return _err("validation_error", "title is required", 400)
    if len(title) > _DECK_TITLE_MAX_LEN:
        return _err("validation_error", f"title must be at most {_DECK_TITLE_MAX_LEN} characters", 400)

    conn = db.get_conn()
    try:
        if user["org_id"]:
            cur = conn.execute(
                "INSERT INTO decks (org_id, name, icon, created_via) VALUES (?, ?, ?, 'mobile_ai')",
                (user["org_id"], title, "🤖"))
        else:
            cur = conn.execute(
                "INSERT INTO decks (owner_id, name, icon, created_via) VALUES (?, ?, ?, 'mobile_ai')",
                (user["id"], title, "🤖"))
        conn.commit()
        row = conn.execute("""
            SELECT d.*, (SELECT COUNT(*) FROM cards c WHERE c.deck_id = d.id) AS card_count
            FROM decks d WHERE d.id = ?
        """, (cur.lastrowid,)).fetchone()
    finally:
        conn.close()

    return jsonify({"data": _serialize_deck_summary(row)}), 201


def _validate_bulk_cards_payload(body):
    cards = body.get("cards")
    if not isinstance(cards, list) or not cards:
        return None, "cards must be a non-empty array"
    if len(cards) > _BULK_CARDS_MAX:
        return None, f"cannot save more than {_BULK_CARDS_MAX} cards at once"

    parsed = []
    for i, c in enumerate(cards):
        if not isinstance(c, dict):
            return None, f"cards[{i}] must be an object"
        question = (c.get("question") or "").strip()
        answer = (c.get("answer") or "").strip()
        if not question or not answer:
            return None, f"cards[{i}] must have non-empty question and answer"
        parsed.append((question, answer))
    return parsed, None


@decks_bp.route("/<int:deck_id>/cards/bulk", methods=["POST"])
@jwt_auth.jwt_required
def post_bulk_cards(deck_id):
    user = g.current_user
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Invalid JSON body", 400)

    cards, err = _validate_bulk_cards_payload(body)
    if err:
        return _err("validation_error", err, 400)

    conn = db.get_conn()
    try:
        deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
        if deck is None:
            return _err("not_found", "Колода не найдена", 404)
        if not _user_owns_deck(user, deck):
            return _err("forbidden", "Нет доступа к этой колоде", 403)

        for question, answer in cards:
            conn.execute("INSERT INTO cards (deck_id, front, back, note) VALUES (?, ?, ?, '')",
                         (deck_id, question, answer))
        # AI-generated {question, answer} cards are always plain flashcards,
        # never MCQ (mirrors app.py's refresh_deck_content_flags outcome for
        # this card shape — avoids importing from app to keep blueprints
        # independent, see api_v1/__init__.py docstring).
        conn.execute("UPDATE decks SET has_terms=1 WHERE id=?", (deck_id,))
        conn.commit()

        card_count = conn.execute("SELECT COUNT(*) AS c FROM cards WHERE deck_id=?",
                                  (deck_id,)).fetchone()["c"]
    finally:
        conn.close()

    return jsonify({"data": {"saved_count": len(cards), "card_count": card_count}}), 201


# ---------------------------------------------------------------------------
# Single-card CRUD (Library add/edit) — POST/PUT/DELETE /decks/<id>/cards[/<cid>]
# ---------------------------------------------------------------------------

_CARD_FIELD_MAX_LEN = 4000


def _validate_card_payload(body, *, partial=False):
    """Validate a single-card add/edit payload. Returns (parsed, error)."""
    if not isinstance(body, dict):
        return None, "Invalid JSON body"
    out = {}
    for field in ("front", "back", "note"):
        if field in body:
            val = body.get(field)
            if val is None:
                val = ""
            if not isinstance(val, str):
                return None, f"{field} must be a string"
            val = val.strip()
            if len(val) > _CARD_FIELD_MAX_LEN:
                return None, f"{field} is too long"
            out[field] = val
    if not partial:
        if not out.get("front"):
            return None, "front is required"
        if not out.get("back"):
            return None, "back is required"
        out.setdefault("note", "")
    return out, None


def _load_card_row(conn, deck_id, card_id):
    return conn.execute("""
        SELECT c.*, p.ef, p.interval_days, p.repetitions, p.due_at, p.last_reviewed,
               p.is_favorite, p.is_difficult, p.lapses
        FROM cards c
        LEFT JOIN user_card_progress p ON p.card_id = c.id AND p.user_id = ?
        WHERE c.id = ? AND c.deck_id = ?
    """, (g.current_user["id"], card_id, deck_id)).fetchone()


@decks_bp.route("/<int:deck_id>/cards", methods=["POST"])
@jwt_auth.jwt_required
def post_create_card(deck_id):
    user = g.current_user
    parsed, err = _validate_card_payload(request.get_json(silent=True))
    if err:
        return _err("validation_error", err, 400)

    conn = db.get_conn()
    try:
        deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
        if deck is None:
            return _err("not_found", "Колода не найдена", 404)
        if not _user_owns_deck(user, deck):
            return _err("forbidden", "Нет доступа к этой колоде", 403)
        cur = conn.execute(
            "INSERT INTO cards (deck_id, front, back, note) VALUES (?, ?, ?, ?)",
            (deck_id, parsed["front"], parsed["back"], parsed["note"]))
        _recalc_deck_flags(conn, deck_id)
        conn.commit()
        row = _load_card_row(conn, deck_id, cur.lastrowid)
    finally:
        conn.close()
    return jsonify({"data": _serialize_card(row, _resolve_lang(user))}), 201


@decks_bp.route("/<int:deck_id>/cards/<int:card_id>", methods=["PUT", "PATCH"])
@jwt_auth.jwt_required
def put_update_card(deck_id, card_id):
    user = g.current_user
    parsed, err = _validate_card_payload(request.get_json(silent=True), partial=True)
    if err:
        return _err("validation_error", err, 400)
    if not parsed:
        return _err("validation_error", "no fields to update", 400)

    conn = db.get_conn()
    try:
        deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
        if deck is None:
            return _err("not_found", "Колода не найдена", 404)
        if not _user_owns_deck(user, deck):
            return _err("forbidden", "Нет доступа к этой колоде", 403)
        existing = conn.execute(
            "SELECT id FROM cards WHERE id=? AND deck_id=?", (card_id, deck_id)).fetchone()
        if existing is None:
            return _err("not_found", "Карточка не найдена", 404)
        sets = ", ".join(f"{f}=?" for f in parsed)
        conn.execute(f"UPDATE cards SET {sets} WHERE id=? AND deck_id=?",
                     (*parsed.values(), card_id, deck_id))
        _recalc_deck_flags(conn, deck_id)
        conn.commit()
        row = _load_card_row(conn, deck_id, card_id)
    finally:
        conn.close()
    return jsonify({"data": _serialize_card(row, _resolve_lang(user))})


@decks_bp.route("/<int:deck_id>/cards/<int:card_id>", methods=["DELETE"])
@jwt_auth.jwt_required
def delete_card(deck_id, card_id):
    user = g.current_user
    conn = db.get_conn()
    try:
        deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
        if deck is None:
            return _err("not_found", "Колода не найдена", 404)
        if not _user_owns_deck(user, deck):
            return _err("forbidden", "Нет доступа к этой колоде", 403)
        cur = conn.execute("DELETE FROM cards WHERE id=? AND deck_id=?", (card_id, deck_id))
        if cur.rowcount == 0:
            return _err("not_found", "Карточка не найдена", 404)
        _recalc_deck_flags(conn, deck_id)
        conn.commit()
    finally:
        conn.close()
    return jsonify({"data": {"deleted": True}})


# ---------------------------------------------------------------------------
# POST /api/v1/study/grade
# ---------------------------------------------------------------------------

def _validate_grade_payload(body):
    """Validate a client-submitted, pre-computed SM-2 result.

    Returns (parsed, None) on success or (None, message) on a validation failure.
    Bounds-checks against the mobile client's own constants/domain (see module
    docstring) — this is a sanity net around values the client already computed,
    not a recomputation of the SM-2 formula.
    """
    card_id = body.get("card_id")
    deck_id = body.get("deck_id")
    if card_id is None or deck_id is None:
        return None, "card_id and deck_id are required"
    card_id = str(card_id)
    deck_id = str(deck_id)

    grade = body.get("grade")
    if isinstance(grade, bool) or not isinstance(grade, int) or grade not in _VALID_GRADES:
        return None, "grade must be one of 1, 3, 4, 5"

    try:
        ease_factor = float(body.get("new_ease_factor"))
        interval = int(body.get("new_interval"))
        repetitions = int(body.get("new_repetitions"))
    except (TypeError, ValueError):
        return None, "new_ease_factor, new_interval and new_repetitions must be numeric"

    if not (_EF_MIN - 1e-3 <= ease_factor <= _EF_MAX + 1e-3):
        return None, f"new_ease_factor must be within [{_EF_MIN}, {_EF_MAX}]"
    ease_factor = max(_EF_MIN, min(_EF_MAX, ease_factor))

    if not (_INTERVAL_MIN <= interval <= _INTERVAL_MAX):
        return None, f"new_interval must be within [{_INTERVAL_MIN}, {_INTERVAL_MAX}]"

    if repetitions < 0:
        return None, "new_repetitions must be >= 0"
    if grade == 1 and repetitions != 0:
        # Mobile's lapse path (CardGrade.again -> sm2Value 1) always resets repetitions to 0.
        return None, "new_repetitions must be 0 for an 'again' grade"

    next_review_at = _parse_iso(body.get("next_review_at"))
    graded_at = _parse_iso(body.get("graded_at"))
    if next_review_at is None or graded_at is None:
        return None, "next_review_at and graded_at must be ISO-8601 timestamps"

    now = datetime.utcnow()
    if graded_at > now + _FUTURE_TOLERANCE:
        return None, "graded_at is too far in the future"
    if graded_at < now - _PAST_TOLERANCE:
        return None, "graded_at is too far in the past"
    # For an interval-0 "Again" grade next_review_at == graded_at; the client
    # computes the two from separate clock reads, so allow a small skew.
    if next_review_at < graded_at - _FUTURE_TOLERANCE:
        return None, "next_review_at cannot be before graded_at"
    if next_review_at > graded_at + timedelta(days=_INTERVAL_MAX):
        return None, "next_review_at is out of range"

    # FSRS scheduler state (optional — older clients won't send these).
    def _opt_float(v):
        try:
            return float(v) if v is not None else None
        except (TypeError, ValueError):
            return None

    return {
        "card_id": card_id,
        "deck_id": deck_id,
        "grade": grade,
        "ease_factor": round(ease_factor, 3),
        "stability": _opt_float(body.get("new_stability")),
        "difficulty": _opt_float(body.get("new_difficulty")),
        "interval": interval,
        "repetitions": repetitions,
        "next_review_at": next_review_at.isoformat(),
        "graded_at": graded_at.isoformat(),
    }, None


def _xp_for_grade(grade):
    return 5 if grade == 5 else 3 if grade == 4 else 1 if grade == 3 else 0


# Anti-grind: repeating the SAME card on the SAME (UTC) day yields less and less
# XP, so users can't farm levels by replaying one deck. Resets every day, so
# genuine daily review still pays. `prior` = times this card was already
# reviewed today (0 = first time today → full XP).
_DAILY_XP_DECAY = (1.0, 0.85, 0.7, 0.5, 0.25)


def decay_xp(base, prior):
    if base <= 0:
        return 0
    mult = _DAILY_XP_DECAY[prior] if prior < len(_DAILY_XP_DECAY) else 0.1
    return max(1, round(base * mult))


def bump_streak(conn, user, xp_gain, graded_at_iso):
    """Mirrors the existing web grading routes' streak/XP bookkeeping (app.py)."""
    new_xp = (user["xp"] or 0) + xp_gain
    today = datetime.utcnow().date().isoformat()
    last = (user["last_study"] or "")[:10]
    streak = user["streak"] or 0
    if last != today:
        yesterday = (datetime.utcnow().date() - timedelta(days=1)).isoformat()
        streak = streak + 1 if last == yesterday else 1
    conn.execute("""
        UPDATE users 
        SET xp=?, streak=?, max_streak=MAX(COALESCE(max_streak, 0), ?), last_study=? 
        WHERE id=?
    """, (new_xp, streak, streak, datetime.utcnow().isoformat(), user["id"]))
    return streak


@study_bp.route("/grade", methods=["POST"])
@jwt_auth.jwt_required
def post_grade():
    user = g.current_user
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Ожидается JSON-тело запроса", 400)

    parsed, err = _validate_grade_payload(body)
    if err:
        return _err("validation_error", err, 400)

    conn = db.get_conn()
    try:
        card = conn.execute("SELECT * FROM cards WHERE id=? AND deck_id=?",
                            (parsed["card_id"], parsed["deck_id"])).fetchone()
        if card is None:
            return _err("not_found", "Карта не найдена", 404)

        # Idempotency: (user_id, card_id, graded_at) uniquely identifies one grading
        # event on the client. A retried sync (e.g. after a dropped connection) hits
        # the UNIQUE constraint and is treated as a no-op — same response, no double
        # XP/streak/progress application. This is the "sync support for pending
        # grades": the endpoint itself is safe to retry, no separate batch API needed.
        cur = conn.execute(
            """INSERT OR IGNORE INTO study_grade_log
               (user_id, card_id, graded_at, grade, ease_factor, interval_days,
                repetitions, next_review_at)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
            (user["id"], parsed["card_id"], parsed["graded_at"], parsed["grade"],
             parsed["ease_factor"], parsed["interval"], parsed["repetitions"],
             parsed["next_review_at"]))
        already_applied = cur.rowcount == 0

        xp_gain = 0
        streak = user["streak"] or 0

        if not already_applied:
            prior = conn.execute(
                "SELECT reviews, lapses, is_favorite, is_difficult FROM user_card_progress "
                "WHERE user_id=? AND card_id=?", (user["id"], parsed["card_id"])).fetchone()
            reviews = ((prior["reviews"] if prior else 0) or 0) + 1
            lapses = ((prior["lapses"] if prior else 0) or 0) + (1 if parsed["grade"] < 3 else 0)

            conn.execute("""
                INSERT OR REPLACE INTO user_card_progress
                    (user_id, card_id, ef, interval_days, repetitions, reviews, lapses,
                     due_at, last_grade, last_reviewed, is_favorite, is_difficult)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                    COALESCE(?, 0), COALESCE(?, 0))
            """, (user["id"], parsed["card_id"], parsed["ease_factor"], parsed["interval"],
                  parsed["repetitions"], reviews, lapses, parsed["next_review_at"],
                  parsed["grade"], parsed["graded_at"],
                  prior["is_favorite"] if prior else 0,
                  prior["is_difficult"] if prior else 0))
            # FSRS state, when the client computed it (older clients omit it).
            if parsed["stability"] is not None and parsed["difficulty"] is not None:
                conn.execute(
                    "UPDATE user_card_progress SET stability=?, difficulty=? "
                    "WHERE user_id=? AND card_id=?",
                    (parsed["stability"], parsed["difficulty"], user["id"], parsed["card_id"]))
            conn.execute(
                "INSERT INTO reviews (user_id, card_id, grade, reviewed_at) VALUES (?, ?, ?, ?)",
                (user["id"], parsed["card_id"], parsed["grade"], parsed["graded_at"]))

            # Diminishing returns: count today's reviews of THIS card (the row we
            # just inserted is included, so subtract it to get prior repeats).
            today_count = conn.execute(
                "SELECT COUNT(*) AS c FROM reviews "
                "WHERE user_id=? AND card_id=? AND substr(reviewed_at,1,10)=?",
                (user["id"], parsed["card_id"], parsed["graded_at"][:10])).fetchone()["c"]
            prior_today = max(0, (today_count or 1) - 1)
            xp_gain = decay_xp(_xp_for_grade(parsed["grade"]), prior_today)
            streak = bump_streak(conn, user, xp_gain, parsed["graded_at"])
            ach_mod.check_and_award(conn, user["id"])
            conn.commit()

        progress = conn.execute(
            "SELECT * FROM user_card_progress WHERE user_id=? AND card_id=?",
            (user["id"], parsed["card_id"])).fetchone()
    finally:
        conn.close()

    return jsonify({"data": {
        "card_id": str(parsed["card_id"]),
        "ease_factor": progress["ef"],
        "interval_days": progress["interval_days"],
        "repetitions": progress["repetitions"] or 0,
        "next_review_at": progress["due_at"],
        "xp_gained": xp_gain,
        "streak": streak,
        "already_applied": already_applied,
    }})


# ---------------------------------------------------------------------------
# POST /api/v1/study/sessions  &  GET /api/v1/study/sessions/<id>
# ---------------------------------------------------------------------------

_SESSION_INT_FIELDS = (
    "total_cards", "new_cards", "review_cards", "again_count",
    "hard_count", "good_count", "easy_count", "duration_seconds",
)


def _validate_session_payload(body):
    session_id = body.get("id")
    if not isinstance(session_id, str) or not session_id.strip():
        return None, "id must be a non-empty string"
    if len(session_id) > 64:
        return None, "id is too long"

    try:
        deck_id = int(body.get("deck_id"))
    except (TypeError, ValueError):
        return None, "deck_id must be a numeric identifier"

    parsed = {"id": session_id.strip(), "deck_id": deck_id}
    for field in _SESSION_INT_FIELDS:
        try:
            value = int(body.get(field))
        except (TypeError, ValueError):
            return None, f"{field} must be an integer"
        if value < 0:
            return None, f"{field} must be >= 0"
        parsed[field] = value

    completed_at = _parse_iso(body.get("completed_at"))
    if completed_at is None:
        return None, "completed_at must be an ISO-8601 timestamp"
    now = datetime.utcnow()
    if completed_at > now + _FUTURE_TOLERANCE:
        return None, "completed_at is too far in the future"
    if completed_at < now - _PAST_TOLERANCE:
        return None, "completed_at is too far in the past"
    parsed["completed_at"] = completed_at.isoformat()

    return parsed, None


def _serialize_session(row):
    return {
        "id": row["id"],
        "deck_id": str(row["deck_id"]),
        "total_cards": row["total_cards"],
        "new_cards": row["new_cards"],
        "review_cards": row["review_cards"],
        "again_count": row["again_count"],
        "hard_count": row["hard_count"],
        "good_count": row["good_count"],
        "easy_count": row["easy_count"],
        "duration_seconds": row["duration_seconds"],
        "completed_at": row["completed_at"],
    }


@study_bp.route("/sessions", methods=["POST"])
@jwt_auth.jwt_required
def post_session():
    user = g.current_user
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Ожидается JSON-тело запроса", 400)

    parsed, err = _validate_session_payload(body)
    if err:
        return _err("validation_error", err, 400)

    conn = db.get_conn()
    try:
        deck = conn.execute("SELECT id FROM decks WHERE id=?", (parsed["deck_id"],)).fetchone()
        if deck is None:
            return _err("not_found", "Колода не найдена", 404)

        # Idempotent by (user_id, id) — a client-generated UUID. Re-POSTing the same
        # session (sync retry) is a no-op; we always return the persisted record.
        conn.execute("""
            INSERT OR IGNORE INTO study_sessions
                (id, user_id, deck_id, total_cards, new_cards, review_cards, again_count,
                 hard_count, good_count, easy_count, duration_seconds, completed_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (parsed["id"], user["id"], parsed["deck_id"], parsed["total_cards"],
              parsed["new_cards"], parsed["review_cards"], parsed["again_count"],
              parsed["hard_count"], parsed["good_count"], parsed["easy_count"],
              parsed["duration_seconds"], parsed["completed_at"]))
        conn.commit()

        row = conn.execute("SELECT * FROM study_sessions WHERE user_id=? AND id=?",
                           (user["id"], parsed["id"])).fetchone()
    finally:
        conn.close()

    return jsonify({"data": _serialize_session(row)}), 201


@study_bp.route("/sessions/<session_id>", methods=["GET"])
@jwt_auth.jwt_required
def get_session(session_id):
    user = g.current_user
    conn = db.get_conn()
    try:
        row = conn.execute("SELECT * FROM study_sessions WHERE user_id=? AND id=?",
                           (user["id"], session_id)).fetchone()
    finally:
        conn.close()

    if row is None:
        return _err("not_found", "Сессия не найдена", 404)
    return jsonify({"data": _serialize_session(row)})
