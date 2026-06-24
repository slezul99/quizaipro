# -*- coding: utf-8 -*-
"""AI Generation endpoints for the mobile /api/v1 layer — Phase 6.

Async job architecture (the "support async generation jobs" requirement):
  The web app already runs AI generation in background threads via
  `ai_gen_jobs.py`, but that tracker is in-memory + disk-JSON-snapshot only —
  fine for a single browser session's progress page, but it can't back a
  persisted `GET /api/v1/ai/jobs` history list (`GenerationHistoryNotifier`)
  that must survive app/server restarts. So mobile generation jobs get their
  own DB-backed table (`ai_generation_jobs`, see db.py) and their own
  lightweight background-thread runner (`_run_generation_job` below) — same
  "create job, run in a thread, poll for status" shape as `ai_gen_jobs`, but
  writing progress straight to SQLite instead of an in-memory dict. Job ids
  are server-generated (mobile never sends one — see
  `AiGenerationRemoteDataSource.generateFromTopic/text/pdf`), so unlike Phase
  5 conversations there is no client-id idempotency layer to build.

Card generation: reuses `ai_gen.generate_from_topic/text/pdf` AS-IS — the
exact same functions (and batching-for-large-counts strategy) as the web
`/ai` route's `gen_fn` closures — satisfying "reuse existing AI infrastructure"
with zero changes to the generation prompts/logic. Only the *framing* differs:
the web flow saves `{front, back, note}` cards straight into a deck, while the
mobile `GenerationJobDto.cards` shape is `{question, answer, topic, difficulty}`
— `_card_to_dto` maps one to the other (see persistence-strategy notes below).

Quality mode mapping (documented, deliberate simplification): the mobile UI
exposes three tiers — fast / balanced / premium — but `ai_gen.generate_from_*`
only has a single binary `quality` flag (whether to run the slower
`_critique_and_improve` AI pass). The most faithful mapping without changing
`ai_gen.py`'s model is fast/balanced -> quality=False, premium -> quality=True;
"premium" is the only tier that pays for the extra critique pass, matching its
"~60 sec · best quality" UI label.

Persistence strategy: `requested_card_count`, `topic`/`input_text`/
`pdf_file_name`, `quality_mode`, `cards_json` (the mapped DTO-shape array),
`error_message`, `result_deck_id` and timestamps are stored directly on
`ai_generation_jobs` — a flat row mirrors `GenerationJobDto` almost field for
field, so serialization is a straight passthrough (`_serialize_job`). Per-card
`topic`/`difficulty` are NOT persisted on `cards` (no such columns exist there
— mirrors the web `save_fn`, which only ever writes `front/back/note`); they
live only inside the job's `cards_json` snapshot, which is exactly what the
mobile module needs for its results/history screens.

File upload architecture: PDF uploads arrive as multipart/form-data
(`FormData.fromMap` with a `MultipartFile`) — handled with Flask's
`request.files`, saved to the same `uploads/` directory the web `/ai` route
uses (`Path(db._DATA_DIR) / "uploads"`, via `secure_filename`), processed
synchronously inside the background thread via the existing
`ai_gen.generate_from_pdf`, then deleted — identical lifecycle to the web
flow's `pdf_path_to_delete` cleanup.
"""
import json
import threading
import uuid
from datetime import datetime
from pathlib import Path

from flask import Blueprint, g, jsonify, request
from werkzeug.utils import secure_filename

import ai_gen
import billing
import db
import fsrs

from . import jwt_auth
from .auth import rate_limit

ai_generation_bp = Blueprint("api_v1_ai_generation", __name__, url_prefix="/api/v1/ai")

_UPLOAD_DIR = Path(db._DATA_DIR) / "uploads"
_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

_MIN_CARDS, _MAX_CARDS = 5, 50
_QUALITY_MODES = ("fast", "balanced", "premium")
_TOPIC_MAX_LEN = 200
_TEXT_MIN_LEN = 50
_TEXT_MAX_LEN = 20000
_QUESTION_MAX_LEN = 1000
_ANSWER_MAX_LEN = 4000
_BATCH_SIZE = 25


