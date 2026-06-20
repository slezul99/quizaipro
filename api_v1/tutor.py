# -*- coding: utf-8 -*-
"""AI Tutor (chat) endpoints for the mobile /api/v1 layer — Phase 5.

Conversation architecture (reuses existing `tutor_conversations`/`tutor_messages`
— the "reuse existing structures" requirement):
  The mobile Tutor module generates a 32-char hex `id` client-side for each
  conversation (same pattern as Phase 4's `client_result_id`). The legacy web
  flow uses autoincrement INTEGER ids with no client id at all. To support
  both without breaking the web app, `tutor_conversations` gained a nullable
  `client_id TEXT` column + a partial unique index on (user_id, client_id):
    - mobile-created rows: public id = client_id (idempotent create/retry)
    - legacy web-created rows (client_id IS NULL): public id = "srv_<int id>"
  `_resolve_conversation` transparently looks up either form, so the mobile
  app can also list/open/continue conversations that were started on the web
  — true cross-platform continuity, not just one-way compatibility.

  `deck_id`/`deck_title` (required by ConversationDto, denormalized like
  test_attempts.scope_name — decks can be renamed/deleted later) are new
  nullable columns; legacy rows simply have them as NULL.

Message persistence: `tutor_messages` needed no schema changes — its
autoincrement INTEGER id is simply stringified (`str(id)`). The mobile client
never sends a message id (see `streamMessage` in tutor_remote_data_source.dart
— body is just `{conversation_id, content, deck_id?}`), so there is no
idempotency key to reuse; each POST /stream creates exactly one user message
+ (on success) one assistant message, exactly like the existing web flow's
`_tutor_save_message`.

Streaming architecture: Server-Sent Events over the existing AI provider
infrastructure (`ai_gen.chat_tutor_stream` — DeepSeek native streaming with
Gemini fallback, already used by the web `/api/tutor/ask?stream=1` route).
The mobile `SseConnectionManager` parses `data: {"delta": "..."}` lines and a
terminal `data: [DONE]`, with `data: {"error": "..."}` for failures — this
endpoint emits exactly that framing (the web route streams raw text/plain
chunks instead, so the formats necessarily differ, but the underlying
generation call — and therefore the answer quality/history — is identical).

This single `/stream` endpoint serves BOTH "Send message" and "Streaming
response" from the request: `SendMessageUseCase` -> `TutorRepository.sendMessage`
-> `TutorRemoteDataSource.streamMessage` -> POST /api/v1/tutor/stream. There is
no separate non-streaming send-message call anywhere in the mobile module.
"""
import json

from flask import Blueprint, Response, g, jsonify, request, stream_with_context

import ai_gen
import db

from . import jwt_auth
from .auth import rate_limit

tutor_bp = Blueprint("api_v1_tutor", __name__, url_prefix="/api/v1/tutor")

_TITLE_MAX_LEN = 80
_DECK_TITLE_MAX_LEN = 200
_MESSAGE_MAX_LEN = 4000
_PREVIEW_MAX_LEN = 100


def _err(code, message, status):
    return jsonify({"error": {"code": code, "message": message}}), status


def _resolve_lang(user):
    """Mirrors api_v1.marketplace._resolve_lang — mobile has no session, so
    language comes from an optional ?lang= override or the user's stored pref."""
    lang = request.args.get("lang") or (user["lang"] if user else None)
    return lang if lang in ("ru", "en", "uz") else "ru"


def _like_escape(value):
    return value.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")


# ---------------------------------------------------------------------------
# Conversation id resolution & serialization
# ---------------------------------------------------------------------------

_CONVERSATION_SELECT = """
    SELECT tc.*,
           (SELECT COUNT(*) FROM tutor_messages tm
            WHERE tm.conversation_id = tc.id) AS message_count,
           (SELECT content FROM tutor_messages tm2
            WHERE tm2.conversation_id = tc.id
            ORDER BY tm2.created_at DESC, tm2.id DESC LIMIT 1) AS last_message
    FROM tutor_conversations tc
"""


def _public_conversation_id(row):
    return row["client_id"] or f"srv_{row['id']}"


