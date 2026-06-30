# -*- coding: utf-8 -*-
"""Mobile-facing JSON auth endpoints under /api/v1/auth/*.

Field-mapping note (Phase 1 pragmatic choice — no schema changes):
The `users` table has no dedicated `email` column, only a unique `username`
(the existing Google-OAuth path already stores the user's email there via
google_auth.find_or_create_user). To stay consistent and avoid a migration:
  - mobile's `email`     -> stored/looked-up as `users.username`
  - mobile's `username`  -> stored as `users.full_name` (display name)
The JSON user object then maps `users.username` back to `email` for the app.
"""
import os
import re
import threading
from datetime import datetime

import requests
from flask import Blueprint, g, jsonify, request
from werkzeug.security import check_password_hash, generate_password_hash

import config
import db
import google_auth

from . import jwt_auth

# Google's ID-token introspection endpoint. We verify the mobile-supplied
# id_token here (audience + issuer + email_verified) instead of pulling in the
# google-auth library, keeping the dependency surface to `requests` (already a
# project dep).
#
# Audience: the mobile id_token is minted for the Firebase project's "Web
# client" (passed as serverClientId in the app), which is a *different* OAuth
# client than the website's redirect-flow GOOGLE_CLIENT_ID. So the mobile
# audience is read from GOOGLE_MOBILE_CLIENT_ID, falling back to
# GOOGLE_CLIENT_ID only if it isn't set — this keeps the existing web Google
# login untouched. Set GOOGLE_MOBILE_CLIENT_ID on Railway to the Firebase Web
# client id.
_GOOGLE_TOKENINFO_URL = "https://oauth2.googleapis.com/tokeninfo"
_GOOGLE_VALID_ISS = ("accounts.google.com", "https://accounts.google.com")


def _google_mobile_client_id():
    return (os.environ.get("GOOGLE_MOBILE_CLIENT_ID", "").strip()
            or config.GOOGLE_CLIENT_ID)

auth_bp = Blueprint("api_v1_auth", __name__, url_prefix="/api/v1/auth")

_EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

# Self-contained rate limiter — deliberately separate from app.py's `_rate_limits`
# so this blueprint has zero coupling to the web app's internals (truly isolated).
_rate_limits = {}
_rate_lock = threading.Lock()


def rate_limit(key: str, max_attempts: int, window_seconds: int) -> bool:
    now = datetime.utcnow().timestamp()
    with _rate_lock:
        attempts = [t for t in _rate_limits.get(key, []) if now - t < window_seconds]
        if len(attempts) >= max_attempts:
            _rate_limits[key] = attempts
            return False
        attempts.append(now)
        _rate_limits[key] = attempts
        return True


def get_client_ip():
    fwd = request.headers.get("X-Forwarded-For", "")
    if fwd:
        return fwd.split(",")[0].strip()
    return request.remote_addr or "unknown"


def _err(code, message, status):
    return jsonify({"error": {"code": code, "message": message}}), status


def _serialize_user(user_row):
    return {
        "id": str(user_row["id"]),
        "email": user_row["username"],
        "username": user_row["full_name"] or None,
        "display_name": user_row["full_name"] or None,
        "avatar_url": None,
        "email_verified": True,
        "xp": user_row["xp"] or 0,
        "streak_days": user_row["streak"] or 0,
        "role": user_row["role"],
        "created_at": user_row["created_at"],
    }


def _token_pair_response(user_row, device_token, status=200):
    access_token, refresh_token = jwt_auth.issue_token_pair(user_row, device_token)
    return jsonify({
        "data": {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "user": _serialize_user(user_row),
        }
    }), status


@auth_bp.route("/register", methods=["POST"])
def register():
    body = request.get_json(silent=True) or {}
    email = (body.get("email") or "").strip().lower()
    password = body.get("password") or ""
    username = (body.get("username") or "").strip()
    display_name = (body.get("display_name") or "").strip()
    device_token = body.get("device_token")

    if not _EMAIL_RE.match(email):
        return _err("invalid_email", "Введите корректный email", 422)
    if len(password) < 6:
        return _err("weak_password", "Пароль должен быть не короче 6 символов", 422)

    ip = get_client_ip()
    if not rate_limit(f"api_register:{ip}", max_attempts=5, window_seconds=600):
        return _err("rate_limited", "Слишком много регистраций. Попробуйте позже.", 429)

    full_name = display_name or username or ""

    conn = db.get_conn()
    try:
        exists = conn.execute(
            "SELECT id FROM users WHERE org_id IS NULL AND username=?", (email,)
        ).fetchone()
        if exists:
            return _err("email_taken", "Этот email уже зарегистрирован", 409)

        cur = conn.execute(
            """INSERT INTO users (org_id, username, password_hash, role, full_name, lang)
               VALUES (NULL, ?, ?, 'individual', ?, 'ru') RETURNING id""",
            (email, generate_password_hash(password), full_name),
        )
        _uid = cur.fetchone()[0]   # fetch RETURNING before commit (SQLite-safe)
        conn.commit()
        user = conn.execute("SELECT * FROM users WHERE id=?", (_uid,)).fetchone()
    finally:
        conn.close()

    return _token_pair_response(user, device_token, status=201)