def _err(code, message, status):
    return jsonify({"error": {"code": code, "message": message}}), status


def _resolve_lang(user):
    """Mirrors api_v1.tutor._resolve_lang — mobile has no session cookie."""
    lang = request.args.get("lang") or (user["lang"] if user else None)
    return lang if lang in ("ru", "en", "uz") else "ru"


def _quality_to_flag(quality_mode):
    """fast/balanced -> quick pass; premium -> + AI critique pass (see module docstring)."""
    return quality_mode == "premium"


# ---------------------------------------------------------------------------
# Job persistence helpers
# ---------------------------------------------------------------------------

def _serialize_job(row):
    cards = json.loads(row["cards_json"]) if row["cards_json"] else []
    return {
        "id": row["id"],
        "source": row["source"],
        "status": row["status"],
        "progress": row["progress"],
        "topic": row["topic"],
        "input_text": row["input_text"],
        "pdf_file_name": row["pdf_file_name"],
        "quality_mode": row["quality_mode"],
        "requested_card_count": row["requested_card_count"],
        "cards": cards,
        "error_message": row["error_message"],
        "created_at": row["created_at"],
        "completed_at": row["completed_at"],
    }


def _card_to_dto(card, source, topic_label):
    """Maps ai_gen's {front, back, note} to GenerationJobDto's
    {question, answer, topic, difficulty} — see module docstring on why
    topic/difficulty are synthesized rather than sourced from the AI."""
    return {
        "question": card.get("front") or "",
        "answer": card.get("back") or "",
        "topic": topic_label,
        "difficulty": "medium",
    }


def _update_job(jid, **fields):
    if not fields:
        return
    set_clause = ", ".join(f"{k}=?" for k in fields)
    conn = db.get_conn()
    try:
        conn.execute(f"UPDATE ai_generation_jobs SET {set_clause} WHERE id=?",
                     (*fields.values(), jid))
        conn.commit()
    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Background generation runner
# ---------------------------------------------------------------------------

def _run_generation_job(jid, user_dict, source, topic_label, gen_fn, total_needed,
                         lang, pdf_path_to_delete=None):
    _update_job(jid, status="processing", progress=5)
    try:
        if total_needed <= _BATCH_SIZE:
            batches = [total_needed]
        else:
            full, remainder = divmod(total_needed, _BATCH_SIZE)
            batches = [_BATCH_SIZE] * full + ([remainder] if remainder else [])

        all_cards = []
        for i, batch_count in enumerate(batches):
            pct = int(10 + (i / len(batches)) * 65)
            _update_job(jid, progress=pct)
            batch = gen_fn(batch_count) or []
            all_cards.extend(batch)

        if not all_cards:
            _update_job(jid, status="failed", progress=0,
                        error_message="AI не смог сгенерировать карточки. Попробуйте конкретнее или повторите позже.",
                        completed_at=datetime.utcnow().isoformat())
            return

        _update_job(jid, progress=90)
        cards_dto = [_card_to_dto(c, source, topic_label) for c in all_cards]
        _update_job(jid, status="completed", progress=100,
                    cards_json=json.dumps(cards_dto, ensure_ascii=False),
                    completed_at=datetime.utcnow().isoformat())
        try:
            billing.log_ai_usage(user_dict, f"mobile_{source}", len(all_cards))
        except Exception as e:
            print(f"[ai_generation] log_ai_usage err (ignored): {e}")
    except Exception as e:
        err = str(e)[:300]
        print(f"[ai_generation:{jid}] error: {err}")
        _update_job(jid, status="failed", progress=0, error_message=f"Ошибка AI: {err}",
                    completed_at=datetime.utcnow().isoformat())
    finally:
        if pdf_path_to_delete is not None:
            try:
                pdf_path_to_delete.unlink(missing_ok=True)
            except Exception:
                pass


