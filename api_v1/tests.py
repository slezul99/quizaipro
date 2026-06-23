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
import achievements as ach_mod
from .study import bump_streak

from . import jwt_auth

test_questions_bp = Blueprint("api_v1_test_questions", __name__, url_prefix="/api/v1/decks")
tests_bp = Blueprint("api_v1_test", __name__, url_prefix="/api/v1/test")

_FUTURE_TOLERANCE = timedelta(minutes=5)
_PAST_TOLERANCE = timedelta(days=90)

TEST_XP_PER_CORRECT = 3
TEST_XP_PERFECT_BONUS = 5


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


def _localize_card(card_dict, lang):
    """Swap front/back/note for their _en/_uz translation if one exists.

    Mirrors app.py:flashcards_view's localization step so mobile test
    questions and flashcards match the seeded translation columns.
    """
    if lang in ("en", "uz"):
        for fld in ("front", "back", "note"):
            tr = card_dict.get(f"{fld}_{lang}")
            if tr:
                card_dict[fld] = tr
    return card_dict


# ---------------------------------------------------------------------------
# MCQ option parsing — ported from app.py:_parse_card_options (see module
# docstring for why this is duplicated rather than imported)
# ---------------------------------------------------------------------------

_MCQ_OPTION_RE = re.compile(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]\s*(.+)$")
_MCQ_LETTER_PREFIX_RE = re.compile(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]")
_MCQ_NEW_LETTERS = ["A", "B", "C", "D", "E", "F", "G", "H"]


def _normalize_card_newlines(text):
    """Convert literal backslash-n escapes (from double-escaped JSON exports,
    e.g. ``"A) x\\nB) y"``) back into real newlines so option parsing — which
    splits on real newlines — works. Idempotent on already-clean text."""
    if not text or "\\" not in text:
        return text
    return (text.replace("\\r\\n", "\n")
                .replace("\\n", "\n")
                .replace("\\r", "\n"))


def _extract_options(src):
    """Pull lettered option lines ("A) ...", "B) ...") out of a text block."""
    options = []
    for line in _normalize_card_newlines(src or "").splitlines():
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
        line for line in _normalize_card_newlines(front or "").splitlines()
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
    back_first = _normalize_card_newlines(
        (card_dict.get("back") or "")).strip().split("\n")[0]
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
            """SELECT id, deck_id, front, back, note,
                      front_en, front_uz, back_en, back_uz, note_en, note_uz
               FROM cards WHERE deck_id=? ORDER BY id""",
            (deck_id,),
        ).fetchall()
    finally:
        conn.close()

    # Fresh per-request seed: mobile fetches once, caches, and shuffles/slices
    # locally per TestConfig — this just avoids "the correct answer is always A".
    shuffle_seed = random.randint(1, 10 ** 9)
    lang = _resolve_lang(user)
    questions = []
    for row in rows:
        card = _localize_card(dict(row), lang)
        q = _build_test_question(card, shuffle_seed)
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


