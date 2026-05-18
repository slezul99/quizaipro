# -*- coding: utf-8 -*-
"""Helpers dlya autorizatsii i prov rolam."""
from functools import wraps
from flask import session, redirect, url_for, abort
import db


def current_user():
    uid = session.get("user_id")
    if not uid:
        return None
    conn = db.get_conn()
    row = conn.execute("SELECT * FROM users WHERE id=?", (uid,)).fetchone()
    conn.close()
    return dict(row) if row else None


def login_required(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        if not session.get("user_id"):
            return redirect(url_for("login"))
        return f(*args, **kwargs)
    return wrapper


def role_required(*roles):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            user = current_user()
            if not user:
                return redirect(url_for("login"))
            if user["role"] not in roles:
                abort(403)
            return f(*args, **kwargs)
        return wrapper
    return decorator


def is_org_admin(user):
    return user and user["role"] in ("admin", "teacher")


# Spisok super-admin username'ov — vladeltsy sayta.
# Tol'ko oni vidyat /superadmin analitiku.
SUPER_ADMINS = {"slezul99@gmail.com"}


def is_super_admin(user):
    return user and user.get("username") in SUPER_ADMINS


def super_admin_required(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        user = current_user()
        if not is_super_admin(user):
            abort(404)  # 404 chtoby skryt' sushchestvovaniye stranitsy
        return f(*args, **kwargs)
    return wrapper


def can_manage_content(user):
    """Mozhet redaktirovat' kolody/karty/kategorii."""
    if not user:
        return False
    if user["role"] == "individual":
        return True   # svoi
    return user["role"] in ("admin", "teacher")