def _start_job(user, source, *, topic=None, input_text=None, pdf_file_name=None,
               quality_mode="balanced", card_count=10, gen_fn, topic_label,
               pdf_path_to_delete=None):
    jid = uuid.uuid4().hex
    lang = _resolve_lang(user)
    now = datetime.utcnow().isoformat()
    conn = db.get_conn()
    try:
        conn.execute("""
            INSERT INTO ai_generation_jobs
                (id, user_id, source, status, progress, topic, input_text, pdf_file_name,
                 quality_mode, requested_card_count, created_at)
            VALUES (?, ?, ?, 'pending', 0, ?, ?, ?, ?, ?, ?)
        """, (jid, user["id"], source, topic, input_text, pdf_file_name,
              quality_mode, card_count, now))
        conn.commit()
        row = conn.execute("SELECT * FROM ai_generation_jobs WHERE id=?", (jid,)).fetchone()
    finally:
        conn.close()

    user_dict = dict(user)
    t = threading.Thread(
        target=_run_generation_job,
        args=(jid, user_dict, source, topic_label, gen_fn, card_count, lang, pdf_path_to_delete),
        daemon=True,
    )
    t.start()
    return row


# ---------------------------------------------------------------------------
# POST /api/v1/ai/generate/topic | text | pdf
# ---------------------------------------------------------------------------

def _validate_card_count(body):
    raw = body.get("card_count", 10)
    try:
        count = int(raw)
    except (TypeError, ValueError):
        return None, "card_count must be an integer"
    if count < _MIN_CARDS or count > _MAX_CARDS:
        return None, f"card_count must be between {_MIN_CARDS} and {_MAX_CARDS}"
    return count, None


def _validate_quality_mode(body):
    mode = body.get("quality_mode", "balanced")
    if mode not in _QUALITY_MODES:
        return None, "quality_mode must be one of: fast, balanced, premium"
    return mode, None


@ai_generation_bp.route("/generate/topic", methods=["POST"])
@jwt_auth.jwt_required
def post_generate_topic():
    user = dict(g.current_user)
    if not (ai_gen.is_available() or ai_gen.is_deepseek_available()):
        return _err("ai_unavailable", "AI не настроен", 503)

    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Invalid JSON body", 400)

    topic = (body.get("topic") or "").strip()
    if not topic:
        return _err("validation_error", "topic is required", 400)
    if len(topic) > _TOPIC_MAX_LEN:
        return _err("validation_error", f"topic must be at most {_TOPIC_MAX_LEN} characters", 400)

    count, err = _validate_card_count(body)
    if err:
        return _err("validation_error", err, 400)
    quality_mode, err = _validate_quality_mode(body)
    if err:
        return _err("validation_error", err, 400)

    ok, used, limit = billing.check_ai_limit(user)
    if not ok:
        return _err("ai_limit_reached", f"Лимит AI достигнут: {used}/{limit} в месяц", 429)
    if not rate_limit(f"api_ai_generate:{user['id']}", max_attempts=10, window_seconds=60):
        return _err("rate_limited", "Слишком много запросов. Подождите немного.", 429)

    lang = _resolve_lang(user)
    quality_flag = _quality_to_flag(quality_mode)

    def gen_fn(c):
        return ai_gen.generate_from_topic(topic, c, lang, quality=quality_flag, output_lang="auto")

    row = _start_job(user, "topic", topic=topic, quality_mode=quality_mode,
                     card_count=count, gen_fn=gen_fn, topic_label=topic)
    return jsonify({"data": _serialize_job(row)}), 202


@ai_generation_bp.route("/generate/text", methods=["POST"])
@jwt_auth.jwt_required
def post_generate_text():
    user = dict(g.current_user)
    if not (ai_gen.is_available() or ai_gen.is_deepseek_available()):
        return _err("ai_unavailable", "AI не настроен", 503)

    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Invalid JSON body", 400)

    text = (body.get("text") or "").strip()
    if len(text) < _TEXT_MIN_LEN:
        return _err("validation_error", f"text must be at least {_TEXT_MIN_LEN} characters", 400)
    if len(text) > _TEXT_MAX_LEN:
        return _err("validation_error", f"text must be at most {_TEXT_MAX_LEN} characters", 400)

    count, err = _validate_card_count(body)
    if err:
        return _err("validation_error", err, 400)
    quality_mode, err = _validate_quality_mode(body)
    if err:
        return _err("validation_error", err, 400)

    ok, used, limit = billing.check_ai_limit(user)
    if not ok:
        return _err("ai_limit_reached", f"Лимит AI достигнут: {used}/{limit} в месяц", 429)
    if not rate_limit(f"api_ai_generate:{user['id']}", max_attempts=10, window_seconds=60):
        return _err("rate_limited", "Слишком много запросов. Подождите немного.", 429)

    lang = _resolve_lang(user)
    quality_flag = _quality_to_flag(quality_mode)
    label = text[:60] + "..." if len(text) > 60 else text

    def gen_fn(c):
        return ai_gen.generate_from_text(text, c, lang, quality=quality_flag, output_lang="auto")

    row = _start_job(user, "text", input_text=text, quality_mode=quality_mode,
                     card_count=count, gen_fn=gen_fn, topic_label=label)
    return jsonify({"data": _serialize_job(row)}), 202


