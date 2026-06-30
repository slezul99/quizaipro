# -*- coding: utf-8 -*-
"""JWT access/refresh token issuance and verification for the mobile /api/v1 layer.

Fully independent from the web app's session-cookie auth (auth.py / app.secret_key):
- separate signing secret (JWT_SECRET_KEY)
- separate storage (refresh_tokens table)
- never touches flask.session

Reuses the existing `users` table and werkzeug password hashes — no new user model.
"""
import hashlib
import secrets
from datetime import datetime, timedelta, timezone
from functools import wraps
from pathlib import Path

import jwt
from flask import g, jsonify, request

import db

BASE = Path(__file__).resolve().parent.parent

ACCESS_TOKEN_TTL = timedelta(minutes=15)
REFRESH_TOKEN_TTL = timedelta(days=30)
JWT_ALGORITHM = "HS256"


def _load_secret():
    import os
    env_secret = os.environ.get("JWT_SECRET_KEY", "").strip()
    if env_secret:
        return env_secret
    secret_file = BASE / "jwt_secret.txt"
    try:
        if secret_file.exists():
            existing = secret_file.read_text(encoding="utf-8").strip()
            if existing:
                return existing
    except OSError:
        pass
    generated = secrets.token_hex(32)
    # Best-effort persist. On Railway the filesystem is ephemeral/possibly
    # read-only, so a failed write must NOT crash module import — fall back to
    # an in-memory secret. NOTE: without JWT_SECRET_KEY set, this regenerates on
    # every restart and invalidates existing tokens — set JWT_SECRET_KEY in prod.
    try:
        secret_file.write_text(generated, encoding="utf-8")
    except OSError:
        pass
    return generated


JWT_SECRET_KEY = _load_secret()


def _now():
    return datetime.now(timezone.utc)


def _hash_token(raw_token: str) -> str:
    return hashlib.sha256(raw_token.encode("utf-8")).hexdigest()


def _user_to_claims(user_row):
    return {
        "sub": str(user_row["id"]),
        "email": user_row["username"],
        "role": user_row["role"],
    }


def _create_access_token(user_row) -> str:
    now = _now()
    payload = {
        **_user_to_claims(user_row),
        "iat": now,
        "exp": now + ACCESS_TOKEN_TTL,
        "jti": secrets.token_hex(8),
    }
    return jwt.encode(payload, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)


def _store_refresh_token(conn, user_id: int, raw_token: str, device_token: str | None = None):
    expires_at = (_now() + REFRESH_TOKEN_TTL).strftime("%Y-%m-%d %H:%M:%S")
    cur = conn.execute(
        """INSERT INTO refresh_tokens (user_id, token_hash, device_token, expires_at)
           VALUES (?, ?, ?, ?) RETURNING id""",
        (user_id, _hash_token(raw_token), device_token, expires_at),
    )
    return cur.fetchone()[0]


def issue_token_pair(user_row, device_token: str | None = None):
    """Create a fresh (access_token, refresh_token) pair for a user, persisting the refresh token."""
    access_token = _create_access_token(user_row)
    raw_refresh = secrets.token_urlsafe(32)
    conn = db.get_conn()
    try:
        _store_refresh_token(conn, user_row["id"], raw_refresh, device_token)
        conn.commit()
    finally:
        conn.close()
    return access_token, raw_refresh


def verify_access_token(raw_token: str):
    """Decode + validate an access token, returning the live `users` row or None."""
    try:
        payload = jwt.decode(raw_token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
    except jwt.PyJWTError:
        return None
    try:
        user_id = int(payload.get("sub", ""))
    except (TypeError, ValueError):
        return None
    conn = db.get_conn()
    try:
        return conn.execute("SELECT * FROM users WHERE id=?", (user_id,)).fetchone()
    finally:
        conn.close()


def rotate_refresh_token(raw_token: str):
    """Validate a refresh token, revoke it, and issue a new (access, refresh) pair.

    Implements rotation: reusing a revoked/replaced token invalidates the whole chain
    (theft-detection) by revoking every still-active token for that user.
    Returns (access_token, refresh_token) or None on any failure.
    """
    if not raw_token:
        return None
    token_hash = _hash_token(raw_token)
    conn = db.get_conn()
    try:
        row = conn.execute(
            "SELECT * FROM refresh_tokens WHERE token_hash=?", (token_hash,)
        ).fetchone()
        if row is None:
            return None

        now_str = _now().strftime("%Y-%m-%d %H:%M:%S")
        if row["revoked_at"] is not None:
            # Reuse of a revoked token => possible theft. Nuke the whole chain.
            conn.execute(
                "UPDATE refresh_tokens SET revoked_at=? WHERE user_id=? AND revoked_at IS NULL",
                (now_str, row["user_id"]),
            )
            conn.commit()
            return None
        if row["expires_at"] <= now_str:
            return None

        user = conn.execute("SELECT * FROM users WHERE id=?", (row["user_id"],)).fetchone()
        if user is None:
            return None

        new_raw_refresh = secrets.token_urlsafe(32)
        new_id = _store_refresh_token(conn, user["id"], new_raw_refresh, row["device_token"])
        conn.execute(
            "UPDATE refresh_tokens SET revoked_at=?, replaced_by=? WHERE id=?",
            (now_str, new_id, row["id"]),
        )
        conn.commit()

        access_token = _create_access_token(user)
        return access_token, new_raw_refresh
    finally:
        conn.close()


def revoke_refresh_token(raw_token: str):
    """Revoke a single refresh token (used on logout). Always succeeds (idempotent)."""
    if not raw_token:
        return
    token_hash = _hash_token(raw_token)
    now_str = _now().strftime("%Y-%m-%d %H:%M:%S")
    conn = db.get_conn()
    try:
        conn.execute(
            "UPDATE refresh_tokens SET revoked_at=? WHERE token_hash=? AND revoked_at IS NULL",
            (now_str, token_hash),
        )
        conn.commit()
    finally:
        conn.close()


def jwt_required(fn):
    """Decorator for /api/v1 routes: requires a valid bearer access token.

    Populates `g.current_user` (a sqlite3.Row). Returns JSON 401 on failure —
    deliberately does NOT redirect (unlike @login_required) since this is an API.
    """
    @wraps(fn)
    def wrapper(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return jsonify({"error": {"code": "unauthorized", "message": "Missing bearer token"}}), 401
        raw_token = auth_header[len("Bearer "):].strip()
        user = verify_access_token(raw_token)
        if user is None:
            return jsonify({"error": {"code": "unauthorized", "message": "Invalid or expired token"}}), 401
        g.current_user = user
        return fn(*args, **kwargs)
    return wrapper