def _resolve_conversation(conn, user, conversation_id):
    """Look up a conversation by its mobile-facing id (client-generated hex,
    or 'srv_<int>' for a legacy web-created chat). Returns the joined row
    (with message_count/last_message) or None."""
    if not isinstance(conversation_id, str) or not conversation_id:
        return None
    if conversation_id.startswith("srv_"):
        try:
            internal_id = int(conversation_id[4:])
        except ValueError:
            return None
        return conn.execute(
            _CONVERSATION_SELECT + " WHERE tc.user_id=? AND tc.id=? AND tc.client_id IS NULL",
            (user["id"], internal_id),
        ).fetchone()
    return conn.execute(
        _CONVERSATION_SELECT + " WHERE tc.user_id=? AND tc.client_id=?",
        (user["id"], conversation_id),
    ).fetchone()


def _serialize_conversation(row):
    last_message = row["last_message"]
    preview = None
    if last_message:
        preview = last_message if len(last_message) <= _PREVIEW_MAX_LEN else last_message[:_PREVIEW_MAX_LEN] + "…"
    return {
        "id": _public_conversation_id(row),
        "title": row["title"],
        "deck_id": str(row["deck_id"]) if row["deck_id"] is not None else None,
        "deck_title": row["deck_title"],
        "is_pinned": bool(row["pinned"]),
        "message_count": row["message_count"],
        "last_message_preview": preview,
        "created_at": row["created_at"],
        "updated_at": row["updated_at"],
    }


def _serialize_message(row, public_conversation_id):
    return {
        "id": str(row["id"]),
        "conversation_id": public_conversation_id,
        "role": row["role"],
        "content": row["content"],
        "created_at": row["created_at"],
    }


# ---------------------------------------------------------------------------
# GET /api/v1/tutor/conversations  (also serves search via ?q=)
# ---------------------------------------------------------------------------

@tutor_bp.route("/conversations", methods=["GET"])
@jwt_auth.jwt_required
def get_conversations():
    user = g.current_user
    q = (request.args.get("q") or "").strip()

    conn = db.get_conn()
    try:
        if q:
            pattern = "%" + _like_escape(q) + "%"
            rows = conn.execute(
                _CONVERSATION_SELECT +
                " WHERE tc.user_id=? AND tc.title LIKE ? ESCAPE '\\'"
                " ORDER BY tc.pinned DESC, tc.updated_at DESC LIMIT 200",
                (user["id"], pattern),
            ).fetchall()
        else:
            rows = conn.execute(
                _CONVERSATION_SELECT +
                " WHERE tc.user_id=? ORDER BY tc.pinned DESC, tc.updated_at DESC LIMIT 200",
                (user["id"],),
            ).fetchall()
    finally:
        conn.close()

    return jsonify({"data": [_serialize_conversation(r) for r in rows]})


# ---------------------------------------------------------------------------
# POST /api/v1/tutor/conversations
# ---------------------------------------------------------------------------

def _validate_create_conversation_payload(body):
    conv_id = body.get("id")
    if not isinstance(conv_id, str) or not conv_id.strip():
        return None, "id must be a non-empty string"
    conv_id = conv_id.strip()
    if len(conv_id) > 64:
        return None, "id is too long"
    if conv_id.startswith("srv_"):
        return None, "id must not use the reserved 'srv_' prefix"

    title = body.get("title")
    if not isinstance(title, str) or not title.strip():
        return None, "title must be a non-empty string"
    title = title.strip()[:_TITLE_MAX_LEN]

    parsed = {"id": conv_id, "title": title, "deck_id": None, "deck_title": None}

    raw_deck_id = body.get("deck_id")
    if raw_deck_id is not None:
        try:
            parsed["deck_id"] = int(raw_deck_id)
        except (TypeError, ValueError):
            return None, "deck_id must be a numeric identifier"

    raw_deck_title = body.get("deck_title")
    if raw_deck_title is not None:
        if not isinstance(raw_deck_title, str):
            return None, "deck_title must be a string"
        parsed["deck_title"] = raw_deck_title.strip()[:_DECK_TITLE_MAX_LEN] or None

    return parsed, None