@ai_generation_bp.route("/generate/pdf", methods=["POST"])
@jwt_auth.jwt_required
def post_generate_pdf():
    user = dict(g.current_user)
    if not (ai_gen.is_available() or ai_gen.is_deepseek_available()):
        return _err("ai_unavailable", "AI не настроен", 503)

    file = request.files.get("file")
    if not file or not file.filename:
        return _err("validation_error", "file is required", 400)
    if not file.filename.lower().endswith(".pdf"):
        return _err("validation_error", "file must be a PDF", 400)

    body = request.form
    count, err = _validate_card_count(body)
    if err:
        return _err("validation_error", err, 400)
    quality_mode, err = _validate_quality_mode(body)
    if err:
        return _err("validation_error", err, 400)

    ok, used, limit = billing.check_ai_limit(user)
    if not ok:
        return _err("ai_limit_reached", f"Лимит AI достигнут: {used}/{limit} в месяц", 429)
    if not rate_limit(f"api_ai_generate:{user['id']}", max_attempts=10, window_seconds=60):
        return _err("rate_limited", "Слишком много запросов. Подождите немного.", 429)

    fname = secure_filename(file.filename) or f"upload_{uuid.uuid4().hex[:8]}.pdf"
    fpath = _UPLOAD_DIR / f"{uuid.uuid4().hex}_{fname}"
    file.save(str(fpath))

    lang = _resolve_lang(user)
    quality_flag = _quality_to_flag(quality_mode)

    def gen_fn(c):
        return ai_gen.generate_from_pdf(fpath, c, lang, quality=quality_flag, output_lang="auto")

    row = _start_job(user, "pdf", pdf_file_name=fname, quality_mode=quality_mode,
                     card_count=count, gen_fn=gen_fn, topic_label=fname,
                     pdf_path_to_delete=fpath)
    return jsonify({"data": _serialize_job(row)}), 202


# ---------------------------------------------------------------------------
# GET /api/v1/ai/jobs/<id>  ·  GET /api/v1/ai/jobs
# ---------------------------------------------------------------------------

@ai_generation_bp.route("/jobs/<job_id>", methods=["GET"])
@jwt_auth.jwt_required
def get_job_status(job_id):
    user = g.current_user
    conn = db.get_conn()
    try:
        row = conn.execute("SELECT * FROM ai_generation_jobs WHERE id=? AND user_id=?",
                           (job_id, user["id"])).fetchone()
    finally:
        conn.close()
    if row is None:
        return _err("not_found", "Задача не найдена", 404)
    return jsonify({"data": _serialize_job(row)})


@ai_generation_bp.route("/jobs", methods=["GET"])
@jwt_auth.jwt_required
def get_job_history():
    user = g.current_user
    conn = db.get_conn()
    try:
        rows = conn.execute(
            "SELECT * FROM ai_generation_jobs WHERE user_id=? ORDER BY created_at DESC, id DESC",
            (user["id"],)
        ).fetchall()
    finally:
        conn.close()
    return jsonify({"data": [_serialize_job(r) for r in rows]})


# ---------------------------------------------------------------------------
# POST /api/v1/ai/find-answers  ·  POST /api/v1/ai/explain
# ---------------------------------------------------------------------------