@auth_bp.route("/login", methods=["POST"])
def login():
    body = request.get_json(silent=True) or {}
    identifier = (body.get("email") or "").strip().lower()
    password = body.get("password") or ""
    device_token = body.get("device_token")

    if not identifier or not password:
        return _err("invalid_request", "Email и пароль обязательны", 422)

    ip = get_client_ip()
    if not rate_limit(f"api_login:{ip}", max_attempts=10, window_seconds=60):
        return _err("rate_limited", "Слишком много попыток. Подождите минуту.", 429)
    if not rate_limit(f"api_login_user:{identifier}", max_attempts=5, window_seconds=300):
        return _err("rate_limited", "Слишком много попыток для этого аккаунта.", 429)

    conn = db.get_conn()
    try:
        user = conn.execute(
            "SELECT * FROM users WHERE org_id IS NULL AND (username=? OR LOWER(full_name)=?)",
            (identifier, identifier),
        ).fetchone()
    finally:
        conn.close()

    if user is None or not check_password_hash(user["password_hash"], password):
        return _err("invalid_credentials", "Неверный email или пароль", 401)

    return _token_pair_response(user, device_token, status=200)


@auth_bp.route("/google", methods=["POST"])
def google_signin():
    """Sign in / sign up with a Google ID token from the mobile app.

    The app obtains the id_token via google_sign_in (configured with the
    Firebase web client id as serverClientId). We verify it against Google,
    then reuse the same email->users.username account model as register/login
    (google_auth.find_or_create_user is the canonical creator)."""
    body = request.get_json(silent=True) or {}
    id_token = (body.get("id_token") or "").strip()
    device_token = body.get("device_token")

    if not id_token:
        return _err("invalid_request", "id_token обязателен", 422)

    ip = get_client_ip()
    if not rate_limit(f"api_google:{ip}", max_attempts=10, window_seconds=60):
        return _err("rate_limited", "Слишком много попыток. Подождите минуту.", 429)

    expected_aud = _google_mobile_client_id()
    if not expected_aud:
        return _err("server_error", "Google вход не настроен на сервере", 500)

    try:
        resp = requests.get(
            _GOOGLE_TOKENINFO_URL, params={"id_token": id_token}, timeout=10
        )
    except requests.RequestException:
        return _err("google_unavailable", "Не удалось связаться с Google", 502)

    if resp.status_code != 200:
        return _err("invalid_google_token", "Недействительный токен Google", 401)

    info = resp.json()
    email = (info.get("email") or "").strip().lower()
    email_verified = str(info.get("email_verified", "")).lower() == "true"
    name = info.get("name") or ""

    if info.get("aud") != expected_aud:
        return _err("invalid_google_token", "Токен предназначен другому приложению", 401)
    if info.get("iss") not in _GOOGLE_VALID_ISS:
        return _err("invalid_google_token", "Неверный издатель токена", 401)
    if not email or not email_verified:
        return _err("invalid_google_token", "Email Google не подтверждён", 401)

    uid = google_auth.find_or_create_user(email, name)
    if uid is None:
        return _err("server_error", "Не удалось создать пользователя", 500)

    conn = db.get_conn()
    try:
        user = conn.execute("SELECT * FROM users WHERE id=?", (uid,)).fetchone()
    finally:
        conn.close()

    return _token_pair_response(user, device_token, status=200)


@auth_bp.route("/me", methods=["GET"])
@jwt_auth.jwt_required
def me():
    return jsonify({"data": _serialize_user(g.current_user)})


@auth_bp.route("/refresh", methods=["POST"])
def refresh():
    body = request.get_json(silent=True) or {}
    raw_refresh = body.get("refresh_token") or ""
    result = jwt_auth.rotate_refresh_token(raw_refresh)
    if result is None:
        return _err("invalid_refresh_token", "Refresh token недействителен или истёк", 401)
    access_token, new_refresh_token = result
    return jsonify({"data": {"access_token": access_token, "refresh_token": new_refresh_token}})


@auth_bp.route("/logout", methods=["POST"])
@jwt_auth.jwt_required
def logout():
    body = request.get_json(silent=True) or {}
    raw_refresh = body.get("refresh_token") or ""
    jwt_auth.revoke_refresh_token(raw_refresh)
    return "", 204