@tutor_bp.route("/conversations", methods=["POST"])
@jwt_auth.jwt_required
def post_conversation():
    user = g.current_user
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Ожидается JSON-тело запроса", 400)

    parsed, err = _validate_create_conversation_payload(body)
    if err:
        return _err("validation_error", err, 400)

    conn = db.get_conn()
    try:
        # Idempotent by (user_id, client_id) — a client-generated hex id.
        # Re-POSTing the same conversation (sync retry) is a no-op; we always
        # return the persisted record (mirrors POST /api/v1/test/results).
        conn.execute("""
            INSERT OR IGNORE INTO tutor_conversations
                (user_id, title, client_id, deck_id, deck_title)
            VALUES (?, ?, ?, ?, ?)
        """, (user["id"], parsed["title"], parsed["id"], parsed["deck_id"], parsed["deck_title"]))
        conn.commit()

        row = conn.execute(
            _CONVERSATION_SELECT + " WHERE tc.user_id=? AND tc.client_id=?",
            (user["id"], parsed["id"]),
        ).fetchone()
    finally:
        conn.close()

    return jsonify({"data": _serialize_conversation(row)}), 201


# ---------------------------------------------------------------------------
# PATCH /api/v1/tutor/conversations/<id>            — rename
# PATCH /api/v1/tutor/conversations/<id>/pin        — pin/unpin
# DELETE /api/v1/tutor/conversations/<id>           — delete
# ---------------------------------------------------------------------------

@tutor_bp.route("/conversations/<conversation_id>", methods=["PATCH"])
@jwt_auth.jwt_required
def patch_conversation(conversation_id):
    user = g.current_user
    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Ожидается JSON-тело запроса", 400)

    title = body.get("title")
    if not isinstance(title, str) or not title.strip():
        return _err("validation_error", "title must be a non-empty string", 400)
    title = title.strip()[:_TITLE_MAX_LEN]

    conn = db.get_conn()
    try:
        conv = _resolve_conversation(conn, user, conversation_id)
        if conv is None:
            return _err("not_found", "Чат не найден", 404)
        conn.execute("UPDATE tutor_conversations SET title=?, updated_at=CURRENT_TIMESTAMP WHERE id=?",
                     (title, conv["id"]))
        conn.commit()
    finally:
        conn.close()

    return jsonify({"data": {"id": conversation_id, "title": title}})


@tutor_bp.route("/conversations/<conversation_id>/pin", methods=["PATCH"])
@jwt_auth.jwt_required
def patch_conversation_pin(conversation_id):
    user = g.current_user
    body = request.get_json(silent=True)
    if not isinstance(body, dict) or "is_pinned" not in body:
        return _err("validation_error", "is_pinned must be provided", 400)
    is_pinned = bool(body.get("is_pinned"))

    conn = db.get_conn()
    try:
        conv = _resolve_conversation(conn, user, conversation_id)
        if conv is None:
            return _err("not_found", "Чат не найден", 404)
        conn.execute("UPDATE tutor_conversations SET pinned=?, updated_at=CURRENT_TIMESTAMP WHERE id=?",
                     (1 if is_pinned else 0, conv["id"]))
        conn.commit()
    finally:
        conn.close()

    return jsonify({"data": {"id": conversation_id, "is_pinned": is_pinned}})


@tutor_bp.route("/conversations/<conversation_id>", methods=["DELETE"])
@jwt_auth.jwt_required
def delete_conversation(conversation_id):
    user = g.current_user
    conn = db.get_conn()
    try:
        conv = _resolve_conversation(conn, user, conversation_id)
        if conv is None:
            return _err("not_found", "Чат не найден", 404)
        conn.execute("DELETE FROM tutor_conversations WHERE id=?", (conv["id"],))
        conn.commit()
    finally:
        conn.close()

    return "", 204


# ---------------------------------------------------------------------------
# GET /api/v1/tutor/conversations/<id>/messages
# ---------------------------------------------------------------------------