def _build_deck_context(conn, user, deck_id_raw):
    """Mirrors api_v1.tutor's inline deck-context builder — small enough that
    duplicating beats introducing a cross-blueprint helper dependency."""
    if not deck_id_raw:
        return ""
    try:
        deck_id = int(deck_id_raw)
    except (TypeError, ValueError):
        return ""
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if deck is None:
        return ""
    if deck["org_id"]:
        owns = user["org_id"] == deck["org_id"]
    else:
        owns = user["id"] == deck["owner_id"]
    if not owns and not deck["is_public"]:
        return ""
    cards = conn.execute("SELECT front, back FROM cards WHERE deck_id=? LIMIT 20", (deck_id,)).fetchall()
    if not cards:
        return ""
    return "\n".join(f"- {c['front']} → {c['back']}" for c in cards)


@ai_generation_bp.route("/find-answers", methods=["POST"])
@jwt_auth.jwt_required
def post_find_answers():
    user = g.current_user
    if not ai_gen.is_available():
        return _err("ai_unavailable", "AI не настроен", 503)

    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Invalid JSON body", 400)

    question = (body.get("question") or "").strip()
    if not question:
        return _err("validation_error", "question is required", 400)
    if len(question) > _QUESTION_MAX_LEN:
        return _err("validation_error", f"question must be at most {_QUESTION_MAX_LEN} characters", 400)

    if not rate_limit(f"api_ai_find_answers:{user['id']}", max_attempts=20, window_seconds=60):
        return _err("rate_limited", "Слишком много запросов. Подождите немного.", 429)

    lang = _resolve_lang(user)
    conn = db.get_conn()
    try:
        deck_context = _build_deck_context(conn, user, body.get("deck_id"))
    finally:
        conn.close()

    result = ai_gen.find_answers(question, deck_context=deck_context, lang=lang)
    if result is None:
        return _err("ai_unavailable", "AI не отвечает. Попробуйте позже.", 503)

    return jsonify({"data": {
        "question": question,
        "explanation": result["explanation"],
        "key_points": result["key_points"],
    }})


@ai_generation_bp.route("/explain", methods=["POST"])
@jwt_auth.jwt_required
def post_explain():
    user = g.current_user
    if not ai_gen.is_available():
        return _err("ai_unavailable", "AI не настроен", 503)

    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Invalid JSON body", 400)

    question = (body.get("question") or "").strip()
    answer = (body.get("answer") or "").strip()
    if not question or not answer:
        return _err("validation_error", "question and answer are required", 400)
    if len(question) > _QUESTION_MAX_LEN:
        return _err("validation_error", f"question must be at most {_QUESTION_MAX_LEN} characters", 400)
    if len(answer) > _ANSWER_MAX_LEN:
        return _err("validation_error", f"answer must be at most {_ANSWER_MAX_LEN} characters", 400)

    if not rate_limit(f"api_ai_explain:{user['id']}", max_attempts=20, window_seconds=60):
        return _err("rate_limited", "Слишком много запросов. Подождите немного.", 429)

    lang = _resolve_lang(user)
    explanation = ai_gen.explain_question(question, answer, lang)
    if explanation is None:
        return _err("ai_unavailable", "AI не отвечает. Попробуйте позже.", 503)

    return jsonify({"data": {"explanation": explanation}})


_VALID_CARD_ACTIONS = {"explain", "simplify", "example", "translate", "analogy"}


