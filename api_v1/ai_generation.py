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