@tutor_bp.route("/conversations/<conversation_id>/messages", methods=["GET"])
@jwt_auth.jwt_required
def get_conversation_messages(conversation_id):
    user = g.current_user
    conn = db.get_conn()
    try:
        conv = _resolve_conversation(conn, user, conversation_id)
        if conv is None:
            return _err("not_found", "Чат не найден", 404)

        rows = conn.execute(
            "SELECT * FROM tutor_messages WHERE conversation_id=? ORDER BY created_at ASC, id ASC",
            (conv["id"],),
        ).fetchall()
        public_id = _public_conversation_id(conv)
    finally:
        conn.close()

    return jsonify({"data": [_serialize_message(r, public_id) for r in rows]})


# ---------------------------------------------------------------------------
# POST /api/v1/tutor/stream  — send message + SSE streaming reply
# ---------------------------------------------------------------------------

def _sse_event(payload):
    return f"data: {json.dumps(payload, ensure_ascii=False)}\n\n"


@tutor_bp.route("/stream", methods=["POST"])
@jwt_auth.jwt_required
def post_stream_message():
    user = g.current_user
    if not (ai_gen.is_available() or ai_gen.is_deepseek_available()):
        return _err("ai_unavailable", "AI не настроен", 503)

    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Ожидается JSON-тело запроса", 400)

    conversation_id = body.get("conversation_id")
    content = body.get("content")
    if not isinstance(conversation_id, str) or not conversation_id.strip():
        return _err("validation_error", "conversation_id must be a non-empty string", 400)
    if not isinstance(content, str) or not content.strip():
        return _err("validation_error", "content must be a non-empty string", 400)
    content = content.strip()[:_MESSAGE_MAX_LEN]

    if not rate_limit(f"api_tutor_stream:{user['id']}", max_attempts=15, window_seconds=60):
        return _err("rate_limited", "Слишком много запросов. Подождите минуту.", 429)

    raw_deck_id = body.get("deck_id")
    deck_id = None
    if raw_deck_id is not None:
        try:
            deck_id = int(raw_deck_id)
        except (TypeError, ValueError):
            deck_id = None

    lang = _resolve_lang(user)

    conn = db.get_conn()
    try:
        conv = _resolve_conversation(conn, user, conversation_id)
        if conv is None:
            return _err("not_found", "Чат не найден", 404)
        internal_conv_id = conv["id"]

        deck_context = ""
        if deck_id:
            deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
            if deck is not None:
                if deck["org_id"]:
                    owns = user["org_id"] == deck["org_id"]
                else:
                    owns = user["id"] == deck["owner_id"]
                if owns or deck["is_public"]:
                    cards = conn.execute("SELECT front, back FROM cards WHERE deck_id=? LIMIT 20", (deck_id,)).fetchall()
                    if cards:
                        deck_context = "\n".join(f"- {c['front']} → {c['back']}" for c in cards)

        # History BEFORE the new user message — chat_tutor_stream appends
        # the current `content` itself (see _build_tutor_prompt).
        history_rows = conn.execute(
            "SELECT role, content FROM tutor_messages WHERE conversation_id=? ORDER BY created_at ASC, id ASC",
            (internal_conv_id,),
        ).fetchall()
        history = [{"role": r["role"], "content": r["content"]} for r in history_rows]

        # Persist the user's message immediately — exactly like the web flow's
        # _tutor_save_message, so it survives even if generation fails.
        conn.execute("INSERT INTO tutor_messages (conversation_id, user_id, role, content) VALUES (?, ?, 'user', ?)",
                     (internal_conv_id, user["id"], content))
        conn.execute("UPDATE tutor_conversations SET updated_at=CURRENT_TIMESTAMP WHERE id=?", (internal_conv_id,))
        conn.commit()
    finally:
        conn.close()

    def _generate():
        chunks = []
        try:
            for chunk in ai_gen.chat_tutor_stream(content, deck_context=deck_context, history=history, lang=lang):
                if chunk:
                    chunks.append(chunk)
                    yield _sse_event({"delta": chunk})
        except Exception as e:
            print(f"[/api/v1/tutor/stream] {type(e).__name__}: {e}")

        answer_text = "".join(chunks).strip()
        if answer_text:
            conn2 = db.get_conn()
            try:
                conn2.execute(
                    "INSERT INTO tutor_messages (conversation_id, user_id, role, content) VALUES (?, ?, 'assistant', ?)",
                    (internal_conv_id, user["id"], answer_text))
                conn2.execute("UPDATE tutor_conversations SET updated_at=CURRENT_TIMESTAMP WHERE id=?",
                              (internal_conv_id,))
                conn2.commit()
            finally:
                conn2.close()
        else:
            yield _sse_event({"error": "AI не отвечает. Попробуйте позже."})

        yield "data: [DONE]\n\n"

    return Response(stream_with_context(_generate()), mimetype="text/event-stream", headers={
        "Cache-Control": "no-cache",
        "X-Accel-Buffering": "no",
    })