@ai_generation_bp.route("/card-action", methods=["POST"])
@jwt_auth.jwt_required
def post_card_action():
    """One AI tutor action on a single card: explain / simplify / example /
    translate / analogy. Stateless — reads the card content from the body so it
    works from any card (study, deck, collection)."""
    user = g.current_user
    if not ai_gen.is_available():
        return _err("ai_unavailable", "AI не настроен", 503)

    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Invalid JSON body", 400)

    action = (body.get("action") or "").strip().lower()
    if action not in _VALID_CARD_ACTIONS:
        return _err("validation_error",
                    f"action must be one of {sorted(_VALID_CARD_ACTIONS)}", 400)

    question = (body.get("question") or "").strip()
    answer = (body.get("answer") or "").strip()
    if not question or not answer:
        return _err("validation_error", "question and answer are required", 400)
    if len(question) > _QUESTION_MAX_LEN:
        return _err("validation_error", f"question must be at most {_QUESTION_MAX_LEN} characters", 400)
    if len(answer) > _ANSWER_MAX_LEN:
        return _err("validation_error", f"answer must be at most {_ANSWER_MAX_LEN} characters", 400)

    target_lang = (body.get("target_lang") or "").strip() or None

    if not rate_limit(f"api_ai_card_action:{user['id']}", max_attempts=20, window_seconds=60):
        return _err("rate_limited", "Слишком много запросов. Подождите немного.", 429)

    lang = _resolve_lang(user)
    result = ai_gen.card_action(question, answer, action, lang, target_lang)
    if result is None:
        return _err("ai_unavailable", "AI не отвечает. Попробуйте позже.", 503)

    return jsonify({"data": {"action": action, "result": result}})


# ── Deck Tutor (Phase 2) ─────────────────────────────────────────────────────
# Deck-level learning guidance grounded in REAL deck content + the learner's own
# spaced-repetition signal (weak cards / recent failures / FSRS retention).
# Data sources: cards, user_card_progress (ef/stability/reviews/lapses/last_grade
# /last_reviewed), reviews (recent failures), fsrs.deck_retention /
# card_retrievability. AI usage is tracked per-feature via _call_gemini's
# `label` (ai_metrics: deck_quiz / deck_mini_test / deck_weak_areas / deck_summary).

_DECK_TUTOR_MAX_CARDS = 60
_DECK_QUIZ_DEFAULT, _DECK_QUIZ_MIN, _DECK_QUIZ_MAX = 5, 3, 15
_DECK_TEST_DEFAULT, _DECK_TEST_MIN, _DECK_TEST_MAX = 6, 3, 15
_WEAK_LIMIT = 12
_FAILURES_LIMIT = 8


def _deck_access(conn, user, deck_id):
    """Returns the deck row if the user may study it (owns it, shares its org, or
    it's public), else None. Mirrors _build_deck_context's access rule."""
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if deck is None:
        return None
    if deck["org_id"]:
        owns = user["org_id"] == deck["org_id"]
    else:
        owns = user["id"] == deck["owner_id"]
    if not owns and not deck["is_public"]:
        return None
    return deck


def _deck_learner_rows(conn, user_id, deck_id):
    """Every card in the deck joined with this user's SRS progress (LEFT JOIN —
    unstudied cards come back with NULL progress)."""
    rows = conn.execute(
        """SELECT c.id AS id, c.front AS front, c.back AS back,
                  p.ef AS ef, p.stability AS stability, p.difficulty AS difficulty,
                  p.interval_days AS interval_days, p.reviews AS reviews,
                  p.lapses AS lapses, p.last_grade AS last_grade,
                  p.last_reviewed AS last_reviewed, p.due_at AS due_at
           FROM cards c
           LEFT JOIN user_card_progress p
                  ON p.card_id = c.id AND p.user_id = ?
           WHERE c.deck_id = ?
           ORDER BY c.id""",
        (user_id, deck_id),
    ).fetchall()
    return [dict(r) for r in rows]


def _deck_recent_failures(conn, user_id, deck_id, limit):
    rows = conn.execute(
        """SELECT c.front AS front, r.grade AS grade, r.reviewed_at AS reviewed_at
           FROM reviews r JOIN cards c ON c.id = r.card_id
           WHERE r.user_id = ? AND c.deck_id = ? AND r.grade <= 2
           ORDER BY r.reviewed_at DESC LIMIT ?""",
        (user_id, deck_id, limit),
    ).fetchall()
    return [dict(r) for r in rows]


def _trunc(s, n):
    s = (s or "").strip().replace("\n", " ")
    return s if len(s) <= n else s[:n - 1] + "…"


def _format_deck_cards(rows, limit=_DECK_TUTOR_MAX_CARDS):
    lines = []
    for r in rows[:limit]:
        front, back = _trunc(r["front"], 200), _trunc(r["back"], 200)
        if front and back:
            lines.append(f"- {front} → {back}")
    return "\n".join(lines)


