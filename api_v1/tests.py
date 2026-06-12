# -*- coding: utf-8 -*-
"""Test (quiz) endpoints for the mobile /api/v1 layer — Phase 4.

Scope decision (see audit report): the mobile Tests module's "setup" and
"session" UI state (`TestSetupNotifier`/`TestConfig`, `TestSessionNotifier`)
are 100% local Riverpod state — `TestConfig` is never serialized or sent to
the server, and scoring/weak-area analysis happens entirely on-device. Of the
five categories in the original request, only three actually touch the
network:

  GET  /api/v1/decks/<id>/test-questions   — fetch MCQ questions for a deck
  POST /api/v1/test/results                — submit a completed test result
  GET  /api/v1/test/history?deckId=<id>    — list past results for a deck

Offline-first design (mirrors Phase 3's grade-sync pattern):
  The mobile client takes the test fully offline (cached questions, local
  scoring), saves the result locally first, and retries `submitResult` later
  if the initial sync fails (`syncPendingResults`). It generates a 32-char hex
  `id` client-side. `client_result_id` + a partial unique index on
  `test_attempts(user_id, client_result_id)` (see db.py) make POST idempotent:
  a retried submission is a no-op and always returns the persisted record —
  exactly like `study_grade_log`/`study_sessions` in api_v1.study.

Reuses the existing `test_attempts` table (the "reuse existing structures"
requirement): `scope_type='deck'`, `scope_id`=deck id, `scope_name`=deck title
(denormalized, matching the mobile TestHistoryDto's required `deck_title`).
Legacy web-submitted attempts have `client_result_id IS NULL` and are
untouched — `id=srv_<int id>` is synthesized for them so every row has a
collision-free string id (mobile's `TestHistoryDto.id` is a String).

MCQ parsing duplication (deliberate isolation choice):
  `_parse_mcq_options` below is a direct port of `app.py:_parse_card_options`
  — a small, pure regex parser with no Flask/session dependencies. It is
  duplicated here rather than imported because `app.py` imports its blueprints
  FROM `api_v1` (importing back from `api_v1` to `app` would be circular), and
  because `api_v1` is documented as fully isolated from `app.py` (see
  api_v1/__init__.py). If the MCQ format conventions in `_parse_card_options`
  ever change, update this copy to match so the mobile and web test flows keep
  seeing the same questions/answers for the same cards.
"""
import random
import re
from datetime import datetime, timedelta, timezone

from flask import Blueprint, g, jsonify, request

import db

from . import jwt_auth

test_questions_bp = Blueprint("api_v1_test_questions", __name__, url_prefix="/api/v1/decks")
tests_bp = Blueprint("api_v1_test", __name__, url_prefix="/api/v1/test")

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


# ---------------------------------------------------------------------------
# MCQ option parsing — ported from app.py:_parse_card_options (see module
# docstring for why this is duplicated rather than imported)
# ---------------------------------------------------------------------------

_MCQ_OPTION_RE = re.compile(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]\s*(.+)$")
_MCQ_LETTER_PREFIX_RE = re.compile(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]")
_MCQ_NEW_LETTERS = ["A", "B", "C", "D", "E", "F", "G", "H"]


def _extract_options(src):
    """Pull lettered option lines ("A) ...", "B) ...") out of a text block."""
    options = []
    for line in (src or "").splitlines():
        line = line.strip()
        if not line:
            continue
        m = _MCQ_OPTION_RE.match(line)
        if m:
            options.append({"letter": m.group(1).upper(), "text": m.group(2).strip()})
    return options


def _mcq_stem(front):
    """Question text with any lettered option lines stripped off.

    Quiz/AI-generated decks frequently inline the answer choices into the card
    front ("What is X?\\nA) ...\\nB) ..."); for the test UI we only want the
    question stem, since the options are rendered as tappable buttons.
    """
    kept = [
        line for line in (front or "").splitlines()
        if not _MCQ_LETTER_PREFIX_RE.match(line.strip())
    ]
    stem = "\n".join(kept).strip()
    return stem or (front or "")