# ---------------------------------------------------------------------------
# POST /api/v1/tutor/diagnose  — explain the student's SPECIFIC test mistake
# POST /api/v1/tutor/followup  — generate a reinforcing question on the topic
#
# Mobile mirror of the web routes /api/diagnose-answer and /api/followup-question.
# The mobile review screen already holds the question + the chosen/correct option
# text locally (the test runs offline), so — unlike the web routes which take a
# server-side answer_id and reconstruct from the DB — these accept the texts
# directly in the JSON body. Both reuse the SAME ai_gen functions as the web,
# so the AI tutoring logic is shared across platforms (no duplication).
# ---------------------------------------------------------------------------

_DIAG_TEXT_MAX = 2000


@tutor_bp.route("/diagnose", methods=["POST"])
@jwt_auth.jwt_required
def post_diagnose():
    user = g.current_user
    if not ai_gen.is_available():
        return _err("ai_unavailable", "AI не настроен", 503)

    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Ожидается JSON-тело запроса", 400)
    question = (body.get("question") or "").strip()[:_DIAG_TEXT_MAX]
    chosen = (body.get("chosen") or "").strip()[:_DIAG_TEXT_MAX]
    correct = (body.get("correct") or "").strip()[:_DIAG_TEXT_MAX]
    if not question or not correct:
        return _err("validation_error", "question and correct are required", 400)

    if not rate_limit(f"api_diagnose:{user['id']}", max_attempts=10, window_seconds=60):
        return _err("rate_limited", "Слишком много запросов. Подождите минуту.", 429)

    diagnosis = ai_gen.diagnose_mistake(question, chosen, correct, _resolve_lang(user))
    if not diagnosis or not diagnosis.get("why_wrong"):
        return _err("ai_failed", "AI не ответил. Попробуйте позже.", 502)
    return jsonify({"data": diagnosis})


@tutor_bp.route("/followup", methods=["POST"])
@jwt_auth.jwt_required
def post_followup():
    user = g.current_user
    if not ai_gen.is_available():
        return _err("ai_unavailable", "AI не настроен", 503)

    body = request.get_json(silent=True)
    if not isinstance(body, dict):
        return _err("validation_error", "Ожидается JSON-тело запроса", 400)
    question = (body.get("question") or "").strip()[:_DIAG_TEXT_MAX]
    correct = (body.get("correct") or "").strip()[:_DIAG_TEXT_MAX]
    misconception = (body.get("misconception") or "").strip()[:300]
    if not question or not correct:
        return _err("validation_error", "question and correct are required", 400)

    if not rate_limit(f"api_followup:{user['id']}", max_attempts=10, window_seconds=60):
        return _err("rate_limited", "Слишком много запросов. Подождите минуту.", 429)

    fu = ai_gen.generate_followup(question, correct, misconception, _resolve_lang(user))
    if not fu:
        return _err("ai_failed", "AI не ответил. Попробуйте позже.", 502)

    letters = ["A", "B", "C", "D", "E", "F"]
    options = [{"letter": letters[i], "text": t} for i, t in enumerate(fu["options"])]
    return jsonify({"data": {
        "question": fu["question"],
        "options": options,
        "correct_letter": letters[fu["correct_index"]],
        "explanation": fu["explanation"],
    }})