def _rank_weak_cards(rows, now):
    """Studied cards the learner struggles with, ranked worst-first by
    (lapses desc, last_grade asc, retrievability asc)."""
    weak = []
    for r in rows:
        if (r.get("reviews") or 0) <= 0:
            continue
        lapses = r.get("lapses") or 0
        last_grade = r.get("last_grade")
        try:
            retr = fsrs.card_retrievability(r, now)
        except Exception:
            retr = 1.0
        is_weak = (lapses > 0
                   or (last_grade is not None and last_grade <= 2)
                   or retr < fsrs.TARGET_RETENTION)
        if not is_weak:
            continue
        weak.append({
            "row": r,
            "lapses": lapses,
            "last_grade": last_grade if last_grade is not None else 5,
            "retr": retr,
        })
    weak.sort(key=lambda w: (-w["lapses"], w["last_grade"], w["retr"]))
    return weak


def _format_weak_cards(weak, limit=_WEAK_LIMIT):
    lines = []
    for w in weak[:limit]:
        r = w["row"]
        front, back = _trunc(r["front"], 160), _trunc(r["back"], 120)
        bits = []
        if w["lapses"] > 0:
            bits.append(f"ошибок: {w['lapses']}")
        bits.append(f"удержание ~{round(w['retr'] * 100)}%")
        lines.append(f'- "{front}" → {back} ({", ".join(bits)})')
    return "\n".join(lines)


def _format_failures(failures):
    return "\n".join(f'- "{_trunc(f["front"], 160)}"' for f in failures)


def _retention_summary_text(retention):
    if not retention or retention.get("now") is None:
        return ""
    return (f"средняя вероятность вспомнить сейчас ~{retention['now']}%, "
            f"через неделю без повторений ~{retention['forecast']}%, "
            f"угасает {retention['fading']} из {retention['studied']} изученных карточек")


def _deck_count(body, default, lo, hi):
    raw = body.get("count") if isinstance(body, dict) else None
    try:
        n = int(raw) if raw is not None else default
    except (TypeError, ValueError):
        n = default
    return max(lo, min(hi, n))


def _deck_tutor_guard(user):
    """Shared availability + rate-limit gate. Returns an error response or None."""
    if not ai_gen.is_available():
        return _err("ai_unavailable", "AI не настроен", 503)
    if not rate_limit(f"api_ai_deck_tutor:{user['id']}", max_attempts=12, window_seconds=60):
        return _err("rate_limited", "Слишком много запросов. Подождите немного.", 429)
    return None


def _load_deck_rows(user, deck_id):
    """Returns (rows, failures, error_response). rows/failures are None when an
    error_response should be returned."""
    conn = db.get_conn()
    try:
        deck = _deck_access(conn, user, deck_id)
        if deck is None:
            return None, None, _err("not_found", "Колода не найдена", 404)
        rows = _deck_learner_rows(conn, user["id"], deck_id)
        failures = _deck_recent_failures(conn, user["id"], deck_id, _FAILURES_LIMIT)
    finally:
        conn.close()
    if not rows:
        return None, None, _err("empty_deck", "В колоде нет карточек", 400)
    return rows, failures, None


@ai_generation_bp.route("/deck/<int:deck_id>/quiz", methods=["POST"])
@jwt_auth.jwt_required
def post_deck_quiz(deck_id):
    """Adaptive MCQ quiz over the deck, weighted toward the learner's weak /
    recently-failed / low-retention cards."""
    user = g.current_user
    guard = _deck_tutor_guard(user)
    if guard is not None:
        return guard
    body = request.get_json(silent=True) or {}
    count = _deck_count(body, _DECK_QUIZ_DEFAULT, _DECK_QUIZ_MIN, _DECK_QUIZ_MAX)

    rows, _failures, err = _load_deck_rows(user, deck_id)
    if err is not None:
        return err

    now = datetime.utcnow()
    weak = _rank_weak_cards(rows, now)
    result = ai_gen.deck_quiz(
        _format_deck_cards(rows),
        _format_weak_cards(weak),
        count=count,
        lang=_resolve_lang(user),
    )
    if result is None:
        return _err("ai_unavailable", "AI не отвечает. Попробуйте позже.", 503)
    return jsonify({"data": {
        "deck_id": deck_id,
        "questions": result["questions"],
        "weak_card_count": len(weak),
    }})