def _parse_mcq_options(card_dict, shuffle_seed=None):
    """Split a card into lettered options + find the correct letter.

    Options may live in `note`/`back` (canonical web format) or be inlined in
    the `front` (quiz/AI-generated decks). We scan all three and use whichever
    yields the richest option list, so both layouts produce a valid test.

    With shuffle_seed given, options are shuffled deterministically (seeded by
    `(shuffle_seed << 8) ^ card_id`, exactly like the web flow) and relettered
    A/B/C/... so the same seed always reproduces the same order for a card.
    """
    options = max(
        (
            _extract_options(card_dict.get("note")),
            _extract_options(card_dict.get("front")),
            _extract_options(card_dict.get("back")),
        ),
        key=len,
    )

    correct_letter = None
    back_first = (card_dict.get("back") or "").strip().split("\n")[0]
    m_corr = _MCQ_LETTER_PREFIX_RE.match(back_first)
    if m_corr:
        correct_letter = m_corr.group(1).upper()

    # Fallbacks for decks that don't use the "C) ..." lettered-answer form:
    #   • a bare answer letter ("С"), or
    #   • the full answer text matching one of the options.
    if correct_letter is None and options:
        bare = back_first.strip()
        if len(bare) == 1 and any(o["letter"] == bare.upper() for o in options):
            correct_letter = bare.upper()
        else:
            for o in options:
                if o["text"].strip().lower() == bare.lower():
                    correct_letter = o["letter"]
                    break

    if shuffle_seed is not None and options:
        correct_text = None
        if correct_letter:
            for o in options:
                if o["letter"] == correct_letter:
                    correct_text = o["text"]
                    break
        rnd = random.Random((shuffle_seed << 8) ^ (card_dict.get("id") or 0))
        rnd.shuffle(options)
        for i, o in enumerate(options):
            o["letter"] = _MCQ_NEW_LETTERS[i] if i < len(_MCQ_NEW_LETTERS) else str(i + 1)
        if correct_text is not None:
            for o in options:
                if o["text"] == correct_text:
                    correct_letter = o["letter"]
                    break

    return options, correct_letter


def _build_test_question(card_row, shuffle_seed):
    """Build a TestQuestionDto-shaped dict, or None if the card isn't an MCQ."""
    options, correct_letter = _parse_mcq_options(dict(card_row), shuffle_seed=shuffle_seed)
    if len(options) < 2 or correct_letter is None:
        return None

    correct_text = None
    option_dtos = []
    for opt in options:
        is_correct = (opt["letter"] == correct_letter)
        if is_correct:
            correct_text = opt["text"]
        option_dtos.append({"id": opt["letter"], "text": opt["text"], "is_correct": is_correct})
    if correct_text is None:
        return None

    return {
        "id": str(card_row["id"]),
        "deck_id": str(card_row["deck_id"]),
        "question": _mcq_stem(card_row["front"]),
        "correct_answer": correct_text,
        "options": option_dtos,
        "topic": None,
    }


# ---------------------------------------------------------------------------
# GET /api/v1/decks/<id>/test-questions
# ---------------------------------------------------------------------------

@test_questions_bp.route("/<int:deck_id>/test-questions", methods=["GET"])
@jwt_auth.jwt_required
def get_test_questions(deck_id):
    user = g.current_user
    conn = db.get_conn()
    try:
        deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
        if deck is None:
            return _err("not_found", "Колода не найдена", 404)
        if not _user_owns_deck(user, deck) and not deck["is_public"]:
            return _err("forbidden", "Нет доступа к этой колоде", 403)

        rows = conn.execute(
            "SELECT id, deck_id, front, back, note FROM cards WHERE deck_id=? ORDER BY id",
            (deck_id,),
        ).fetchall()
    finally:
        conn.close()

    # Fresh per-request seed: mobile fetches once, caches, and shuffles/slices
    # locally per TestConfig — this just avoids "the correct answer is always A".
    shuffle_seed = random.randint(1, 10 ** 9)
    questions = []
    for row in rows:
        q = _build_test_question(row, shuffle_seed)
        if q is not None:
            questions.append(q)

    return jsonify({"data": questions})


# ---------------------------------------------------------------------------
# POST /api/v1/test/results
# ---------------------------------------------------------------------------

_RESULT_INT_FIELDS = ("total_questions", "correct_count", "duration_seconds")


