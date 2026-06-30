# -*- coding: utf-8 -*-
"""Google OAuth 2.0 - redirect/callback flow."""
import json
import secrets
from urllib import request as urlreq
from urllib import parse as urlparse
from urllib import error as urlerr

from flask import session, redirect, url_for, request, flash
from werkzeug.security import generate_password_hash

import db
import config

AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
TOKEN_URL = "https://oauth2.googleapis.com/token"
USERINFO_URL = "https://www.googleapis.com/oauth2/v2/userinfo"


def login_url(redirect_uri: str) -> str:
    """Vozvraschayet URL na Google chtoby user voshyol."""
    state = secrets.token_urlsafe(16)
    session["oauth_state"] = state
    params = {
        "client_id": config.GOOGLE_CLIENT_ID,
        "redirect_uri": redirect_uri,
        "response_type": "code",
        "scope": "openid email profile",
        "state": state,
        "access_type": "online",
        "prompt": "select_account",
    }
    return f"{AUTH_URL}?{urlparse.urlencode(params)}"


def handle_callback(code: str, redirect_uri: str) -> dict | None:
    """Obmenivayet code na user-info. Vozvraschayet dict s email/name/picture."""
    # Step 1: code -> token
    body = urlparse.urlencode({
        "code": code,
        "client_id": config.GOOGLE_CLIENT_ID,
        "client_secret": config.GOOGLE_CLIENT_SECRET,
        "redirect_uri": redirect_uri,
        "grant_type": "authorization_code",
    }).encode()
    try:
        resp = urlreq.urlopen(urlreq.Request(TOKEN_URL, data=body), timeout=15)
        token_data = json.loads(resp.read().decode())
    except urlerr.HTTPError as e:
        print(f"[OAuth] token error: {e.code} {e.read().decode('utf-8','replace')[:200]}")
        return None
    except Exception as e:
        print(f"[OAuth] {type(e).__name__}: {e}")
        return None

    access_token = token_data.get("access_token")
    if not access_token:
        return None

    # Step 2: token -> user info
    try:
        req = urlreq.Request(USERINFO_URL,
                             headers={"Authorization": f"Bearer {access_token}"})
        resp = urlreq.urlopen(req, timeout=15)
        user_info = json.loads(resp.read().decode())
    except Exception as e:
        print(f"[OAuth] userinfo error: {e}")
        return None

    return user_info


def find_or_create_user(email: str, name: str = "") -> int | None:
    """Naydet pol'zovatelya po email ili sozdayet novyy individual'nyy akkaunt."""
    if not email:
        return None
    conn = db.get_conn()
    user = conn.execute("SELECT id FROM users WHERE org_id IS NULL AND username=?",
                        (email,)).fetchone()
    if user:
        conn.close()
        return user["id"]
    # Sozdayem
    cur = conn.execute("""INSERT INTO users (org_id, username, password_hash, role, full_name, lang)
                          VALUES (NULL, ?, ?, 'individual', ?, 'ru') RETURNING id""",
                       (email, generate_password_hash(secrets.token_urlsafe(16)), name))
    uid = cur.fetchone()[0]
    conn.commit(); conn.close()
    return uid