def _save_attempt_answers(conn, attempt_id, answers):
    """Persist per-question answers into test_attempt_answers (mirrors the web
    flow in app.py) so the dashboard activity feed can show the full Q&A.

    Lenient by design: a malformed/missing answers list never breaks result
    submission — the attempt summary is what matters for XP/streak."""
    if not attempt_id or not isinstance(answers, list):
        return
    for pos, ans in enumerate(answers, 1):
        if not isinstance(ans, dict):
            continue
        try:
            position = int(ans.get("position", pos))
            is_correct = 1 if ans.get("is_correct") else 0
            ans_xp = TEST_XP_PER_CORRECT if is_correct else 0
            card_id = ans.get("card_id")
            card_id = int(card_id) if card_id is not None else None
            conn.execute("""
                INSERT INTO test_attempt_answers
                (attempt_id, position, card_id, front, back, note, chosen, correct, is_correct, xp_earned)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                attempt_id, position, card_id,
                str(ans.get("front") or "")[:4000],
                str(ans.get("back") or "")[:4000],
                str(ans.get("note") or "")[:4000],
                str(ans.get("chosen") or ""),
                str(ans.get("correct") or ""),
                is_correct, ans_xp,
            ))
        except Exception as e:
            print(f"[test_result answers] skipped answer {pos}: {e}")


# Anti-grind: a correct answer on a question (card) already seen today — in
# tests OR flashcard reviews — is worth progressively less. New questions pay
# full, so "same deck, different questions" still rewards properly. Resets daily.
_DAILY_XP_DECAY = (1.0, 0.85, 0.7, 0.5, 0.25)


def _decay_xp(base, prior):
    if base <= 0:
        return 0
    mult = _DAILY_XP_DECAY[prior] if prior < len(_DAILY_XP_DECAY) else 0.1
    return max(1, round(base * mult))


def _compute_test_xp(conn, user_id, day_iso, answers, correct_count, is_perfect):
    """Per-question diminishing XP. Falls back to the flat formula when the
    client didn't send a usable answers list (older clients)."""
    bonus = TEST_XP_PERFECT_BONUS if is_perfect else 0
    if not isinstance(answers, list) or not answers:
        return correct_count * TEST_XP_PER_CORRECT + bonus

    correct_cards = []
    correct_no_card = 0
    for ans in answers:
        if not isinstance(ans, dict) or not ans.get("is_correct"):
            continue
        cid = ans.get("card_id")
        try:
            cid = int(cid) if cid is not None else None
        except (TypeError, ValueError):
            cid = None
        if cid is None:
            correct_no_card += 1
        else:
            correct_cards.append(cid)

    if not correct_cards:
        return correct_no_card * TEST_XP_PER_CORRECT + bonus

    ids = list(set(correct_cards))
    ph = ",".join("?" for _ in ids)
    prior = {cid: 0 for cid in ids}
    for row in conn.execute(
            f"SELECT taa.card_id AS cid, COUNT(*) AS c FROM test_attempt_answers taa "
            f"JOIN test_attempts ta ON ta.id = taa.attempt_id "
            f"WHERE ta.user_id=? AND substr(ta.finished_at,1,10)=? AND taa.card_id IN ({ph}) "
            f"GROUP BY taa.card_id", (user_id, day_iso, *ids)):
        prior[row["cid"]] = prior.get(row["cid"], 0) + (row["c"] or 0)
    for row in conn.execute(
            f"SELECT card_id AS cid, COUNT(*) AS c FROM reviews "
            f"WHERE user_id=? AND substr(reviewed_at,1,10)=? AND card_id IN ({ph}) "
            f"GROUP BY card_id", (user_id, day_iso, *ids)):
        prior[row["cid"]] = prior.get(row["cid"], 0) + (row["c"] or 0)

    total = correct_no_card * TEST_XP_PER_CORRECT
    seen = {}
    for cid in correct_cards:
        p = prior.get(cid, 0) + seen.get(cid, 0)
        total += _decay_xp(TEST_XP_PER_CORRECT, p)
        seen[cid] = seen.get(cid, 0) + 1
    return total + bonus


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

        # Diminishing returns per repeated question (resets daily); perfect
        # bonus stays flat. Falls back to the flat formula for old clients.
        xp_gain = _compute_test_xp(
            conn, user["id"], completed_at.date().isoformat(),
            body.get("answers"), parsed["correct_count"], is_perfect)

        # Idempotent by (user_id, client_result_id) — re-POSTing the same
        # client-generated id (a sync retry) is a no-op; we always return the
        # persisted record (mirrors POST /api/v1/study/sessions).
        cur = conn.execute("""
            INSERT OR IGNORE INTO test_attempts
                (user_id, scope_type, scope_id, scope_name, total_q, correct, wrong,
                 score_pct, duration_sec, is_perfect, xp_earned, started_at, finished_at, client_result_id)
            VALUES (?, 'deck', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (user["id"], parsed["deck_id"], deck["name"], parsed["total_questions"],
              parsed["correct_count"], wrong, score_pct, parsed["duration_seconds"],
              is_perfect, xp_gain, started_at.isoformat(), completed_at.isoformat(), parsed["id"]))
        already_applied = cur.rowcount == 0

        if not already_applied:
            attempt_id = cur.lastrowid
            _save_attempt_answers(conn, attempt_id, body.get("answers"))
            bump_streak(conn, user, xp_gain, completed_at.isoformat())
            ach_mod.award_test_completed(conn, user["id"], perfect=(is_perfect == 1))
            ach_mod.check_and_award(conn, user["id"])

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