def _validate_result_payload(body):
    result_id = body.get("id")
    if not isinstance(result_id, str) or not result_id.strip():
        return None, "id must be a non-empty string"
    if len(result_id) > 64:
        return None, "id is too long"

    try:
        deck_id = int(body.get("deck_id"))
    except (TypeError, ValueError):
        return None, "deck_id must be a numeric identifier"

    parsed = {"id": result_id.strip(), "deck_id": deck_id}
    for field in _RESULT_INT_FIELDS:
        try:
            value = int(body.get(field))
        except (TypeError, ValueError):
            return None, f"{field} must be an integer"
        if value < 0:
            return None, f"{field} must be >= 0"
        parsed[field] = value

    if parsed["correct_count"] > parsed["total_questions"]:
        return None, "correct_count cannot exceed total_questions"

    completed_at = _parse_iso(body.get("completed_at"))
    if completed_at is None:
        return None, "completed_at must be an ISO-8601 timestamp"
    now = datetime.utcnow()
    if completed_at > now + _FUTURE_TOLERANCE:
        return None, "completed_at is too far in the future"
    if completed_at < now - _PAST_TOLERANCE:
        return None, "completed_at is too far in the past"
    parsed["completed_at"] = completed_at

    return parsed, None


def _serialize_test_attempt(row):
    return {
        "id": row["client_result_id"] or f"srv_{row['id']}",
        "deck_id": str(row["scope_id"]),
        "deck_title": row["scope_name"] or "",
        "total_questions": row["total_q"],
        "correct_count": row["correct"],
        "duration_seconds": row["duration_sec"] or 0,
        "completed_at": row["finished_at"],
    }


@tests_bp.route("/results", methods=["POST"])
@jwt_auth.jwt_required
def post_test_result():
    user = g.current_user
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Ожидается JSON-тело запроса", 400)

    parsed, err = _validate_result_payload(body)
    if err:
        return _err("validation_error", err, 400)

    conn = db.get_conn()
    try:
        deck = conn.execute("SELECT id, name FROM decks WHERE id=?", (parsed["deck_id"],)).fetchone()
        if deck is None:
            return _err("not_found", "Колода не найдена", 404)

        completed_at = parsed["completed_at"]
        started_at = completed_at - timedelta(seconds=parsed["duration_seconds"])
        wrong = parsed["total_questions"] - parsed["correct_count"]
        score_pct = (parsed["correct_count"] / parsed["total_questions"] * 100.0) if parsed["total_questions"] else 0.0
        is_perfect = 1 if (wrong == 0 and parsed["correct_count"] > 0) else 0

        # Idempotent by (user_id, client_result_id) — re-POSTing the same
        # client-generated id (a sync retry) is a no-op; we always return the
        # persisted record (mirrors POST /api/v1/study/sessions).
        conn.execute("""
            INSERT OR IGNORE INTO test_attempts
                (user_id, scope_type, scope_id, scope_name, total_q, correct, wrong,
                 score_pct, duration_sec, is_perfect, started_at, finished_at, client_result_id)
            VALUES (?, 'deck', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (user["id"], parsed["deck_id"], deck["name"], parsed["total_questions"],
              parsed["correct_count"], wrong, score_pct, parsed["duration_seconds"],
              is_perfect, started_at.isoformat(), completed_at.isoformat(), parsed["id"]))
        conn.commit()

        row = conn.execute("SELECT * FROM test_attempts WHERE user_id=? AND client_result_id=?",
                           (user["id"], parsed["id"])).fetchone()
    finally:
        conn.close()

    return jsonify({"data": _serialize_test_attempt(row)}), 201


# ---------------------------------------------------------------------------
# GET /api/v1/test/history?deckId=<id>
# ---------------------------------------------------------------------------

@tests_bp.route("/history", methods=["GET"])
@jwt_auth.jwt_required
def get_test_history():
    user = g.current_user
    try:
        deck_id = int(request.args.get("deckId"))
    except (TypeError, ValueError):
        return _err("validation_error", "deckId must be a numeric identifier", 400)

    conn = db.get_conn()
    try:
        rows = conn.execute("""
            SELECT * FROM test_attempts
            WHERE user_id=? AND scope_type='deck' AND scope_id=?
            ORDER BY finished_at DESC
        """, (user["id"], deck_id)).fetchall()
    finally:
        conn.close()

    return jsonify({"data": [_serialize_test_attempt(r) for r in rows]})