@ai_generation_bp.route("/deck/<int:deck_id>/mini-test", methods=["POST"])
@jwt_auth.jwt_required
def post_deck_mini_test(deck_id):
    """Short balanced assessment (easy/medium/hard MCQ mix) across the deck."""
    user = g.current_user
    guard = _deck_tutor_guard(user)
    if guard is not None:
        return guard
    body = request.get_json(silent=True) or {}
    count = _deck_count(body, _DECK_TEST_DEFAULT, _DECK_TEST_MIN, _DECK_TEST_MAX)

    rows, _failures, err = _load_deck_rows(user, deck_id)
    if err is not None:
        return err

    result = ai_gen.deck_mini_test(
        _format_deck_cards(rows),
        count=count,
        lang=_resolve_lang(user),
    )
    if result is None:
        return _err("ai_unavailable", "AI не отвечает. Попробуйте позже.", 503)
    return jsonify({"data": {
        "deck_id": deck_id,
        "questions": result["questions"],
    }})


@ai_generation_bp.route("/deck/<int:deck_id>/weak-areas", methods=["POST"])
@jwt_auth.jwt_required
def post_deck_weak_areas(deck_id):
    """Diagnose weak topics / cards / focus areas from the learner's real review
    signal. Returns has_data=False when the deck hasn't been studied yet."""
    user = g.current_user
    guard = _deck_tutor_guard(user)
    if guard is not None:
        return guard

    rows, failures, err = _load_deck_rows(user, deck_id)
    if err is not None:
        return err

    now = datetime.utcnow()
    retention = fsrs.deck_retention(rows, now)
    weak = _rank_weak_cards(rows, now)

    # No study history → nothing real to analyse.
    if retention.get("studied", 0) == 0:
        return jsonify({"data": {
            "deck_id": deck_id, "has_data": False,
            "weakest_topics": [], "weakest_cards": [], "focus_areas": [],
            "summary": "", "retention": retention,
        }})

    # Studied, but nothing is weak → all strong; skip the AI call.
    if not weak:
        return jsonify({"data": {
            "deck_id": deck_id, "has_data": True,
            "weakest_topics": [], "weakest_cards": [], "focus_areas": [],
            "summary": "", "retention": retention,
        }})

    result = ai_gen.deck_weak_areas(
        _format_weak_cards(weak),
        retention_summary=_retention_summary_text(retention),
        failures_context=_format_failures(failures),
        lang=_resolve_lang(user),
    )
    if result is None:
        return _err("ai_unavailable", "AI не отвечает. Попробуйте позже.", 503)
    return jsonify({"data": {
        "deck_id": deck_id, "has_data": True,
        "weakest_topics": result["weakest_topics"],
        "weakest_cards": result["weakest_cards"],
        "focus_areas": result["focus_areas"],
        "summary": result["summary"],
        "retention": retention,
    }})


@ai_generation_bp.route("/deck/<int:deck_id>/summary", methods=["POST"])
@jwt_auth.jwt_required
def post_deck_summary(deck_id):
    """Teacher-style deck summary: key concepts, common mistakes, important
    facts — grounded in the deck's real cards (+ the learner's weak cards)."""
    user = g.current_user
    guard = _deck_tutor_guard(user)
    if guard is not None:
        return guard

    rows, _failures, err = _load_deck_rows(user, deck_id)
    if err is not None:
        return err

    now = datetime.utcnow()
    weak = _rank_weak_cards(rows, now)
    result = ai_gen.deck_summary(
        _format_deck_cards(rows),
        _format_weak_cards(weak),
        lang=_resolve_lang(user),
    )
    if result is None:
        return _err("ai_unavailable", "AI не отвечает. Попробуйте позже.", 503)
    return jsonify({"data": {
        "deck_id": deck_id,
        "key_concepts": result["key_concepts"],
        "common_mistakes": result["common_mistakes"],
        "important_facts": result["important_facts"],
    }})
