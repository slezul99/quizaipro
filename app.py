# -*- coding: utf-8 -*-
"""QuizAIPro v3 — Multi-tenant + Google OAuth + AI + Stripe."""
import os
import re
import sys
import secrets
from datetime import datetime, timedelta, date
from pathlib import Path

# === Console encoding (P0-5) ===
# On Windows the process stdout/stderr default to the system code page
# (cp1251/cp1252), which cannot encode many glyphs the AI returns — chemistry
# subscripts (₂/₆), reaction arrows (→), emoji, etc. Any `print()` that echoes
# raw AI output (e.g. ai_gen._parse_cards_json) then raises
# `UnicodeEncodeError: 'charmap' codec can't encode character …`, crashing the
# generation job (topic "Photosynthesis" failed while "Dogs" worked). Force
# UTF-8 with replacement so logging can never abort a request.
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, ValueError):
        pass

from flask import Flask, render_template, render_template_string, request, jsonify, redirect, url_for, session, flash, abort
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename

import db
import sm2
import fsrs
import importer
import i18n
import config
import google_auth
import billing
import analytics
import ai_gen
import vision_jobs
import achievements as ach_mod
import goals as goals_mod
import help_content
import bot_protection
from auth import current_user, login_required, role_required, can_manage_content, super_admin_required, is_super_admin, SUPER_ADMINS

BASE = Path(__file__).resolve().parent
# Production: /data/uploads (persistent volume), Lokalno: ./uploads
_DATA_DIR = os.environ.get("DATA_DIR") or str(BASE)
UPLOAD = Path(_DATA_DIR) / "uploads"
UPLOAD.mkdir(parents=True, exist_ok=True)

app = Flask(__name__)
# Doverem zagolovkam X-Forwarded-* ot proksi (Railway + Cloudflare)
# Eto nuzhno chtoby url_for(_external=True) generiroval https://, a ne http://
from werkzeug.middleware.proxy_fix import ProxyFix
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)
app.secret_key = os.environ.get("SECRET_KEY") or secrets.token_hex(16)
# Upload limit: 50 MB. Bolshiye fayly (PDF, Word, video) — eshchyo razumno,
# no ne 200 MB DoS vector.
app.config["MAX_CONTENT_LENGTH"] = 50 * 1024 * 1024
app.config["UPLOAD_FOLDER"] = str(UPLOAD)

# === Mobile /api/v1 JSON REST layer (isolated Blueprint, JWT-based, no session coupling) ===
# Guarded registration: the mobile API is an isolated layer that must NEVER be
# able to take down the website. A missing package once crash-looped every
# gunicorn worker (commit a0b681d). The guard catches *any* failure — missing
# module, import error, bad registration — so the web deploy always boots; if
# the mobile layer fails, the site stays up and /api/v1 simply 404s (visible in
# logs). Set JWT_SECRET_KEY in the Railway env so issued tokens survive restarts.
try:
    from api_v1 import (
        ai_generation_bp as _api_v1_ai_generation_bp,
        auth_bp as _api_v1_auth_bp,
        dashboard_bp as _api_v1_dashboard_bp,
        library_bp as _api_v1_library_bp,
        marketplace_bp as _api_v1_marketplace_bp,
        decks_bp as _api_v1_decks_bp,
        study_bp as _api_v1_study_bp,
        test_questions_bp as _api_v1_test_questions_bp,
        tests_bp as _api_v1_tests_bp,
        tutor_bp as _api_v1_tutor_bp,
    )
    for _api_bp in (
        _api_v1_auth_bp, _api_v1_dashboard_bp, _api_v1_library_bp,
        _api_v1_marketplace_bp, _api_v1_decks_bp, _api_v1_study_bp,
        _api_v1_test_questions_bp, _api_v1_tests_bp, _api_v1_tutor_bp,
        _api_v1_ai_generation_bp,
    ):
        app.register_blueprint(_api_bp)
    print("[INIT] Mobile /api/v1 layer registered.")
except Exception as _api_e:
    import traceback as _tb
    print(f"[INIT] /api/v1 layer NOT registered — running web-only: "
          f"{type(_api_e).__name__}: {_api_e}")
    _tb.print_exc()

# === SECURITY CONFIG ===
# Stoykie persistent secret key (sokhranyaet sessii pri perezapuske)
SECRET_FILE = BASE / ".secret_key"
if not os.environ.get("SECRET_KEY"):
    if SECRET_FILE.exists():
        app.secret_key = SECRET_FILE.read_bytes()
    else:
        new_key = secrets.token_bytes(32)
        SECRET_FILE.write_bytes(new_key)
        try:
            os.chmod(SECRET_FILE, 0o600)  # Tol'ko vladelets
        except Exception:
            pass
        app.secret_key = new_key

# Cookie zashchita
# Auto-enable HTTPS-only cookies on production (Railway / cloud with PORT env var)
_is_production = bool(
    os.environ.get("RAILWAY_ENVIRONMENT") or
    os.environ.get("HTTPS_ONLY") == "1" or
    (os.environ.get("PORT") and not os.environ.get("FLASK_DEBUG"))
)
app.config.update(
    SESSION_COOKIE_HTTPONLY=True,        # JS ne mozhet chitat' cookie (XSS zashchita)
    SESSION_COOKIE_SAMESITE="Lax",       # CSRF zashchita
    SESSION_COOKIE_SECURE=_is_production, # HTTPS-only cookies v production
    PERMANENT_SESSION_LIFETIME=timedelta(days=30),
    SESSION_REFRESH_EACH_REQUEST=True,
)

# === SEO verifikatsiya (Google Search Console + Yandex) ===
# Nuzhno: zaregistrirovat'sya v https://search.google.com/search-console,
# vybrat' sposob "HTML tag" — vstavit' tot tokin v env GOOGLE_SITE_VERIFICATION na Railway.
app.config["GOOGLE_SITE_VERIFICATION"] = os.environ.get("GOOGLE_SITE_VERIFICATION", "")
app.config["YANDEX_VERIFICATION"] = os.environ.get("YANDEX_VERIFICATION", "")


# === RATE LIMITING (brute-force zashchita) ===
# Prostoy in-memory limiter. Dlya MVP horoshchiy.
_rate_limits = {}  # {key: [(timestamp, ...)]}


def rate_limit(key: str, max_attempts: int = 5, window_seconds: int = 60) -> bool:
    """Vozvrashchaet True esli mozhno, False esli prevyshen limit."""
    now = datetime.utcnow().timestamp()
    attempts = _rate_limits.get(key, [])
    # Ochishchayem starye popytki vne okna
    attempts = [t for t in attempts if now - t < window_seconds]
    if len(attempts) >= max_attempts:
        _rate_limits[key] = attempts
        return False
    attempts.append(now)
    _rate_limits[key] = attempts
    return True


def get_client_ip():
    """Real client IP behind Cloudflare + Railway.

    Behind Cloudflare the only trustworthy client IP is `CF-Connecting-IP`:
    X-Forwarded-For in this chain often starts with the Cloudflare *edge* IP
    (the user's nearest datacenter — Warsaw, San Jose, …), which made analytics
    geolocate everyone to those edge cities. Prefer CF's header, then other
    real-IP headers, and only then fall back to the XFF chain / remote_addr.
    """
    for h in ("CF-Connecting-IP", "True-Client-IP", "X-Real-IP"):
        v = (request.headers.get(h, "") or "").strip()
        if v:
            return v
    fwd = request.headers.get("X-Forwarded-For", "")
    if fwd:
        parts = [p.strip() for p in fwd.split(",") if p.strip()]
        if parts:
            return parts[0]
    return request.remote_addr or "unknown"


# === SECURITY HEADERS ===
@app.after_request
def security_headers(response):
    """Dobavlyaem zashchitnye HTTP-zagolovki k kazhdomu otvetu."""
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "SAMEORIGIN"  # Anti-clickjacking
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"
    if _is_production:
        # HSTS — brauzer pomnit chto sayt tol'ko HTTPS na 1 god
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    return response


# === BOT PROTECTION ==========================================================
# Block known scanner patterns (WordPress probes, .env attempts, shells, etc)
# BEFORE Flask processes them — saves CPU + cleans analytics.
_blocked_bot_count = {"total": 0}

@app.before_request
def block_scanner_bots():
    """Otklonyaem boty-skanyery do togo kak Flask render-it 404."""
    path = request.path
    ua = request.headers.get("User-Agent", "")
    if bot_protection.is_bot_request(path, ua):
        _blocked_bot_count["total"] += 1
        # Logiruem v security log dlya audita
        try:
            log_security("BOT_BLOCKED", f"path={path[:100]} ua={ua[:60]}")
        except Exception:
            pass
        # Vozvrashchaem 444 (Connection Closed Without Response — minimum work).
        # Boty obychno ne ponimayut etot kod i prekraschayut atakovat'.
        from flask import Response
        return Response("", status=444)


# === CSRF zashchita ===
def get_csrf_token():
    """Vozvrashchaet (ili sozdayet) CSRF-token dlya tekuschey sessii."""
    if "_csrf_token" not in session:
        session["_csrf_token"] = secrets.token_urlsafe(32)
    return session["_csrf_token"]


# === Logging podozritel'nykh sobytiy ===
SECURITY_LOG = BASE / "users_export" / "security.log"
SECURITY_LOG.parent.mkdir(exist_ok=True)


def log_security(event: str, details: str = ""):
    """Zapisyvaet podozritel'nye sobytiya v fayl."""
    try:
        with open(SECURITY_LOG, "a", encoding="utf-8") as f:
            ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            ip = get_client_ip() if request else "-"
            f.write(f"[{ts}] {event} | IP: {ip} | {details}\n")
    except Exception:
        pass


@app.before_request
def csrf_protect():
    """Proveryaem CSRF-token na vse POST-zaprosy. Iskl: webhook'i."""
    if request.method == "POST":
        # Iskl: Stripe webhook (svoya proverka po podpisi)
        if request.path == "/webhooks/stripe":
            return
        # Iskl: mobil'nyy /api/v1 — JSON + Bearer-token auth, ne cookie/sessiya
        # (CSRF ne primenim). Vosstanovleno vmeste s registratsiey api_v1.
        if request.path.startswith("/api/v1/"):
            return
        # Iskl: API-vyzovy (XMLHttpRequest s tem zhe origin) — Flask SameSite zaschishchaet ikh
        # Tol'ko proveryaem klassicheskie HTML-formy:
        token = request.form.get("_csrf")
        if token and token == session.get("_csrf_token"):
            return  # OK
        # Esli net tokena no zapros AJAX (fetch s X-Requested-With) — propuskaem
        # potomu chto SameSite=Lax uzhe zashchitil
        if request.headers.get("X-Requested-With") == "XMLHttpRequest":
            return
        # Esli forma bez tokena — blokiruem (no tol'ko esli session est')
        if "user_id" in session and request.form:
            abort(403, "CSRF token missing or invalid")


# last_seen tracker — obnovlyaem ne chashche raza v 60 sek
import threading
_last_seen_cache = {}
_last_seen_lock = threading.Lock()

@app.before_request
def track_last_seen():
    """Otmechaem polzovatelya kak online (last_seen) na lyubom zaprose, ne chashche raza v minutu."""
    uid = session.get("user_id")
    if not uid or request.path.startswith("/static/") or request.path.startswith("/api/live/"):
        return
    now = datetime.utcnow()
    with _last_seen_lock:
        last = _last_seen_cache.get(uid)
        if last and (now - last).total_seconds() < 60:
            return
        _last_seen_cache[uid] = now
    try:
        conn = db.get_conn()
        # Pishem v formate SQLite "YYYY-MM-DD HH:MM:SS" (BEZ "T") — chtoby strokovoye sravneniye s datetime('now') rabotalo pravil'no
        conn.execute("UPDATE users SET last_seen=? WHERE id=?",
                     (now.strftime("%Y-%m-%d %H:%M:%S"), uid))
        conn.commit()
        conn.close()
    except Exception:
        pass


# === ANALYTICS: trekkin posescheniy ==========================================
# Cache chtoby ne pisat' kazhdyy zapros v BD: 1 visit ot odnogo IP+session za 30 sek
_visit_cache = {}
_visit_cache_lock = threading.Lock()

# Putya kotorye NE logiruem (eto ne prosmotry stranic, a sluzhebnye vyzovy)
_ANALYTICS_SKIP_PREFIXES = (
    "/static/",
    "/favicon.ico",
    "/api/",          # vse API / XHR / mobilnye (/api/v1/...) vyzovy — ne stranicy
    "/login",
    "/logout",
    "/register",
    "/auth/",
    "/superadmin",
)


@app.before_request
def track_analytics():
    """Logiruem posechenie sayta dlya analitiki super-admina."""
    path = request.path
    if any(path.startswith(p) for p in _ANALYTICS_SKIP_PREFIXES):
        return
    if request.method not in ("GET", "POST"):
        return
    # Ne logiruem boty-skanyery (chistim analitiku)
    ua = request.headers.get("User-Agent", "")
    if bot_protection.is_bot_request(path, ua):
        return

    # Ne logiruyem vizity super-adminov
    if session.get("username") in SUPER_ADMINS:
        return

    try:
        ip = get_client_ip()
        user_id = session.get("user_id")

        sid = session.get("_csrf_token", "")
        if not sid:
            ua_short = (request.headers.get("User-Agent", "") or "")[:50]
            sid = f"{ip}_{hash(ua_short)}"

        cache_key = f"{sid}:{path}"
        now = datetime.utcnow()
        with _visit_cache_lock:
            last = _visit_cache.get(cache_key)
            if last and (now - last).total_seconds() < 30:
                return
            _visit_cache[cache_key] = now
            if len(_visit_cache) > 5000:
                _visit_cache.clear()

        analytics.log_visit(
            user_id=user_id,
            ip=ip,
            path=path,
            method=request.method,
            user_agent=request.headers.get("User-Agent", ""),
            referrer=request.headers.get("Referer", ""),
            session_id=sid,
        )
    except Exception:
        # Analytics must never break the main request
        pass


@app.context_processor
def inject_csrf():
    """Dostupno v shablonakh kak {{ csrf_token() }}."""
    return {"csrf_token": get_csrf_token}


# Jinja-fil'tr: UTC datetime/string -> Tashkent (UTC+5)
@app.template_filter("tashkent")
def _tashkent_filter(value, fmt: str = "%Y-%m-%d %H:%M"):
    """Konvertiruem ISO/SQLite-stroku v UTC -> tashkentskoye vremya (+5).
    Primery vhoda: '2026-05-20T18:54:12.987807', '2026-05-20 18:54:12', None."""
    if not value:
        return ""
    # Esli prishyol uzhe datetime
    if isinstance(value, datetime):
        dt = value
    else:
        s = str(value).strip()
        if not s:
            return ""
        # Snimaem 'T' i mikrosekundy
        s = s.replace("T", " ")
        if "." in s:
            s = s.split(".")[0]
        try:
            dt = datetime.strptime(s[:19], "%Y-%m-%d %H:%M:%S")
        except Exception:
            try:
                dt = datetime.strptime(s[:16], "%Y-%m-%d %H:%M")
            except Exception:
                return str(value)[:16]
    # +5 chasov dlya Tashkenta
    dt_tash = dt + timedelta(hours=5)
    return dt_tash.strftime(fmt)


# === Multi-lang field accessor for cards =====================================
# Cards may have front/back/note translations in <field>_en, <field>_uz columns.
# This helper returns the user's lang version if present, else the default field.

def _card_field(card, field):
    """Get field value in user's language (front/back/note). Falls back to default."""
    lang = session.get("lang", "ru") if request else "ru"
    # RU = default field
    if lang == "ru":
        try: return card[field] or ""
        except (KeyError, TypeError, IndexError):
            try: return card.get(field, "") or ""
            except Exception: return ""
    # EN/UZ — try translated column first, fallback to default
    key_translated = f"{field}_{lang}"
    try:
        v = card[key_translated]
        if v: return v
    except (KeyError, TypeError, IndexError):
        try:
            v = card.get(key_translated, "")
            if v: return v
        except Exception: pass
    # Fallback
    try: return card[field] or ""
    except (KeyError, TypeError, IndexError):
        try: return card.get(field, "") or ""
        except Exception: return ""


@app.template_filter("card_field")
def _card_field_filter(card, field):
    """Jinja filter: {{ card | card_field('front') }} returns localized version."""
    return _card_field(card, field)


# ---------------------- helpers ---------------------------------------------

def t(key):
    lang = session.get("lang", "ru")
    return i18n.get(lang, key)


def _plural_form(n, lang):
    """Pick the plural category for `n`. Russian has three (1 / 2-4 / 5+);
    en/uz collapse to singular vs plural (Uzbek leaves the noun unchanged, so
    its 'many' form simply holds the base word)."""
    n = abs(int(n))
    if lang == "ru":
        if n % 10 == 1 and n % 100 != 11:
            return "one"
        if 2 <= n % 10 <= 4 and not (12 <= n % 100 <= 14):
            return "few"
        return "many"
    return "one" if n == 1 else "many"


def npl(n, key):
    """Localized count noun: returns the i18n value for `{key}_{one|few|many}`,
    chosen by the current language's plural rules. e.g. npl(1,'mk_decks') -> 'колода'."""
    lang = session.get("lang", "ru")
    return i18n.get(lang, f"{key}_{_plural_form(n, lang)}")


@app.context_processor
def inject_globals():
    user = current_user()
    plan = billing.get_active_plan(user) if user else "free"
    # Vyderzhivayem novye achievements iz sessii (tol'ko 1 raz)
    new_ach_keys = session.pop("new_achievements", [])
    new_ach = [ach_mod.ACH_BY_KEY[k] for k in new_ach_keys if k in ach_mod.ACH_BY_KEY]

    # Goals reminder
    goal_reminder = None
    if user:
        try:
            conn = db.get_conn()
            if not goals_mod.is_reminder_dismissed_today(conn, user["id"]):
                active_goals = goals_mod.get_active_goals_with_progress(conn, user["id"])
                # Pokazyvaem napominanie esli est' aktivnyye tseli i hot' odna ne sdelana
                pending = [g for g in active_goals if not g["today"]["completed"]]
                behind = [g for g in active_goals if g["status_info"].get("behind")]
                if pending or behind:
                    # Vybiraem sluchaynuyu motivatsionnuyu frazu chtoby ne nadoedalo
                    import random as _random
                    lang = session.get("lang", "ru")
                    motivation_pool = {
                        "ru": [
                            "Не сдавайтесь, у вас всё получится!",
                            "Каждая карточка — шаг к цели 💪",
                            "Маленький рывок сегодня — большой результат завтра",
                            "Ваш мозг скажет вам спасибо ✨",
                            "Лучшее время начать — прямо сейчас",
                            "Один день — одна привычка ближе к успеху",
                            "Регулярность сильнее таланта 🚀",
                            "Сделайте сегодня то, что благодарно завтра",
                            "Цель ближе чем кажется — продолжайте!",
                            "5 минут — лучше чем 0 минут",
                            "Память любит постоянство 🧠",
                            "Вы уже на пути — не сворачивайте",
                        ],
                        "en": [
                            "Don't give up, you can do it!",
                            "Every card is a step closer 💪",
                            "Small effort today, big results tomorrow",
                            "Your brain will thank you ✨",
                            "The best time to start is now",
                            "One day, one habit closer to success",
                            "Consistency beats talent 🚀",
                            "Do today what your future self will thank you for",
                            "Your goal is closer than it seems!",
                            "5 minutes beats 0 minutes",
                            "Memory loves consistency 🧠",
                            "You're already on track — keep going",
                        ],
                        "uz": [
                            "Taslim boʻlmang, qoʻlingizdan keladi!",
                            "Har bir kartochka — maqsadingiz tomon qadam 💪",
                            "Bugungi kichik harakat — ertangi katta natija",
                            "Miyangiz sizga rahmat aytadi ✨",
                            "Boshlash uchun eng yaxshi vaqt — hozir",
                            "Bir kun — bir odat muvaffaqiyatga yaqinroq",
                            "Doimiylik isteʼdoddan kuchliroq 🚀",
                            "Bugun shunday qilingki, ertaga oʻzingizga rahmat aytasiz",
                            "Maqsad koʻrinishidan ham yaqinroq — davom eting!",
                            "5 daqiqa hech narsadan koʻra yaxshi",
                            "Xotira doimiylikni yaxshi koʻradi 🧠",
                            "Siz allaqachon yoʻldasiz — yana bir oz!",
                        ],
                    }
                    pool = motivation_pool.get(lang, motivation_pool["ru"])
                    motivation = _random.choice(pool)

                    goal_reminder = {
                        "pending": pending[:3],   # max 3 chtoby ne pereveshat'
                        "behind": behind[:3],
                        "count": len(active_goals),
                        "motivation": motivation,
                    }
            conn.close()
        except Exception as e:
            print(f"[goals reminder] {e}")

    return {
        "current_user": user,
        "t": t,
        "npl": npl,
        "lang": session.get("lang", "ru"),
        "all_langs": [("ru", "Русский"), ("en", "English"), ("uz", "Oʻzbek")],
        "has_google": config.has_google(),
        "has_stripe": config.has_stripe(),
        "current_plan": plan,
        "plans": config.PLANS,
        "ai_available": ai_gen.is_available(),
        "new_achievements": new_ach,
        "goal_reminder": goal_reminder,
        "is_super_admin": is_super_admin(user),
        "welcome_steps_json": _welcome_steps_json(session.get("lang", "ru")),
    }


def _welcome_steps_json(lang: str) -> str:
    """Shagovaya privetstvennaya instruktsiya — vozvrashayet JSON-array dlya Alpine."""
    import json as _json
    if lang == "en":
        steps = [
            {"icon": "👋", "title": "Welcome to QuizAIPro!",
             "desc": "Smart flashcards with spaced repetition. Let's set you up in 3 minutes."},
            {"icon": "📚", "title": "1. Create your first deck",
             "desc": "A deck = a set of cards (questions/terms). Click + New deck on the dashboard.",
             "link": "/dashboard", "cta": "Open Dashboard"},
            {"icon": "📥", "title": "2. Import or add cards",
             "desc": "Paste text, upload PDF/Word, or use AI to generate questions automatically.",
             "link": "/import", "cta": "Import"},
            {"icon": "🃏", "title": "3. Study with Flashcards",
             "desc": "Click 🃏 Flashcards on a deck. Flip cards, rate Easy/Good/Hard. Algorithm picks the best moment for review."},
            {"icon": "🎯", "title": "4. Set a goal",
             "desc": "Pick a deadline and difficulty — the system splits your work into daily chunks and reminds you.",
             "link": "/goals", "cta": "My goals"},
            {"icon": "❓", "title": "Need help?",
             "desc": "Click ❓ in the top right anytime to see a full guide. Or message us — we listen to feedback."},
        ]
    elif lang == "uz":
        steps = [
            {"icon": "👋", "title": "QuizAIPro ga xush kelibsiz!",
             "desc": "Aqlli kartochkalar va takrorlash algoritmi. 3 daqiqada sozlab beramiz."},
            {"icon": "📚", "title": "1. Birinchi kolodani yarating",
             "desc": "Koloda = savol/javoblar to'plami. Dashboardda + Yangi koloda tugmasini bosing.",
             "link": "/dashboard", "cta": "Dashboard"},
            {"icon": "📥", "title": "2. Kartalar import qiling",
             "desc": "Matn yuklang, PDF/Word import qiling, yoki AI orqali avtomatik savollar yarating.",
             "link": "/import", "cta": "Import"},
            {"icon": "🃏", "title": "3. Flashcards bilan oʻqing",
             "desc": "Kolodada 🃏 Flashcards bosing. Kartalarni aylantirish, baho berish — algoritm sizga eng yaxshi paytda eslatadi."},
            {"icon": "🎯", "title": "4. Maqsad qoʻying",
             "desc": "Muddat tanlang — tizim ishni har kunlik kichik qismlarga ajratadi va eslatib turadi.",
             "link": "/goals", "cta": "Maqsadlar"},
            {"icon": "❓", "title": "Yordam kerakmi?",
             "desc": "Yuqori oʻng burchakdagi ❓ tugmasini istalgan vaqt bosing — toʻliq qoʻllanma bor."},
        ]
    else:  # ru default
        steps = [
            {"icon": "👋", "title": "Добро пожаловать в QuizAIPro!",
             "desc": "Умные карточки с алгоритмом повторений. Давайте настроим всё за 3 минуты."},
            {"icon": "📚", "title": "Шаг 1. Создайте первую колоду",
             "desc": "Колода = набор карточек (вопросы или термины). На дашборде нажмите + Новая колода.",
             "link": "/dashboard", "cta": "На дашборд"},
            {"icon": "📥", "title": "Шаг 2. Загрузите карточки",
             "desc": "Можно вставить текстом, загрузить PDF/Word, или использовать AI чтобы сгенерировать вопросы за 30 секунд.",
             "link": "/import", "cta": "Импорт"},
            {"icon": "🃏", "title": "Шаг 3. Учите через Flashcards",
             "desc": "Откройте колоду → нажмите 🃏 Flashcards. Переворачивайте карты, оценивайте Сложно/Хорошо/Легко. Алгоритм SM-2 решит когда показать снова — учиться будете в 2-3 раза эффективнее."},
            {"icon": "🎯", "title": "Шаг 4. Поставьте цель",
             "desc": "Выберите колоду и срок — система сама посчитает сколько карт делать в день и будет напоминать. Если отстанете — поддержит.",
             "link": "/goals", "cta": "Мои цели"},
            {"icon": "❓", "title": "Нужна помощь?",
             "desc": "Кнопка ❓ в правом верхнем углу — там подробное руководство по всем функциям. Дуэли, Match, Live test, чаты, AI — всё разобрано с примерами."},
        ]
    return _json.dumps(steps, ensure_ascii=False)


def slugify(s):
    s = re.sub(r"[^a-zA-Z0-9а-яА-Я]+", "-", s.lower())
    return s.strip("-")[:50] or f"org{int(datetime.now().timestamp())}"


def can_view_deck(user, deck):
    if not deck: return False
    org = deck["org_id"] if isinstance(deck, dict) or hasattr(deck, "keys") else None
    own = deck["owner_id"] if isinstance(deck, dict) or hasattr(deck, "keys") else None
    # Publichnaya koloda — viden lyubomu polzovatelyu (vklyuchaya super-admina)
    try:
        is_pub = (deck.get("is_public") if isinstance(deck, dict) else deck["is_public"]) or 0
    except (KeyError, IndexError, TypeError):
        is_pub = 0
    if is_pub:
        return True
    if org and user["org_id"] == org: return True
    if own and user["id"] == own: return True
    return False


# === MCQ detection helper ====================================================
_MCQ_OPTION_RE = re.compile(r"^\s*([A-Da-dА-Гa-г1-4])\s*[\)\.\:\-]\s*\S", re.MULTILINE)


def _has_mcq_options(text: str) -> bool:
    """Return True if note/back text looks like multiple-choice options.
    Detects A) B) C) D), 1) 2) 3) 4), А) Б) В) Г) etc.
    Need at least 2 different option letters/numbers."""
    if not text:
        return False
    matches = _MCQ_OPTION_RE.findall(text)
    if len(matches) < 2:
        return False
    unique = {m.upper() for m in matches}
    return len(unique) >= 2


def _card_is_mcq(card_row) -> bool:
    """True if a card has MCQ options either in `note`, `back`, or `front` field.
    Old decks store options in `back`; new decks use `note`; AI/seed often puts them in `front`."""
    note = ""
    back = ""
    front = ""
    try:
        note = card_row["note"] or ""
    except (KeyError, IndexError, TypeError):
        try:
            note = card_row.get("note") or ""
        except Exception:
            pass
    try:
        back = card_row["back"] or ""
    except (KeyError, IndexError, TypeError):
        try:
            back = card_row.get("back") or ""
        except Exception:
            pass
    try:
        front = card_row["front"] or ""
    except (KeyError, IndexError, TypeError):
        try:
            front = card_row.get("front") or ""
        except Exception:
            pass
    if _has_mcq_options(note):
        return True
    if _has_mcq_options(back):
        return True
    if _has_mcq_options(front):
        return True
    return False


def _localize_deck_fields(deck_dict, lang):
    """Swap a deck's name/description for their _en/_uz translation if one
    exists (seeded marketplace decks). Mirrors _localize_card_fields — `name`
    /`description` are the RU default, *_en/*_uz are overrides."""
    if lang in ("en", "uz"):
        for fld in ("name", "description"):
            tr = deck_dict.get(f"{fld}_{lang}")
            if tr:
                deck_dict[fld] = tr
    return deck_dict


def _localize_card_fields(card_dict, lang):
    """Swap front/back/note for their _en/_uz translation if one exists.

    Used by flashcards_view and the /test flow so seeded translations
    (front_uz/back_uz/note_uz, _en) show up for non-RU users.
    """
    if lang in ("en", "uz"):
        for fld in ("front", "back", "note"):
            tr = card_dict.get(f"{fld}_{lang}")
            if tr:
                card_dict[fld] = tr
    return card_dict


def refresh_deck_content_flags(conn, deck_id: int):
    """Pересчитывает has_mcq и has_terms для колоды и сохраняет в decks.
    Вызывать при: добавлении/удалении карточки, импорте, AI генерации.
    Проверяет note, back AND front (different formats store options differently)."""
    cards = conn.execute(
        "SELECT note, back, front FROM cards WHERE deck_id=?", (deck_id,)
    ).fetchall()
    has_mcq = 0
    has_terms = 0
    for c in cards:
        if _card_is_mcq(c):
            has_mcq = 1
        else:
            has_terms = 1
        if has_mcq and has_terms:
            break  # both found, no need to continue
    conn.execute(
        "UPDATE decks SET has_mcq=?, has_terms=? WHERE id=?",
        (has_mcq, has_terms, deck_id)
    )


def _check_goals_daily_completion(conn, user_id):
    """Posle kazhdogo otveta — proveryaem, ne vypolnil li polzovatel' dnevnuyu normu po tselyam.
    Esli da i ranshe ne nachislyali bonus segodnya — daet XP. Vozvraschaet spisok soobshcheniy."""
    today = date.today().isoformat()
    awarded = []
    goals = goals_mod.get_active_goals_with_progress(conn, user_id)
    for g in goals:
        # Awarded segodnya?
        already = conn.execute("""
            SELECT 1 FROM goal_daily_extras
            WHERE goal_id=? AND date=? AND extra_quota=0 AND done=1
        """, (g["id"], today)).fetchone()
        if already:
            continue
        if g["today"]["completed"]:
            # Otmechaem
            conn.execute("""
                INSERT INTO goal_daily_extras (goal_id, date, extra_quota, done)
                VALUES (?, ?, 0, 1)
            """, (g["id"], today))
            conn.execute("UPDATE users SET xp = xp + ? WHERE id=?",
                         (goals_mod.DAILY_QUOTA_XP, user_id))
            awarded.append({
                "title": g["title"],
                "xp": goals_mod.DAILY_QUOTA_XP,
            })
    if awarded:
        conn.commit()
    return awarded


# ---------------------- public ----------------------------------------------

@app.route("/")
def index():
    if session.get("user_id"):
        return redirect(url_for("dashboard"))
    return render_template("landing.html")


@app.route("/terms")
def terms_page():
    """Pol'zovatelskoye soglashenie (publicno dostupno bez login)."""
    return render_template("terms.html")


@app.route("/privacy")
def privacy_page():
    """Politika konfidentsial'nosti (publicno dostupno bez login)."""
    return render_template("privacy.html")


@app.route("/sitemap.xml")
def sitemap_xml():
    """SEO sitemap dlya Google Search Console — vklyuchaem publichnyy kontent."""
    base_url = "https://quizaipro.com"
    today = datetime.utcnow().strftime("%Y-%m-%d")

    # Staticheskie publichnye stranitsy
    static_pages = [
        ("", "1.0", "weekly"),
        ("/login", "0.7", "monthly"),
        ("/register", "0.8", "monthly"),
        ("/marketplace", "0.9", "weekly"),
        ("/leaderboard", "0.6", "weekly"),
        ("/terms", "0.4", "yearly"),
        ("/privacy", "0.4", "yearly"),
    ]

    xml = ['<?xml version="1.0" encoding="UTF-8"?>',
           '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']

    for path, priority, freq in static_pages:
        xml.append("<url>")
        xml.append(f"<loc>{base_url}{path}</loc>")
        xml.append(f"<lastmod>{today}</lastmod>")
        xml.append(f"<changefreq>{freq}</changefreq>")
        xml.append(f"<priority>{priority}</priority>")
        xml.append("</url>")

    # Dinamicheskoye: publichnye kolody iz marketplace
    try:
        conn = db.get_conn()
        public_decks = conn.execute("""
            SELECT id, COALESCE(created_at, '') AS created_at FROM decks
            WHERE is_public = 1
            ORDER BY clones_count DESC LIMIT 500
        """).fetchall()
        for d in public_decks:
            lastmod = (d["created_at"] or today).split(" ")[0][:10] or today
            xml.append("<url>")
            xml.append(f"<loc>{base_url}/deck/{d['id']}</loc>")
            xml.append(f"<lastmod>{lastmod}</lastmod>")
            xml.append("<changefreq>weekly</changefreq>")
            xml.append("<priority>0.7</priority>")
            xml.append("</url>")

        # Polzovateli s otkrytym profilem (filtruem bot-podobnye i sistemnye akkaunty)
        public_users = conn.execute("""
            SELECT username FROM users
            WHERE COALESCE(profile_public, 1) = 1
              AND username IS NOT NULL
              AND username NOT LIKE '%@%'              -- net email-pohojih usernames
              AND username NOT LIKE '%backdoor%'       -- net podozritel'nyh
              AND username NOT LIKE '%xss%'
              AND username NOT LIKE '%admin%'
              AND username NOT LIKE '%system%'
              AND username NOT LIKE '%test%'
              AND LENGTH(username) >= 3
              AND xp > 0                                -- tol'ko aktivnye polzovateli
            ORDER BY xp DESC LIMIT 200
        """).fetchall()
        for u in public_users:
            # URL-encode imena (russkiy/uzbeksskiy alfavit)
            from urllib.parse import quote
            uname = quote(u['username'])
            xml.append("<url>")
            xml.append(f"<loc>{base_url}/u/{uname}</loc>")
            xml.append(f"<lastmod>{today}</lastmod>")
            xml.append("<changefreq>monthly</changefreq>")
            xml.append("<priority>0.5</priority>")
            xml.append("</url>")
        # Sub'ekty marketpleysa (vazhnaya kontent dlya SEO)
        try:
            subjects = conn.execute(
                "SELECT slug FROM mp_subjects WHERE is_active=1"
            ).fetchall()
            for s in subjects:
                xml.append("<url>")
                xml.append(f"<loc>{base_url}/marketplace/subject/{s['slug']}</loc>")
                xml.append(f"<lastmod>{today}</lastmod>")
                xml.append("<changefreq>weekly</changefreq>")
                xml.append("<priority>0.8</priority>")
                xml.append("</url>")
        except Exception:
            pass
        # Kollektsii marketpleysa
        try:
            collections = conn.execute(
                "SELECT slug FROM collections WHERE is_active=1"
            ).fetchall()
            for c in collections:
                xml.append("<url>")
                xml.append(f"<loc>{base_url}/collection/{c['slug']}</loc>")
                xml.append(f"<lastmod>{today}</lastmod>")
                xml.append("<changefreq>weekly</changefreq>")
                xml.append("<priority>0.7</priority>")
                xml.append("</url>")
        except Exception:
            pass
        conn.close()
    except Exception as e:
        print(f"[sitemap] dynamic part failed: {e}")

    xml.append("</urlset>")
    from flask import Response
    return Response("\n".join(xml), mimetype="application/xml")


@app.route("/robots.txt")
def robots_txt():
    """SEO robots.txt — razreshaem indeksirovat' publichnye stranitsy."""
    txt = "User-agent: *\n"
    txt += "Allow: /\n"
    txt += "Disallow: /dashboard\n"
    txt += "Disallow: /superadmin\n"
    txt += "Disallow: /api/\n"
    txt += "Disallow: /admin/\n"
    txt += "Disallow: /settings\n"
    txt += "Disallow: /billing\n"
    txt += "\n"
    txt += "Sitemap: https://quizaipro.com/sitemap.xml\n"
    from flask import Response
    return Response(txt, mimetype="text/plain")


@app.route("/favicon.ico")
def favicon():
    """Yandex i drugie poiskoviki ishchut favicon po /favicon.ico v korne sayta."""
    from flask import send_from_directory
    return send_from_directory(
        str(Path(__file__).parent / "static"),
        "favicon.ico",
        mimetype="image/vnd.microsoft.icon"
    )


@app.route("/set-lang/<lang>")
def set_lang(lang):
    if lang not in ("ru", "en", "uz"): lang = "ru"
    session["lang"] = lang
    if session.get("user_id"):
        conn = db.get_conn()
        conn.execute("UPDATE users SET lang=? WHERE id=?", (lang, session["user_id"]))
        conn.commit(); conn.close()
    return redirect(request.referrer or url_for("index"))


# ---------------------- auth (username/password) ----------------------------

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        # Rate limit po IP — 10 popytok v minutu
        ip = get_client_ip()
        if not rate_limit(f"login:{ip}", max_attempts=10, window_seconds=60):
            flash("Слишком много попыток. Подождите 1 минуту.", "error")
            return render_template("login.html")

        org_name = request.form.get("org_name", "").strip()
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")
        mode = request.form.get("mode", "individual")
        if not username or not password:
            flash("Введите имя и пароль", "error"); return render_template("login.html")
        # Rate limit po imeni polzovatelya — 5 popytok v 5 minut (zashchita ot bryute)
        if not rate_limit(f"login_user:{username}", max_attempts=5, window_seconds=300):
            flash("Слишком много попыток для этого аккаунта. Подождите 5 минут.", "error")
            return render_template("login.html")

        conn = db.get_conn()
        if mode == "corporate":
            # Корпоративный режим временно отключён (в разработке)
            conn.close()
            flash("Режим «Учебный центр» в разработке. Войдите как индивидуальный пользователь.", "error")
            return render_template("login.html")
        if mode == "corporate":
            if not org_name:
                conn.close(); flash("Название организации", "error"); return render_template("login.html")
            org = conn.execute("SELECT * FROM organizations WHERE name=?", (org_name,)).fetchone()
            if not org:
                conn.close(); flash("Организация не найдена", "error"); return render_template("login.html")
            user = conn.execute("SELECT * FROM users WHERE org_id=? AND username=?",
                                (org["id"], username)).fetchone()
        else:
            user = conn.execute("SELECT * FROM users WHERE org_id IS NULL AND username=?",
                                (username,)).fetchone()
        conn.close()
        if user and check_password_hash(user["password_hash"], password):
            # Sbros rate-limit pri uspehe
            _rate_limits.pop(f"login_user:{username}", None)
            session.clear()  # Anti-session-fixation
            session["user_id"] = user["id"]
            session["username"] = user["username"]
            session["lang"] = user["lang"] or "ru"
            session.permanent = True
            return redirect(url_for("dashboard"))
        log_security("LOGIN_FAILED", f"username={username} mode={mode}")
        flash("Неверные данные", "error")
    return render_template("login.html")


# --- Avto-zhurnal registratsiy v fayl ---

REGISTRATIONS_DIR = Path(__file__).parent / "users_export"
REGISTRATIONS_DIR.mkdir(exist_ok=True)
REGISTRATIONS_LOG = REGISTRATIONS_DIR / "registrations.csv"


def log_registration(username: str, role: str, mode: str, org_name: str = "", source: str = "form"):
    """Dobavlyaet stroku v users_export/registrations.csv pri kazhdoy novoy registratsii."""
    import csv
    is_new = not REGISTRATIONS_LOG.exists()
    with open(REGISTRATIONS_LOG, "a", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f, delimiter=";")
        if is_new:
            w.writerow(["Дата", "Логин", "Роль", "Тип", "Организация", "Источник"])
        w.writerow([
            datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            username,
            role,
            mode,
            org_name or "—",
            source,
        ])


@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        # Rate limit po IP — 5 registratsiy v 10 minut (anti-spam)
        ip = get_client_ip()
        if not rate_limit(f"register:{ip}", max_attempts=5, window_seconds=600):
            flash("Слишком много регистраций с этого адреса. Подождите 10 минут.", "error")
            return render_template("register.html")

        mode = request.form.get("mode", "individual")
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")
        org_name = request.form.get("org_name", "").strip()
        # Validatsiya: bukvy (lat/cyr), tsifry, ., _, - (anti-injection)
        if not re.match(r"^[a-zA-Zа-яА-ЯёЁ0-9._-]{3,32}$", username):
            flash("Логин: 3-32 символа, буквы (рус/eng), цифры, . _ -", "error")
            return render_template("register.html")
        if len(password) < 6:
            flash("Минимум 6 символов для пароля", "error"); return render_template("register.html")
        conn = db.get_conn()
        try:
            if mode == "corporate":
                # Корпоративный режим временно отключён
                conn.close()
                flash("Регистрация учебных центров в разработке. Зарегистрируйтесь как индивидуальный пользователь.", "error")
                return render_template("register.html")
            if mode == "corporate":
                if len(org_name) < 2:
                    flash("Введите название организации", "error"); return render_template("register.html")
                exists = conn.execute("SELECT id FROM organizations WHERE name=?", (org_name,)).fetchone()
                if exists:
                    flash("Организация уже существует", "error"); return render_template("register.html")
                cur = conn.execute("INSERT INTO organizations (name, slug) VALUES (?, ?)",
                                   (org_name, slugify(org_name)))
                org_id = cur.lastrowid
                conn.execute("""INSERT INTO users (org_id, username, password_hash, role, lang)
                               VALUES (?, ?, ?, 'admin', 'ru')""",
                            (org_id, username, generate_password_hash(password)))
            else:
                exists = conn.execute("SELECT id FROM users WHERE org_id IS NULL AND username=?",
                                      (username,)).fetchone()
                if exists:
                    flash("Имя пользователя уже занято", "error"); return render_template("register.html")
                conn.execute("""INSERT INTO users (org_id, username, password_hash, role, lang)
                               VALUES (NULL, ?, ?, 'individual', 'ru')""",
                            (username, generate_password_hash(password)))
            conn.commit()
            if mode == "corporate":
                user = conn.execute("SELECT * FROM users WHERE org_id=? AND username=?",
                                    (org_id, username)).fetchone()
            else:
                user = conn.execute("SELECT * FROM users WHERE org_id IS NULL AND username=?",
                                    (username,)).fetchone()
            # Avto-zhurnal registratsii
            try:
                log_registration(
                    username=username,
                    role=user["role"],
                    mode=mode,
                    org_name=org_name if mode == "corporate" else "",
                    source="form"
                )
            except Exception as log_err:
                print(f"[!] Ne udalos' zapisat' registratsiyu v fayl: {log_err}")
            session["user_id"] = user["id"]; session["username"] = user["username"]; session["lang"] = "ru"
            return redirect(url_for("dashboard"))
        except Exception as e:
            flash(f"Oshibka: {e}", "error")
        finally:
            conn.close()
    return render_template("register.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("index"))


# ---------------------- Google OAuth ----------------------------------------

@app.route("/auth/google")
def auth_google():
    if not config.has_google():
        flash("Google OAuth ne nastroen", "error")
        return redirect(url_for("login"))
    redirect_uri = url_for("auth_google_callback", _external=True)
    return redirect(google_auth.login_url(redirect_uri))


@app.route("/auth/google/callback")
def auth_google_callback():
    if not config.has_google():
        return redirect(url_for("login"))
    code = request.args.get("code")
    state = request.args.get("state")
    if not code or state != session.get("oauth_state"):
        flash("Oshibka avtorizatsii", "error")
        return redirect(url_for("login"))
    redirect_uri = url_for("auth_google_callback", _external=True)
    info = google_auth.handle_callback(code, redirect_uri)
    if not info or not info.get("email"):
        flash("Ne udalos' poluchit' email iz Google", "error")
        return redirect(url_for("login"))
    uid = google_auth.find_or_create_user(info["email"], info.get("name", ""))
    if not uid:
        flash("Oshibka sozdaniya akkaunta", "error")
        return redirect(url_for("login"))
    # Avto-zhurnal — tol'ko esli polzovatel' tol'ko chto sozdan (registratsiya, ne login)
    try:
        conn = db.get_conn()
        u = conn.execute("SELECT username, role, created_at FROM users WHERE id=?", (uid,)).fetchone()
        conn.close()
        if u:
            # Schitaem novym esli created_at v poslednie 30 sek
            from datetime import datetime as _dt, timedelta as _td
            try:
                cu = _dt.fromisoformat(u["created_at"])
                if _dt.utcnow() - cu < _td(seconds=30):
                    log_registration(u["username"], u["role"], "individual",
                                     org_name="", source="google")
            except Exception:
                pass
    except Exception as log_err:
        print(f"[!] Google reg log oshibka: {log_err}")
    session["user_id"] = uid
    session["username"] = u["username"] if u else ""
    session["lang"] = "ru"
    return redirect(url_for("dashboard"))


# ---------------------- dashboard -------------------------------------------

@app.route("/help")
@login_required
def help_page():
    """Stranitsa pomoshchi — kak polzovatsya saytom."""
    lang = session.get("lang", "ru")
    user = current_user()
    # Progress prokhozhdeniya tour'ov (dobavleny pozzhe — koloncki mogut otsutstvovat')
    tour_progress = {"basic": False, "import": False, "categories": False}
    try:
        conn = db.get_conn()
        row = conn.execute(
            "SELECT COALESCE(tour_basic_done,0) AS b, COALESCE(tour_import_done,0) AS i, COALESCE(tour_categories_done,0) AS c FROM users WHERE id=?",
            (user["id"],)
        ).fetchone()
        conn.close()
        if row:
            tour_progress = {"basic": bool(row["b"]), "import": bool(row["i"]), "categories": bool(row["c"])}
    except Exception:
        pass  # kolonok eshche net (do migratsii)
    help_payload = help_content.get(lang)
    return render_template(
        "help.html",
        help_data=help_payload,
        help_payload=help_payload,
        tour_progress=tour_progress,
    )


@app.route("/api/welcome/dismiss", methods=["POST"])
@login_required
def api_welcome_dismiss():
    """Otmechaem chto polzovatel' uvidel privetstvennyy tour."""
    user = current_user()
    conn = db.get_conn()
    conn.execute("UPDATE users SET welcome_shown=1 WHERE id=?", (user["id"],))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/api/welcome/restart", methods=["POST"])
@login_required
def api_welcome_restart():
    """Zanovo zapustit welcome tour (iz /help knopki 'Pokazat snova')."""
    user = current_user()
    conn = db.get_conn()
    conn.execute("UPDATE users SET welcome_shown=0 WHERE id=?", (user["id"],))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/api/tour/complete", methods=["POST"])
@login_required
def api_tour_complete():
    """Otmechaem chto polzovatel' proshyol konkretnyy etap tour'a.
    Stages: basic / import / categories
    """
    user = current_user()
    stage = (request.form.get("stage") or "").strip().lower()
    if stage not in ("basic", "import", "categories"):
        return jsonify({"ok": False, "error": "invalid stage"}), 400
    column = f"tour_{stage}_done"
    conn = db.get_conn()
    try:
        conn.execute(f"ALTER TABLE users ADD COLUMN {column} INTEGER DEFAULT 0")
    except Exception:
        pass
    conn.execute(f"UPDATE users SET {column}=1 WHERE id=?", (user["id"],))
    conn.commit(); conn.close()
    return jsonify({"ok": True, "stage": stage})


@app.route("/tour/<stage>")
@login_required
def tour_launcher(stage):
    """Launcher dlya tour'a — perenapravlyaet na nuzhnuyu stranitsu s ?tour=stage parametrom.
    Etapy zablokirovany do prokhozhdeniya predyduschih.
    """
    user = current_user()
    # Proveryaem progress
    progress = {"basic": False, "import": False, "categories": False}
    try:
        conn = db.get_conn()
        row = conn.execute(
            "SELECT COALESCE(tour_basic_done,0) AS b, COALESCE(tour_import_done,0) AS i, COALESCE(tour_categories_done,0) AS c FROM users WHERE id=?",
            (user["id"],)
        ).fetchone()
        conn.close()
        if row:
            progress = {"basic": bool(row["b"]), "import": bool(row["i"]), "categories": bool(row["c"])}
    except Exception:
        pass

    if stage == "basic":
        return redirect(url_for("dashboard") + "?tour=basic")
    if stage == "import":
        if not progress["basic"]:
            flash("Сначала пройдите этап 'Основы'", "info")
            return redirect(url_for("dashboard") + "?tour=basic")
        return redirect("/import?tour=import")
    if stage == "categories":
        if not progress["import"]:
            flash("Сначала пройдите этап 'Импорт'", "info")
            return redirect("/import?tour=import")
        return redirect("/categories?tour=categories")
    return redirect(url_for("dashboard"))


@app.route("/api/install-demo-decks", methods=["POST"])
@login_required
def api_install_demo_decks():
    """Sozdaet demo-kolody na yazyke polzovatelya: 3 kolody."""
    user = current_user()
    user_id = user["id"]
    org_id = user["org_id"]
    lang = session.get("lang") or user.get("lang") or "ru"

    import demo_content
    DEMO_DECKS = demo_content.get_demo_decks(lang)

    # Vsyo v try/except — chtoby vmesto HTML 500 oshibki vernut' JSON s tochnym soobshcheniyem
    try:
        conn = db.get_conn()
        created_ids = []
        for deck_data in DEMO_DECKS:
            cur = conn.execute(
                """INSERT INTO decks (org_id, owner_id, name, icon, is_public)
                   VALUES (?, ?, ?, ?, 0)""",
                (org_id, user_id, deck_data["name"], deck_data["icon"])
            )
            deck_id = cur.lastrowid
            created_ids.append(deck_id)
            for front, back, note in deck_data["cards"]:
                conn.execute(
                    """INSERT INTO cards (deck_id, front, back, note)
                       VALUES (?, ?, ?, ?)""",
                    (deck_id, front, back, note)
                )
        conn.commit()
        conn.close()
        return jsonify({"ok": True, "deck_ids": created_ids, "count": len(created_ids)})
    except Exception as e:
        import traceback
        tb = traceback.format_exc()
        print(f"[install-demo-decks] {type(e).__name__}: {e}\n{tb}")
        try:
            conn.close()
        except Exception:
            pass
        return jsonify({
            "ok": False,
            "error": f"{type(e).__name__}: {e}",
        }), 500


@app.route("/dashboard")
@login_required
def dashboard():
    user = current_user()
    if user["role"] in ("admin", "teacher"):
        return _admin_dashboard(user)
    return _student_dashboard(user)


def _student_dashboard(user):
    conn = db.get_conn()
    now = datetime.utcnow().isoformat()
    # has_mcq / has_terms — predvychislennye flagi (NULL = eshchyo ne schitano → fallback na SQL)
    # Esli NULL — ispol'zuem SQL-podschet (dlya starykh kolod)
    # Proveryaem note I back — starye kolody hranyat varianty pryamo v back.
    mcq_filter = (
        "(c.note LIKE '%A)%' OR c.note LIKE '%А)%' OR c.note LIKE 'A.%' OR c.note LIKE '1)%' "
        " OR c.back LIKE '%A)%' OR c.back LIKE '%А)%' OR c.back LIKE 'A.%' OR c.back LIKE '1)%')"
    )
    if user["org_id"]:
        decks = conn.execute(f"""
            SELECT d.*, c.name AS category_name, c.icon AS category_icon, c.parent_id AS category_parent_id,
                pc.name AS parent_name, pc.icon AS parent_icon,
                (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS card_count,
                COALESCE(d.has_mcq,
                    (SELECT CASE WHEN COUNT(*)>0 THEN 1 ELSE 0 END FROM cards c WHERE c.deck_id=d.id AND {mcq_filter})
                ) AS mcq_count,
                COALESCE(d.has_terms,
                    (SELECT CASE WHEN COUNT(*)>0 THEN 1 ELSE 0 END FROM cards c WHERE c.deck_id=d.id AND NOT {mcq_filter})
                ) AS terms_count,
                (SELECT COUNT(*) FROM cards crd
                 LEFT JOIN user_card_progress p ON p.card_id=crd.id AND p.user_id=?
                 WHERE crd.deck_id=d.id AND (p.due_at IS NULL OR p.due_at <= ?)) AS due_count,
                (SELECT COUNT(*) FROM cards crd
                 JOIN user_card_progress p ON p.card_id=crd.id
                 WHERE crd.deck_id=d.id AND p.user_id=? AND p.interval_days >= 7) AS learned_count
            FROM decks d
            LEFT JOIN categories c ON c.id=d.category_id
            LEFT JOIN categories pc ON pc.id=c.parent_id
            WHERE d.org_id=? ORDER BY pc.name, c.name, d.created_at DESC
        """, (user["id"], now, user["id"], user["org_id"])).fetchall()
    else:
        decks = conn.execute(f"""
            SELECT d.*, c.name AS category_name, c.icon AS category_icon, c.parent_id AS category_parent_id,
                pc.name AS parent_name, pc.icon AS parent_icon,
                (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS card_count,
                COALESCE(d.has_mcq,
                    (SELECT CASE WHEN COUNT(*)>0 THEN 1 ELSE 0 END FROM cards c WHERE c.deck_id=d.id AND {mcq_filter})
                ) AS mcq_count,
                COALESCE(d.has_terms,
                    (SELECT CASE WHEN COUNT(*)>0 THEN 1 ELSE 0 END FROM cards c WHERE c.deck_id=d.id AND NOT {mcq_filter})
                ) AS terms_count,
                (SELECT COUNT(*) FROM cards crd
                 LEFT JOIN user_card_progress p ON p.card_id=crd.id AND p.user_id=?
                 WHERE crd.deck_id=d.id AND (p.due_at IS NULL OR p.due_at <= ?)) AS due_count,
                (SELECT COUNT(*) FROM cards crd
                 JOIN user_card_progress p ON p.card_id=crd.id
                 WHERE crd.deck_id=d.id AND p.user_id=? AND p.interval_days >= 7) AS learned_count
            FROM decks d
            LEFT JOIN categories c ON c.id=d.category_id
            LEFT JOIN categories pc ON pc.id=c.parent_id
            WHERE d.owner_id=? ORDER BY pc.name, c.name, d.created_at DESC
        """, (user["id"], now, user["id"], user["id"])).fetchall()

    total = sum(d["card_count"] for d in decks)
    learned = sum(d["learned_count"] for d in decks)
    due = sum(d["due_count"] for d in decks)
    total_reviews = conn.execute("SELECT COUNT(*) AS c FROM reviews WHERE user_id=?",
                                 (user["id"],)).fetchone()["c"]
    # Daily goal — skol'ko otvetil segodnya
    today_reviews = conn.execute("""
        SELECT COUNT(*) AS c FROM reviews
        WHERE user_id=? AND DATE(reviewed_at) = DATE('now')
    """, (user["id"],)).fetchone()["c"] or 0
    daily_goal = user["daily_goal"] if "daily_goal" in user.keys() else 20
    daily_goal = daily_goal or 20
    # Obshchee uderzhanie (FSRS) po vsem izuchennym kartam — "skol'ko ty pomnish' seychas"
    ret_rows = conn.execute("""
        SELECT p.reviews, p.stability, p.last_reviewed, p.interval_days, p.ef
        FROM user_card_progress p
        WHERE p.user_id=? AND p.reviews IS NOT NULL AND p.reviews > 0
    """, (user["id"],)).fetchall()
    retention = fsrs.deck_retention([dict(r) for r in ret_rows])
    by_category = {}
    for d in decks:
        # Esli kategoriya — eto podkategoriya, gruppiruem po "Roditel' → Dochka"
        if d["category_name"]:
            if d["parent_name"]:
                cat_label = f"{d['parent_name']} → {d['category_name']}"
                cat_icon = d["parent_icon"] or "📁"
            else:
                cat_label = d["category_name"]
                cat_icon = d["category_icon"] or "📁"
        else:
            cat_label = "Без категории"
            cat_icon = "📁"
        if cat_label not in by_category:
            by_category[cat_label] = {"icon": cat_icon, "decks": []}
        by_category[cat_label]["decks"].append(d)

    # Kategorii dlya formy "novaya kolodа"
    if user["org_id"]:
        all_cats = conn.execute("SELECT * FROM categories WHERE org_id=? ORDER BY parent_id IS NULL DESC, name",
                                (user["org_id"],)).fetchall()
    else:
        all_cats = conn.execute("SELECT * FROM categories WHERE owner_id=? ORDER BY parent_id IS NULL DESC, name",
                                (user["id"],)).fetchall()
    conn.close()
    return render_template("dashboard_student.html",
        decks=decks, total=total, learned=learned, due=due,
        total_reviews=total_reviews, by_category=by_category,
        all_categories=all_cats,
        today_reviews=today_reviews, daily_goal=daily_goal,
        retention=retention,
    )


def _admin_dashboard(user):
    conn = db.get_conn()
    org_id = user["org_id"]
    f_group = request.args.get("group_id", type=int)
    f_category = request.args.get("category_id", type=int)
    f_deck = request.args.get("deck_id", type=int)

    groups = conn.execute("SELECT * FROM groups WHERE org_id=? ORDER BY name", (org_id,)).fetchall()
    categories = conn.execute("SELECT * FROM categories WHERE org_id=? ORDER BY name", (org_id,)).fetchall()
    decks = conn.execute("""SELECT d.*, c.name AS category_name FROM decks d
                            LEFT JOIN categories c ON c.id=d.category_id
                            WHERE d.org_id=? ORDER BY d.name""", (org_id,)).fetchall()
    total_cards = conn.execute("""
        SELECT COUNT(*) AS c FROM cards crd JOIN decks d ON d.id=crd.deck_id WHERE d.org_id=?""",
        (org_id,)).fetchone()["c"]

    if f_group:
        students = conn.execute("""
            SELECT u.* FROM users u JOIN group_members gm ON gm.user_id=u.id
            WHERE gm.group_id=? AND u.role='student'""", (f_group,)).fetchall()
    else:
        students = conn.execute("""SELECT * FROM users WHERE org_id=? AND role='student'
                                    ORDER BY username""", (org_id,)).fetchall()

    deck_filter = " AND crd.deck_id=?" if f_deck else ""
    cat_filter = " AND d.category_id=?" if f_category and not f_deck else ""
    extra = []
    if f_deck: extra.append(f_deck)
    elif f_category: extra.append(f_category)

    student_stats = []
    for s in students:
        params_a = [s["id"]] + extra
        params_b = [s["id"]] + extra
        params_c = [s["id"]] + extra
        row = conn.execute(f"""
            SELECT
                (SELECT COUNT(*) FROM cards crd JOIN decks d ON d.id=crd.deck_id
                 LEFT JOIN user_card_progress p ON p.card_id=crd.id AND p.user_id=?
                 WHERE d.org_id={org_id}{deck_filter}{cat_filter} AND p.interval_days >= 7) AS learned,
                (SELECT COUNT(*) FROM cards crd JOIN decks d ON d.id=crd.deck_id
                 LEFT JOIN user_card_progress p ON p.card_id=crd.id AND p.user_id=?
                 WHERE d.org_id={org_id}{deck_filter}{cat_filter}) AS total,
                (SELECT COUNT(*) FROM reviews r JOIN cards crd ON crd.id=r.card_id
                 JOIN decks d ON d.id=crd.deck_id
                 WHERE r.user_id=? AND d.org_id={org_id}{deck_filter}{cat_filter}) AS reviews
        """, params_a + params_b + params_c).fetchone()
        student_stats.append({
            "id": s["id"], "username": s["username"], "full_name": s["full_name"],
            "learned": row["learned"] or 0, "total": row["total"] or 0,
            "progress": round((row["learned"] / row["total"] * 100) if row["total"] else 0, 1),
            "reviews": row["reviews"] or 0, "xp": s["xp"] or 0, "streak": s["streak"] or 0,
        })

    org_learned = sum(s["learned"] for s in student_stats)
    org_total = sum(s["total"] for s in student_stats)
    org_progress = round((org_learned / org_total * 100) if org_total else 0, 1)

    cat_stats = []
    for cat in categories:
        cat_total = conn.execute("""SELECT COUNT(*) AS c FROM cards crd JOIN decks d ON d.id=crd.deck_id
                                     WHERE d.category_id=?""", (cat["id"],)).fetchone()["c"]
        cat_reviews = conn.execute("""SELECT AVG(CASE WHEN grade>=3 THEN 1.0 ELSE 0.0 END) AS rate, COUNT(*) AS cnt
                                       FROM reviews r JOIN cards crd ON crd.id=r.card_id
                                       JOIN decks d ON d.id=crd.deck_id WHERE d.category_id=?""",
                                    (cat["id"],)).fetchone()
        cat_stats.append({"id": cat["id"], "name": cat["name"], "icon": cat["icon"],
            "cards": cat_total, "success_rate": round((cat_reviews["rate"] or 0) * 100, 1),
            "reviews": cat_reviews["cnt"] or 0})

    deck_stats = []
    for d in decks:
        d_reviews = conn.execute("""SELECT AVG(CASE WHEN grade>=3 THEN 1.0 ELSE 0.0 END) AS rate, COUNT(*) AS cnt
                                     FROM reviews r JOIN cards crd ON crd.id=r.card_id WHERE crd.deck_id=?""",
                                  (d["id"],)).fetchone()
        d_cards = conn.execute("SELECT COUNT(*) AS c FROM cards WHERE deck_id=?", (d["id"],)).fetchone()["c"]
        deck_stats.append({"id": d["id"], "name": d["name"], "icon": d["icon"],
            "category": d["category_name"], "cards": d_cards,
            "success_rate": round((d_reviews["rate"] or 0) * 100, 1),
            "reviews": d_reviews["cnt"] or 0})

    group_stats = []
    for g in groups:
        g_members = conn.execute("SELECT COUNT(*) AS c FROM group_members WHERE group_id=?",
                                  (g["id"],)).fetchone()["c"]
        g_avg = conn.execute("""
            SELECT AVG(progress) AS p FROM (
                SELECT CAST((SELECT COUNT(*) FROM cards crd JOIN decks d ON d.id=crd.deck_id
                     JOIN user_card_progress p ON p.card_id=crd.id
                     WHERE p.user_id=u.id AND d.org_id=? AND p.interval_days>=7) AS REAL) /
                    NULLIF((SELECT COUNT(*) FROM cards crd JOIN decks d ON d.id=crd.deck_id
                     WHERE d.org_id=?), 0) AS progress
                FROM users u JOIN group_members gm ON gm.user_id=u.id
                WHERE gm.group_id=? AND u.role='student'
            )""", (org_id, org_id, g["id"])).fetchone()
        group_stats.append({"id": g["id"], "name": g["name"], "members": g_members,
            "progress": round((g_avg["p"] or 0) * 100, 1)})

    student_stats_top = sorted(student_stats, key=lambda x: -x["progress"])[:10]
    student_stats_worst = sorted(student_stats, key=lambda x: x["progress"])[:10]
    deck_stats_worst = sorted([d for d in deck_stats if d["reviews"] > 0],
                               key=lambda x: x["success_rate"])[:10]
    cat_stats_worst = sorted([c for c in cat_stats if c["reviews"] > 0],
                              key=lambda x: x["success_rate"])[:10]
    conn.close()
    return render_template("dashboard_admin.html",
        groups=groups, categories=categories, decks=decks,
        total_cards=total_cards, org_progress=org_progress,
        org_learned=org_learned, org_total=org_total, n_students=len(students),
        student_stats=student_stats, student_stats_top=student_stats_top,
        student_stats_worst=student_stats_worst, deck_stats_worst=deck_stats_worst,
        cat_stats_worst=cat_stats_worst, cat_stats=cat_stats, deck_stats=deck_stats,
        group_stats=group_stats, f_group=f_group, f_category=f_category, f_deck=f_deck,
    )


# ---------------------- admin user/group management ------------------------

@app.route("/admin/students")
@role_required("admin", "teacher")
def admin_students():
    user = current_user()
    conn = db.get_conn()
    students = conn.execute("""
        SELECT u.*, GROUP_CONCAT(g.name, ', ') AS groups FROM users u
        LEFT JOIN group_members gm ON gm.user_id=u.id
        LEFT JOIN groups g ON g.id=gm.group_id
        WHERE u.org_id=? AND u.role='student' GROUP BY u.id ORDER BY u.username""",
        (user["org_id"],)).fetchall()
    teachers = conn.execute("""SELECT * FROM users WHERE org_id=? AND role IN ('teacher', 'admin')
                                ORDER BY role, username""", (user["org_id"],)).fetchall()
    groups = conn.execute("SELECT * FROM groups WHERE org_id=? ORDER BY name", (user["org_id"],)).fetchall()
    conn.close()
    return render_template("admin_users.html", students=students, teachers=teachers, groups=groups)


@app.route("/admin/user/new", methods=["POST"])
@role_required("admin", "teacher")
def admin_user_new():
    user = current_user()
    username = request.form.get("username", "").strip()
    password = request.form.get("password", "")
    full_name = request.form.get("full_name", "").strip()
    role = request.form.get("role", "student")
    group_id = request.form.get("group_id", type=int)
    if user["role"] != "admin" and role in ("admin", "teacher"): abort(403)
    if len(username) < 3 or len(password) < 4:
        flash("Min 3/4 simvolov", "error"); return redirect(url_for("admin_students"))
    conn = db.get_conn()
    try:
        cur = conn.execute("""INSERT INTO users (org_id, username, password_hash, role, full_name, lang)
                               VALUES (?, ?, ?, ?, ?, 'ru')""",
                          (user["org_id"], username, generate_password_hash(password), role, full_name))
        if group_id and role == "student":
            conn.execute("INSERT OR IGNORE INTO group_members (group_id, user_id) VALUES (?, ?)",
                         (group_id, cur.lastrowid))
        conn.commit()
        # Avto-zhurnal: poluchaem imya organizatsii
        org_name = ""
        if user["org_id"]:
            org = conn.execute("SELECT name FROM organizations WHERE id=?", (user["org_id"],)).fetchone()
            org_name = org["name"] if org else ""
        try:
            log_registration(username, role, "corporate",
                             org_name=org_name, source=f"by_{user['role']}_{user['username']}")
        except Exception as log_err:
            print(f"[!] Admin reg log oshibka: {log_err}")
        flash(f"Sozdan: {username}", "success")
    except Exception as e: flash(f"Error: {e}", "error")
    finally: conn.close()
    return redirect(url_for("admin_students"))


@app.route("/admin/user/<int:user_id>/delete", methods=["POST"])
@role_required("admin")
def admin_user_delete(user_id):
    user = current_user()
    conn = db.get_conn()
    target = conn.execute("SELECT * FROM users WHERE id=? AND org_id=?",
                          (user_id, user["org_id"])).fetchone()
    if not target: conn.close(); abort(404)
    if target["id"] == user["id"]:
        conn.close(); flash("Ne udalit' sebya", "error"); return redirect(url_for("admin_students"))
    conn.execute("DELETE FROM users WHERE id=?", (user_id,))
    conn.commit(); conn.close(); return redirect(url_for("admin_students"))


@app.route("/admin/user/<int:user_id>/reset-password", methods=["POST"])
@role_required("admin", "teacher")
def admin_user_reset_password(user_id):
    """Sbros parolya: admin/uchitel' ustanavlivayet novyy parol' polzovatelyu.
    Pokazyvaet noviy parol' v flash 1 raz."""
    user = current_user()
    new_password = request.form.get("new_password", "").strip()
    conn = db.get_conn()
    target = conn.execute("SELECT * FROM users WHERE id=? AND org_id=?",
                          (user_id, user["org_id"])).fetchone()
    if not target:
        conn.close(); abort(404)
    # Uchitel' ne mozhet menyat' parol' adminu
    if user["role"] == "teacher" and target["role"] in ("admin", "teacher"):
        conn.close()
        flash("Учитель не может менять пароль администратора или другого учителя", "error")
        return redirect(url_for("admin_students"))
    # Esli novyy parol' ne zadan — generiruem
    if not new_password:
        import secrets, string
        alphabet = string.ascii_letters + string.digits
        new_password = "".join(secrets.choice(alphabet) for _ in range(8))
    if len(new_password) < 4:
        conn.close()
        flash("Пароль должен быть минимум 4 символа", "error")
        return redirect(url_for("admin_students"))
    conn.execute("UPDATE users SET password_hash=? WHERE id=?",
                 (generate_password_hash(new_password), user_id))
    conn.commit(); conn.close()
    # Flash s pomoshchyu specialnoy katеgorii — render v shablone otdel'no
    flash(f"🔑 Новый пароль для @{target['username']}: {new_password} — сохраните и передайте пользователю!", "password_reset")
    return redirect(url_for("admin_students"))


@app.route("/admin/group/new", methods=["POST"])
@role_required("admin", "teacher")
def admin_group_new():
    user = current_user()
    name = request.form.get("name", "").strip()
    if not name: return redirect(url_for("admin_students"))
    conn = db.get_conn()
    conn.execute("INSERT INTO groups (org_id, name) VALUES (?, ?)", (user["org_id"], name))
    conn.commit(); conn.close(); return redirect(url_for("admin_students"))


@app.route("/admin/group/<int:group_id>/delete", methods=["POST"])
@role_required("admin", "teacher")
def admin_group_delete(group_id):
    user = current_user()
    conn = db.get_conn()
    g = conn.execute("SELECT * FROM groups WHERE id=? AND org_id=?",
                     (group_id, user["org_id"])).fetchone()
    if not g: conn.close(); abort(404)
    conn.execute("DELETE FROM groups WHERE id=?", (group_id,))
    conn.commit(); conn.close(); return redirect(url_for("admin_students"))


# ---------------------- categories ------------------------------------------

@app.route("/categories")
@login_required
def categories_list():
    user = current_user()
    conn = db.get_conn()
    if user["org_id"]:
        cats_raw = conn.execute("""
            SELECT c.*,
                (SELECT COUNT(*) FROM decks WHERE category_id=c.id) AS deck_count,
                COALESCE((SELECT SUM(cnt) FROM (
                    SELECT (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt
                    FROM decks d WHERE d.category_id=c.id OR d.category_id IN (
                        SELECT id FROM categories WHERE parent_id=c.id
                    )
                )), 0) AS card_count
            FROM categories c WHERE c.org_id=? ORDER BY c.parent_id IS NULL DESC, c.name
        """, (user["org_id"],)).fetchall()
    else:
        cats_raw = conn.execute("""
            SELECT c.*,
                (SELECT COUNT(*) FROM decks WHERE category_id=c.id) AS deck_count,
                COALESCE((SELECT SUM(cnt) FROM (
                    SELECT (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt
                    FROM decks d WHERE d.category_id=c.id OR d.category_id IN (
                        SELECT id FROM categories WHERE parent_id=c.id
                    )
                )), 0) AS card_count
            FROM categories c WHERE c.owner_id=? ORDER BY c.parent_id IS NULL DESC, c.name
        """, (user["id"],)).fetchall()
    conn.close()

    # Stroyim derevo: roditeli i ikh deti
    all_cats = [dict(c) for c in cats_raw]
    roots = [c for c in all_cats if not c.get("parent_id")]
    children_by_parent = {}
    for c in all_cats:
        if c.get("parent_id"):
            children_by_parent.setdefault(c["parent_id"], []).append(c)
    for r in roots:
        r["children"] = children_by_parent.get(r["id"], [])

    return render_template("categories.html",
        roots=roots,
        all_cats=all_cats,
        # Dlya formy "novaya podkategoriya" — nuzhny tol'ko korni
        parent_options=[c for c in all_cats if not c.get("parent_id")])


@app.route("/category/new", methods=["POST"])
@login_required
def category_new():
    user = current_user()
    if not can_manage_content(user): abort(403)
    name = request.form.get("name", "").strip()
    icon = request.form.get("icon", "").strip()[:2] or "📁"
    parent_id = request.form.get("parent_id", type=int) or None
    if not name: return redirect(url_for("categories_list"))
    conn = db.get_conn()
    # Proveryaem chto parent prinadlezhit pol'zovatelyu
    if parent_id:
        parent = conn.execute("SELECT * FROM categories WHERE id=?", (parent_id,)).fetchone()
        if not parent or (parent["org_id"] != user["org_id"] and parent["owner_id"] != user["id"]):
            parent_id = None
    if user["org_id"]:
        conn.execute("INSERT INTO categories (org_id, parent_id, name, icon) VALUES (?, ?, ?, ?)",
                     (user["org_id"], parent_id, name, icon))
    else:
        conn.execute("INSERT INTO categories (owner_id, parent_id, name, icon) VALUES (?, ?, ?, ?)",
                     (user["id"], parent_id, name, icon))
    conn.commit(); conn.close()
    return redirect(url_for("categories_list"))


@app.route("/category/<int:cat_id>/delete", methods=["POST"])
@login_required
def category_delete(cat_id):
    user = current_user()
    if not can_manage_content(user): abort(403)
    conn = db.get_conn()
    cat = conn.execute("SELECT * FROM categories WHERE id=?", (cat_id,)).fetchone()
    if not cat: conn.close(); abort(404)
    if cat["org_id"] != user["org_id"] and cat["owner_id"] != user["id"]:
        conn.close(); abort(403)
    conn.execute("DELETE FROM categories WHERE id=?", (cat_id,))
    conn.commit(); conn.close()
    return redirect(url_for("categories_list"))


# ---------------------- decks/cards -----------------------------------------

@app.route("/deck/new", methods=["POST"])
@login_required
def deck_new():
    user = current_user()
    if not can_manage_content(user): abort(403)
    name = request.form.get("name", "").strip() or "Без названия"
    icon = request.form.get("icon", "").strip()[:2] or "📚"
    category_id = request.form.get("category_id", type=int)
    # Tour-flag: prokidyvayem dal'she chtoby tour mog prodolzhitsya na deck-stranitse
    tour_flag = (request.form.get("tour") or "").strip()
    conn = db.get_conn()
    if user["org_id"]:
        cur = conn.execute("INSERT INTO decks (org_id, category_id, name, icon) VALUES (?, ?, ?, ?)",
                          (user["org_id"], category_id, name, icon))
    else:
        cur = conn.execute("INSERT INTO decks (owner_id, category_id, name, icon) VALUES (?, ?, ?, ?)",
                          (user["id"], category_id, name, icon))
    deck_id = cur.lastrowid
    conn.commit(); conn.close()
    target = url_for("deck_view", deck_id=deck_id)
    if tour_flag == "basic":
        target += "?tour=basic-deck"
    return redirect(target)


@app.route("/deck/<int:deck_id>")
@login_required
def deck_view(deck_id):
    user = current_user()
    conn = db.get_conn()
    deck = conn.execute("""SELECT d.*, c.name AS category_name FROM decks d
                            LEFT JOIN categories c ON c.id=d.category_id WHERE d.id=?""",
                        (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)
    deck = _localize_deck_fields(dict(deck), session.get("lang", "ru"))
    cards_raw = conn.execute("""SELECT c.*, p.ef, p.interval_days, p.reviews, p.lapses,
        p.due_at, p.stability, p.last_reviewed
        FROM cards c LEFT JOIN user_card_progress p ON p.card_id=c.id AND p.user_id=?
        WHERE c.deck_id=? ORDER BY c.id DESC""", (user["id"], deck_id)).fetchall()
    cards = [dict(c) for c in cards_raw]
    # Localize: if user is en/uz and translation exists, swap
    _user_lang = session.get("lang", "ru")
    if _user_lang in ("en", "uz"):
        for c in cards:
            for fld in ("front", "back", "note"):
                tr = c.get(f"{fld}_{_user_lang}", "")
                if tr:
                    c[fld] = tr
    # Regex dlya parsa MCQ-vidov: "A) text" / "А) текст" / "A. text"
    _opt_re = re.compile(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]?\s+(.+)$")
    for c in cards:
        c["level"] = sm2.card_level(c)
        c["difficulty"] = sm2.card_difficulty(c)
        # === Pre-parse MCQ options on server ===
        # Cards may store options in any of: front (seeded MCQ decks),
        # note (older AI-generated decks), or back (legacy imports).
        opts = []
        # Try fields in priority order: front -> note -> back
        # If front contains MCQ options, also clean up the question text
        for src_field in ("front", "note", "back"):
            text = (c.get(src_field) or "").strip()
            if not text:
                continue
            candidate_opts = []
            for line in text.split("\n"):
                m = _opt_re.match(line.strip())
                if m:
                    candidate_opts.append({"letter": m.group(1).upper(), "text": m.group(2).strip()})
            # Need at least 2 different letters
            if len({o["letter"] for o in candidate_opts}) >= 2:
                opts = candidate_opts
                # If options are in front, strip them out for display:
                # take only the part before the first option
                if src_field == "front":
                    parts = []
                    for line in text.split("\n"):
                        if _opt_re.match(line.strip()):
                            break  # stop at first option
                        parts.append(line)
                    cleaned_q = "\n".join(parts).strip()
                    if cleaned_q:
                        c["front_clean"] = cleaned_q
                break
        c["options"] = opts
        # Determine which letter is correct (first letter of "back")
        c["correct_letter"] = None
        if c.get("back") and opts:
            m = _opt_re.match(c["back"].strip().split("\n")[0].strip())
            if m:
                letter = m.group(1).upper()
                if any(o["letter"] == letter for o in opts):
                    c["correct_letter"] = letter
    if user["org_id"]:
        cats = conn.execute("SELECT * FROM categories WHERE org_id=?", (user["org_id"],)).fetchall()
    else:
        cats = conn.execute("SELECT * FROM categories WHERE owner_id=?", (user["id"],)).fetchall()
    # Marketplace reviews/ratings (own review floated to the top).
    rating = _decks_ratings(conn, [deck_id]).get(deck_id, {"avg": 0, "count": 0})
    reviews = [dict(r) for r in conn.execute("""
        SELECT r.id, r.stars, r.text, r.created_at, r.user_id,
               COALESCE(NULLIF(u.full_name,''), u.username) AS author
        FROM deck_reviews r JOIN users u ON u.id=r.user_id
        WHERE r.deck_id=? AND r.is_hidden=0
        ORDER BY (r.user_id=?) DESC, r.updated_at DESC LIMIT 50
    """, (deck_id, user["id"])).fetchall()]
    my_review = next((rv for rv in reviews if rv["user_id"] == user["id"]), None)
    conn.close()
    # Schitaem skol'ko v kolodе MCQ-kart i terms-kart na osnove faktov,
    # chtoby shablon mog pokazat' obe knopki esli oba tipa est'.
    mcq_count = sum(1 for c in cards if len(c.get("options") or []) >= 2)
    terms_count = len(cards) - mcq_count
    # FSRS memory snapshot for the deck (makes forgetting visible).
    retention = fsrs.deck_retention(cards)
    return render_template("deck.html", deck=deck, cards=cards, categories=cats,
                            can_edit=can_manage_content(user),
                            rating=rating, reviews=reviews, my_review=my_review,
                            mcq_count=mcq_count, terms_count=terms_count,
                            retention=retention)


@app.route("/deck/<int:deck_id>/edit", methods=["POST"])
@login_required
def deck_edit(deck_id):
    user = current_user()
    if not can_manage_content(user): abort(403)
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)
    name = request.form.get("name", "").strip()
    icon = request.form.get("icon", "").strip()[:2]
    category_id = request.form.get("category_id", type=int)
    if name: conn.execute("UPDATE decks SET name=? WHERE id=?", (name, deck_id))
    if icon: conn.execute("UPDATE decks SET icon=? WHERE id=?", (icon, deck_id))
    if "category_id" in request.form:
        conn.execute("UPDATE decks SET category_id=? WHERE id=?", (category_id or None, deck_id))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/deck/<int:deck_id>/delete", methods=["POST"])
@login_required
def deck_delete(deck_id):
    user = current_user()
    if not can_manage_content(user): abort(403)
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)
    conn.execute("DELETE FROM decks WHERE id=?", (deck_id,))
    conn.commit(); conn.close()
    return redirect(url_for("dashboard"))


@app.route("/deck/<int:deck_id>/clone", methods=["POST"])
@login_required
def deck_clone(deck_id):
    """Klonirovaniye kolody — sozdayet kopiyu so vsemi kartami."""
    user = current_user()
    if not can_manage_content(user): abort(403)
    conn = db.get_conn()
    src = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not src or not can_view_deck(user, dict(src)):
        conn.close(); abort(404)

    new_name = (request.form.get("new_name") or "").strip() or f"{src['name']} (копия)"

    if user["org_id"]:
        cur = conn.execute("""INSERT INTO decks (org_id, category_id, name, icon, description)
                              VALUES (?, ?, ?, ?, ?)""",
                          (user["org_id"], src["category_id"], new_name, src["icon"], src["description"]))
    else:
        cur = conn.execute("""INSERT INTO decks (owner_id, category_id, name, icon, description)
                              VALUES (?, ?, ?, ?, ?)""",
                          (user["id"], src["category_id"], new_name, src["icon"], src["description"]))
    new_deck_id = cur.lastrowid

    # Kopiruem karty (bez progressа — eto novaya kolod dlya samostoyatelnogo izucheniya)
    cards = conn.execute("SELECT front, back, note, image_url FROM cards WHERE deck_id=?",
                         (deck_id,)).fetchall()
    for c in cards:
        conn.execute("""INSERT INTO cards (deck_id, front, back, note, image_url)
                       VALUES (?, ?, ?, ?, ?)""",
                     (new_deck_id, c["front"], c["back"], c["note"], c["image_url"] or ""))
    conn.commit(); conn.close()
    flash(f"Колода скопирована: {new_name}", "success")
    return redirect(url_for("deck_view", deck_id=new_deck_id))


@app.route("/deck/<int:deck_id>/card/new", methods=["POST"])
@login_required
def card_new(deck_id):
    user = current_user()
    if not can_manage_content(user): abort(403)
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(403)
    front = request.form.get("front", "").strip() or "Вопрос..."
    back = request.form.get("back", "").strip() or "Ответ..."
    note = request.form.get("note", "").strip()
    cur = conn.execute("INSERT INTO cards (deck_id, front, back, note) VALUES (?, ?, ?, ?)",
                       (deck_id, front, back, note))
    cid = cur.lastrowid
    refresh_deck_content_flags(conn, deck_id)
    conn.commit(); conn.close()
    return jsonify({"ok": True, "id": cid})


@app.route("/card/<int:card_id>/edit", methods=["POST"])
@login_required
def card_edit(card_id):
    user = current_user()
    if not can_manage_content(user): abort(403)
    conn = db.get_conn()
    row = conn.execute("""SELECT c.*, d.org_id, d.owner_id FROM cards c
                          JOIN decks d ON d.id=c.deck_id WHERE c.id=?""", (card_id,)).fetchone()
    if not row: conn.close(); abort(404)
    if not can_view_deck(user, {"org_id": row["org_id"], "owner_id": row["owner_id"]}):
        conn.close(); abort(403)
    front = request.form.get("front", "").strip()
    back = request.form.get("back", "").strip()
    note = request.form.get("note", "").strip()
    image_url = request.form.get("image_url", None)
    if image_url is not None:
        # Eksplitsitno menyaem image_url (mozhno postavit' pustoy chtoby ubrat' kartinku)
        conn.execute("UPDATE cards SET front=?, back=?, note=?, image_url=? WHERE id=?",
                     (front or row["front"], back or row["back"], note, image_url.strip(), card_id))
    else:
        conn.execute("UPDATE cards SET front=?, back=?, note=? WHERE id=?",
                     (front or row["front"], back or row["back"], note, card_id))
    conn.commit(); conn.close(); return jsonify({"ok": True})


@app.route("/card/<int:card_id>/upload-image", methods=["POST"])
@login_required
def card_upload_image(card_id):
    """Zagruzka kartinki k karte. Sokhranyaet v static/card_images."""
    user = current_user()
    if not can_manage_content(user):
        return jsonify({"error": "forbidden"}), 403
    file = request.files.get("image")
    if not file or not file.filename:
        return jsonify({"error": "no_file"}), 400
    # Validatsiya tipa
    ext = Path(file.filename).suffix.lower()
    if ext not in (".jpg", ".jpeg", ".png", ".gif", ".webp"):
        return jsonify({"error": "bad_type"}), 400
    # Raver fayla
    file.seek(0, 2)
    size = file.tell()
    file.seek(0)
    if size > 5 * 1024 * 1024:
        return jsonify({"error": "too_large"}), 400

    conn = db.get_conn()
    row = conn.execute("""SELECT c.*, d.org_id, d.owner_id FROM cards c
                          JOIN decks d ON d.id=c.deck_id WHERE c.id=?""", (card_id,)).fetchone()
    if not row or not can_view_deck(user, {"org_id": row["org_id"], "owner_id": row["owner_id"]}):
        conn.close()
        return jsonify({"error": "forbidden"}), 403

    # Sokhranyaem
    img_dir = BASE / "static" / "card_images"
    img_dir.mkdir(parents=True, exist_ok=True)
    safe_name = f"card_{card_id}_{secrets.token_hex(6)}{ext}"
    img_path = img_dir / safe_name
    file.save(str(img_path))

    rel_url = f"/static/card_images/{safe_name}"
    conn.execute("UPDATE cards SET image_url=? WHERE id=?", (rel_url, card_id))
    conn.commit(); conn.close()
    return jsonify({"ok": True, "url": rel_url})


@app.route("/card/<int:card_id>/delete", methods=["POST"])
@login_required
def card_delete(card_id):
    user = current_user()
    if not can_manage_content(user): abort(403)
    conn = db.get_conn()
    row = conn.execute("""SELECT c.*, d.org_id, d.owner_id FROM cards c
                          JOIN decks d ON d.id=c.deck_id WHERE c.id=?""", (card_id,)).fetchone()
    if not row or not can_view_deck(user, {"org_id": row["org_id"], "owner_id": row["owner_id"]}):
        conn.close(); abort(403)
    deck_id_for_refresh = row["deck_id"]
    conn.execute("DELETE FROM cards WHERE id=?", (card_id,))
    refresh_deck_content_flags(conn, deck_id_for_refresh)
    conn.commit(); conn.close(); return jsonify({"ok": True})


# ---------------------- FLASHCARDS (Quizlet-style flip cards) ----------------

@app.route("/deck/<int:deck_id>/flashcards")
@login_required
def flashcards_view(deck_id):
    """Premium flip-card studi rezhim. Bez SM-2 — prosto listanie + flip."""
    user = current_user()
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)

    # Razreshaem flashcards esli est' hot' odna ne-MCQ karta v kolode.
    # Ranshe blokirovali mcq-koldy, no teper' v odnoy kolodе mogut byt' karty oboikh tipov.
    # Proveryaem note I back (starye kolody hranili varianty v back).
    cards_check = conn.execute("SELECT note, back FROM cards WHERE deck_id=?", (deck_id,)).fetchall()
    has_terms = any(
        not _card_is_mcq(c)
        for c in cards_check
    ) if cards_check else False
    deck_type = (deck["deck_type"] if "deck_type" in deck.keys() else "mcq") or "mcq"
    # Esli net ni odnoy terms-karty i deck_type=mcq i ne force — perenapravlyaem
    if not has_terms and deck_type == "mcq" and not request.args.get("force"):
        conn.close()
        flash("В этой колоде нет словарных карт. Используйте режим Тест.", "info")
        return redirect(url_for("deck_view", deck_id=deck_id))

    # Filtry: only_favorites, only_difficult, only_fading (FSRS — ostyvayushchie)
    only_fav = request.args.get("only_fav", "0") == "1"
    only_hard = request.args.get("only_hard", "0") == "1"
    only_fading = request.args.get("only_fading", "0") == "1"

    where = "c.deck_id=?"
    params = [deck_id]
    join = "LEFT JOIN user_card_progress p ON p.card_id=c.id AND p.user_id=?"
    join_params = [user["id"]]
    if only_fav:
        where += " AND p.is_favorite=1"
    if only_hard:
        where += " AND p.is_difficult=1"

    cards = conn.execute(
        f"""SELECT c.id, c.front, c.back, c.note, c.image_url,
                c.front_en, c.front_uz, c.back_en, c.back_uz, c.note_en, c.note_uz,
                COALESCE(p.is_favorite, 0) AS is_favorite,
                COALESCE(p.is_difficult, 0) AS is_difficult,
                COALESCE(p.reviews, 0) AS reviews,
                p.stability, p.last_reviewed, p.interval_days, p.ef
            FROM cards c {join}
            WHERE {where}
            ORDER BY c.id""",
        join_params + params
    ).fetchall()
    conn.close()

    # Localize: if user lang is en/uz and translation exists, swap into front/back/note
    lang = session.get("lang", "ru")
    cards_list = [_localize_card_fields(dict(c), lang) for c in cards]

    if only_fading:
        # Tol'ko ostyvayushchie izuchennye karty, snachala samye zabytye (nizkiy R).
        scored = []
        for c in cards_list:
            if (c.get("reviews") or 0) <= 0:
                continue
            r = fsrs.card_retrievability(c)
            if r < fsrs.TARGET_RETENTION:
                scored.append((r, c))
        scored.sort(key=lambda x: x[0])
        cards_list = [c for _, c in scored]
        if not cards_list:
            flash("Нет остывающих карт — память свежа! 🧠", "info")
            return redirect(url_for("deck_view", deck_id=deck_id))

    return render_template("flashcards.html",
        deck=_localize_deck_fields(dict(deck), lang),
        cards=cards_list,
        only_fav=only_fav,
        only_hard=only_hard,
        only_fading=only_fading)


@app.route("/api/card/<int:card_id>/favorite", methods=["POST"])
@login_required
def api_card_favorite(card_id):
    """Tumbler izbrannogo dlya karty."""
    user = current_user()
    conn = db.get_conn()
    # Ubedimsya chto progress-row sushchestvuyet
    conn.execute("""INSERT OR IGNORE INTO user_card_progress (user_id, card_id, ef, interval_days, reviews, lapses)
                    VALUES (?, ?, 2.5, 0, 0, 0)""", (user["id"], card_id))
    row = conn.execute("SELECT is_favorite FROM user_card_progress WHERE user_id=? AND card_id=?",
                       (user["id"], card_id)).fetchone()
    new_val = 0 if (row and row["is_favorite"]) else 1
    conn.execute("UPDATE user_card_progress SET is_favorite=? WHERE user_id=? AND card_id=?",
                 (new_val, user["id"], card_id))
    conn.commit(); conn.close()
    return jsonify({"ok": True, "is_favorite": bool(new_val)})


@app.route("/api/card/<int:card_id>/difficult", methods=["POST"])
@login_required
def api_card_difficult(card_id):
    """Tumbler 'trudnaya karta'."""
    user = current_user()
    conn = db.get_conn()
    conn.execute("""INSERT OR IGNORE INTO user_card_progress (user_id, card_id, ef, interval_days, reviews, lapses)
                    VALUES (?, ?, 2.5, 0, 0, 0)""", (user["id"], card_id))
    row = conn.execute("SELECT is_difficult FROM user_card_progress WHERE user_id=? AND card_id=?",
                       (user["id"], card_id)).fetchone()
    new_val = 0 if (row and row["is_difficult"]) else 1
    conn.execute("UPDATE user_card_progress SET is_difficult=? WHERE user_id=? AND card_id=?",
                 (new_val, user["id"], card_id))
    conn.commit(); conn.close()
    return jsonify({"ok": True, "is_difficult": bool(new_val)})


@app.route("/api/card/<int:card_id>/grade", methods=["POST"])
@login_required
def api_card_grade(card_id):
    """SM-2 ocenka karty iz flashcards (Slozhno=3, Khorosho=4, Legko=5)."""
    user = current_user()
    try:
        grade = int(request.form.get("grade", 4))
    except Exception:
        grade = 4
    if grade not in (3, 4, 5):
        grade = 4
    conn = db.get_conn()
    p = conn.execute("SELECT * FROM user_card_progress WHERE user_id=? AND card_id=?",
                     (user["id"], card_id)).fetchone()
    cur_state = dict(p) if p else {"ef": 2.5, "interval_days": 0, "reviews": 0, "lapses": 0}
    new_state = fsrs.calc_fsrs(cur_state, grade)
    conn.execute("""INSERT OR REPLACE INTO user_card_progress
        (user_id, card_id, ef, interval_days, reviews, lapses, due_at, last_grade, last_reviewed,
         is_favorite, is_difficult)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?,
                COALESCE((SELECT is_favorite FROM user_card_progress WHERE user_id=? AND card_id=?), 0),
                COALESCE((SELECT is_difficult FROM user_card_progress WHERE user_id=? AND card_id=?), 0))""",
        (user["id"], card_id, new_state["ef"], new_state["interval_days"],
         new_state["reviews"], new_state["lapses"], new_state["due_at"],
         grade, datetime.utcnow().isoformat(),
         user["id"], card_id, user["id"], card_id))
    conn.execute("UPDATE user_card_progress SET stability=?, difficulty=? WHERE user_id=? AND card_id=?",
                 (new_state["stability"], new_state["difficulty"], user["id"], card_id))
    conn.execute("INSERT INTO reviews (user_id, card_id, grade) VALUES (?, ?, ?)",
                 (user["id"], card_id, grade))
    xp_gain = 5 if grade == 5 else 3 if grade == 4 else 1
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
    new_unlocks = ach_mod.check_and_award(conn, user["id"])
    today_count = conn.execute(
        "SELECT COUNT(*) AS c FROM reviews WHERE user_id=? AND DATE(reviewed_at) = DATE('now')",
        (user["id"],)
    ).fetchone()["c"] or 0
    daily_goal = (user["daily_goal"] if "daily_goal" in user.keys() else 20) or 20
    if today_count >= daily_goal:
        new_unlocks += ach_mod.award_goal_done(conn, user["id"])
    # Proveryaem dnevnyye normy obuchayushchih celey
    goal_daily_done = _check_goals_daily_completion(conn, user["id"])
    conn.commit(); conn.close()
    if new_unlocks:
        existing = session.get("new_achievements", [])
        existing.extend([a["key"] for a in new_unlocks])
        session["new_achievements"] = list(set(existing))
    return jsonify({
        "ok": True,
        "xp_gain": xp_gain,
        "new_xp": new_xp,
        "streak": streak,
        "achievements": [{"icon": a["icon"], "name": a["name"], "desc": a["desc"], "xp": a["xp"]}
                         for a in new_unlocks],
        "goal_daily_done": goal_daily_done,
    })


@app.route("/api/flashcards/complete", methods=["POST"])
@login_required
def api_flashcards_complete():
    """Otmechaem chto polzovatel' proshyol vse flashcards. Daet XP."""
    user = current_user()
    seen = int(request.form.get("seen", 0) or 0)
    conn = db.get_conn()
    # +1 XP za karty (no ne bolshe 30 za sessiyu)
    bonus = min(30, seen)
    if bonus > 0:
        conn.execute("UPDATE users SET xp = xp + ?, last_study=? WHERE id=?",
                     (bonus, datetime.utcnow().isoformat(), user["id"]))
    new_unlocks = ach_mod.check_and_award(conn, user["id"])
    conn.commit(); conn.close()
    if new_unlocks:
        existing = session.get("new_achievements", [])
        existing.extend([a["key"] for a in new_unlocks])
        session["new_achievements"] = list(set(existing))
    return jsonify({"ok": True, "xp_bonus": bonus,
                    "achievements": [{"icon": a["icon"], "name": a["name"], "desc": a["desc"], "xp": a["xp"]}
                                     for a in new_unlocks]})


@app.route("/category/<int:category_id>/flashcards")
@login_required
def category_flashcards(category_id):
    """Flashcards po kategorii — obyedinyaet karty so vseh kolod."""
    user = current_user()
    only_fav = request.args.get("only_fav", "0") == "1"
    only_hard = request.args.get("only_hard", "0") == "1"
    conn = db.get_conn()
    cat = conn.execute("SELECT * FROM categories WHERE id=?", (category_id,)).fetchone()
    if not cat:
        conn.close(); abort(404)
    if cat["org_id"] and cat["org_id"] != user["org_id"]:
        conn.close(); abort(403)
    if cat["owner_id"] and cat["owner_id"] != user["id"] and not cat["org_id"]:
        conn.close(); abort(403)

    card_ids, decks = _category_card_pool(conn, user, category_id)
    if not card_ids:
        conn.close()
        flash(f"В категории «{cat['name']}» нет карт", "error")
        return redirect(url_for("categories_list"))

    placeholders = ",".join("?" * len(card_ids))
    where = f"c.id IN ({placeholders})"
    params = list(card_ids)
    if only_fav:
        where += " AND COALESCE(p.is_favorite, 0) = 1"
    if only_hard:
        where += " AND COALESCE(p.is_difficult, 0) = 1"
    cards = conn.execute(
        f"""SELECT c.id, c.front, c.back, c.note, c.image_url,
                COALESCE(p.is_favorite, 0) AS is_favorite,
                COALESCE(p.is_difficult, 0) AS is_difficult,
                COALESCE(p.reviews, 0) AS reviews
            FROM cards c
            LEFT JOIN user_card_progress p ON p.card_id=c.id AND p.user_id=?
            WHERE {where}
            ORDER BY c.id""",
        [user["id"]] + params
    ).fetchall()
    conn.close()

    # Virtualnyy deck dlya shablona
    virtual_deck = {
        "id": decks[0]["id"] if decks else 0,
        "name": cat["name"],
        "icon": cat["icon"] or "📁",
    }
    cards_list = [dict(c) for c in cards]
    return render_template("flashcards.html",
        deck=virtual_deck,
        cards=cards_list,
        only_fav=only_fav,
        only_hard=only_hard,
        category_id=category_id)


# ---------------------- study -----------------------------------------------

@app.route("/deck/<int:deck_id>/study")
@login_required
def study_start(deck_id):
    """Redirect na novyy flashcards rezhim."""
    return redirect(url_for("flashcards_view", deck_id=deck_id))


@app.route("/study")
@login_required
def study_view():
    queue = session.get("study_queue", [])
    idx = session.get("study_idx", 0)
    deck_id = session.get("study_deck")
    if not queue or idx >= len(queue):
        return render_template("study_done.html",
            stats=session.get("study_stats", {"good":0, "again":0}),
            total=len(queue), deck_id=deck_id)
    conn = db.get_conn()
    card = conn.execute("SELECT * FROM cards WHERE id=?", (queue[idx],)).fetchone()
    conn.close()
    if not card:
        session["study_idx"] = idx + 1
        return redirect(url_for("study_view"))
    return render_template("study.html", card=dict(card), idx=idx, total=len(queue),
        stats=session.get("study_stats", {"good":0, "again":0}), deck_id=deck_id)


@app.route("/study/grade", methods=["POST"])
@login_required
def study_grade():
    user = current_user()
    grade = int(request.form.get("grade", 3))
    queue = session.get("study_queue", [])
    idx = session.get("study_idx", 0)
    if idx >= len(queue): return redirect(url_for("study_view"))
    card_id = queue[idx]
    conn = db.get_conn()
    p = conn.execute("SELECT * FROM user_card_progress WHERE user_id=? AND card_id=?",
                     (user["id"], card_id)).fetchone()
    cur_state = dict(p) if p else {"ef": 2.5, "interval_days": 0, "reviews": 0, "lapses": 0}
    new_state = fsrs.calc_fsrs(cur_state, grade)
    conn.execute("""INSERT OR REPLACE INTO user_card_progress
        (user_id, card_id, ef, interval_days, reviews, lapses, due_at, last_grade, last_reviewed)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        (user["id"], card_id, new_state["ef"], new_state["interval_days"],
         new_state["reviews"], new_state["lapses"], new_state["due_at"],
         grade, datetime.utcnow().isoformat()))
    conn.execute("UPDATE user_card_progress SET stability=?, difficulty=? WHERE user_id=? AND card_id=?",
                 (new_state["stability"], new_state["difficulty"], user["id"], card_id))
    conn.execute("INSERT INTO reviews (user_id, card_id, grade) VALUES (?, ?, ?)",
                 (user["id"], card_id, grade))
    xp_gain = 5 if grade == 5 else 3 if grade == 4 else 1 if grade == 3 else 0
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
    # Achievements
    new_unlocks = ach_mod.check_and_award(conn, user["id"])
    # Goal achievement
    today_count = conn.execute("""
        SELECT COUNT(*) AS c FROM reviews WHERE user_id=? AND DATE(reviewed_at) = DATE('now')
    """, (user["id"],)).fetchone()["c"] or 0
    daily_goal = (user["daily_goal"] if "daily_goal" in user.keys() else 20) or 20
    if today_count >= daily_goal:
        new_unlocks += ach_mod.award_goal_done(conn, user["id"])
    conn.commit(); conn.close()
    if new_unlocks:
        existing = session.get("new_achievements", [])
        existing.extend([a["key"] for a in new_unlocks])
        session["new_achievements"] = list(set(existing))
    stats = session.get("study_stats", {"good": 0, "again": 0})
    if grade >= 3: stats["good"] += 1
    else: stats["again"] += 1; queue.append(card_id); session["study_queue"] = queue
    session["study_stats"] = stats; session["study_idx"] = idx + 1
    return redirect(url_for("study_view"))


# ---------------------- TEST mode (multiple choice) -------------------------

@app.route("/test/history")
@login_required
def test_history():
    """Istoriya vseh testov polzovatelya. Mozhet fil'trovat'sya po scope."""
    user = current_user()
    scope_type = request.args.get("scope_type")  # 'deck' / 'category' / None
    scope_id = request.args.get("scope_id", type=int)

    conn = db.get_conn()
    if scope_type and scope_id:
        attempts = conn.execute("""
            SELECT * FROM test_attempts
            WHERE user_id=? AND scope_type=? AND scope_id=?
            ORDER BY finished_at DESC LIMIT 100
        """, (user["id"], scope_type, scope_id)).fetchall()
    else:
        attempts = conn.execute("""
            SELECT * FROM test_attempts
            WHERE user_id=?
            ORDER BY finished_at DESC LIMIT 100
        """, (user["id"],)).fetchall()

    # Aggregate stats
    summary = {
        "total": len(attempts),
        "perfect": sum(1 for a in attempts if a["is_perfect"]),
        "avg_score": round(sum(a["score_pct"] for a in attempts) / len(attempts), 1) if attempts else 0,
        "best_score": max((a["score_pct"] for a in attempts), default=0),
        "total_time_min": round(sum(a["duration_sec"] or 0 for a in attempts) / 60, 1),
    }
    scope_label = ""
    if scope_type and scope_id and attempts:
        scope_label = attempts[0]["scope_name"] or ""
    conn.close()
    return render_template("test_history.html",
        attempts=[dict(a) for a in attempts],
        summary=summary,
        scope_type=scope_type,
        scope_id=scope_id,
        scope_label=scope_label,
    )


@app.route("/test/history/<int:attempt_id>")
@login_required
def test_attempt_detail(attempt_id):
    """Detalnyy prosmotr odnoy popytki testa: kazhdyy vopros, otvet polzovatelya, pravil'nyy otvet."""
    user = current_user()
    conn = db.get_conn()
    attempt = conn.execute(
        "SELECT * FROM test_attempts WHERE id=? AND user_id=?",
        (attempt_id, user["id"])
    ).fetchone()
    if not attempt:
        conn.close(); abort(404)
    answers = conn.execute(
        "SELECT * FROM test_attempt_answers WHERE attempt_id=? ORDER BY position",
        (attempt_id,)
    ).fetchall()
    conn.close()

    # Parsing variantov MCQ dlya kazhdogo voprosa (kak v deck.html)
    _opt_re = re.compile(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]?\s+(.+)$")
    answers_parsed = []
    for a in answers:
        ad = dict(a)
        source = (ad.get("note") or "").strip() or (ad.get("back") or "")
        opts = []
        for line in source.split("\n"):
            m = _opt_re.match(line.strip())
            if m:
                opts.append({"letter": m.group(1).upper(), "text": m.group(2).strip()})
        if not opts and ad.get("back"):
            for line in ad["back"].split("\n"):
                m = _opt_re.match(line.strip())
                if m:
                    opts.append({"letter": m.group(1).upper(), "text": m.group(2).strip()})
        ad["options"] = opts
        answers_parsed.append(ad)

    return render_template("test_attempt_detail.html",
        attempt=dict(attempt),
        answers=answers_parsed,
    )


@app.route("/deck/<int:deck_id>/test")
@login_required
def test_start(deck_id):
    """Zapuskaem test rezhim — pokazyvaem voprosy s variantami otvetov."""
    user = current_user()
    count = int(request.args.get("count", 0))
    shuffle = request.args.get("shuffle", "0") == "1"
    only_hard = request.args.get("only_hard", "0") == "1"
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)
    cards_raw = conn.execute(
        """SELECT c.*, p.ef, p.interval_days, p.reviews, p.lapses, p.due_at, p.last_grade
        FROM cards c LEFT JOIN user_card_progress p ON p.card_id=c.id AND p.user_id=?
        WHERE c.deck_id=? ORDER BY c.id""", (user["id"], deck_id)
    ).fetchall()
    conn.close()
    if not cards_raw:
        flash("В колоде нет вопросов", "info")
        return redirect(url_for("deck_view", deck_id=deck_id))

    # Fil'tr "Tol'ko trudnye"
    if only_hard:
        cards_filtered = []
        for c in cards_raw:
            cd = dict(c)
            d = sm2.card_difficulty(cd)
            if d["key"] in ("hard", "learning"):
                cards_filtered.append(c)
        if not cards_filtered:
            flash("Нет трудных карт. Сначала пройдите тест.", "info")
            return redirect(url_for("deck_view", deck_id=deck_id))
        cards_raw = cards_filtered

    card_ids = [c["id"] for c in cards_raw]
    if shuffle:
        import random
        random.shuffle(card_ids)
    if count > 0:
        card_ids = card_ids[:count]
    session["test_queue"] = card_ids
    session["test_idx"] = 0
    session["test_deck"] = deck_id
    session["test_stats"] = {"correct": 0, "wrong": 0}
    session["test_answers"] = []  # Spisok {card_id, chosen, correct, is_correct}
    session["test_scope"] = {"type": "deck", "id": deck_id, "name": deck["name"]}
    session["test_started_at"] = datetime.utcnow().isoformat()
    import random as _r
    session["test_seed"] = _r.randint(1, 10**9)
    return redirect(url_for("test_view"))


@app.route("/test")
@login_required
def test_view():
    queue = session.get("test_queue", [])
    idx = session.get("test_idx", 0)
    deck_id = session.get("test_deck")
    lang = session.get("lang", "ru")
    if not queue or idx >= len(queue):
        stats = session.get("test_stats", {"correct": 0, "wrong": 0})
        # Sobiraem dannye dlya review: vopros + otvety + ob'yasnenie
        answers = session.get("test_answers", [])
        review = []
        if answers:
            seed_for_review = session.get("test_seed", 0) or None
            conn = db.get_conn()
            for a in answers:
                card = conn.execute("SELECT * FROM cards WHERE id=?", (a["card_id"],)).fetchone()
                if not card:
                    continue
                cd = _localize_card_fields(dict(card), lang)
                # Razbiraem varianty S TEM ZHE seed — bukvy budut sovpadat'
                opts, corr_letter = _parse_card_options(cd, shuffle_seed=seed_for_review)
                review.append({
                    "card_id": cd["id"],
                    "front": cd["front"],
                    "back": cd["back"],
                    "note": cd.get("note", ""),
                    "options": opts,
                    "chosen": a["chosen"],
                    "correct": corr_letter or a.get("correct"),
                    "is_correct": a["is_correct"],
                })
            conn.close()
        return render_template("test_done.html",
            stats=stats, total=len(queue), deck_id=deck_id, review=review)
    conn = db.get_conn()
    card = conn.execute("SELECT * FROM cards WHERE id=?", (queue[idx],)).fetchone()
    conn.close()
    if not card:
        session["test_idx"] = idx + 1
        return redirect(url_for("test_view"))

    # Razbiraem varianty s peremeshivaniyem (s tem zhe seed-om)
    card_d = _localize_card_fields(dict(card), lang)
    options, correct_letter = _parse_card_options(
        card_d,
        shuffle_seed=session.get("test_seed", 0) or None
    )

    return render_template("test.html",
        card=card_d, options=options, correct_letter=correct_letter,
        idx=idx, total=len(queue),
        stats=session.get("test_stats", {"correct": 0, "wrong": 0}),
        deck_id=deck_id)


@app.route("/test/answer", methods=["POST"])
@login_required
def test_answer():
    user = current_user()
    chosen = request.form.get("chosen", "").strip().upper()
    queue = session.get("test_queue", [])
    idx = session.get("test_idx", 0)
    if idx >= len(queue):
        return redirect(url_for("test_view"))
    card_id = queue[idx]

    # Server-side: recompute pravil'nuyu bukvu s tem zhe shuffle seed-om
    conn0 = db.get_conn()
    card_row = conn0.execute("SELECT * FROM cards WHERE id=?", (card_id,)).fetchone()
    conn0.close()
    correct = ""
    if card_row:
        _opts, correct_letter = _parse_card_options(
            dict(card_row),
            shuffle_seed=session.get("test_seed", 0) or None
        )
        correct = correct_letter or ""

    is_correct = (chosen == correct)
    grade = 4 if is_correct else 1

    # Sokhranyaem progress (kak v study)
    conn = db.get_conn()
    p = conn.execute("SELECT * FROM user_card_progress WHERE user_id=? AND card_id=?",
                     (user["id"], card_id)).fetchone()
    cur_state = dict(p) if p else {"ef": 2.5, "interval_days": 0, "reviews": 0, "lapses": 0}
    new_state = fsrs.calc_fsrs(cur_state, grade)
    conn.execute("""INSERT OR REPLACE INTO user_card_progress
        (user_id, card_id, ef, interval_days, reviews, lapses, due_at, last_grade, last_reviewed)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        (user["id"], card_id, new_state["ef"], new_state["interval_days"],
         new_state["reviews"], new_state["lapses"], new_state["due_at"],
         grade, datetime.utcnow().isoformat()))
    conn.execute("UPDATE user_card_progress SET stability=?, difficulty=? WHERE user_id=? AND card_id=?",
                 (new_state["stability"], new_state["difficulty"], user["id"], card_id))
    conn.execute("INSERT INTO reviews (user_id, card_id, grade) VALUES (?, ?, ?)",
                 (user["id"], card_id, grade))
    if is_correct:
        new_xp = (user["xp"] or 0) + 3
        conn.execute("UPDATE users SET xp=?, last_study=? WHERE id=?",
                     (new_xp, datetime.utcnow().isoformat(), user["id"]))
    conn.commit(); conn.close()

    stats = session.get("test_stats", {"correct": 0, "wrong": 0})
    if is_correct:
        stats["correct"] += 1
    else:
        stats["wrong"] += 1
    session["test_stats"] = stats

    # Sokhranyaem otvet dlya review v kontse
    answers = session.get("test_answers", [])
    answers.append({
        "card_id": card_id,
        "chosen": chosen,
        "correct": correct,
        "is_correct": is_correct,
    })
    session["test_answers"] = answers

    # Achievements check
    conn2 = db.get_conn()
    new_unlocks = ach_mod.check_and_award(conn2, user["id"])
    # Esli eto byl posledniy vopros — schityaem test sygran (i +perfect esli 100%)
    queue_now = session.get("test_queue", [])
    is_last = (idx + 1) >= len(queue_now)
    if is_last:
        is_perfect = (stats["wrong"] == 0 and stats["correct"] > 0)
        from api_v1.tests import TEST_XP_PER_CORRECT, TEST_XP_PERFECT_BONUS
        xp_earned_h = stats["correct"] * TEST_XP_PER_CORRECT + (TEST_XP_PERFECT_BONUS if is_perfect else 0)
        new_unlocks += ach_mod.award_test_completed(conn2, user["id"], perfect=is_perfect)

        # === Zapis' v istoriyu testov ===
        try:
            scope = session.get("test_scope") or {}
            scope_type = scope.get("type") or ("deck" if session.get("test_deck") else "deck")
            scope_id = scope.get("id") or session.get("test_deck") or 0
            scope_name = scope.get("name") or ""
            total_q_h = stats["correct"] + stats["wrong"]
            score_pct_h = (stats["correct"] / total_q_h * 100) if total_q_h else 0
            started_at = session.get("test_started_at") or ""
            duration_sec = 0
            if started_at:
                try:
                    started_dt = datetime.fromisoformat(started_at.replace("Z", ""))
                    duration_sec = max(0, int((datetime.utcnow() - started_dt).total_seconds()))
                except Exception:
                    duration_sec = 0
            conn2.execute("""
                INSERT INTO test_attempts
                (user_id, scope_type, scope_id, scope_name, total_q, correct, wrong, score_pct, duration_sec, is_perfect, xp_earned, started_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                user["id"], scope_type, scope_id, scope_name,
                total_q_h, stats["correct"], stats["wrong"],
                round(score_pct_h, 2), duration_sec,
                1 if is_perfect else 0, xp_earned_h,
                started_at,
            ))
            attempt_id = conn2.execute("SELECT last_insert_rowid() AS id").fetchone()["id"]

            # === Sokhranyaem detali kazhdogo otveta dlya prosmotra istorii ===
            session_answers = session.get("test_answers", [])
            if session_answers and attempt_id:
                # Beryom snapshot kart na moment testa
                card_ids_in_test = [a["card_id"] for a in session_answers]
                if card_ids_in_test:
                    placeholders = ",".join(["?"] * len(card_ids_in_test))
                    cards_rows = conn2.execute(
                        f"SELECT id, front, back, COALESCE(note,'') AS note FROM cards WHERE id IN ({placeholders})",
                        card_ids_in_test
                    ).fetchall()
                    cards_map = {c["id"]: dict(c) for c in cards_rows}

                    for pos, ans in enumerate(session_answers, 1):
                        card = cards_map.get(ans["card_id"], {})
                        ans_is_correct = 1 if ans.get("is_correct") else 0
                        from api_v1.tests import TEST_XP_PER_CORRECT
                        ans_xp = TEST_XP_PER_CORRECT if ans_is_correct else 0
                        conn2.execute("""
                            INSERT INTO test_attempt_answers
                            (attempt_id, position, card_id, front, back, note, chosen, correct, is_correct, xp_earned)
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """, (
                            attempt_id, pos, ans["card_id"],
                            card.get("front", "[karta udalena]"),
                            card.get("back", ""),
                            card.get("note", ""),
                            ans.get("chosen", ""),
                            ans.get("correct", ""),
                            ans_is_correct,
                            ans_xp,
                        ))
        except Exception as e:
            print(f"[test_history] failed: {e}")

        # === Esli eto byl ekzamen tseli — proveryaem rezul'tat ===
        exam_goal_id = session.pop("test_exam_goal_id", None)
        if exam_goal_id:
            total_q = stats["correct"] + stats["wrong"]
            score_pct = (stats["correct"] / total_q * 100) if total_q else 0
            passed = score_pct >= 60
            g = conn2.execute("SELECT * FROM learning_goals WHERE id=? AND user_id=?",
                              (exam_goal_id, user["id"])).fetchone()
            if g:
                if passed:
                    conn2.execute("""UPDATE learning_goals
                        SET status='completed', exam_passed=1, exam_score=?, completed_at=?
                        WHERE id=?""",
                        (score_pct, datetime.utcnow().isoformat(), exam_goal_id))
                    conn2.execute("UPDATE users SET xp = xp + ? WHERE id=?",
                                  (goals_mod.GOAL_EXAM_XP + goals_mod.GOAL_COMPLETE_XP, user["id"]))
                    flash(f"🏆 Экзамен сдан! {score_pct:.0f}% — цель завершена! +{goals_mod.GOAL_EXAM_XP + goals_mod.GOAL_COMPLETE_XP} XP", "success")
                else:
                    conn2.execute("""UPDATE learning_goals SET exam_score=? WHERE id=?""",
                                  (score_pct, exam_goal_id))
                    flash(f"⚠️ Экзамен не сдан: {score_pct:.0f}%. Нужно минимум 60%. Попробуйте ещё раз.", "error")
    conn2.commit(); conn2.close()
    if new_unlocks:
        existing = session.get("new_achievements", [])
        existing.extend([a["key"] for a in new_unlocks])
        session["new_achievements"] = list(set(existing))

    session["test_idx"] = idx + 1
    return redirect(url_for("test_view"))


# ---------------------- CATEGORY-based game launchers -----------------------
# Pulim karty so vseh kolod kategorii (i ee podkategoriy)

def _category_card_pool(conn, user, category_id, limit=None):
    """Pulim id kart iz vseh kolod, kotorye prinadlezhat kategorii ili ee podkategoriyam.
    Vozvrashchaem (cards_ids, decks_used)."""
    # Sobiraem tu kategoriyu + vse podkategorii
    cat_ids = [category_id]
    children = conn.execute(
        "SELECT id FROM categories WHERE parent_id=?",
        (category_id,)
    ).fetchall()
    cat_ids.extend([c["id"] for c in children])

    placeholders = ",".join("?" * len(cat_ids))
    if user["org_id"]:
        decks = conn.execute(
            f"""SELECT d.id, d.name, d.icon FROM decks d
                WHERE d.org_id=? AND d.category_id IN ({placeholders})""",
            (user["org_id"], *cat_ids)
        ).fetchall()
    else:
        decks = conn.execute(
            f"""SELECT d.id, d.name, d.icon FROM decks d
                WHERE d.owner_id=? AND d.category_id IN ({placeholders})""",
            (user["id"], *cat_ids)
        ).fetchall()
    deck_ids = [d["id"] for d in decks]
    if not deck_ids:
        return [], []
    deck_ph = ",".join("?" * len(deck_ids))
    sql = f"SELECT id FROM cards WHERE deck_id IN ({deck_ph}) ORDER BY RANDOM()"
    if limit:
        sql += f" LIMIT {int(limit)}"
    cards = conn.execute(sql, deck_ids).fetchall()
    return [c["id"] for c in cards], [dict(d) for d in decks]


@app.route("/category/<int:category_id>/play")
@login_required
def category_play(category_id):
    """Stranitsa zapuska igr po kategorii s vyborom kol-va voprosov."""
    user = current_user()
    conn = db.get_conn()
    cat = conn.execute("SELECT * FROM categories WHERE id=?", (category_id,)).fetchone()
    if not cat:
        conn.close(); abort(404)
    if cat["org_id"] and cat["org_id"] != user["org_id"]:
        conn.close(); abort(403)
    if cat["owner_id"] and cat["owner_id"] != user["id"] and not cat["org_id"]:
        conn.close(); abort(403)
    card_ids, decks = _category_card_pool(conn, user, category_id)
    conn.close()
    return render_template("category_play.html",
        category=dict(cat),
        card_count=len(card_ids),
        deck_count=len(decks),
        decks=decks)


@app.route("/category/<int:category_id>/test")
@login_required
def category_test_start(category_id):
    """Test po vsey kategorii — pulim karty so vseh kolod."""
    user = current_user()
    count = int(request.args.get("count", 10))
    count = max(3, min(count, 50))
    conn = db.get_conn()
    cat = conn.execute("SELECT * FROM categories WHERE id=?", (category_id,)).fetchone()
    if not cat:
        conn.close(); abort(404)
    # Proverka dostupa
    if cat["org_id"] and cat["org_id"] != user["org_id"]:
        conn.close(); abort(403)
    if cat["owner_id"] and cat["owner_id"] != user["id"] and not cat["org_id"]:
        conn.close(); abort(403)
    card_ids, decks = _category_card_pool(conn, user, category_id, limit=count)
    conn.close()
    if len(card_ids) < 3:
        flash(f"В категории «{cat['name']}» меньше 3 карт", "error")
        return redirect(url_for("categories_list"))
    # Stavim v sessiyu (ispol'zuya pervyy deck dlya vozvrata)
    session["test_queue"] = card_ids
    session["test_idx"] = 0
    session["test_deck"] = decks[0]["id"] if decks else None
    session["test_category_name"] = cat["name"]
    session["test_stats"] = {"correct": 0, "wrong": 0}
    session["test_answers"] = []
    session["test_scope"] = {"type": "category", "id": category_id, "name": cat["name"]}
    session["test_started_at"] = datetime.utcnow().isoformat()
    import random as _r
    session["test_seed"] = _r.randint(1, 10**9)
    return redirect(url_for("test_view"))


@app.route("/category/<int:category_id>/match")
@login_required
def category_match_game(category_id):
    """Match-igra po kategorii — pulim 6 sluchaynyh kart."""
    user = current_user()
    count = int(request.args.get("count", 6))
    count = max(3, min(count, 12))
    conn = db.get_conn()
    cat = conn.execute("SELECT * FROM categories WHERE id=?", (category_id,)).fetchone()
    if not cat:
        conn.close(); abort(404)
    if cat["org_id"] and cat["org_id"] != user["org_id"]:
        conn.close(); abort(403)
    if cat["owner_id"] and cat["owner_id"] != user["id"] and not cat["org_id"]:
        conn.close(); abort(403)
    card_ids, decks = _category_card_pool(conn, user, category_id, limit=count)
    if len(card_ids) < 3:
        conn.close()
        flash(f"В категории «{cat['name']}» меньше 3 карт", "error")
        return redirect(url_for("categories_list"))

    placeholders = ",".join("?" * len(card_ids))
    cards_raw = conn.execute(
        f"SELECT id, front, back, note FROM cards WHERE id IN ({placeholders})",
        card_ids
    ).fetchall()
    conn.close()
    pairs = []
    for c in cards_raw:
        cd = dict(c)
        ans = (cd["back"] or "").split("\n")[0].strip()
        m = re.match(r"^[A-Za-zА-Яа-яЁё0-9]+\s*[\)\.\:\-]\s*(.+)$", ans)
        if m:
            ans = m.group(1).strip()
        front = cd["front"]
        if len(front) > 100: front = front[:97] + "..."
        if len(ans) > 80: ans = ans[:77] + "..."
        pairs.append({"id": cd["id"], "front": front, "back": ans})
    # Virtualnyy deck dlya shablona
    virtual_deck = {
        "id": decks[0]["id"] if decks else 0,
        "name": f"📁 {cat['name']}",
        "icon": cat.get("icon") if hasattr(cat, "get") else (cat["icon"] if "icon" in cat.keys() else "📁"),
    }
    return render_template("match.html", deck=virtual_deck, pairs=pairs, count=len(pairs),
        category_id=category_id)


@app.route("/category/<int:category_id>/duel/<username>", methods=["POST"])
@login_required
def category_duel_challenge(category_id, username):
    """Vyzov na duel' po kategorii."""
    user = current_user()
    conn = db.get_conn()
    target = conn.execute("SELECT * FROM users WHERE username=?", (username,)).fetchone()
    if not target or target["id"] == user["id"]:
        conn.close(); abort(404)
    cat = conn.execute("SELECT * FROM categories WHERE id=?", (category_id,)).fetchone()
    if not cat:
        conn.close(); abort(404)
    card_ids, decks = _category_card_pool(conn, user, category_id, limit=5)
    if len(card_ids) < 3:
        conn.close()
        return jsonify({"error": "not_enough_cards"}), 400
    # Predstavitelnaya koloda — pervaya
    deck_id = decks[0]["id"]

    cur = conn.execute(
        """INSERT INTO duels (player1_id, player2_id, deck_id, question_count, shuffle_seed)
           VALUES (?, ?, ?, ?, ?)""",
        (user["id"], target["id"], deck_id, len(card_ids), secrets.randbelow(10**9)+1)
    )
    duel_id = cur.lastrowid
    for i, cid in enumerate(card_ids):
        conn.execute("INSERT INTO duel_cards (duel_id, position, card_id) VALUES (?, ?, ?)",
                     (duel_id, i, cid))
    _notify(conn, target["id"], "duel_challenge",
            f"⚔️ @{user['username']} вызвал вас на дуэль ({cat['name']})!",
            f"/duel/{duel_id}")
    conn.commit(); conn.close()
    return jsonify({"ok": True, "duel_id": duel_id})


# ---------------------- MATCH game (sopostavi pary) -------------------------

@app.route("/deck/<int:deck_id>/match")
@login_required
def match_game(deck_id):
    """Stranitsa match-igry: vybiraet 5-10 kart i otdaet karty + otvety dlya peremeshivaniya."""
    user = current_user()
    count = int(request.args.get("count", 6))
    count = max(3, min(count, 12))  # ot 3 do 12 par
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)

    deck_type = (deck["deck_type"] if "deck_type" in deck.keys() else "mcq") or "mcq"
    if deck_type == "mcq":
        conn.close()
        flash("Match доступен только для колод-словарей (терминов)", "info")
        return redirect(url_for("deck_view", deck_id=deck_id))
    cards_raw = conn.execute(
        "SELECT id, front, back, note FROM cards WHERE deck_id=? ORDER BY RANDOM() LIMIT ?",
        (deck_id, count)
    ).fetchall()
    conn.close()

    if len(cards_raw) < 3:
        flash("Нужно минимум 3 карты в колоде", "error")
        return redirect(url_for("deck_view", deck_id=deck_id))

    # Dlya kazhdoy karty vyderzhivayem korotkiy otvet (pervaya stroka back)
    pairs = []
    for c in cards_raw:
        cd = dict(c)
        # Korotkiy otvet — pervaya stroka back, ubivayem nomera A) B)
        ans = (cd["back"] or "").split("\n")[0].strip()
        # Esli otvet nachinaetsya s "B) tekst" — vyderzhivayem tol'ko tekst
        m = re.match(r"^[A-Za-zА-Яа-яЁё0-9]+\s*[\)\.\:\-]\s*(.+)$", ans)
        if m:
            ans = m.group(1).strip()
        # Korotkiy vopros — obrezat' do 100 simv
        front = cd["front"]
        if len(front) > 100:
            front = front[:97] + "..."
        if len(ans) > 80:
            ans = ans[:77] + "..."
        pairs.append({"id": cd["id"], "front": front, "back": ans})

    return render_template("match.html", deck=dict(deck), pairs=pairs, count=len(pairs))


@app.route("/api/my/new_achievements")
@login_required
def api_my_new_achievements():
    """Vozvrashchaet i ochishchaet ozhidayushchie dostizheniya iz sessii."""
    keys = session.pop("new_achievements", [])
    achievements = []
    for k in keys:
        a = ach_mod.ACH_BY_KEY.get(k)
        if a:
            achievements.append({"icon": a["icon"], "name": a["name"], "desc": a["desc"], "xp": a["xp"]})
    return jsonify({"achievements": achievements})


@app.route("/api/match/complete", methods=["POST"])
@login_required
def api_match_complete():
    """Otmetka chto match-igra zavershena. Daet XP i dostizheniya."""
    user = current_user()
    pairs = int(request.form.get("pairs", 0) or 0)
    time_sec = int(request.form.get("time", 0) or 0)
    conn = db.get_conn()
    new_unlocks = ach_mod.award_match_completed(conn, user["id"], pairs=pairs, time_sec=time_sec)
    # Bonus XP za skorost'
    if pairs >= 3:
        bonus_xp = max(5, 30 - time_sec // 5)
        conn.execute("UPDATE users SET xp = xp + ? WHERE id=?", (bonus_xp, user["id"]))
    conn.commit(); conn.close()
    if new_unlocks:
        existing = session.get("new_achievements", [])
        existing.extend([a["key"] for a in new_unlocks])
        session["new_achievements"] = list(set(existing))
    return jsonify({
        "ok": True,
        "achievements": [{"icon": a["icon"], "name": a["name"], "desc": a["desc"], "xp": a["xp"]}
                         for a in new_unlocks]
    })


# ---------------------- STATS (lichnaya statistika) -------------------------

@app.route("/stats")
@login_required
def stats_page():
    """Lichnaya statistika polzovatelya: grafik aktivnosti, heatmap, accuracy."""
    user = current_user()
    conn = db.get_conn()

    # Reviews za posledniy 365 dney (dlya heatmap)
    rows = conn.execute("""
        SELECT DATE(reviewed_at) AS d,
               COUNT(*) AS cnt,
               SUM(CASE WHEN grade >= 3 THEN 1 ELSE 0 END) AS good,
               SUM(CASE WHEN grade < 3 THEN 1 ELSE 0 END) AS bad
        FROM reviews
        WHERE user_id=?
          AND reviewed_at >= datetime('now', '-365 days')
        GROUP BY DATE(reviewed_at)
        ORDER BY d
    """, (user["id"],)).fetchall()

    by_date = {r["d"]: dict(r) for r in rows}

    # Stroyim heatmap: 365 dney
    today = datetime.utcnow().date()
    heatmap = []
    for i in range(364, -1, -1):
        d = today - timedelta(days=i)
        ds = d.isoformat()
        cnt = by_date.get(ds, {}).get("cnt", 0)
        heatmap.append({
            "date": ds,
            "weekday": d.weekday(),  # 0=mon, 6=sun
            "count": cnt,
            "level": 0 if cnt == 0 else (1 if cnt < 10 else (2 if cnt < 30 else (3 if cnt < 60 else 4))),
        })

    # Posledniye 30 dney — graphik
    last_30 = []
    for i in range(29, -1, -1):
        d = today - timedelta(days=i)
        ds = d.isoformat()
        r = by_date.get(ds, {})
        last_30.append({
            "date": ds,
            "label": d.strftime("%d.%m"),
            "good": r.get("good", 0),
            "bad": r.get("bad", 0),
            "total": r.get("cnt", 0),
        })

    # Posledniye 7 dney — kratkaya statistika
    last_7_total = sum(d["total"] for d in last_30[-7:])
    last_7_good = sum(d["good"] for d in last_30[-7:])
    last_7_accuracy = round(last_7_good / last_7_total * 100) if last_7_total else 0

    # Posledniye 30 dney
    last_30_total = sum(d["total"] for d in last_30)
    last_30_good = sum(d["good"] for d in last_30)
    last_30_accuracy = round(last_30_good / last_30_total * 100) if last_30_total else 0

    # Vsego za vse vremya
    total_row = conn.execute(
        "SELECT COUNT(*) AS c, SUM(CASE WHEN grade>=3 THEN 1 ELSE 0 END) AS g FROM reviews WHERE user_id=?",
        (user["id"],)
    ).fetchone()
    total_reviews = total_row["c"] or 0
    total_good = total_row["g"] or 0
    total_accuracy = round(total_good / total_reviews * 100) if total_reviews else 0

    # Aktivnyye dni
    active_days = sum(1 for h in heatmap if h["count"] > 0)

    # Lucshiy den' (max otvetov)
    best_day = max(heatmap, key=lambda h: h["count"]) if heatmap else None

    # Statistika igr
    game_stats = ach_mod.get_user_game_stats(conn, user["id"])
    conn.commit()

    conn.close()

    return render_template("stats.html",
        heatmap=heatmap,
        last_30=last_30,
        last_7_total=last_7_total,
        last_7_accuracy=last_7_accuracy,
        last_30_total=last_30_total,
        last_30_accuracy=last_30_accuracy,
        total_reviews=total_reviews,
        total_accuracy=total_accuracy,
        active_days=active_days,
        best_day=best_day,
        user=user,
        game_stats=game_stats,
    )


# ====================================================================
# LEARNING GOALS
# ====================================================================

@app.route("/goals")
@login_required
def goals_page():
    """Stranitsa "Mои цели" — spisok aktivnyh + zavershennyh."""
    user = current_user()
    conn = db.get_conn()
    active = goals_mod.get_active_goals_with_progress(conn, user["id"])
    finished = conn.execute("""
        SELECT g.*,
            CASE g.target_type
                WHEN 'deck' THEN (SELECT name FROM decks WHERE id=g.target_id)
                WHEN 'category' THEN (SELECT name FROM categories WHERE id=g.target_id)
            END AS target_name,
            CASE g.target_type
                WHEN 'deck' THEN (SELECT icon FROM decks WHERE id=g.target_id)
                WHEN 'category' THEN (SELECT icon FROM categories WHERE id=g.target_id)
            END AS target_icon
        FROM learning_goals g
        WHERE g.user_id=? AND g.status != 'active'
        ORDER BY g.completed_at DESC LIMIT 30
    """, (user["id"],)).fetchall()
    # Spisok kolod / kategoriy dlya formy sozdaniya
    if user["org_id"]:
        decks = conn.execute("""
            SELECT d.id, d.name, d.icon,
                (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt
            FROM decks d WHERE d.org_id=? ORDER BY d.name
        """, (user["org_id"],)).fetchall()
        cats = conn.execute("""
            SELECT c.id, c.name, c.icon, c.parent_id,
                (SELECT name FROM categories WHERE id=c.parent_id) AS parent_name
            FROM categories c WHERE c.org_id=? ORDER BY c.parent_id IS NULL DESC, c.name
        """, (user["org_id"],)).fetchall()
    else:
        decks = conn.execute("""
            SELECT d.id, d.name, d.icon,
                (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt
            FROM decks d WHERE d.owner_id=? ORDER BY d.name
        """, (user["id"],)).fetchall()
        cats = conn.execute("""
            SELECT c.id, c.name, c.icon, c.parent_id,
                (SELECT name FROM categories WHERE id=c.parent_id) AS parent_name
            FROM categories c WHERE c.owner_id=? ORDER BY c.parent_id IS NULL DESC, c.name
        """, (user["id"],)).fetchall()
    conn.close()
    return render_template("goals.html",
        active=active,
        finished=[dict(g) for g in finished],
        decks=[dict(d) for d in decks if d["cnt"] > 0],
        categories=[dict(c) for c in cats])


@app.route("/goals/new", methods=["POST"])
@login_required
def goal_new():
    """Sozdat novuyu tsel'."""
    user = current_user()
    title = request.form.get("title", "").strip()
    target_type = request.form.get("target_type", "")
    target_id = request.form.get("target_id", type=int)
    end_date = request.form.get("end_date", "").strip()
    end_time = (request.form.get("end_time", "") or "23:59").strip()
    difficulty = request.form.get("difficulty", "medium")
    exam = request.form.get("exam_required", "1") == "1"
    solo = request.form.get("solo_mode", "0") == "1"
    if not (target_type in ("deck", "category") and target_id and end_date):
        flash("Заполните все поля", "error")
        return redirect(url_for("goals_page"))
    if not title:
        title = "Цель"
    conn = db.get_conn()
    goal_id = goals_mod.create_goal(conn, user, title=title,
        target_type=target_type, target_id=target_id,
        end_date=end_date, end_time=end_time,
        difficulty=difficulty, exam_required=exam, solo_mode=solo)
    conn.close()
    if not goal_id:
        flash("Не удалось создать цель — нет карт или дата уже прошла", "error")
    else:
        flash("🎯 Цель создана! Удачи в обучении!", "success")
    return redirect(url_for("goals_page"))


@app.route("/goal/<int:goal_id>/extra", methods=["POST"])
@login_required
def goal_add_extra(goal_id):
    """Dop. mini-tsel' na segodnya."""
    user = current_user()
    extra = request.form.get("extra", type=int)
    if not extra:
        return jsonify({"error": "no_value"}), 400
    conn = db.get_conn()
    g = conn.execute("SELECT * FROM learning_goals WHERE id=? AND user_id=?",
                     (goal_id, user["id"])).fetchone()
    if not g:
        conn.close(); return jsonify({"error": "not_found"}), 404
    ok = goals_mod.add_extra_today(conn, goal_id, extra)
    conn.close()
    return jsonify({"ok": ok})


@app.route("/goal/<int:goal_id>/extend", methods=["POST"])
@login_required
def goal_extend(goal_id):
    """Prodlit deadline tseli."""
    user = current_user()
    new_end = request.form.get("end_date", "").strip()
    new_end_time = (request.form.get("end_time", "") or "23:59").strip()
    conn = db.get_conn()
    g = conn.execute("SELECT * FROM learning_goals WHERE id=? AND user_id=?",
                     (goal_id, user["id"])).fetchone()
    if not g:
        conn.close()
        flash("Цель не найдена", "error")
        return redirect(url_for("goals_page"))
    ok = goals_mod.extend_deadline(conn, goal_id, new_end, new_end_time)
    conn.close()
    if ok:
        flash("📅 Срок продлён. Не сдавайся!", "success")
    else:
        flash("Неверная дата или время", "error")
    return redirect(url_for("goals_page"))


@app.route("/goal/<int:goal_id>/abandon", methods=["POST"])
@login_required
def goal_abandon(goal_id):
    """Otkazat'sya ot tseli."""
    user = current_user()
    conn = db.get_conn()
    conn.execute("""UPDATE learning_goals SET status='abandoned', completed_at=?
                    WHERE id=? AND user_id=?""",
                 (datetime.utcnow().isoformat(), goal_id, user["id"]))
    conn.commit(); conn.close()
    flash("Цель отменена", "info")
    return redirect(url_for("goals_page"))


@app.route("/goal/<int:goal_id>/exam")
@login_required
def goal_exam_start(goal_id):
    """Forma vybora: skol'ko voprosov v ekzamen."""
    user = current_user()
    conn = db.get_conn()
    g = conn.execute("SELECT * FROM learning_goals WHERE id=? AND user_id=?",
                     (goal_id, user["id"])).fetchone()
    if not g:
        conn.close(); abort(404)
    overall = goals_mod.get_overall_progress(conn, user["id"], dict(g))
    conn.close()
    return render_template("goal_exam_setup.html",
        goal=dict(g), overall=overall)


@app.route("/goal/<int:goal_id>/exam/start", methods=["POST"])
@login_required
def goal_exam_run(goal_id):
    """Zapuskayem ekzamen kak test."""
    user = current_user()
    count_param = request.form.get("count", "20")
    conn = db.get_conn()
    g = conn.execute("SELECT * FROM learning_goals WHERE id=? AND user_id=?",
                     (goal_id, user["id"])).fetchone()
    if not g:
        conn.close(); abort(404)
    if count_param == "all":
        cards_pool = goals_mod.collect_card_ids_simple(conn, g["target_type"], g["target_id"])
        # Beryom tol'ko kotorye user uzhe videl
        seen = conn.execute("""
            SELECT card_id FROM user_card_progress
            WHERE user_id=? AND reviews > 0
        """, (user["id"],)).fetchall()
        seen_set = {r["card_id"] for r in seen}
        card_ids = [cid for cid in cards_pool if cid in seen_set] or cards_pool
        # Mishaem
        import random as _r
        _r.shuffle(card_ids)
    else:
        try: count = int(count_param)
        except: count = 20
        count = max(5, min(count, 100))
        card_ids = goals_mod.pick_exam_cards(conn, user["id"], dict(g), count)
    conn.close()
    if len(card_ids) < 5:
        flash("Недостаточно карт для экзамена. Прежде нужно ответить хотя бы на 5 карт.", "error")
        return redirect(url_for("goals_page"))

    session["test_queue"] = card_ids
    session["test_idx"] = 0
    session["test_deck"] = None
    session["test_stats"] = {"correct": 0, "wrong": 0}
    session["test_answers"] = []
    session["test_seed"] = secrets.randbelow(10**9) + 1
    # Pomechaem chto eto ekzamen tseli
    session["test_exam_goal_id"] = goal_id
    return redirect(url_for("test_view"))


@app.route("/api/goal/dismiss-reminder", methods=["POST"])
@login_required
def goal_dismiss_reminder():
    """Polzovatel' ne hochet videt' napominanie segodnya."""
    user = current_user()
    conn = db.get_conn()
    goals_mod.dismiss_reminder_today(conn, user["id"])
    conn.close()
    return jsonify({"ok": True})


@app.route("/achievements")
@login_required
def achievements_page():
    """Stranitsa s vsemi dostizheniyami polzovatelya."""
    user = current_user()
    conn = db.get_conn()
    # Eshyo raz proveryaem chtoby aktualizirovat'
    ach_mod.check_and_award(conn, user["id"])
    conn.commit()
    items = ach_mod.get_user_achievements(conn, user["id"])
    unlocked_count = sum(1 for i in items if i["unlocked"])
    total_count = len(items)
    conn.close()
    return render_template("achievements.html",
        items=items,
        unlocked_count=unlocked_count,
        total_count=total_count,
    )


# Growth-stages tree showcase (web mirror of the mobile feature, richer
# animations). The 9 stages are a client-side visual catalog keyed off the
# user's streak; art lives in static/trees/.
GROWTH_STAGES = [
    {"key": "seed",      "title": "Семечко",            "rank": "Первое зерно",       "range": "1–2 дня",     "start": 0,   "img": "1_seed.webp",      "accent": "#F59E0B", "glow": "#FFD16A", "particle": "sparks",       "colors": "#FFE08A,#FFFFFF"},
    {"key": "sprout",    "title": "Росток",             "rank": "Садовод",            "range": "3–6 дней",    "start": 3,   "img": "2_sprout.webp",    "accent": "#22C55E", "glow": "#86EFAC", "particle": "greenMotes",   "colors": "#86EFAC,#4ADE80"},
    {"key": "young",     "title": "Молодое дерево",     "rank": "Хранитель ростка",   "range": "7–13 дней",   "start": 7,   "img": "3_young.webp",     "accent": "#16A34A", "glow": "#FFE9A6", "particle": "sunRising",    "colors": "#FFE9A6,#FFD16A"},
    {"key": "blooming",  "title": "Цветущее дерево",    "rank": "Цветовод",           "range": "14–29 дней",  "start": 14,  "img": "4_blooming.webp",  "accent": "#EC4899", "glow": "#F9A8D4", "particle": "petals",       "colors": "#F9A8D4,#F472B6,#FBCFE8"},
    {"key": "mature",    "title": "Зрелое дерево",      "rank": "Лесник",             "range": "30–59 дней",  "start": 30,  "img": "5_mature.webp",    "accent": "#F97316", "glow": "#FCB873", "particle": "autumnLeaves", "colors": "#EA8C2E,#D97706,#B45309"},
    {"key": "rare",      "title": "Редкое дерево",      "rank": "Маг леса",           "range": "60–99 дней",  "start": 60,  "img": "6_rare.webp",      "accent": "#8B5CF6", "glow": "#C4B5FD", "particle": "purpleOrbit",  "colors": "#C4B5FD,#A78BFA"},
    {"key": "legendary", "title": "Легендарное дерево", "rank": "Хранитель леса",     "range": "100–199 дней","start": 100, "img": "7_legendary.webp", "accent": "#F59E0B", "glow": "#FFD56A", "particle": "goldRising",   "colors": "#FFD56A,#FFB020", "ring": True},
    {"key": "mythical",  "title": "Мифическое дерево",  "rank": "Повелитель стихий",  "range": "200–364 дня", "start": 200, "img": "8_mythical.webp",  "accent": "#3B82F6", "glow": "#93C5FD", "particle": "crystals",     "colors": "#93C5FD,#60A5FA,#BAE6FD"},
    {"key": "eternal",   "title": "Древо Вечности",     "rank": "Древний",            "range": "365+ дней",   "start": 365, "img": "9_eternal.webp",   "accent": "#A855F7", "glow": "#FFE08A", "particle": "stars",        "colors": "#FFE08A,#FFFFFF,#FCD34D", "ring": True},
]


def growth_stage_for(streak):
    """The growth stage dict matching a streak length (highest reached)."""
    cur = GROWTH_STAGES[0]
    for s in GROWTH_STAGES:
        if (streak or 0) >= s["start"]:
            cur = s
    return cur


@app.context_processor
def inject_tree_status():
    """Exposes the logged-in user's tree status (rank title + colour) to every
    template — used for the avatar ring and the growth page status."""
    try:
        u = current_user()
        if not u:
            return {}
        st = growth_stage_for(u["streak"] if "streak" in u.keys() else 0)
        return {"tree_status": {
            "key": st["key"], "rank": t(f"gr_r_{st['key']}"), "title": t(f"gr_t_{st['key']}"),
            "accent": st["accent"], "glow": st["glow"],
        }}
    except Exception:
        return {}


@app.route("/growth")
@login_required
def growth_page():
    """Стадии роста — анимированные деревья серии (web)."""
    user = current_user()
    streak = (user["streak"] if user and "streak" in user.keys() else 0) or 0
    idx = 0
    for i, s in enumerate(GROWTH_STAGES):
        if streak >= s["start"]:
            idx = i
    current = GROWTH_STAGES[idx]
    nxt = GROWTH_STAGES[idx + 1] if idx + 1 < len(GROWTH_STAGES) else None

    # Progress within the current stage toward the next one.
    if nxt:
        span = max(1, nxt["start"] - current["start"])
        done = streak - current["start"]
        stage_progress = max(0.0, min(1.0, done / span))
        days_to_next = max(0, nxt["start"] - streak)
    else:
        stage_progress = 1.0
        days_to_next = 0

    # Localise the stage labels (title/rank/range) for the current language so
    # they translate everywhere the template uses them (display, alt, aria,
    # data-* attributes read by the tree JS).
    def _loc(s):
        return {**s, "title": t(f"gr_t_{s['key']}"), "rank": t(f"gr_r_{s['key']}"), "range": t(f"gr_g_{s['key']}")}
    loc_stages = [_loc(s) for s in GROWTH_STAGES]

    return render_template(
        "growth_stages.html",
        stages=loc_stages,
        streak=streak,
        current_key=current["key"],
        next_key=(nxt["key"] if nxt else None),
        next_title=(t(f"gr_t_{nxt['key']}") if nxt else None),
        days_to_next=days_to_next,
        stage_progress=stage_progress,
    )


@app.route("/deck/<int:deck_id>/export-json")
@login_required
def export_deck_json(deck_id):
    """Eksport kolody v JSON (backup, mozhno importirovat' obratno)."""
    user = current_user()
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)
    cards = conn.execute(
        "SELECT front, back, note, image_url FROM cards WHERE deck_id=? ORDER BY id",
        (deck_id,)
    ).fetchall()
    conn.close()
    import json as _json
    payload = {
        "format": "quizpro/v1",
        "deck": {
            "name": deck["name"],
            "icon": deck["icon"],
            "description": deck["description"] or "",
        },
        "cards": [
            {
                "front": c["front"],
                "back": c["back"],
                "note": c["note"] or "",
                "image_url": c["image_url"] or "",
            } for c in cards
        ],
        "exported_at": datetime.now().isoformat(),
        "card_count": len(cards),
    }
    safe_name = re.sub(r'[^\w\-]', '_', deck["name"])[:40]
    filename = f"{safe_name}.json"
    from flask import Response
    return Response(
        _json.dumps(payload, ensure_ascii=False, indent=2),
        mimetype="application/json",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )


# === AI KONVERTATSIYA: testy ↔ slovari =======================================

@app.route("/deck/<int:deck_id>/convert/<direction>", methods=["POST"])
@login_required
def deck_ai_convert(deck_id, direction):
    """AI preobrazuet karty:
      direction='to_terms'  — testy → slovari (term-style)
      direction='to_tests'  — slovari → testy s 4 variantami

    Stoit 1 AI-generatsiyu (obshchiy schyotchik s /ai)."""
    user = current_user()
    if not can_manage_content(user):
        abort(403)
    if direction not in ("to_terms", "to_tests"):
        return jsonify({"ok": False, "error": "invalid direction"}), 400
    if not ai_gen.is_available():
        return jsonify({"ok": False, "error": "AI ne nastroen"}), 503

    # Limit AI proverim
    ok, used, limit = billing.check_ai_limit(user)
    if not ok:
        return jsonify({"ok": False, "error": f"Лимит AI достигнут: {used}/{limit}"}), 403

    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)

    cards_raw = conn.execute(
        "SELECT id, front, back, note FROM cards WHERE deck_id=? ORDER BY id",
        (deck_id,)
    ).fetchall()
    if not cards_raw:
        conn.close()
        return jsonify({"ok": False, "error": "В колоде нет карт"}), 400

    # Filtruyem podkhodyashchie karty po napravleniyu
    src_cards = []
    if direction == "to_terms":
        # Beryom tol'ko MCQ-karty (s variantami v note ILI back)
        for c in cards_raw:
            if _card_is_mcq(c):
                src_cards.append({"front": c["front"], "back": c["back"], "note": c["note"] or ""})
        if not src_cards:
            conn.close()
            return jsonify({"ok": False, "error": "В колоде нет тестовых карт для конвертации"}), 400
    else:  # to_tests
        # Beryom tol'ko ne-MCQ karty
        for c in cards_raw:
            if not _card_is_mcq(c):
                src_cards.append({"front": c["front"], "back": c["back"], "note": c["note"] or ""})
        if not src_cards:
            conn.close()
            return jsonify({"ok": False, "error": "В колоде нет словарных карт для конвертации"}), 400

    # Ogranichivaem batch — chtoby ne perevalit' API limit
    src_cards = src_cards[:50]

    lang = session.get("lang", "ru")
    new_deck_name = (request.form.get("new_deck_name") or "").strip()
    target_kind = "Slovari" if direction == "to_terms" else "Testy"
    if not new_deck_name:
        new_deck_name = f"{deck['name']} ({target_kind})"

    try:
        if direction == "to_terms":
            new_cards = ai_gen.convert_tests_to_flashcards(src_cards, lang=lang)
        else:
            new_cards = ai_gen.convert_flashcards_to_tests(src_cards, lang=lang)
    except Exception as e:
        conn.close()
        return jsonify({"ok": False, "error": f"AI error: {str(e)[:200]}"}), 500

    if not new_cards:
        conn.close()
        return jsonify({"ok": False, "error": "AI ne smog konvertirovat'"}), 500

    # Sokhranyaem v novuyu kolodu
    icon = "🃏" if direction == "to_terms" else "📝"
    deck_type_new = "terms" if direction == "to_terms" else "mcq"
    if user["org_id"]:
        cur = conn.execute(
            "INSERT INTO decks (org_id, category_id, name, icon, deck_type, created_via) VALUES (?, ?, ?, ?, ?, ?)",
            (user["org_id"], deck["category_id"], new_deck_name, icon, deck_type_new, "ai_convert")
        )
    else:
        cur = conn.execute(
            "INSERT INTO decks (owner_id, category_id, name, icon, deck_type, created_via) VALUES (?, ?, ?, ?, ?, ?)",
            (user["id"], deck["category_id"], new_deck_name, icon, deck_type_new, "ai_convert")
        )
    new_deck_id = cur.lastrowid
    for c in new_cards:
        conn.execute(
            "INSERT INTO cards (deck_id, front, back, note) VALUES (?, ?, ?, ?)",
            (new_deck_id, c["front"], c["back"], c.get("note", ""))
        )
    conn.commit()
    conn.close()

    # Schityvaem v obshchiy AI-schyotchik
    billing.log_ai_usage(user, f"convert_{direction}", len(new_cards))

    return jsonify({
        "ok": True,
        "deck_id": new_deck_id,
        "count": len(new_cards),
        "url": url_for("deck_view", deck_id=new_deck_id),
    })


@app.route("/deck/<int:deck_id>/ai-find-answers", methods=["POST"])
@login_required
def deck_ai_find_answers(deck_id):
    """AI analiziruet karty bez otmechennogo pravil'nogo otveta i nakhodit ego.
    Kartochka schitaetsya 'bez otveta' esli back soderzhit polnyy spisok variantov
    (mnogostrochnyy s A) B) C) D)) — eto signal chto pravil'nyy ne razobran."""
    user = current_user()
    if not can_manage_content(user):
        return jsonify({"ok": False, "error": "forbidden"}), 403

    if not ai_gen.is_available():
        return jsonify({"ok": False, "error": "ai_not_configured"}), 503

    # Proverka kvoty AI
    ok, used, limit = billing.check_ai_limit(user)
    if not ok:
        return jsonify({"ok": False, "error": "ai_quota_exceeded",
                        "used": used, "limit": limit}), 429

    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close()
        return jsonify({"ok": False, "error": "not_found"}), 404

    # Berem vse karty kolody
    rows = conn.execute(
        "SELECT id, front, back, note FROM cards WHERE deck_id=? ORDER BY id",
        (deck_id,)
    ).fetchall()

    # Filtruem te, chto BEZ otmechennogo pravil'nogo otveta:
    # - Esli back mnogostrochnyy I soderzhit A) B) C) ... = ne otmecheno
    # - Esli back odna stroka i nachinaetsya s "X) ..." — uzhe otmecheno
    candidates = []
    import re as _re
    for r in rows:
        back = (r["back"] or "").strip()
        # Schitayem skol'ko strok-variantov
        lines = [l.strip() for l in back.split("\n") if l.strip()]
        option_lines = [l for l in lines if _re.match(r"^[A-Da-d1-4А-Гa-г]\s*[\)\.]\s*", l)]
        # Esli > 1 strok-variantov v back — eto polnyy spisok bez otmetki
        if len(option_lines) >= 2:
            candidates.append({
                "id": r["id"],
                "front": r["front"],
                "back": back,
                "note": r["note"] or "",
            })

    if not candidates:
        conn.close()
        return jsonify({"ok": True, "updated": 0, "skipped": 0,
                        "msg": "Все карты уже имеют отмеченные правильные ответы"})

    # Vyzyvayem AI
    lang = session.get("lang", "ru")
    try:
        results = ai_gen.find_correct_answers(candidates, lang=lang)
    except Exception as e:
        conn.close()
        print(f"[AI find-answers] err: {e}")
        return jsonify({"ok": False, "error": "ai_error", "msg": str(e)[:200]}), 500

    # Obnovlyaem karty
    updated = 0
    skipped = 0
    for res in results:
        if not res.get("correct_letter") or not res.get("back"):
            skipped += 1
            continue
        conn.execute(
            "UPDATE cards SET back=?, note=? WHERE id=? AND deck_id=?",
            (res["back"], res.get("note", ""), res["id"], deck_id)
        )
        updated += 1

    # Logiruem AI usage
    if updated > 0:
        conn.execute("""INSERT INTO ai_usage (user_id, org_id, kind, cards_generated)
                        VALUES (?, ?, ?, ?)""",
                     (user.get("id") if user.get("role") == "individual" else None,
                      user.get("org_id"), "find_answers", updated))

    conn.commit()
    conn.close()

    return jsonify({
        "ok": True,
        "updated": updated,
        "skipped": skipped,
        "total": len(candidates),
    })


@app.route("/import-json", methods=["POST"])
@login_required
def import_deck_json():
    """Import kolody iz JSON-fayla (svoy ili otrugogo polzovatelya)."""
    user = current_user()
    if not can_manage_content(user):
        abort(403)
    file = request.files.get("file")
    if not file or not file.filename:
        flash("Выберите файл", "error")
        return redirect(url_for("import_page"))
    try:
        import json as _json
        payload = _json.loads(file.read().decode("utf-8"))
        if payload.get("format") != "quizpro/v1":
            flash("Неверный формат файла", "error")
            return redirect(url_for("import_page"))
    except Exception:
        flash("Файл повреждён", "error")
        return redirect(url_for("import_page"))

    deck_data = payload.get("deck", {})
    cards = payload.get("cards", [])
    if not cards:
        flash("В файле нет карт", "error")
        return redirect(url_for("import_page"))

    conn = db.get_conn()
    name = deck_data.get("name", "Импорт") + " (импорт)"
    icon = deck_data.get("icon", "📥")
    desc = deck_data.get("description", "")

    if user["org_id"]:
        cur = conn.execute("INSERT INTO decks (org_id, name, icon, description) VALUES (?, ?, ?, ?)",
                          (user["org_id"], name, icon, desc))
    else:
        cur = conn.execute("INSERT INTO decks (owner_id, name, icon, description) VALUES (?, ?, ?, ?)",
                          (user["id"], name, icon, desc))
    new_deck_id = cur.lastrowid
    for c in cards:
        if not c.get("front") or not c.get("back"):
            continue
        conn.execute("""INSERT INTO cards (deck_id, front, back, note, image_url)
                       VALUES (?, ?, ?, ?, ?)""",
                     (new_deck_id, c["front"], c["back"], c.get("note", ""), c.get("image_url", "")))
    conn.commit(); conn.close()
    flash(f"Импортировано {len(cards)} карт", "success")
    return redirect(url_for("deck_view", deck_id=new_deck_id))


@app.route("/marketplace")
@login_required
def marketplace():
    """Marketplace v2 — Educational Library with Subjects."""
    user = current_user()
    conn = db.get_conn()
    lang = session.get("lang", "ru")

    # Subjects
    subjects_raw = conn.execute("""
        SELECT s.*,
            (SELECT COUNT(*) FROM collections c WHERE c.subject_id=s.id AND c.is_active=1) AS coll_count,
            (SELECT COALESCE(SUM(
                (SELECT COUNT(*) FROM collection_decks WHERE collection_id=c2.id)
             ),0) FROM collections c2 WHERE c2.subject_id=s.id AND c2.is_active=1) AS deck_count
        FROM mp_subjects s WHERE s.is_active=1
        ORDER BY s.sort_order ASC
    """).fetchall()
    subjects = []
    for s in subjects_raw:
        d = dict(s)
        d["title"] = d.get(f"title_{lang}") or d["title_en"]
        d["desc"]  = d.get(f"desc_{lang}")  or d.get("desc_en", "")
        subjects.append(d)

    # Featured collections (newest / most decks)
    featured_raw = conn.execute("""
        SELECT c.*,
            s.slug AS subject_slug, s.title_ru AS subj_ru, s.title_en AS subj_en, s.title_uz AS subj_uz,
            (SELECT COUNT(*) FROM collection_decks WHERE collection_id=c.id) AS deck_count
        FROM collections c
        LEFT JOIN mp_subjects s ON s.id=c.subject_id
        WHERE c.is_active=1
        ORDER BY c.sort_order ASC, c.id ASC
        LIMIT 6
    """).fetchall()
    featured = []
    for row in featured_raw:
        d = dict(row)
        d["title"] = d.get(f"title_{lang}") or d["title_en"]
        d["desc"]  = d.get(f"desc_{lang}")  or d.get("desc_en", "")
        d["subj_title"] = d.get(f"subj_{lang}") or d.get("subj_en", "")
        featured.append(d)

    # Trending decks — most-cloned public decks (social proof + discovery)
    trending_raw = conn.execute("""
        SELECT d.*,
            (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS card_count,
            CASE WHEN d.org_id IS NOT NULL
                 THEN (SELECT name FROM organizations WHERE id=d.org_id)
                 ELSE (SELECT username FROM users WHERE id=d.owner_id)
            END AS author
        FROM decks d
        WHERE d.is_public=1 AND d.clones_count > 0
        ORDER BY d.clones_count DESC, d.id DESC
        LIMIT 10
    """).fetchall()
    trending = _attach_ratings(conn, [_localize_deck_fields(dict(d), lang) for d in trending_raw])

    # Legacy collections (no subject_id) — keep backward compat
    legacy_raw = conn.execute("""
        SELECT c.*,
            (SELECT COUNT(*) FROM collection_decks WHERE collection_id=c.id) AS deck_count
        FROM collections c
        WHERE c.is_active=1 AND (c.subject_id IS NULL OR c.subject_id=0)
        ORDER BY c.sort_order ASC, c.id ASC
    """).fetchall()
    legacy = []
    for row in legacy_raw:
        d = dict(row)
        d["title"] = d.get(f"title_{lang}") or d["title_ru"]
        d["desc"]  = d.get(f"desc_{lang}")  or d.get("desc_ru", "")
        legacy.append(d)

    conn.close()
    return render_template("marketplace.html",
                           subjects=subjects, featured=featured, legacy=legacy, trending=trending)


@app.route("/collection/<slug>")
@login_required
def collection_view(slug):
    """Stranitsa tematicheskoj kollektsii s kolodami."""
    user = current_user()
    conn = db.get_conn()
    coll = conn.execute("SELECT * FROM collections WHERE slug=? AND is_active=1", (slug,)).fetchone()
    if not coll:
        conn.close(); abort(404)
    coll = dict(coll)

    decks = conn.execute("""
        SELECT d.*,
            (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS card_count,
            CASE WHEN d.org_id IS NOT NULL
                 THEN (SELECT name FROM organizations WHERE id=d.org_id)
                 ELSE (SELECT username FROM users WHERE id=d.owner_id)
            END AS author
        FROM collection_decks cd
        JOIN decks d ON d.id=cd.deck_id
        WHERE cd.collection_id=?
        ORDER BY cd.sort_order ASC
    """, (coll["id"],)).fetchall()
    lang = session.get("lang", "ru")
    decks = _attach_ratings(conn, [_localize_deck_fields(dict(d), lang) for d in decks])
    conn.close()
    coll["title"] = coll.get(f"title_{lang}") or coll["title_ru"]
    coll["desc"] = coll.get(f"desc_{lang}") or coll.get("desc_ru", "")
    return render_template("collection.html", coll=coll, decks=decks)


@app.route("/marketplace/deck/<int:deck_id>/preview")
@login_required
def marketplace_deck_preview(deck_id):
    """Sample cards for the marketplace preview modal — lets users see what's
    inside a deck before cloning (localized question + answer, up to 3)."""
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not deck["is_public"]:
        conn.close()
        return jsonify({"error": "not_found"}), 404
    total = conn.execute("SELECT COUNT(*) AS c FROM cards WHERE deck_id=?", (deck_id,)).fetchone()["c"]
    rows = conn.execute(
        """SELECT front, back, note, front_en, front_uz, back_en, back_uz
           FROM cards WHERE deck_id=? ORDER BY id LIMIT 3""", (deck_id,)).fetchall()
    conn.close()
    lang = session.get("lang", "ru")
    cards = []
    for r in rows:
        c = _localize_card_fields(dict(r), lang)
        # For MCQ the correct answer often carries an "A) " prefix — strip it.
        back = (c.get("back") or "").strip()
        m = re.match(r"^[A-Za-zА-Яа-яЁё0-9]+\s*[\)\.\:\-]\s*(.+)$", back.split("\n")[0])
        if m:
            back = m.group(1).strip()
        cards.append({"front": (c.get("front") or "").strip(), "back": back})
    return jsonify({"ok": True, "total": total, "cards": cards})


# ── Deck reviews (ratings) ─────────────────────────────────────────────────
_REVIEW_AUTO_HIDE = 3  # reports before a review is auto-hidden (light moderation)


def _decks_ratings(conn, deck_ids):
    """Batched {deck_id: {'avg': float, 'count': int}} for a list of decks."""
    deck_ids = [d for d in deck_ids if d is not None]
    if not deck_ids:
        return {}
    ph = ",".join("?" * len(deck_ids))
    rows = conn.execute(
        f"""SELECT deck_id, ROUND(AVG(stars), 1) AS avg, COUNT(*) AS count
            FROM deck_reviews WHERE is_hidden=0 AND deck_id IN ({ph})
            GROUP BY deck_id""", list(deck_ids)).fetchall()
    return {r["deck_id"]: {"avg": r["avg"], "count": r["count"]} for r in rows}


def _attach_ratings(conn, decks):
    """Add rating/rating_count to each deck dict for the card macro."""
    ratings = _decks_ratings(conn, [d["id"] for d in decks])
    for d in decks:
        r = ratings.get(d["id"])
        d["rating"] = (r["avg"] if r else 0) or 0
        d["rating_count"] = (r["count"] if r else 0) or 0
    return decks


@app.route("/deck/<int:deck_id>/review", methods=["POST"])
@login_required
def deck_review(deck_id):
    """Create or update the current user's star rating + optional review text."""
    user = current_user()
    conn = db.get_conn()
    deck = conn.execute("SELECT id, is_public FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not deck["is_public"]:
        conn.close(); abort(404)
    try:
        stars = int(request.form.get("stars", 0))
    except (TypeError, ValueError):
        stars = 0
    if stars < 1 or stars > 5:
        conn.close()
        flash(t("rv_need_stars"), "error")
        return redirect(url_for("deck_view", deck_id=deck_id) + "#reviews")
    text = (request.form.get("text") or "").strip()[:1000]
    conn.execute("""
        INSERT INTO deck_reviews (deck_id, user_id, stars, text)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(deck_id, user_id)
        DO UPDATE SET stars=excluded.stars, text=excluded.text, updated_at=CURRENT_TIMESTAMP
    """, (deck_id, user["id"], stars, text))
    conn.commit(); conn.close()
    flash(t("rv_thanks"), "success")
    return redirect(url_for("deck_view", deck_id=deck_id) + "#reviews")


@app.route("/deck/<int:deck_id>/review/delete", methods=["POST"])
@login_required
def deck_review_delete(deck_id):
    user = current_user()
    conn = db.get_conn()
    conn.execute("DELETE FROM deck_reviews WHERE deck_id=? AND user_id=?", (deck_id, user["id"]))
    conn.commit(); conn.close()
    return redirect(url_for("deck_view", deck_id=deck_id) + "#reviews")


@app.route("/review/<int:review_id>/report", methods=["POST"])
@login_required
def review_report(review_id):
    """Flag a review; auto-hide after a few reports (light moderation)."""
    conn = db.get_conn()
    row = conn.execute("SELECT deck_id FROM deck_reviews WHERE id=?", (review_id,)).fetchone()
    if row:
        conn.execute("UPDATE deck_reviews SET reports = reports + 1 WHERE id=?", (review_id,))
        conn.execute("UPDATE deck_reviews SET is_hidden=1 WHERE id=? AND reports >= ?",
                     (review_id, _REVIEW_AUTO_HIDE))
        conn.commit()
    did = row["deck_id"] if row else None
    conn.close()
    flash(t("rv_reported"), "info")
    return redirect(url_for("deck_view", deck_id=did) + "#reviews" if did else url_for("marketplace"))


# === Admin: manage collections ===
@app.route("/admin/collections")
@login_required
def admin_collections():
    user = current_user()
    if not is_super_admin(user): abort(403)
    conn = db.get_conn()
    colls = conn.execute("""
        SELECT c.*, (SELECT COUNT(*) FROM collection_decks WHERE collection_id=c.id) AS deck_count
        FROM collections c ORDER BY c.sort_order, c.id
    """).fetchall()
    # Public decks for adding
    pub_decks = conn.execute("""
        SELECT d.id, d.name, d.icon,
            (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS card_count
        FROM decks d WHERE d.is_public=1 ORDER BY d.clones_count DESC LIMIT 200
    """).fetchall()
    conn.close()
    return render_template("admin_collections.html", collections=colls, pub_decks=pub_decks)


@app.route("/admin/collections/create", methods=["POST"])
@login_required
def admin_collection_create():
    user = current_user()
    if not is_super_admin(user): abort(403)
    data = request.form
    conn = db.get_conn()
    conn.execute("""
        INSERT INTO collections (slug, title_ru, title_en, title_uz, desc_ru, desc_en, desc_uz,
            icon, color, color2, level, tags, sort_order)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, (
        data.get("slug","").strip(),
        data.get("title_ru",""), data.get("title_en",""), data.get("title_uz",""),
        data.get("desc_ru",""), data.get("desc_en",""), data.get("desc_uz",""),
        data.get("icon","📚"), data.get("color","#6366f1"), data.get("color2","#8b5cf6"),
        data.get("level",""), data.get("tags",""),
        int(data.get("sort_order", 0)),
    ))
    conn.commit(); conn.close()
    flash("Коллекция создана", "success")
    return redirect(url_for("admin_collections"))


@app.route("/admin/collections/<int:coll_id>/add-deck", methods=["POST"])
@login_required
def admin_collection_add_deck(coll_id):
    user = current_user()
    if not is_super_admin(user): abort(403)
    deck_id = request.form.get("deck_id", type=int)
    sort_order = request.form.get("sort_order", 0, type=int)
    if not deck_id: abort(400)
    conn = db.get_conn()
    conn.execute("INSERT OR IGNORE INTO collection_decks (collection_id, deck_id, sort_order) VALUES (?,?,?)",
                 (coll_id, deck_id, sort_order))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/admin/collections/<int:coll_id>/remove-deck", methods=["POST"])
@login_required
def admin_collection_remove_deck(coll_id):
    user = current_user()
    if not is_super_admin(user): abort(403)
    deck_id = request.form.get("deck_id", type=int)
    conn = db.get_conn()
    conn.execute("DELETE FROM collection_decks WHERE collection_id=? AND deck_id=?", (coll_id, deck_id))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/admin/collections/<int:coll_id>/delete", methods=["POST"])
@login_required
def admin_collection_delete(coll_id):
    user = current_user()
    if not is_super_admin(user): abort(403)
    conn = db.get_conn()
    conn.execute("DELETE FROM collections WHERE id=?", (coll_id,))
    conn.commit(); conn.close()
    flash("Коллекция удалена", "success")
    return redirect(url_for("admin_collections"))


# ─────────────────────────────────────────────────────────────────────────────
# MARKETPLACE v2 — Subject / Level / Learning Path pages
# ─────────────────────────────────────────────────────────────────────────────

@app.route("/marketplace/subject/<slug>")
@login_required
def marketplace_subject(slug):
    """Subject page: /marketplace/subject/english"""
    user = current_user()
    conn = db.get_conn()
    subj = conn.execute(
        "SELECT * FROM mp_subjects WHERE slug=? AND is_active=1", (slug,)
    ).fetchone()
    if not subj:
        conn.close(); abort(404)
    subj = dict(subj)
    lang = session.get("lang", "ru")
    subj["title"] = subj.get(f"title_{lang}") or subj["title_en"]
    subj["desc"]  = subj.get(f"desc_{lang}")  or subj.get("desc_en", "")

    colls_raw = conn.execute("""
        SELECT c.*,
            (SELECT COUNT(*) FROM collection_decks WHERE collection_id=c.id) AS deck_count,
            (SELECT COALESCE(SUM(
                (SELECT COUNT(*) FROM cards WHERE deck_id=cd2.deck_id)
             ),0) FROM collection_decks cd2 WHERE cd2.collection_id=c.id) AS card_count,
            (SELECT MAX(COALESCE(d.has_mcq, 0))
             FROM collection_decks cd3 JOIN decks d ON d.id=cd3.deck_id
             WHERE cd3.collection_id=c.id) AS has_mcq,
            (SELECT MAX(COALESCE(d.has_terms, 0))
             FROM collection_decks cd4 JOIN decks d ON d.id=cd4.deck_id
             WHERE cd4.collection_id=c.id) AS has_terms,
            (SELECT cd5.deck_id FROM collection_decks cd5
             JOIN decks d ON d.id=cd5.deck_id
             WHERE cd5.collection_id=c.id AND COALESCE(d.has_mcq,0)=1
             ORDER BY cd5.sort_order LIMIT 1) AS first_mcq_deck_id,
            (SELECT cd6.deck_id FROM collection_decks cd6
             JOIN decks d ON d.id=cd6.deck_id
             WHERE cd6.collection_id=c.id AND COALESCE(d.has_terms,0)=1
             ORDER BY cd6.sort_order LIMIT 1) AS first_terms_deck_id
        FROM collections c
        WHERE c.subject_id=? AND c.is_active=1
        ORDER BY c.sort_order ASC, c.id ASC
    """, (subj["id"],)).fetchall()

    colls = []
    for c_row in colls_raw:
        d = dict(c_row)
        d["title"] = d.get(f"title_{lang}") or d["title_en"]
        d["desc"]  = d.get(f"desc_{lang}")  or d.get("desc_en", "")
        colls.append(d)

    paths = conn.execute("""
        SELECT * FROM learning_paths
        WHERE subject_id=? AND is_active=1
        ORDER BY sort_order ASC
    """, (subj["id"],)).fetchall()
    paths = [dict(p) for p in paths]
    for p in paths:
        p["title"] = p.get(f"title_{lang}") or p["title_en"]
        p["desc"]  = p.get(f"desc_{lang}")  or p.get("desc_en", "")

    conn.close()
    return render_template("marketplace_subject.html",
                           subj=subj, collections=colls, paths=paths)


@app.route("/marketplace/path/<slug>")
@login_required
def marketplace_path(slug):
    """Learning path page: /marketplace/path/english-a1-path"""
    user = current_user()
    conn = db.get_conn()
    path = conn.execute(
        "SELECT * FROM learning_paths WHERE slug=? AND is_active=1", (slug,)
    ).fetchone()
    if not path:
        conn.close(); abort(404)
    path = dict(path)
    lang = session.get("lang", "ru")
    path["title"] = path.get(f"title_{lang}") or path["title_en"]
    path["desc"]  = path.get(f"desc_{lang}")  or path.get("desc_en", "")

    steps_raw = conn.execute("""
        SELECT s.*,
            c.slug AS coll_slug, c.title_ru AS coll_title_ru, c.title_en AS coll_title_en,
            c.title_uz AS coll_title_uz, c.icon AS coll_icon, c.color AS coll_color,
            c.color2 AS coll_color2,
            (SELECT COUNT(*) FROM collection_decks WHERE collection_id=c.id) AS coll_deck_count
        FROM learning_path_steps s
        LEFT JOIN collections c ON c.id=s.collection_id
        WHERE s.path_id=?
        ORDER BY s.step_order ASC
    """, (path["id"],)).fetchall()

    steps = []
    for s in steps_raw:
        sd = dict(s)
        sd["title"] = sd.get(f"title_{lang}") or sd.get("title_en", "")
        sd["coll_title"] = sd.get(f"coll_title_{lang}") or sd.get("coll_title_en", "")
        steps.append(sd)

    # Subject for breadcrumb
    subj = None
    if path.get("subject_id"):
        subj = conn.execute(
            "SELECT * FROM mp_subjects WHERE id=?", (path["subject_id"],)
        ).fetchone()
        if subj:
            subj = dict(subj)
            subj["title"] = subj.get(f"title_{lang}") or subj["title_en"]

    conn.close()
    return render_template("marketplace_path.html", path=path, steps=steps, subj=subj)


@app.route("/marketplace/search")
@login_required
def marketplace_search():
    """Search across marketplace collections."""
    user = current_user()
    q = request.args.get("q", "").strip()
    subject_slug = request.args.get("subject", "")
    level = request.args.get("level", "")
    lang = session.get("lang", "ru")

    conn = db.get_conn()
    where_parts = ["c.is_active=1"]
    params = []

    if q:
        where_parts.append(
            "(c.title_ru LIKE ? OR c.title_en LIKE ? OR c.title_uz LIKE ? OR c.tags LIKE ?)"
        )
        like = f"%{q}%"
        params += [like, like, like, like]
    if subject_slug:
        where_parts.append("s.slug=?")
        params.append(subject_slug)
    if level:
        where_parts.append("c.level=?")
        params.append(level)

    where = " AND ".join(where_parts)
    colls_raw = conn.execute(f"""
        SELECT c.*,
            s.slug AS subject_slug, s.title_ru AS subj_ru, s.title_en AS subj_en,
            (SELECT COUNT(*) FROM collection_decks WHERE collection_id=c.id) AS deck_count
        FROM collections c
        LEFT JOIN mp_subjects s ON s.id=c.subject_id
        WHERE {where}
        ORDER BY c.sort_order ASC, c.id ASC
        LIMIT 60
    """, params).fetchall()

    colls = []
    for row in colls_raw:
        d = dict(row)
        d["title"] = d.get(f"title_{lang}") or d["title_en"]
        d["desc"]  = d.get(f"desc_{lang}")  or d.get("desc_en", "")
        d["subj_title"] = d.get(f"subj_{lang}") or d.get("subj_en", "")
        colls.append(d)

    # Search/browse individual public decks with filters + sort — collections-only
    # search misses most content, so this is the primary results section.
    ctype = request.args.get("type", "")    # 'test' | 'cards'
    sort = request.args.get("sort", "popular")
    _DECK_SORT = {
        "popular": "d.clones_count DESC, d.id DESC",
        "rating": "(SELECT AVG(stars) FROM deck_reviews WHERE deck_id=d.id AND is_hidden=0) DESC, d.clones_count DESC",
        "new": "d.id DESC",
        "cards": "card_count DESC, d.id DESC",
    }
    where_d = ["d.is_public=1"]
    params_d = []
    if q:
        like = f"%{q}%"
        where_d.append("(d.name LIKE ? OR d.description LIKE ?)")
        params_d += [like, like]
    if ctype == "test":
        where_d.append("d.has_mcq=1")
    elif ctype == "cards":
        where_d.append("d.has_terms=1")
    if subject_slug:
        where_d.append("""EXISTS (SELECT 1 FROM collection_decks cd JOIN collections cc ON cc.id=cd.collection_id
            WHERE cd.deck_id=d.id AND cc.subject_id=(SELECT id FROM mp_subjects WHERE slug=?))""")
        params_d.append(subject_slug)
    if level:
        where_d.append("""EXISTS (SELECT 1 FROM collection_decks cd2 JOIN collections cc2 ON cc2.id=cd2.collection_id
            WHERE cd2.deck_id=d.id AND cc2.level=?)""")
        params_d.append(level)
    order_d = _DECK_SORT.get(sort, _DECK_SORT["popular"])
    decks_raw = conn.execute(f"""
        SELECT d.*,
            (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS card_count,
            CASE WHEN d.org_id IS NOT NULL
                 THEN (SELECT name FROM organizations WHERE id=d.org_id)
                 ELSE (SELECT username FROM users WHERE id=d.owner_id)
            END AS author
        FROM decks d
        WHERE {' AND '.join(where_d)}
        ORDER BY {order_d}
        LIMIT 30
    """, params_d).fetchall()
    decks = _attach_ratings(conn, [_localize_deck_fields(dict(d), lang) for d in decks_raw])

    subjects = conn.execute(
        "SELECT * FROM mp_subjects WHERE is_active=1 ORDER BY sort_order"
    ).fetchall()
    subjects = [dict(s) for s in subjects]
    for s in subjects:
        s["title"] = s.get(f"title_{lang}") or s["title_en"]

    conn.close()
    return render_template("marketplace_search.html",
                           collections=colls, decks=decks, subjects=subjects,
                           q=q, subject_slug=subject_slug, level=level,
                           ctype=ctype, sort=sort)


@app.route("/search")
@login_required
def global_search():
    """Global'nyy poisk: po polzovatelyam, kolod, kanal."""
    user = current_user()
    q = request.args.get("q", "").strip()
    results = {"users": [], "decks": [], "channels": []}
    if len(q) >= 2:
        like = f"%{q}%"
        conn = db.get_conn()
        # Polzovateli (tol'ko publichnye + ne korp)
        results["users"] = [dict(r) for r in conn.execute("""
            SELECT id, username, full_name, xp, streak FROM users
            WHERE (username LIKE ? OR full_name LIKE ?)
              AND role='individual' AND org_id IS NULL
              AND COALESCE(profile_public, 1) = 1
            LIMIT 20
        """, (like, like)).fetchall()]
        # Publichnye kolody
        results["decks"] = [dict(r) for r in conn.execute("""
            SELECT d.id, d.name, d.icon, d.clones_count,
                (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS card_count,
                CASE WHEN d.org_id IS NOT NULL
                     THEN (SELECT name FROM organizations WHERE id=d.org_id)
                     ELSE (SELECT username FROM users WHERE id=d.owner_id) END AS author,
                (SELECT username FROM users WHERE id=d.owner_id) AS author_username
            FROM decks d
            WHERE d.is_public=1 AND (d.name LIKE ? OR d.description LIKE ?)
            ORDER BY d.clones_count DESC LIMIT 20
        """, (like, like)).fetchall()]
        # Publichnye kanaly
        results["channels"] = [dict(r) for r in conn.execute("""
            SELECT c.id, c.name, c.avatar,
                (SELECT COUNT(*) FROM chat_members WHERE chat_id=c.id) AS member_count
            FROM chats c
            WHERE c.type='channel' AND c.is_public=1 AND c.name LIKE ?
            ORDER BY member_count DESC LIMIT 20
        """, (like,)).fetchall()]
        conn.close()
    return render_template("search.html", q=q, results=results)


@app.route("/settings", methods=["GET", "POST"])
@login_required
def settings_page():
    """Nastroyki privatnosti polzovatelya."""
    user = current_user()
    if request.method == "POST":
        profile_public = 1 if request.form.get("profile_public") else 0
        show_in_leaderboard = 1 if request.form.get("show_in_leaderboard") else 0
        allow_friend_requests = 1 if request.form.get("allow_friend_requests") else 0
        full_name = request.form.get("full_name", "").strip()[:60]
        bio = request.form.get("bio", "").strip()[:200]
        avatar_color = request.form.get("avatar_color", "").strip()[:7]
        # Validatsiya hex tsveta
        if avatar_color and not re.match(r"^#[0-9a-fA-F]{6}$", avatar_color):
            avatar_color = ""
        conn = db.get_conn()
        conn.execute("""UPDATE users
            SET profile_public=?, show_in_leaderboard=?, allow_friend_requests=?,
                full_name=?, bio=?, avatar_color=?
            WHERE id=?""",
            (profile_public, show_in_leaderboard, allow_friend_requests,
             full_name, bio, avatar_color, user["id"]))
        conn.commit(); conn.close()
        flash("Настройки сохранены", "success")
        return redirect(url_for("settings_page"))
    return render_template("settings.html", user=user)


@app.route("/leaderboard")
@login_required
def leaderboard():
    """Global'nyy leaderboard individualnyh polzovateley."""
    user = current_user()
    conn = db.get_conn()
    # Top-50 individual'nyh polzovateley po XP (tol'ko teh kto razreshil)
    top_users = conn.execute("""
        SELECT u.id, u.username, u.full_name, u.avatar_color, u.xp, u.streak, u.created_at,
            (SELECT COUNT(*) FROM decks WHERE owner_id=u.id) AS decks_count,
            (SELECT COUNT(*) FROM decks WHERE owner_id=u.id AND is_public=1) AS public_decks,
            (SELECT COUNT(*) FROM reviews WHERE user_id=u.id) AS reviews_count,
            (SELECT COUNT(*) FROM user_card_progress WHERE user_id=u.id AND interval_days >= 7) AS learned_count
        FROM users u
        WHERE u.role='individual' AND u.org_id IS NULL
          AND COALESCE(u.show_in_leaderboard, 1) = 1
        ORDER BY u.xp DESC, u.streak DESC
        LIMIT 50
    """).fetchall()

    # Pozitsiya tekuschego polzovatelya
    my_rank = None
    if user["role"] == "individual" or not user["org_id"]:
        rank_row = conn.execute("""
            SELECT COUNT(*) + 1 AS rank
            FROM users
            WHERE role='individual' AND org_id IS NULL AND xp > ?
        """, (user["xp"] or 0,)).fetchone()
        my_rank = rank_row["rank"] if rank_row else None

    conn.close()
    return render_template("leaderboard.html", top_users=top_users, my_rank=my_rank, current=user)


@app.route("/u/<username>")
@login_required
def public_profile(username):
    """Publichnyy profil' polzovatelya: ego XP, streak, kolody."""
    user = current_user()
    conn = db.get_conn()
    target = conn.execute("""
        SELECT * FROM users WHERE username=? AND role='individual' AND org_id IS NULL
    """, (username,)).fetchone()
    if not target:
        conn.close()
        flash("Пользователь не найден", "error")
        return redirect(url_for("leaderboard"))

    is_me = (user["id"] == target["id"])
    # Privacy: esli profil' privatnyy i eto ne svoy — pokazyvayem zaglushku
    if not is_me and not target["profile_public"]:
        # Eshche dlya druzey razreshim
        is_friend = conn.execute("""
            SELECT 1 FROM friendships
            WHERE status='accepted' AND
                ((from_id=? AND to_id=?) OR (from_id=? AND to_id=?))
        """, (user["id"], target["id"], target["id"], user["id"])).fetchone()
        if not is_friend:
            conn.close()
            return render_template("public_profile_private.html", target=target)

    # Statistika
    decks_total = conn.execute(
        "SELECT COUNT(*) AS c FROM decks WHERE owner_id=?", (target["id"],)
    ).fetchone()["c"]
    decks_public = conn.execute(
        "SELECT * FROM decks WHERE owner_id=? AND is_public=1 ORDER BY clones_count DESC",
        (target["id"],)
    ).fetchall()
    cards_total = conn.execute("""
        SELECT COUNT(*) AS c FROM cards c
        JOIN decks d ON d.id=c.deck_id WHERE d.owner_id=?
    """, (target["id"],)).fetchone()["c"]
    learned = conn.execute("""
        SELECT COUNT(*) AS c FROM user_card_progress
        WHERE user_id=? AND interval_days >= 7
    """, (target["id"],)).fetchone()["c"]
    reviews = conn.execute(
        "SELECT COUNT(*) AS c FROM reviews WHERE user_id=?", (target["id"],)
    ).fetchone()["c"]

    # Achievements
    ach_count = conn.execute(
        "SELECT COUNT(*) AS c FROM user_achievements WHERE user_id=?", (target["id"],)
    ).fetchone()["c"]
    recent_achievements = conn.execute("""
        SELECT ach_key, unlocked_at FROM user_achievements
        WHERE user_id=? ORDER BY unlocked_at DESC LIMIT 6
    """, (target["id"],)).fetchall()

    # Privodim k formatu shablona
    recent = []
    for r in recent_achievements:
        ach = ach_mod.ACH_BY_KEY.get(r["ach_key"])
        if ach:
            recent.append({**ach, "unlocked_at": r["unlocked_at"]})

    # Reyt'ing v leaderboard
    rank_row = conn.execute("""
        SELECT COUNT(*) + 1 AS rank FROM users
        WHERE role='individual' AND org_id IS NULL AND xp > ?
    """, (target["xp"] or 0,)).fetchone()
    rank = rank_row["rank"] if rank_row else None

    # Status druzhby
    friendship_status = "none"  # none / sent / pending / friends
    if not is_me:
        existing = conn.execute("""
            SELECT * FROM friendships
            WHERE (from_id=? AND to_id=?) OR (from_id=? AND to_id=?)
        """, (user["id"], target["id"], target["id"], user["id"])).fetchone()
        if existing:
            if existing["status"] == "accepted":
                friendship_status = "friends"
            elif existing["from_id"] == user["id"]:
                friendship_status = "sent"
            else:
                friendship_status = "pending"
    else:
        friendship_status = None

    # Kolody dostupnye dlya duelya:
    # 1. Moi sobstvennye kolody (tol'ko gde >=3 kart)
    # 2. Publichnye kolody soperntika
    # 3. Top publichnykh marketplace kolod
    duel_decks = []
    if not is_me:
        my_decks = conn.execute("""
            SELECT d.id, d.name, d.icon, 'my' AS source,
                (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt
            FROM decks d
            WHERE d.owner_id=? OR d.org_id=?
        """, (user["id"], user["org_id"] or -1)).fetchall()
        for d in my_decks:
            if d["cnt"] >= 3:
                duel_decks.append(dict(d))

        # Publichnye soperntika (esli est')
        opp_decks = conn.execute("""
            SELECT d.id, d.name, d.icon, 'theirs' AS source,
                (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt
            FROM decks d
            WHERE d.owner_id=? AND d.is_public=1
        """, (target["id"],)).fetchall()
        for d in opp_decks:
            if d["cnt"] >= 3 and d["id"] not in [x["id"] for x in duel_decks]:
                duel_decks.append(dict(d))

        # Top marketplace
        market = conn.execute("""
            SELECT d.id, d.name, d.icon, 'market' AS source,
                (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt
            FROM decks d
            WHERE d.is_public=1 AND d.owner_id != ?
            ORDER BY d.clones_count DESC LIMIT 20
        """, (target["id"],)).fetchall()
        for d in market:
            if d["cnt"] >= 3 and d["id"] not in [x["id"] for x in duel_decks]:
                duel_decks.append(dict(d))

    conn.close()
    return render_template("public_profile.html",
        target=target,
        decks_total=decks_total,
        decks_public=decks_public,
        cards_total=cards_total,
        learned=learned,
        reviews=reviews,
        ach_count=ach_count,
        recent_achievements=recent,
        rank=rank,
        is_me=is_me,
        friendship_status=friendship_status,
        duel_decks=duel_decks,
    )


@app.route("/deck/<int:deck_id>/toggle-public", methods=["POST"])
@login_required
def deck_toggle_public(deck_id):
    """Vladelets makayet svoyu kolodu publichnoy/privatnoy."""
    user = current_user()
    if not can_manage_content(user): abort(403)
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)
    deck_d = dict(deck)
    # Vision PDF kolodu nelzya publikat na Free plane (predotvraschaem zlouupotreblenie AI Vision)
    # Super-admin i beta-tester obhodyat eto ogranicheniye
    if deck_d.get("created_via") == "vision_pdf" and not is_super_admin(user) and not user.get("is_beta_tester"):
        plan = billing.get_active_plan(user)
        if plan == "free":
            conn.close()
            return jsonify({
                "ok": False,
                "error": "vision_no_publish_on_free",
                "msg": "На бесплатном тарифе колоды созданные через AI Vision нельзя публиковать. Обновите план."
            }), 403
    new_state = 0 if deck["is_public"] else 1
    conn.execute("UPDATE decks SET is_public=? WHERE id=?", (new_state, deck_id))
    conn.commit(); conn.close()
    return jsonify({"ok": True, "is_public": new_state})


# === FRIENDS / NOTIFICATIONS ===

def _notify(conn, user_id, ntype, message, link=""):
    """Vnutrennaya: dobavit notifikatsiyu polzovatelyu."""
    conn.execute("""INSERT INTO notifications (user_id, type, message, link)
                   VALUES (?, ?, ?, ?)""", (user_id, ntype, message, link))


@app.route("/friend/<username>/request", methods=["POST"])
@login_required
def friend_request(username):
    """Otpravit zapros v druzhbu."""
    user = current_user()
    conn = db.get_conn()
    target = conn.execute("SELECT * FROM users WHERE username=?", (username,)).fetchone()
    if not target or target["id"] == user["id"]:
        conn.close(); abort(404)
    # Polzovatel' zapretil zaprosy?
    if target["allow_friend_requests"] == 0:
        conn.close()
        return jsonify({"error": "blocked", "msg": "Этот пользователь не принимает запросы"}), 400
    # Yavlyaetsya li uzhe zapros
    existing = conn.execute("""
        SELECT * FROM friendships
        WHERE (from_id=? AND to_id=?) OR (from_id=? AND to_id=?)
    """, (user["id"], target["id"], target["id"], user["id"])).fetchone()
    if existing:
        conn.close()
        return jsonify({"error": "exists"}), 400
    conn.execute("""INSERT INTO friendships (from_id, to_id, status)
                   VALUES (?, ?, 'pending')""", (user["id"], target["id"]))
    _notify(conn, target["id"], "friend_request",
            f"@{user['username']} хочет добавить вас в друзья",
            f"/u/{user['username']}")
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/friend/<username>/accept", methods=["POST"])
@login_required
def friend_accept(username):
    """Prinyat' zapros."""
    user = current_user()
    conn = db.get_conn()
    sender = conn.execute("SELECT * FROM users WHERE username=?", (username,)).fetchone()
    if not sender:
        conn.close(); abort(404)
    fr = conn.execute("""
        SELECT * FROM friendships WHERE from_id=? AND to_id=? AND status='pending'
    """, (sender["id"], user["id"])).fetchone()
    if not fr:
        conn.close()
        return jsonify({"error": "not_found"}), 404
    conn.execute("""UPDATE friendships SET status='accepted'
                   WHERE from_id=? AND to_id=?""", (sender["id"], user["id"]))
    _notify(conn, sender["id"], "friend_accepted",
            f"@{user['username']} принял ваш запрос в друзья!",
            f"/u/{user['username']}")
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/friend/<username>/remove", methods=["POST"])
@login_required
def friend_remove(username):
    """Udalit' iz druzey ili otmenit' zapros."""
    user = current_user()
    conn = db.get_conn()
    target = conn.execute("SELECT * FROM users WHERE username=?", (username,)).fetchone()
    if not target:
        conn.close(); abort(404)
    conn.execute("""DELETE FROM friendships
                   WHERE (from_id=? AND to_id=?) OR (from_id=? AND to_id=?)""",
                 (user["id"], target["id"], target["id"], user["id"]))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/friends")
@login_required
def friends_page():
    """Spisok druzey i ozhidayushchikh zaprosov."""
    user = current_user()
    conn = db.get_conn()
    # Druzya (oba storony accepted)
    friends = conn.execute("""
        SELECT u.id, u.username, u.xp, u.streak,
            (SELECT COUNT(*) FROM decks WHERE owner_id=u.id AND is_public=1) AS public_decks
        FROM friendships f
        JOIN users u ON (u.id = CASE WHEN f.from_id=? THEN f.to_id ELSE f.from_id END)
        WHERE (f.from_id=? OR f.to_id=?) AND f.status='accepted'
        ORDER BY u.xp DESC
    """, (user["id"], user["id"], user["id"])).fetchall()

    # Vhodyashchie zaprosy
    incoming = conn.execute("""
        SELECT u.id, u.username, u.xp FROM friendships f
        JOIN users u ON u.id = f.from_id
        WHERE f.to_id=? AND f.status='pending'
    """, (user["id"],)).fetchall()

    # Iskhodyashchie zaprosy
    outgoing = conn.execute("""
        SELECT u.id, u.username FROM friendships f
        JOIN users u ON u.id = f.to_id
        WHERE f.from_id=? AND f.status='pending'
    """, (user["id"],)).fetchall()

    conn.close()
    duel_category_id = request.args.get("duel_category", type=int)
    duel_category = None
    if duel_category_id:
        conn2 = db.get_conn()
        cat_row = conn2.execute("SELECT id, name, icon FROM categories WHERE id=?",
                                (duel_category_id,)).fetchone()
        conn2.close()
        if cat_row:
            duel_category = dict(cat_row)
    return render_template("friends.html",
        friends=friends, incoming=incoming, outgoing=outgoing,
        duel_category=duel_category)


@app.route("/notifications")
@login_required
def notifications_page():
    """Spisok uvedomleniy + pomechaem prochitannymi."""
    user = current_user()
    conn = db.get_conn()
    notifs = conn.execute("""
        SELECT * FROM notifications WHERE user_id=?
        ORDER BY created_at DESC LIMIT 50
    """, (user["id"],)).fetchall()
    conn.execute("UPDATE notifications SET is_read=1 WHERE user_id=?", (user["id"],))
    conn.commit(); conn.close()
    return render_template("notifications.html", notifs=notifs)


@app.route("/api/notifications/unread")
@login_required
def api_notifications_unread():
    """Kol-vo neprochitannykh dlya badge v navbare."""
    user = current_user()
    conn = db.get_conn()
    n = conn.execute(
        "SELECT COUNT(*) AS c FROM notifications WHERE user_id=? AND is_read=0",
        (user["id"],)
    ).fetchone()["c"]
    conn.close()
    return jsonify({"count": n})


# === END FRIENDS ===


# ====================================================================
# CHATS / GROUPS / CHANNELS
# ====================================================================

def _user_in_chat(conn, chat_id, user_id):
    return conn.execute("SELECT 1 FROM chat_members WHERE chat_id=? AND user_id=?",
                        (chat_id, user_id)).fetchone() is not None


@app.route("/chats")
@login_required
def chats_list():
    """Spisok vsekh chat'ov polzovatelya."""
    user = current_user()
    conn = db.get_conn()
    chats = conn.execute("""
        SELECT c.*, cm.last_read_at,
            (SELECT COUNT(*) FROM messages WHERE chat_id=c.id
             AND (cm.last_read_at IS NULL OR created_at > cm.last_read_at)
             AND user_id != ?) AS unread,
            (SELECT content FROM messages WHERE chat_id=c.id ORDER BY id DESC LIMIT 1) AS last_msg,
            (SELECT created_at FROM messages WHERE chat_id=c.id ORDER BY id DESC LIMIT 1) AS last_msg_at,
            (SELECT COUNT(*) FROM chat_members WHERE chat_id=c.id) AS member_count,
            CASE WHEN c.type='dm' THEN
                (SELECT u.username FROM chat_members m
                 JOIN users u ON u.id=m.user_id
                 WHERE m.chat_id=c.id AND m.user_id != ? LIMIT 1)
            ELSE c.name END AS display_name
        FROM chats c
        JOIN chat_members cm ON cm.chat_id=c.id AND cm.user_id=?
        ORDER BY COALESCE(last_msg_at, c.created_at) DESC
    """, (user["id"], user["id"], user["id"])).fetchall()
    conn.close()
    return render_template("chats_list.html", chats=chats)


@app.route("/chat/<int:chat_id>")
@login_required
def chat_view(chat_id):
    """Otkryvaem chat — soobshchenia + members + uchastniki."""
    user = current_user()
    conn = db.get_conn()
    chat = conn.execute("SELECT * FROM chats WHERE id=?", (chat_id,)).fetchone()
    if not chat:
        conn.close(); abort(404)

    is_member = _user_in_chat(conn, chat_id, user["id"])
    if not is_member:
        if chat["type"] != "channel" or not chat["is_public"]:
            conn.close(); abort(403)

    if is_member:
        conn.execute("UPDATE chat_members SET last_read_at=? WHERE chat_id=? AND user_id=?",
                     (datetime.utcnow().isoformat(), chat_id, user["id"]))

    messages = conn.execute("""
        SELECT m.*, u.username, u.full_name FROM messages m
        JOIN users u ON u.id=m.user_id
        WHERE m.chat_id=? ORDER BY m.id DESC LIMIT 200
    """, (chat_id,)).fetchall()
    messages = list(reversed([dict(m) for m in messages]))

    # Reactions
    msg_ids = [m["id"] for m in messages]
    reactions_by_msg = {}
    if msg_ids:
        placeholders = ",".join("?" for _ in msg_ids)
        rxs = conn.execute(f"""
            SELECT message_id, emoji, COUNT(*) AS cnt,
                MAX(CASE WHEN user_id=? THEN 1 ELSE 0 END) AS mine
            FROM message_reactions WHERE message_id IN ({placeholders})
            GROUP BY message_id, emoji
        """, [user["id"]] + msg_ids).fetchall()
        for rx in rxs:
            reactions_by_msg.setdefault(rx["message_id"], []).append({
                "emoji": rx["emoji"], "count": rx["cnt"], "mine": bool(rx["mine"])
            })
    for m in messages:
        m["reactions"] = reactions_by_msg.get(m["id"], [])

    # Pinned messages naverhu
    pinned = [m for m in messages if m["is_pinned"]]

    members = conn.execute("""
        SELECT u.id, u.username, u.full_name, cm.role FROM chat_members cm
        JOIN users u ON u.id=cm.user_id
        WHERE cm.chat_id=? ORDER BY cm.role='owner' DESC, cm.role='admin' DESC, u.username
    """, (chat_id,)).fetchall()

    display_name = chat["name"]
    if chat["type"] == "dm":
        partner = conn.execute("""
            SELECT u.username, u.full_name FROM chat_members m
            JOIN users u ON u.id=m.user_id
            WHERE m.chat_id=? AND m.user_id != ? LIMIT 1
        """, (chat_id, user["id"])).fetchone()
        if partner:
            display_name = partner["full_name"] or partner["username"]

    conn.commit()
    conn.close()
    return render_template("chat_view.html",
        chat=dict(chat), messages=messages, members=members,
        is_member=is_member, display_name=display_name, pinned=pinned)


@app.route("/api/chat/<int:chat_id>/send", methods=["POST"])
@login_required
def chat_send(chat_id):
    user = current_user()
    content = request.form.get("content", "").strip()[:2000]
    if not content:
        return jsonify({"error": "empty"}), 400
    conn = db.get_conn()
    chat = conn.execute("SELECT * FROM chats WHERE id=?", (chat_id,)).fetchone()
    if not chat:
        conn.close(); abort(404)
    if not _user_in_chat(conn, chat_id, user["id"]):
        conn.close(); abort(403)
    if chat["type"] == "channel":
        member = conn.execute("SELECT role FROM chat_members WHERE chat_id=? AND user_id=?",
                              (chat_id, user["id"])).fetchone()
        if member and member["role"] not in ("owner", "admin"):
            conn.close()
            return jsonify({"error": "channel_readonly"}), 403
    conn.execute("INSERT INTO messages (chat_id, user_id, content) VALUES (?, ?, ?)",
                 (chat_id, user["id"], content))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/api/chat/<int:chat_id>/messages")
@login_required
def chat_messages_api(chat_id):
    """Polling novye soobshcheniya."""
    user = current_user()
    after_id = request.args.get("after", 0, type=int)
    conn = db.get_conn()
    chat = conn.execute("SELECT * FROM chats WHERE id=?", (chat_id,)).fetchone()
    if not chat:
        conn.close(); abort(404)
    is_member = _user_in_chat(conn, chat_id, user["id"])
    if not is_member and not (chat["type"] == "channel" and chat["is_public"]):
        conn.close(); abort(403)
    rows = conn.execute("""
        SELECT m.id, m.user_id, m.content, m.created_at, m.is_pinned, m.edited_at,
               u.username, u.full_name FROM messages m
        JOIN users u ON u.id=m.user_id
        WHERE m.chat_id=? AND m.id > ? ORDER BY m.id ASC LIMIT 100
    """, (chat_id, after_id)).fetchall()
    if is_member and rows:
        conn.execute("UPDATE chat_members SET last_read_at=? WHERE chat_id=? AND user_id=?",
                     (datetime.utcnow().isoformat(), chat_id, user["id"]))
        conn.commit()
    # Reactions
    msg_ids = [r["id"] for r in rows]
    reactions_by_msg = {}
    if msg_ids:
        placeholders = ",".join("?" for _ in msg_ids)
        rxs = conn.execute(f"""
            SELECT message_id, emoji, COUNT(*) AS cnt,
                MAX(CASE WHEN user_id=? THEN 1 ELSE 0 END) AS mine
            FROM message_reactions WHERE message_id IN ({placeholders})
            GROUP BY message_id, emoji
        """, [user["id"]] + msg_ids).fetchall()
        for rx in rxs:
            reactions_by_msg.setdefault(rx["message_id"], []).append({
                "emoji": rx["emoji"], "count": rx["cnt"], "mine": bool(rx["mine"])
            })
    conn.close()
    msgs_out = []
    for r in rows:
        d = dict(r)
        d["reactions"] = reactions_by_msg.get(r["id"], [])
        msgs_out.append(d)
    return jsonify({"messages": msgs_out})


@app.route("/api/message/<int:msg_id>/react", methods=["POST"])
@login_required
def message_react(msg_id):
    """Toggle reaction na soobshcheniye."""
    user = current_user()
    emoji = request.form.get("emoji", "").strip()
    # Tol'ko dopuskaem opredelennye emoji (predotvrashayem zlowytrebleniye)
    allowed = ["👍", "❤️", "😂", "🎉", "🔥", "👏", "🤔", "😢"]
    if emoji not in allowed:
        return jsonify({"error": "bad_emoji"}), 400
    conn = db.get_conn()
    msg = conn.execute("SELECT chat_id FROM messages WHERE id=?", (msg_id,)).fetchone()
    if not msg:
        conn.close(); abort(404)
    if not _user_in_chat(conn, msg["chat_id"], user["id"]):
        conn.close(); abort(403)
    # Toggle: esli est' — udalit', net — dobavit'
    existing = conn.execute("""
        SELECT 1 FROM message_reactions WHERE message_id=? AND user_id=? AND emoji=?
    """, (msg_id, user["id"], emoji)).fetchone()
    if existing:
        conn.execute("DELETE FROM message_reactions WHERE message_id=? AND user_id=? AND emoji=?",
                     (msg_id, user["id"], emoji))
    else:
        conn.execute("INSERT INTO message_reactions (message_id, user_id, emoji) VALUES (?,?,?)",
                     (msg_id, user["id"], emoji))
    conn.commit(); conn.close()
    return jsonify({"ok": True, "added": not existing})


@app.route("/api/message/<int:msg_id>/pin", methods=["POST"])
@login_required
def message_pin(msg_id):
    """Pin/unpin soobshcheniye (tol'ko owner/admin chatа)."""
    user = current_user()
    conn = db.get_conn()
    msg = conn.execute("SELECT * FROM messages WHERE id=?", (msg_id,)).fetchone()
    if not msg:
        conn.close(); abort(404)
    member = conn.execute("""
        SELECT role FROM chat_members WHERE chat_id=? AND user_id=?
    """, (msg["chat_id"], user["id"])).fetchone()
    if not member or member["role"] not in ("owner", "admin"):
        conn.close(); abort(403)
    new_state = 0 if msg["is_pinned"] else 1
    conn.execute("UPDATE messages SET is_pinned=? WHERE id=?", (new_state, msg_id))
    conn.commit(); conn.close()
    return jsonify({"ok": True, "is_pinned": new_state})


@app.route("/api/message/<int:msg_id>/delete", methods=["POST"])
@login_required
def message_delete(msg_id):
    """Udalit' svoye soobshcheniye (ili admin/owner mozhet udalyat' chuzhie)."""
    user = current_user()
    conn = db.get_conn()
    msg = conn.execute("SELECT * FROM messages WHERE id=?", (msg_id,)).fetchone()
    if not msg:
        conn.close(); abort(404)
    can_delete = msg["user_id"] == user["id"]
    if not can_delete:
        member = conn.execute("SELECT role FROM chat_members WHERE chat_id=? AND user_id=?",
                              (msg["chat_id"], user["id"])).fetchone()
        if member and member["role"] in ("owner", "admin"):
            can_delete = True
    if not can_delete:
        conn.close(); abort(403)
    conn.execute("DELETE FROM messages WHERE id=?", (msg_id,))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/chat/dm/<username>", methods=["POST"])
@login_required
def chat_dm_open(username):
    """Otkryt' / sozdat' DM."""
    user = current_user()
    conn = db.get_conn()
    target = conn.execute("SELECT * FROM users WHERE username=?", (username,)).fetchone()
    if not target or target["id"] == user["id"]:
        conn.close(); abort(404)
    existing = conn.execute("""
        SELECT c.id FROM chats c
        JOIN chat_members m1 ON m1.chat_id=c.id AND m1.user_id=?
        JOIN chat_members m2 ON m2.chat_id=c.id AND m2.user_id=?
        WHERE c.type='dm' LIMIT 1
    """, (user["id"], target["id"])).fetchone()
    if existing:
        chat_id = existing["id"]
    else:
        cur = conn.execute("INSERT INTO chats (type, owner_id) VALUES ('dm', ?)", (user["id"],))
        chat_id = cur.lastrowid
        conn.execute("INSERT INTO chat_members (chat_id, user_id, role) VALUES (?, ?, 'member')",
                     (chat_id, user["id"]))
        conn.execute("INSERT INTO chat_members (chat_id, user_id, role) VALUES (?, ?, 'member')",
                     (chat_id, target["id"]))
        conn.commit()
    conn.close()
    return redirect(url_for("chat_view", chat_id=chat_id))


@app.route("/chat/new", methods=["POST"])
@login_required
def chat_new():
    user = current_user()
    chat_type = request.form.get("type", "group")
    if chat_type not in ("group", "channel"):
        abort(400)
    name = request.form.get("name", "").strip()[:60]
    avatar = request.form.get("avatar", "💬").strip()[:2] or "💬"
    is_public = 1 if request.form.get("is_public") else 0
    if not name:
        flash("Введите название", "error")
        return redirect(url_for("chats_list"))
    conn = db.get_conn()
    cur = conn.execute("""INSERT INTO chats (type, name, owner_id, is_public, avatar)
                          VALUES (?, ?, ?, ?, ?)""",
                       (chat_type, name, user["id"], is_public, avatar))
    chat_id = cur.lastrowid
    conn.execute("INSERT INTO chat_members (chat_id, user_id, role) VALUES (?, ?, 'owner')",
                 (chat_id, user["id"]))
    conn.commit(); conn.close()
    return redirect(url_for("chat_view", chat_id=chat_id))


@app.route("/chat/<int:chat_id>/join", methods=["POST"])
@login_required
def chat_join(chat_id):
    user = current_user()
    conn = db.get_conn()
    chat = conn.execute("SELECT * FROM chats WHERE id=?", (chat_id,)).fetchone()
    if not chat or chat["type"] == "dm" or not chat["is_public"]:
        conn.close(); abort(404)
    conn.execute("INSERT OR IGNORE INTO chat_members (chat_id, user_id, role) VALUES (?, ?, 'member')",
                 (chat_id, user["id"]))
    conn.commit(); conn.close()
    return redirect(url_for("chat_view", chat_id=chat_id))


@app.route("/chat/<int:chat_id>/leave", methods=["POST"])
@login_required
def chat_leave(chat_id):
    user = current_user()
    conn = db.get_conn()
    chat = conn.execute("SELECT * FROM chats WHERE id=?", (chat_id,)).fetchone()
    if not chat:
        conn.close(); abort(404)
    if chat["type"] == "dm":
        conn.close()
        return redirect(url_for("chats_list"))
    if chat["owner_id"] == user["id"]:
        conn.execute("DELETE FROM chats WHERE id=?", (chat_id,))
    else:
        conn.execute("DELETE FROM chat_members WHERE chat_id=? AND user_id=?",
                     (chat_id, user["id"]))
    conn.commit(); conn.close()
    return redirect(url_for("chats_list"))


@app.route("/channels")
@login_required
def channels_browse():
    conn = db.get_conn()
    channels = conn.execute("""
        SELECT c.*, (SELECT COUNT(*) FROM chat_members WHERE chat_id=c.id) AS member_count
        FROM chats c
        WHERE c.type='channel' AND c.is_public=1
        ORDER BY member_count DESC LIMIT 50
    """).fetchall()
    conn.close()
    return render_template("channels.html", channels=channels)


# === END CHATS ===


# ====================================================================
# DUEL — 1vs1 multiplayer quiz
# ====================================================================

@app.route("/duel/challenge/<username>", methods=["POST"])
@login_required
def duel_challenge(username):
    """Vyzyvayem polzovatelya na duel'."""
    user = current_user()
    deck_id = request.form.get("deck_id", type=int)
    if not deck_id:
        return jsonify({"error": "no_deck"}), 400
    conn = db.get_conn()
    target = conn.execute("SELECT * FROM users WHERE username=?", (username,)).fetchone()
    if not target or target["id"] == user["id"]:
        conn.close(); abort(404)
    # Vladelets dolzhen mochi videt' kolod
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck:
        conn.close(); abort(404)
    cards = conn.execute("SELECT id FROM cards WHERE deck_id=? ORDER BY RANDOM() LIMIT 5",
                         (deck_id,)).fetchall()
    if len(cards) < 3:
        conn.close()
        return jsonify({"error": "not_enough_cards"}), 400

    cur = conn.execute("""INSERT INTO duels (player1_id, player2_id, deck_id, question_count, shuffle_seed)
                          VALUES (?, ?, ?, ?, ?)""",
                       (user["id"], target["id"], deck_id, len(cards), secrets.randbelow(10**9)+1))
    duel_id = cur.lastrowid
    for i, c in enumerate(cards):
        conn.execute("INSERT INTO duel_cards (duel_id, position, card_id) VALUES (?, ?, ?)",
                     (duel_id, i, c["id"]))
    _notify(conn, target["id"], "duel_challenge",
            f"⚔️ @{user['username']} вызвал вас на дуэль!",
            f"/duel/{duel_id}")
    conn.commit(); conn.close()
    return jsonify({"ok": True, "duel_id": duel_id})


@app.route("/duel/<int:duel_id>")
@login_required
def duel_view(duel_id):
    user = current_user()
    conn = db.get_conn()
    duel = conn.execute("""
        SELECT d.*, p1.username AS p1_username, p1.full_name AS p1_full_name, p1.avatar_color AS p1_color,
               p2.username AS p2_username, p2.full_name AS p2_full_name, p2.avatar_color AS p2_color,
               dk.name AS deck_name
        FROM duels d
        JOIN users p1 ON p1.id=d.player1_id
        JOIN users p2 ON p2.id=d.player2_id
        JOIN decks dk ON dk.id=d.deck_id
        WHERE d.id=?
    """, (duel_id,)).fetchone()
    if not duel:
        conn.close(); abort(404)
    if user["id"] not in (duel["player1_id"], duel["player2_id"]):
        conn.close(); abort(403)
    conn.close()
    return render_template("duel.html", duel=dict(duel))


@app.route("/api/duel/<int:duel_id>/state")
@login_required
def duel_state(duel_id):
    user = current_user()
    conn = db.get_conn()
    duel = conn.execute("""
        SELECT d.*, p1.username AS p1_username, p1.full_name AS p1_name,
               p2.username AS p2_username, p2.full_name AS p2_name
        FROM duels d
        JOIN users p1 ON p1.id=d.player1_id
        JOIN users p2 ON p2.id=d.player2_id
        WHERE d.id=?
    """, (duel_id,)).fetchone()
    if not duel:
        conn.close()
        return jsonify({"error": "not_found"}), 404
    if user["id"] not in (duel["player1_id"], duel["player2_id"]):
        conn.close(); abort(403)

    state = dict(duel)
    state["is_p1"] = (user["id"] == duel["player1_id"])

    # Tekuschiy vopros
    state["question"] = None
    if duel["status"] == "running":
        cq = conn.execute("""
            SELECT c.id, c.front, c.back, c.note FROM duel_cards dc
            JOIN cards c ON c.id=dc.card_id
            WHERE dc.duel_id=? AND dc.position=?
        """, (duel_id, duel["current_idx"])).fetchone()
        if cq:
            cd = {"id": cq["id"], "front": cq["front"], "back": cq["back"], "note": cq["note"]}
            seed = duel["shuffle_seed"] if "shuffle_seed" in duel.keys() else None
            options, correct = _parse_card_options(cd, shuffle_seed=seed or None)
            state["question"] = {
                "front": cd["front"],
                "options": options,
                "correct": correct if user["id"] in (duel["player1_id"], duel["player2_id"]) and duel["status"] == "finished" else None,
                "started_at": duel["question_started_at"],
                "time_per_q": duel["time_per_q"],
            }
            # Otvet etogo polzovatelya
            ans = conn.execute("""
                SELECT chosen, is_correct FROM duel_answers
                WHERE duel_id=? AND user_id=? AND question_idx=?
            """, (duel_id, user["id"], duel["current_idx"])).fetchone()
            if ans:
                state["question"]["my_answer"] = ans["chosen"]
                state["question"]["my_correct"] = bool(ans["is_correct"])
            # Otvetil li opponent
            opp_id = duel["player2_id"] if state["is_p1"] else duel["player1_id"]
            opp_ans = conn.execute("""
                SELECT 1 FROM duel_answers WHERE duel_id=? AND user_id=? AND question_idx=?
            """, (duel_id, opp_id, duel["current_idx"])).fetchone()
            state["question"]["opp_answered"] = opp_ans is not None
    conn.close()
    return jsonify(state)


@app.route("/api/duel/<int:duel_id>/accept", methods=["POST"])
@login_required
def duel_accept(duel_id):
    user = current_user()
    conn = db.get_conn()
    duel = conn.execute("SELECT * FROM duels WHERE id=?", (duel_id,)).fetchone()
    if not duel or duel["player2_id"] != user["id"] or duel["status"] != "pending":
        conn.close(); abort(403)
    now = datetime.utcnow().isoformat()
    conn.execute("""UPDATE duels SET status='running', question_started_at=? WHERE id=?""",
                 (now, duel_id))
    _notify(conn, duel["player1_id"], "duel_accepted",
            f"⚔️ Дуэль началась!", f"/duel/{duel_id}")
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/api/duel/<int:duel_id>/decline", methods=["POST"])
@login_required
def duel_decline(duel_id):
    user = current_user()
    conn = db.get_conn()
    duel = conn.execute("SELECT * FROM duels WHERE id=?", (duel_id,)).fetchone()
    if not duel or duel["player2_id"] != user["id"] or duel["status"] != "pending":
        conn.close(); abort(403)
    conn.execute("UPDATE duels SET status='declined' WHERE id=?", (duel_id,))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/api/duel/<int:duel_id>/answer", methods=["POST"])
@login_required
def duel_answer(duel_id):
    user = current_user()
    chosen = request.form.get("chosen", "").strip().upper()
    conn = db.get_conn()
    duel = conn.execute("SELECT * FROM duels WHERE id=?", (duel_id,)).fetchone()
    if not duel or duel["status"] != "running":
        conn.close()
        return jsonify({"error": "not_running"}), 400
    if user["id"] not in (duel["player1_id"], duel["player2_id"]):
        conn.close(); abort(403)

    cq = conn.execute("""
        SELECT c.* FROM duel_cards dc JOIN cards c ON c.id=dc.card_id
        WHERE dc.duel_id=? AND dc.position=?
    """, (duel_id, duel["current_idx"])).fetchone()
    if not cq:
        conn.close()
        return jsonify({"error": "no_question"}), 400

    options, correct_letter = _parse_card_options(dict(cq),
        shuffle_seed=(duel["shuffle_seed"] if "shuffle_seed" in duel.keys() else None) or None)
    is_correct = (chosen == correct_letter)
    time_taken = 0
    if duel["question_started_at"]:
        try:
            sd = datetime.fromisoformat(duel["question_started_at"])
            time_taken = max(0, int((datetime.utcnow() - sd).total_seconds()))
        except Exception:
            pass

    # Score: 100 + bonus za skorost'
    if is_correct:
        speed_bonus = max(0, int(50 * (1 - min(time_taken / duel["time_per_q"], 1))))
        score_gain = 100 + speed_bonus
    else:
        score_gain = 0

    try:
        conn.execute("""INSERT INTO duel_answers (duel_id, user_id, question_idx, chosen, is_correct, time_taken, score_gain)
                       VALUES (?,?,?,?,?,?,?)""",
                     (duel_id, user["id"], duel["current_idx"], chosen,
                      1 if is_correct else 0, time_taken, score_gain))
        if is_correct:
            if user["id"] == duel["player1_id"]:
                conn.execute("UPDATE duels SET p1_score = p1_score + ? WHERE id=?", (score_gain, duel_id))
            else:
                conn.execute("UPDATE duels SET p2_score = p2_score + ? WHERE id=?", (score_gain, duel_id))
    except Exception:
        pass

    # Proveryaem otvetili li oba — esli da, perehodim k sleduyushchemu
    answered = conn.execute("""
        SELECT COUNT(DISTINCT user_id) AS c FROM duel_answers
        WHERE duel_id=? AND question_idx=?
    """, (duel_id, duel["current_idx"])).fetchone()["c"]

    if answered >= 2:
        next_idx = duel["current_idx"] + 1
        if next_idx >= duel["question_count"]:
            # Duel' zakonchen
            row = conn.execute("SELECT p1_score, p2_score FROM duels WHERE id=?", (duel_id,)).fetchone()
            winner_id = None
            if row["p1_score"] > row["p2_score"]:
                winner_id = duel["player1_id"]
            elif row["p2_score"] > row["p1_score"]:
                winner_id = duel["player2_id"]
            conn.execute("""UPDATE duels SET status='finished', winner_id=?, finished_at=?
                           WHERE id=?""",
                         (winner_id, datetime.utcnow().isoformat(), duel_id))
            # Bonus XP pobeditelya
            if winner_id:
                conn.execute("UPDATE users SET xp = xp + 50 WHERE id=?", (winner_id,))

            # Achievement: vsem uchasnikam — duel done; pobeditelyu — won
            p1_id = duel["player1_id"]
            p2_id = duel["player2_id"]
            is_draw = (winner_id is None)
            for pid in (p1_id, p2_id):
                won_flag = (pid == winner_id) and not is_draw
                lost_flag = (winner_id is not None) and (pid != winner_id)
                new_achs = ach_mod.award_duel_completed(conn, pid,
                    won=won_flag, lost=lost_flag, draw=is_draw)
                if pid == user["id"] and new_achs:
                    existing = session.get("new_achievements", [])
                    existing.extend([a["key"] for a in new_achs])
                    session["new_achievements"] = list(set(existing))
            # Esli duel' iz turnira — obnovlyaem match
            tm = conn.execute("SELECT * FROM tournament_matches WHERE duel_id=?", (duel_id,)).fetchone()
            if tm:
                final_winner = winner_id
                if not final_winner:
                    import random
                    final_winner = random.choice([duel["player1_id"], duel["player2_id"]])
                conn.execute("UPDATE tournament_matches SET status='finished', winner_id=? WHERE id=?",
                             (final_winner, tm["id"]))
                loser = duel["player2_id"] if final_winner == duel["player1_id"] else duel["player1_id"]
                conn.execute("UPDATE tournament_players SET eliminated_at=? WHERE tournament_id=? AND user_id=?",
                             (datetime.utcnow().isoformat(), tm["tournament_id"], loser))
                _tournament_advance(conn, tm["tournament_id"])
        else:
            conn.execute("UPDATE duels SET current_idx=?, question_started_at=? WHERE id=?",
                         (next_idx, datetime.utcnow().isoformat(), duel_id))

    conn.commit(); conn.close()
    return jsonify({"ok": True, "is_correct": is_correct, "score_gain": score_gain})


@app.route("/duels")
@login_required
def duels_list():
    """Spisok moih duel'."""
    user = current_user()
    conn = db.get_conn()
    duels = conn.execute("""
        SELECT d.*,
            p1.username AS p1_username, p2.username AS p2_username,
            dk.name AS deck_name
        FROM duels d
        JOIN users p1 ON p1.id=d.player1_id
        JOIN users p2 ON p2.id=d.player2_id
        JOIN decks dk ON dk.id=d.deck_id
        WHERE d.player1_id=? OR d.player2_id=?
        ORDER BY d.created_at DESC LIMIT 50
    """, (user["id"], user["id"])).fetchall()
    conn.close()
    return render_template("duels_list.html", duels=duels, current_user_id=user["id"])


# === END DUELS ===


# ====================================================================
# TOURNAMENTS — turnir s bracket
# ====================================================================

def _tournament_create_first_round(conn, t_id, players_list):
    """Pri starte: pary igrokov v 1-y round."""
    import random
    shuffled = list(players_list)
    random.shuffle(shuffled)
    pos = 0
    for i in range(0, len(shuffled), 2):
        p1 = shuffled[i]
        p2 = shuffled[i+1] if i+1 < len(shuffled) else None
        conn.execute("""INSERT INTO tournament_matches
            (tournament_id, round, bracket_pos, player1_id, player2_id, status)
            VALUES (?, 1, ?, ?, ?, 'pending')""",
            (t_id, pos, p1, p2))
        pos += 1


def _tournament_advance(conn, t_id):
    """Posle zaversheniya match'a: dvigaem pobeditelya v sleduyushiy round.
    Esli vse match'i finiseny — sozdayem sleduyushchiy round ili finiseм turnir."""
    # Tekushiy aktivnyy round
    cur_round = conn.execute("""
        SELECT MAX(round) AS r FROM tournament_matches WHERE tournament_id=?
    """, (t_id,)).fetchone()["r"]
    if not cur_round:
        return
    # Vse match'i etogo round zakoncheny?
    pending = conn.execute("""
        SELECT COUNT(*) AS c FROM tournament_matches
        WHERE tournament_id=? AND round=? AND status != 'finished'
    """, (t_id, cur_round)).fetchone()["c"]
    if pending > 0:
        return
    # Sobiraem pobeditedeley
    winners = conn.execute("""
        SELECT winner_id, bracket_pos FROM tournament_matches
        WHERE tournament_id=? AND round=? ORDER BY bracket_pos
    """, (t_id, cur_round)).fetchall()
    winner_ids = [w["winner_id"] for w in winners if w["winner_id"]]
    if len(winner_ids) <= 1:
        # Final
        conn.execute("UPDATE tournaments SET status='finished', winner_id=?, finished_at=? WHERE id=?",
                     (winner_ids[0] if winner_ids else None, datetime.utcnow().isoformat(), t_id))
        if winner_ids:
            conn.execute("UPDATE users SET xp = xp + 200 WHERE id=?", (winner_ids[0],))
        return
    # Sozdaem sleduyushiy round s parami pobeditedeley
    next_round = cur_round + 1
    pos = 0
    for i in range(0, len(winner_ids), 2):
        p1 = winner_ids[i]
        p2 = winner_ids[i+1] if i+1 < len(winner_ids) else None
        conn.execute("""INSERT INTO tournament_matches
            (tournament_id, round, bracket_pos, player1_id, player2_id, status)
            VALUES (?, ?, ?, ?, ?, 'pending')""",
            (t_id, next_round, pos, p1, p2))
        pos += 1


@app.route("/api/my-decks")
@login_required
def api_my_decks():
    """Spisok moih kolod dlya vybora v turnire/duel."""
    user = current_user()
    conn = db.get_conn()
    if user["org_id"]:
        rows = conn.execute("""
            SELECT d.id, d.name, d.icon,
                (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt
            FROM decks d WHERE d.org_id=? OR d.is_public=1
            ORDER BY d.created_at DESC LIMIT 100
        """, (user["org_id"],)).fetchall()
    else:
        rows = conn.execute("""
            SELECT d.id, d.name, d.icon,
                (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt
            FROM decks d WHERE d.owner_id=? OR d.is_public=1
            ORDER BY d.created_at DESC LIMIT 100
        """, (user["id"],)).fetchall()
    conn.close()
    return jsonify({"decks": [dict(r) for r in rows if r["cnt"] >= 5]})


@app.route("/tournaments")
@login_required
def tournaments_list():
    user = current_user()
    conn = db.get_conn()
    open_tours = conn.execute("""
        SELECT t.*, u.username AS creator_username, d.name AS deck_name, d.icon AS deck_icon,
            (SELECT COUNT(*) FROM tournament_players WHERE tournament_id=t.id) AS players_count
        FROM tournaments t
        JOIN users u ON u.id=t.creator_id
        JOIN decks d ON d.id=t.deck_id
        WHERE t.status='open' ORDER BY t.created_at DESC LIMIT 50
    """).fetchall()
    my_tours = conn.execute("""
        SELECT t.*, u.username AS creator_username, d.name AS deck_name, d.icon AS deck_icon,
            (SELECT COUNT(*) FROM tournament_players WHERE tournament_id=t.id) AS players_count
        FROM tournaments t
        JOIN users u ON u.id=t.creator_id
        JOIN decks d ON d.id=t.deck_id
        WHERE t.id IN (SELECT tournament_id FROM tournament_players WHERE user_id=?)
        ORDER BY t.created_at DESC LIMIT 50
    """, (user["id"],)).fetchall()
    conn.close()
    return render_template("tournaments_list.html", open_tours=open_tours, my_tours=my_tours)


@app.route("/tournament/new", methods=["POST"])
@login_required
def tournament_new():
    user = current_user()
    name = request.form.get("name", "").strip()[:60]
    deck_id = request.form.get("deck_id", type=int)
    size = int(request.form.get("size", 4))
    if size not in (4, 8, 16):
        size = 4
    if not name or not deck_id:
        flash("Введите название и выберите колоду", "error")
        return redirect(url_for("tournaments_list"))
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck:
        conn.close(); abort(404)
    cards_count = conn.execute("SELECT COUNT(*) AS c FROM cards WHERE deck_id=?", (deck_id,)).fetchone()["c"]
    if cards_count < 5:
        conn.close()
        flash("В колоде должно быть минимум 5 вопросов", "error")
        return redirect(url_for("tournaments_list"))
    cur = conn.execute("""INSERT INTO tournaments (name, creator_id, deck_id, size)
                          VALUES (?, ?, ?, ?)""",
                       (name, user["id"], deck_id, size))
    t_id = cur.lastrowid
    # Sozdatel' avtomaticheski v turnire
    conn.execute("INSERT INTO tournament_players (tournament_id, user_id, slot) VALUES (?, ?, 0)",
                 (t_id, user["id"]))
    conn.commit(); conn.close()
    return redirect(url_for("tournament_view", tournament_id=t_id))


@app.route("/tournament/<int:tournament_id>")
@login_required
def tournament_view(tournament_id):
    user = current_user()
    conn = db.get_conn()
    t = conn.execute("""
        SELECT t.*, u.username AS creator_username, d.name AS deck_name, d.icon AS deck_icon
        FROM tournaments t JOIN users u ON u.id=t.creator_id
        JOIN decks d ON d.id=t.deck_id WHERE t.id=?
    """, (tournament_id,)).fetchone()
    if not t:
        conn.close(); abort(404)
    players = conn.execute("""
        SELECT u.id, u.username, u.full_name, u.avatar_color, p.eliminated_at
        FROM tournament_players p JOIN users u ON u.id=p.user_id
        WHERE p.tournament_id=? ORDER BY p.slot
    """, (tournament_id,)).fetchall()
    matches = conn.execute("""
        SELECT m.*,
            p1.username AS p1_username, p2.username AS p2_username,
            w.username AS winner_username
        FROM tournament_matches m
        LEFT JOIN users p1 ON p1.id=m.player1_id
        LEFT JOIN users p2 ON p2.id=m.player2_id
        LEFT JOIN users w ON w.id=m.winner_id
        WHERE m.tournament_id=? ORDER BY m.round, m.bracket_pos
    """, (tournament_id,)).fetchall()
    is_player = conn.execute(
        "SELECT 1 FROM tournament_players WHERE tournament_id=? AND user_id=?",
        (tournament_id, user["id"])
    ).fetchone() is not None

    # Razbivayem matches po round'am
    rounds = {}
    for m in matches:
        rounds.setdefault(m["round"], []).append(dict(m))

    # Tekushiy match polzovatelya
    my_match = None
    if is_player and t["status"] == "running":
        my_match = conn.execute("""
            SELECT * FROM tournament_matches
            WHERE tournament_id=? AND (player1_id=? OR player2_id=?) AND status='pending'
            ORDER BY round LIMIT 1
        """, (tournament_id, user["id"], user["id"])).fetchone()
        if my_match:
            my_match = dict(my_match)

    conn.close()
    return render_template("tournament_view.html",
        tournament=dict(t), players=players, rounds=rounds, is_player=is_player,
        my_match=my_match, current_uid=user["id"])


@app.route("/tournament/<int:tournament_id>/join", methods=["POST"])
@login_required
def tournament_join(tournament_id):
    user = current_user()
    conn = db.get_conn()
    t = conn.execute("SELECT * FROM tournaments WHERE id=?", (tournament_id,)).fetchone()
    if not t or t["status"] != "open":
        conn.close()
        flash("Регистрация закрыта", "error")
        return redirect(url_for("tournaments_list"))
    cnt = conn.execute(
        "SELECT COUNT(*) AS c FROM tournament_players WHERE tournament_id=?",
        (tournament_id,)
    ).fetchone()["c"]
    if cnt >= t["size"]:
        conn.close()
        flash("Турнир заполнен", "error")
        return redirect(url_for("tournament_view", tournament_id=tournament_id))
    conn.execute("INSERT OR IGNORE INTO tournament_players (tournament_id, user_id, slot) VALUES (?, ?, ?)",
                 (tournament_id, user["id"], cnt))
    # Esli zapolnen — avto-start
    if cnt + 1 >= t["size"]:
        players = conn.execute("""
            SELECT user_id FROM tournament_players WHERE tournament_id=? ORDER BY slot
        """, (tournament_id,)).fetchall()
        _tournament_create_first_round(conn, tournament_id, [p["user_id"] for p in players])
        conn.execute("UPDATE tournaments SET status='running' WHERE id=?", (tournament_id,))
    conn.commit(); conn.close()
    return redirect(url_for("tournament_view", tournament_id=tournament_id))


@app.route("/tournament/match/<int:match_id>/start", methods=["POST"])
@login_required
def tournament_match_start(match_id):
    """Igrok startuet match — sozdayem duel'."""
    user = current_user()
    conn = db.get_conn()
    m = conn.execute("SELECT * FROM tournament_matches WHERE id=?", (match_id,)).fetchone()
    if not m or m["status"] != "pending":
        conn.close(); abort(404)
    if user["id"] not in (m["player1_id"], m["player2_id"]):
        conn.close(); abort(403)
    # Esli duel' uzhe est' — perehodim
    if m["duel_id"]:
        conn.close()
        return redirect(url_for("duel_view", duel_id=m["duel_id"]))
    # Esli odin igrok (bye) — avto-pobeda
    if not m["player2_id"]:
        conn.execute("UPDATE tournament_matches SET status='finished', winner_id=? WHERE id=?",
                     (m["player1_id"], match_id))
        _tournament_advance(conn, m["tournament_id"])
        conn.commit(); conn.close()
        return redirect(url_for("tournament_view", tournament_id=m["tournament_id"]))
    # Sozdayem duel'
    t = conn.execute("SELECT * FROM tournaments WHERE id=?", (m["tournament_id"],)).fetchone()
    cards = conn.execute("SELECT id FROM cards WHERE deck_id=? ORDER BY RANDOM() LIMIT 5",
                         (t["deck_id"],)).fetchall()
    cur = conn.execute("""INSERT INTO duels (player1_id, player2_id, deck_id, question_count, status, question_started_at)
                          VALUES (?, ?, ?, ?, 'running', ?)""",
                       (m["player1_id"], m["player2_id"], t["deck_id"], len(cards),
                        datetime.utcnow().isoformat()))
    duel_id = cur.lastrowid
    for i, c in enumerate(cards):
        conn.execute("INSERT INTO duel_cards (duel_id, position, card_id) VALUES (?, ?, ?)",
                     (duel_id, i, c["id"]))
    conn.execute("UPDATE tournament_matches SET duel_id=?, status='running' WHERE id=?",
                 (duel_id, match_id))
    conn.commit(); conn.close()
    return redirect(url_for("duel_view", duel_id=duel_id))


# Hook v duel finish — pomechaem match
@app.route("/api/tournament/match/<int:match_id>/check")
@login_required
def tournament_match_check(match_id):
    """Polling: proverit zaverishilsa li duel' i obnovit' match."""
    conn = db.get_conn()
    m = conn.execute("SELECT * FROM tournament_matches WHERE id=?", (match_id,)).fetchone()
    if not m:
        conn.close(); abort(404)
    if m["duel_id"] and m["status"] == "running":
        d = conn.execute("SELECT * FROM duels WHERE id=?", (m["duel_id"],)).fetchone()
        if d and d["status"] == "finished":
            winner = d["winner_id"]
            if not winner:
                # Nichya — slu chayno odin pobedil (sluchayno)
                import random
                winner = random.choice([m["player1_id"], m["player2_id"]])
            conn.execute("UPDATE tournament_matches SET status='finished', winner_id=? WHERE id=?",
                         (winner, match_id))
            loser = m["player2_id"] if winner == m["player1_id"] else m["player1_id"]
            conn.execute("UPDATE tournament_players SET eliminated_at=? WHERE tournament_id=? AND user_id=?",
                         (datetime.utcnow().isoformat(), m["tournament_id"], loser))
            _tournament_advance(conn, m["tournament_id"])
            conn.commit()
    conn.close()
    return jsonify({"ok": True})


# === END TOURNAMENTS ===


# ====================================================================
# STUDY GROUPS — sovmestnoye izucheniye
# ====================================================================

@app.route("/study-groups")
@login_required
def study_groups_list():
    user = current_user()
    conn = db.get_conn()
    public_groups = conn.execute("""
        SELECT g.*, u.username AS owner_username,
            (SELECT COUNT(*) FROM study_group_members WHERE group_id=g.id) AS members_count,
            (SELECT COUNT(*) FROM study_group_decks WHERE group_id=g.id) AS decks_count
        FROM study_groups g JOIN users u ON u.id=g.owner_id
        WHERE g.is_public=1
        ORDER BY members_count DESC LIMIT 50
    """).fetchall()
    my_groups = conn.execute("""
        SELECT g.*, u.username AS owner_username,
            (SELECT COUNT(*) FROM study_group_members WHERE group_id=g.id) AS members_count,
            (SELECT COUNT(*) FROM study_group_decks WHERE group_id=g.id) AS decks_count
        FROM study_groups g JOIN users u ON u.id=g.owner_id
        WHERE g.id IN (SELECT group_id FROM study_group_members WHERE user_id=?)
        ORDER BY g.created_at DESC
    """, (user["id"],)).fetchall()
    conn.close()
    return render_template("study_groups_list.html",
        public_groups=public_groups, my_groups=my_groups)


@app.route("/study-group/new", methods=["POST"])
@login_required
def study_group_new():
    user = current_user()
    name = request.form.get("name", "").strip()[:60]
    description = request.form.get("description", "").strip()[:300]
    avatar = request.form.get("avatar", "🎓").strip()[:2] or "🎓"
    is_public = 1 if request.form.get("is_public") else 0
    if not name:
        flash("Введите название", "error")
        return redirect(url_for("study_groups_list"))
    conn = db.get_conn()
    # Sozdayem chat dlya gruppy
    cur = conn.execute("INSERT INTO chats (type, name, owner_id, avatar) VALUES ('group', ?, ?, ?)",
                       (name, user["id"], avatar))
    chat_id = cur.lastrowid
    conn.execute("INSERT INTO chat_members (chat_id, user_id, role) VALUES (?, ?, 'owner')",
                 (chat_id, user["id"]))
    # Sozdayem study group
    cur = conn.execute("""INSERT INTO study_groups (name, owner_id, description, avatar, is_public, chat_id)
                          VALUES (?, ?, ?, ?, ?, ?)""",
                       (name, user["id"], description, avatar, is_public, chat_id))
    g_id = cur.lastrowid
    conn.execute("INSERT INTO study_group_members (group_id, user_id, role) VALUES (?, ?, 'owner')",
                 (g_id, user["id"]))
    conn.commit(); conn.close()
    return redirect(url_for("study_group_view", group_id=g_id))


@app.route("/study-group/<int:group_id>")
@login_required
def study_group_view(group_id):
    user = current_user()
    conn = db.get_conn()
    group = conn.execute("""
        SELECT g.*, u.username AS owner_username
        FROM study_groups g JOIN users u ON u.id=g.owner_id WHERE g.id=?
    """, (group_id,)).fetchone()
    if not group:
        conn.close(); abort(404)
    is_member = conn.execute(
        "SELECT 1 FROM study_group_members WHERE group_id=? AND user_id=?",
        (group_id, user["id"])
    ).fetchone() is not None
    if not is_member and not group["is_public"]:
        conn.close(); abort(403)

    members = conn.execute("""
        SELECT u.id, u.username, u.full_name, u.avatar_color, u.xp, u.streak,
            sgm.role, sgm.joined_at,
            (SELECT COUNT(*) FROM reviews r
             JOIN cards c ON c.id=r.card_id
             JOIN study_group_decks sgd ON sgd.deck_id=c.deck_id
             WHERE sgd.group_id=? AND r.user_id=u.id) AS group_reviews,
            (SELECT COUNT(*) FROM reviews r
             JOIN cards c ON c.id=r.card_id
             JOIN study_group_decks sgd ON sgd.deck_id=c.deck_id
             WHERE sgd.group_id=? AND r.user_id=u.id AND r.grade>=3) AS group_correct
        FROM study_group_members sgm JOIN users u ON u.id=sgm.user_id
        WHERE sgm.group_id=?
        ORDER BY sgm.role='owner' DESC, group_reviews DESC
    """, (group_id, group_id, group_id)).fetchall()

    group_decks = conn.execute("""
        SELECT d.id, d.name, d.icon,
            (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt,
            au.username AS added_by_username, sgd.added_at
        FROM study_group_decks sgd
        JOIN decks d ON d.id=sgd.deck_id
        LEFT JOIN users au ON au.id=sgd.added_by
        WHERE sgd.group_id=?
        ORDER BY sgd.added_at DESC
    """, (group_id,)).fetchall()

    # Kolody dlya dobavleniya — moi + publichnyye
    available_decks = []
    if is_member:
        added_ids = [d["id"] for d in group_decks]
        if user["org_id"]:
            avail = conn.execute("""
                SELECT id, name, icon FROM decks WHERE org_id=?
                ORDER BY created_at DESC
            """, (user["org_id"],)).fetchall()
        else:
            avail = conn.execute("""
                SELECT id, name, icon FROM decks WHERE owner_id=?
                ORDER BY created_at DESC
            """, (user["id"],)).fetchall()
        available_decks = [dict(d) for d in avail if d["id"] not in added_ids]

    # Statistika gruppy: lider'-bord po reviews
    total_reviews = sum(m["group_reviews"] for m in members)
    total_correct = sum(m["group_correct"] for m in members)
    accuracy = round(total_correct / total_reviews * 100) if total_reviews else 0

    conn.close()
    return render_template("study_group_view.html",
        group=dict(group), members=members, group_decks=group_decks,
        is_member=is_member, available_decks=available_decks,
        total_reviews=total_reviews, accuracy=accuracy)


@app.route("/study-group/<int:group_id>/join", methods=["POST"])
@login_required
def study_group_join(group_id):
    user = current_user()
    conn = db.get_conn()
    group = conn.execute("SELECT * FROM study_groups WHERE id=?", (group_id,)).fetchone()
    if not group or not group["is_public"]:
        conn.close(); abort(404)
    conn.execute("INSERT OR IGNORE INTO study_group_members (group_id, user_id) VALUES (?, ?)",
                 (group_id, user["id"]))
    if group["chat_id"]:
        conn.execute("INSERT OR IGNORE INTO chat_members (chat_id, user_id, role) VALUES (?, ?, 'member')",
                     (group["chat_id"], user["id"]))
    conn.commit(); conn.close()
    return redirect(url_for("study_group_view", group_id=group_id))


@app.route("/study-group/<int:group_id>/leave", methods=["POST"])
@login_required
def study_group_leave(group_id):
    user = current_user()
    conn = db.get_conn()
    group = conn.execute("SELECT * FROM study_groups WHERE id=?", (group_id,)).fetchone()
    if not group:
        conn.close(); abort(404)
    if group["owner_id"] == user["id"]:
        conn.execute("DELETE FROM study_groups WHERE id=?", (group_id,))
    else:
        conn.execute("DELETE FROM study_group_members WHERE group_id=? AND user_id=?",
                     (group_id, user["id"]))
        if group["chat_id"]:
            conn.execute("DELETE FROM chat_members WHERE chat_id=? AND user_id=?",
                         (group["chat_id"], user["id"]))
    conn.commit(); conn.close()
    return redirect(url_for("study_groups_list"))


@app.route("/study-group/<int:group_id>/add-deck", methods=["POST"])
@login_required
def study_group_add_deck(group_id):
    user = current_user()
    deck_id = request.form.get("deck_id", type=int)
    conn = db.get_conn()
    is_member = conn.execute(
        "SELECT 1 FROM study_group_members WHERE group_id=? AND user_id=?",
        (group_id, user["id"])
    ).fetchone()
    if not is_member or not deck_id:
        conn.close(); abort(403)
    # Mozhno dobavlyat' tol'ko svoyu kolodu
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(403)
    conn.execute("""INSERT OR IGNORE INTO study_group_decks (group_id, deck_id, added_by)
                   VALUES (?, ?, ?)""", (group_id, deck_id, user["id"]))
    conn.commit(); conn.close()
    return redirect(url_for("study_group_view", group_id=group_id))


@app.route("/study-group/<int:group_id>/remove-deck/<int:deck_id>", methods=["POST"])
@login_required
def study_group_remove_deck(group_id, deck_id):
    user = current_user()
    conn = db.get_conn()
    group = conn.execute("SELECT * FROM study_groups WHERE id=?", (group_id,)).fetchone()
    if not group:
        conn.close(); abort(404)
    sgd = conn.execute(
        "SELECT * FROM study_group_decks WHERE group_id=? AND deck_id=?",
        (group_id, deck_id)
    ).fetchone()
    if not sgd:
        conn.close(); abort(404)
    # Tol'ko vladelets gruppy ili tot kto dobavil mozhet ubrat'
    if group["owner_id"] != user["id"] and sgd["added_by"] != user["id"]:
        conn.close(); abort(403)
    conn.execute("DELETE FROM study_group_decks WHERE group_id=? AND deck_id=?",
                 (group_id, deck_id))
    conn.commit(); conn.close()
    return redirect(url_for("study_group_view", group_id=group_id))


# === END STUDY GROUPS ===


@app.route("/marketplace/clone/<int:deck_id>", methods=["POST"])
@login_required
def marketplace_clone(deck_id):
    """Lyuboy zaregistrirovannyy mozhet sklonirovat' publichnyy kolod."""
    user = current_user()
    if not can_manage_content(user):
        abort(403)
    conn = db.get_conn()
    src = conn.execute("SELECT * FROM decks WHERE id=? AND is_public=1", (deck_id,)).fetchone()
    if not src:
        conn.close()
        flash("Колода не найдена или не публичная", "error")
        return redirect(url_for("marketplace"))

    new_name = src["name"]
    if user["org_id"]:
        cur = conn.execute("""INSERT INTO decks (org_id, name, icon, description)
                              VALUES (?, ?, ?, ?)""",
                          (user["org_id"], new_name, src["icon"], src["description"]))
    else:
        cur = conn.execute("""INSERT INTO decks (owner_id, name, icon, description)
                              VALUES (?, ?, ?, ?)""",
                          (user["id"], new_name, src["icon"], src["description"]))
    new_deck_id = cur.lastrowid

    cards = conn.execute("SELECT front, back, note, image_url FROM cards WHERE deck_id=?",
                         (deck_id,)).fetchall()
    for c in cards:
        conn.execute("""INSERT INTO cards (deck_id, front, back, note, image_url)
                       VALUES (?, ?, ?, ?, ?)""",
                     (new_deck_id, c["front"], c["back"], c["note"], c["image_url"] or ""))

    # Schetchik klonirovaniyа
    conn.execute("UPDATE decks SET clones_count = clones_count + 1 WHERE id=?", (deck_id,))
    # Uvedomim avtora
    if src["owner_id"] and src["owner_id"] != user["id"]:
        _notify(conn, src["owner_id"], "deck_clone",
                f"@{user['username']} скопировал вашу колоду «{src['name']}»",
                f"/u/{user['username']}")
    conn.commit(); conn.close()
    flash(f"Колода скопирована в вашу библиотеку", "success")
    return redirect(url_for("deck_view", deck_id=new_deck_id))


@app.route("/tutor")
@login_required
def tutor_page():
    """AI-tutor chat — student spravlivaet AI o lyubom voprose."""
    user = current_user()

    # Avtomaticheski vosstanavlivaem poslednyuyu besedu iz DB esli sessiya pustaya
    if not session.get("tutor_conv_id"):
        try:
            conn = db.get_conn()
            last_conv = conn.execute(
                "SELECT id FROM tutor_conversations WHERE user_id=? ORDER BY updated_at DESC LIMIT 1",
                (user["id"],)
            ).fetchone()
            if last_conv:
                conv_id = last_conv["id"]
                msgs = conn.execute(
                    "SELECT role, content FROM tutor_messages WHERE conversation_id=? ORDER BY created_at ASC",
                    (conv_id,)
                ).fetchall()
                conn.close()
                session["tutor_conv_id"] = conv_id
                session["tutor_history"] = [{"role": m["role"], "content": m["content"]} for m in msgs][-40:]
            else:
                conn.close()
        except Exception as e:
            print(f"[tutor_page] restore session error: {e}")

    return render_template(
        "tutor.html",
        is_super_admin=is_super_admin(user),
        deepseek_available=ai_gen.is_deepseek_available(),
    )


@app.route("/api/tutor/guest-ask", methods=["POST"])
def api_tutor_guest_ask():
    """AI-tutor dlya gostey na landing page — bez autentifikatsii, ogranicheno."""
    if not (ai_gen.is_available() or ai_gen.is_deepseek_available()):
        return jsonify({"error": "ai_unavailable"}), 503

    message = request.form.get("message", "").strip()[:500]
    if not message:
        return jsonify({"error": "empty"}), 400

    # Rate limit po IP — 5 zaprosov v minutu
    ip = request.remote_addr or "unknown"
    if not rate_limit(f"tutor_guest:{ip}", max_attempts=5, window_seconds=60):
        return jsonify({"error": "rate_limit", "msg": "Слишком много запросов. Зарегистрируйтесь для полного доступа."}), 429

    lang = session.get("lang", "ru")

    from flask import Response
    def _stream():
        try:
            for chunk in ai_gen.chat_tutor_stream(
                message,
                deck_context="",
                history=[],
                lang=lang,
                provider="",
            ):
                yield chunk
        except Exception as e:
            print(f"[guest-ask] {e}")
            yield "\n\n[Зарегистрируйтесь для полного доступа к AI репетитору]"

    return Response(_stream(), mimetype="text/plain; charset=utf-8")


@app.route("/api/tutor/ask", methods=["POST"])
@login_required
def api_tutor_ask():
    """AI-tutor otvechayet na vopros polzovatelya.

    Istoriya vsegda gruzitsya iz DB (ne iz sessii) — nadezhno pri lyubom razmere.
    """
    # Hotya by odin provider dolzhen byt' nastroen (DeepSeek ili Gemini)
    if not (ai_gen.is_available() or ai_gen.is_deepseek_available()):
        return jsonify({"error": "ai_unavailable", "msg": "AI не настроен"}), 503
    user = current_user()
    message = request.form.get("message", "").strip()[:1000]
    if not message:
        return jsonify({"error": "empty"}), 400

    # Rate limit
    if not rate_limit(f"tutor:{user['id']}", max_attempts=15, window_seconds=60):
        return jsonify({"error": "rate_limit", "msg": "Слишком много запросов. Подождите минуту."}), 429

    lang = session.get("lang", "ru")
    want_stream = request.form.get("stream") == "1"
    provider_override = (request.form.get("provider") or "").strip().lower()
    if provider_override not in ("deepseek", "gemini"):
        provider_override = ""
    if provider_override and not is_super_admin(user):
        provider_override = ""

    # Poluchaem ili sozdaem chat v DB
    conv_id = _tutor_get_or_create_conv(user["id"], message)

    # Kontekst kolody
    deck_context = ""
    deck_id = request.form.get("deck_id", type=int)
    if deck_id:
        conn = db.get_conn()
        deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
        if deck is not None and can_view_deck(user, deck):
            cards = conn.execute("SELECT front, back FROM cards WHERE deck_id=? LIMIT 20", (deck_id,)).fetchall()
            if cards:
                deck_context = "\n".join([f"- {c['front']} → {c['back']}" for c in cards])
        conn.close()

    # VSEGDA gruzim istoriyu iz DB — nadezhno, ne zavisit ot razmera cookie
    conn = db.get_conn()
    db_msgs = conn.execute(
        "SELECT role, content FROM tutor_messages WHERE conversation_id=? ORDER BY created_at ASC",
        (conv_id,)
    ).fetchall()
    # Learner model (RAG): the user's weakest cards, for personalisation.
    learner_context = db.tutor_learner_context(conn, user["id"])
    conn.close()
    history = [{"role": m["role"], "content": m["content"]} for m in db_msgs]

    # Sohranim user-soobshchenie v DB
    _tutor_save_message(conv_id, user["id"], "user", message)

    if want_stream:
        # Stream: yield chunks po mere generatsii (DeepSeek native, Gemini fallback)
        from flask import Response

        # Header reflects the provider that actually answers. DeepSeek only runs
        # when it's enabled; while it's off everything is gemini-3.5-flash, so a
        # stale provider="deepseek" preference must not mislabel a Gemini reply.
        used_provider = "gemini"
        if provider_override != "gemini" and ai_gen.is_deepseek_available():
            used_provider = "deepseek"

        # Poluchaem ili sozdaem chat v DB
        conv_id = _tutor_get_or_create_conv(user["id"], message)
        _tutor_save_message(conv_id, user["id"], "user", message)

        def _web_tool_executor(name, args):
            """DB-backed agentic-tutor tools (create_deck / open_deck) for web."""
            c2 = db.get_conn()
            try:
                if name == "create_deck":
                    topic = (args.get("topic") or "").strip()
                    if not topic:
                        return None
                    deck_name = (str(args.get("name") or topic).strip() or topic)[:120]
                    try:
                        cnt = max(5, min(20, int(args.get("count") or 10)))
                    except (TypeError, ValueError):
                        cnt = 10
                    cards = ai_gen.generate_from_topic(topic, count=cnt, output_lang=lang)
                    if not cards:
                        return None
                    if user.get("org_id"):
                        cur2 = c2.execute(
                            "INSERT INTO decks (org_id, name, icon, created_via) VALUES (?, ?, ?, 'tutor_ai')",
                            (user["org_id"], deck_name, "🤖"))
                    else:
                        cur2 = c2.execute(
                            "INSERT INTO decks (owner_id, name, icon, created_via) VALUES (?, ?, ?, 'tutor_ai')",
                            (user["id"], deck_name, "🤖"))
                    did = cur2.lastrowid
                    for cc in cards:
                        c2.execute("INSERT INTO cards (deck_id, front, back, note) VALUES (?, ?, ?, ?)",
                                   (did, cc["front"], cc["back"], cc.get("note", "")))
                    refresh_deck_content_flags(c2, did)
                    c2.commit()
                    return {
                        "ru": f"✅ Создал колоду «{deck_name}» — {len(cards)} карточек: [открыть](/deck/{did})",
                        "en": f"✅ Created the deck “{deck_name}” — {len(cards)} cards: [open](/deck/{did})",
                        "uz": f"✅ «{deck_name}» to'plamini yaratdim — {len(cards)} karta: [ochish](/deck/{did})",
                    }.get(lang, f"✅ Колода «{deck_name}» создана: /deck/{did}")
                if name == "open_deck":
                    q = (args.get("query") or "").strip()
                    if not q:
                        return None
                    row = c2.execute(
                        "SELECT id, name FROM decks WHERE owner_id=? AND name LIKE ? ORDER BY id DESC LIMIT 1",
                        (user["id"], f"%{q}%")).fetchone()
                    if not row:
                        return {
                            "ru": f"Не нашёл колоду по запросу «{q}».",
                            "en": f"Couldn't find a deck matching “{q}”.",
                            "uz": f"«{q}» bo'yicha to'plam topilmadi.",
                        }.get(lang, f"Не нашёл колоду «{q}».")
                    return {
                        "ru": f"Вот колода «{row['name']}»: [открыть](/deck/{row['id']})",
                        "en": f"Here's the deck “{row['name']}”: [open](/deck/{row['id']})",
                        "uz": f"«{row['name']}» to'plami: [ochish](/deck/{row['id']})",
                    }.get(lang, f"Колода «{row['name']}»: /deck/{row['id']}")
            finally:
                c2.close()
            return None

        def _stream():
            full = []
            try:
                for chunk in ai_gen.chat_tutor_stream(
                    message,
                    deck_context=deck_context,
                    history=history,
                    lang=lang,
                    provider=provider_override,
                    learner_context=learner_context,
                    tool_executor=_web_tool_executor,
                ):
                    full.append(chunk)
                    yield chunk
            except Exception as e:
                print(f"[/api/tutor/ask stream] {type(e).__name__}: {e}")
            # Posle zaversheniya — sokhranyaem tolko v DB (ne v sessiyu — cookie limit)
            answer_text = "".join(full).strip()
            if answer_text:
                _tutor_save_message(conv_id, user["id"], "assistant", answer_text)

        return Response(_stream(), mimetype="text/plain; charset=utf-8", headers={
            "X-AI-Provider": used_provider,
            "X-Conv-Id": str(conv_id),
        })

    # Non-stream (legacy)
    answer = ai_gen.chat_tutor(
        message,
        deck_context=deck_context,
        history=history,
        lang=lang,
        provider=provider_override,
        learner_context=learner_context,
    )
    if not answer:
        return jsonify({"error": "ai_failed", "msg": "AI не отвечает. Попробуйте позже."}), 500

    history.append({"role": "user", "content": message})
    history.append({"role": "assistant", "content": answer})
    session["tutor_history"] = history[-40:]
    return jsonify({"ok": True, "answer": answer})


@app.route("/api/tutor/clear", methods=["POST"])
@login_required
def api_tutor_clear():
    session.pop("tutor_history", None)
    session.pop("tutor_conv_id", None)
    return jsonify({"ok": True})


@app.route("/api/tutor/set-conv", methods=["POST"])
@login_required
def api_tutor_set_conv():
    """Sinhronizirovat sessiyu s otkrytym chatom."""
    user = current_user()
    conv_id = request.form.get("conv_id", type=int)
    if not conv_id:
        return jsonify({"error": "no_id"}), 400
    conn = db.get_conn()
    row = conn.execute(
        "SELECT id FROM tutor_conversations WHERE id=? AND user_id=?",
        (conv_id, user["id"])
    ).fetchone()
    conn.close()
    if not row:
        return jsonify({"error": "not_found"}), 404
    # Zagruzhaem istoriyu iz DB v sessiyu
    conn = db.get_conn()
    msgs = conn.execute(
        "SELECT role, content FROM tutor_messages WHERE conversation_id=? ORDER BY created_at ASC",
        (conv_id,)
    ).fetchall()
    conn.close()
    session["tutor_conv_id"] = conv_id
    session["tutor_history"] = [{"role": m["role"], "content": m["content"]} for m in msgs][-40:]
    return jsonify({"ok": True})


# ===================== TUTOR CHAT HISTORY =====================

@app.route("/api/tutor/conversations", methods=["GET"])
@login_required
def api_tutor_conversations():
    """Spisok vsekh tutor-chatov polzovatelya."""
    user = current_user()
    conn = db.get_conn()
    rows = conn.execute("""
        SELECT id, title, pinned, created_at, updated_at
        FROM tutor_conversations
        WHERE user_id = ?
        ORDER BY pinned DESC, updated_at DESC
        LIMIT 200
    """, (user["id"],)).fetchall()
    conn.close()
    return jsonify({"conversations": [dict(r) for r in rows]})


@app.route("/api/tutor/conversations", methods=["POST"])
@login_required
def api_tutor_conversations_create():
    """Sozdat novyy tutor-chat."""
    user = current_user()
    title = (request.json or {}).get("title", "Новый чат")[:80]
    conn = db.get_conn()
    cur = conn.execute(
        "INSERT INTO tutor_conversations (user_id, title) VALUES (?, ?)",
        (user["id"], title)
    )
    conv_id = cur.lastrowid
    conn.commit(); conn.close()
    return jsonify({"id": conv_id, "title": title})


@app.route("/api/tutor/conversations/<int:conv_id>", methods=["GET"])
@login_required
def api_tutor_conversation_get(conv_id):
    """Poluchit chat + vse soobshcheniya."""
    user = current_user()
    conn = db.get_conn()
    conv = conn.execute(
        "SELECT * FROM tutor_conversations WHERE id=? AND user_id=?",
        (conv_id, user["id"])
    ).fetchone()
    if not conv:
        conn.close(); return jsonify({"error": "not_found"}), 404
    msgs = conn.execute(
        "SELECT id, role, content, created_at FROM tutor_messages WHERE conversation_id=? ORDER BY created_at ASC",
        (conv_id,)
    ).fetchall()
    conn.close()
    return jsonify({"conversation": dict(conv), "messages": [dict(m) for m in msgs]})


@app.route("/api/tutor/conversations/<int:conv_id>", methods=["PATCH"])
@login_required
def api_tutor_conversation_patch(conv_id):
    """Pereimenovat / pin."""
    user = current_user()
    data = request.json or {}
    updates = []
    params = []
    if "title" in data:
        updates.append("title=?"); params.append(str(data["title"])[:80])
    if "pinned" in data:
        updates.append("pinned=?"); params.append(1 if data["pinned"] else 0)
    if not updates:
        return jsonify({"error": "nothing"}), 400
    params += [conv_id, user["id"]]
    conn = db.get_conn()
    conn.execute(f"UPDATE tutor_conversations SET {', '.join(updates)} WHERE id=? AND user_id=?", params)
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/api/tutor/conversations/<int:conv_id>", methods=["DELETE"])
@login_required
def api_tutor_conversation_delete(conv_id):
    """Udalit chat."""
    user = current_user()
    conn = db.get_conn()
    conn.execute("DELETE FROM tutor_conversations WHERE id=? AND user_id=?", (conv_id, user["id"]))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


def _tutor_save_message(conv_id: int, user_id: int, role: str, content: str):
    """Sohranit soobshchenie i obnovit updated_at chata."""
    conn = db.get_conn()
    conn.execute(
        "INSERT INTO tutor_messages (conversation_id, user_id, role, content) VALUES (?,?,?,?)",
        (conv_id, user_id, role, content)
    )
    conn.execute(
        "UPDATE tutor_conversations SET updated_at=CURRENT_TIMESTAMP WHERE id=?",
        (conv_id,)
    )
    conn.commit(); conn.close()


def _tutor_get_or_create_conv(user_id: int, first_message: str) -> int:
    """Vozvrashchaet ID tekushchego chata iz sessii ili sozdaet novyy."""
    conv_id = session.get("tutor_conv_id")
    if conv_id:
        # Proverka chto chat prinadlezit polzovatelyu
        conn = db.get_conn()
        row = conn.execute(
            "SELECT id FROM tutor_conversations WHERE id=? AND user_id=?",
            (conv_id, user_id)
        ).fetchone()
        if row:
            # Esli istoriya v sessii pustaya — podgruzim iz DB
            if not session.get("tutor_history"):
                msgs = conn.execute(
                    "SELECT role, content FROM tutor_messages WHERE conversation_id=? ORDER BY created_at ASC",
                    (conv_id,)
                ).fetchall()
                session["tutor_history"] = [{"role": m["role"], "content": m["content"]} for m in msgs][-40:]
            conn.close()
            return conv_id
        conn.close()
    # Sozdaem novyy chat
    title = first_message.strip()[:60] or "Новый чат"
    conn = db.get_conn()
    cur = conn.execute(
        "INSERT INTO tutor_conversations (user_id, title) VALUES (?,?)",
        (user_id, title)
    )
    conv_id = cur.lastrowid
    conn.commit(); conn.close()
    session["tutor_conv_id"] = conv_id
    return conv_id


@app.route("/api/explain-card", methods=["POST"])
@login_required
def api_explain_card():
    """AI ob'yasnyayet vopros i otvet."""
    if not ai_gen.is_available():
        return jsonify({"error": "ai_unavailable"}), 503
    user = current_user()
    card_id = request.form.get("card_id", type=int)
    if not card_id:
        return jsonify({"error": "no_card"}), 400
    conn = db.get_conn()
    card = conn.execute("""SELECT c.*, d.org_id, d.owner_id FROM cards c
                          JOIN decks d ON d.id=c.deck_id WHERE c.id=?""", (card_id,)).fetchone()
    if not card or not can_view_deck(user, {"org_id": card["org_id"], "owner_id": card["owner_id"]}):
        conn.close()
        return jsonify({"error": "forbidden"}), 403
    conn.close()
    # Rate limit: 10 ob'yasneniy v minutu na user
    if not rate_limit(f"explain:{user['id']}", max_attempts=10, window_seconds=60):
        return jsonify({"error": "rate_limit", "msg": "Слишком много запросов. Подождите минуту."}), 429
    explanation = ai_gen.explain_question(card["front"], card["back"], session.get("lang", "ru"))
    if not explanation:
        return jsonify({"error": "ai_failed"}), 500
    return jsonify({"ok": True, "explanation": explanation})


@app.route("/api/diagnose-answer", methods=["POST"])
@login_required
def api_diagnose_answer():
    """AI-diagnostika konkretnoy oshibki v testе.

    Beryom sokhranennyy otvet popytki (test_attempt_answers), vosstanavlivaem
    TEKST vybrannogo studentom varianta i pravil'nogo varianta i prosim AI
    ob'yasnit' imenno EGO oshibku (a ne prosto pereskazat' otvet)."""
    if not ai_gen.is_available():
        return jsonify({"error": "ai_unavailable"}), 503
    user = current_user()
    answer_id = request.form.get("answer_id", type=int)
    if not answer_id:
        return jsonify({"error": "no_answer"}), 400
    conn = db.get_conn()
    row = conn.execute("""
        SELECT aa.* FROM test_attempt_answers aa
        JOIN test_attempts ta ON ta.id = aa.attempt_id
        WHERE aa.id=? AND ta.user_id=?
    """, (answer_id, user["id"])).fetchone()
    conn.close()
    if not row:
        return jsonify({"error": "forbidden"}), 403
    if row["is_correct"] == 1:
        return jsonify({"error": "not_wrong"}), 400
    # Rate limit: 10 razborov v minutu na user
    if not rate_limit(f"diagnose:{user['id']}", max_attempts=10, window_seconds=60):
        return jsonify({"error": "rate_limit", "msg": "Слишком много запросов. Подождите минуту."}), 429

    ad = dict(row)
    # Vosstanavlivaem tekst variantov (kak v test_attempt_detail)
    _opt_re = re.compile(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]?\s+(.+)$")
    opts = {}
    source = (ad.get("note") or "").strip() or (ad.get("back") or "")
    for line in source.split("\n"):
        m = _opt_re.match(line.strip())
        if m:
            opts[m.group(1).upper()] = m.group(2).strip()
    chosen_letter = (ad.get("chosen") or "").strip().upper()
    correct_letter = (ad.get("correct") or "").strip().upper()
    chosen_text = opts.get(chosen_letter) or ad.get("chosen") or ""
    correct_text = opts.get(correct_letter) or ad.get("correct") or ad.get("back") or ""

    diagnosis = ai_gen.diagnose_mistake(
        ad.get("front", ""), chosen_text, correct_text, session.get("lang", "ru"))
    if not diagnosis or not diagnosis.get("why_wrong"):
        return jsonify({"error": "ai_failed"}), 500
    return jsonify({"ok": True, "diagnosis": diagnosis})


@app.route("/api/followup-question", methods=["POST"])
@login_required
def api_followup_question():
    """Generiruet novyy trenirovochnyy vopros na temu oshibki — chtoby srazu
    zakrepit' ponimanie posle razbora (cikl 'oshibsya → ponyal → zakrepil')."""
    if not ai_gen.is_available():
        return jsonify({"error": "ai_unavailable"}), 503
    user = current_user()
    answer_id = request.form.get("answer_id", type=int)
    if not answer_id:
        return jsonify({"error": "no_answer"}), 400
    misconception = (request.form.get("misconception") or "").strip()[:300]
    conn = db.get_conn()
    row = conn.execute("""
        SELECT aa.* FROM test_attempt_answers aa
        JOIN test_attempts ta ON ta.id = aa.attempt_id
        WHERE aa.id=? AND ta.user_id=?
    """, (answer_id, user["id"])).fetchone()
    conn.close()
    if not row:
        return jsonify({"error": "forbidden"}), 403
    if not rate_limit(f"followup:{user['id']}", max_attempts=10, window_seconds=60):
        return jsonify({"error": "rate_limit", "msg": "Слишком много запросов. Подождите минуту."}), 429

    ad = dict(row)
    _opt_re = re.compile(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]?\s+(.+)$")
    opts = {}
    source = (ad.get("note") or "").strip() or (ad.get("back") or "")
    for line in source.split("\n"):
        m = _opt_re.match(line.strip())
        if m:
            opts[m.group(1).upper()] = m.group(2).strip()
    correct_letter = (ad.get("correct") or "").strip().upper()
    correct_text = opts.get(correct_letter) or ad.get("correct") or ad.get("back") or ""

    fu = ai_gen.generate_followup(
        ad.get("front", ""), correct_text, misconception, session.get("lang", "ru"))
    if not fu:
        return jsonify({"error": "ai_failed"}), 500
    # Prevrashchaem v bukvy (A/B/C...) dlya UI
    letters = ["A", "B", "C", "D", "E", "F"]
    options = [{"letter": letters[i], "text": t} for i, t in enumerate(fu["options"])]
    return jsonify({"ok": True, "followup": {
        "question": fu["question"],
        "options": options,
        "correct_letter": letters[fu["correct_index"]],
        "explanation": fu["explanation"],
    }})


@app.route("/api/daily-goal", methods=["POST"])
@login_required
def api_daily_goal():
    """Polzovatel' menyaet svoyu dnevnuyu tsel'."""
    user = current_user()
    goal = request.form.get("goal", type=int)
    if not goal or goal < 1 or goal > 500:
        return jsonify({"error": "bad_value"}), 400
    conn = db.get_conn()
    conn.execute("UPDATE users SET daily_goal=? WHERE id=?", (goal, user["id"]))
    conn.commit(); conn.close()
    return jsonify({"ok": True, "goal": goal})


# ====================================================================
# LIVE TEST — real-time gruppovoy test (uchitel' khostit, studenty igrayut)
# ====================================================================

import string


def _gen_live_code():
    """6-znachnyy code: 4 bukvy + 2 tsifry, izbegaem putanitsy 0/O, 1/I."""
    chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    return "".join(secrets.choice(chars) for _ in range(6))


def _parse_card_options(card_dict, shuffle_seed=None):
    """Razbirayem note/back na varianty A/B/C... + nakhodim pravil'nyy.
    Esli shuffle_seed zadan — meshaem varianty i pereprisvayivayem bukvy."""
    options = []
    src = card_dict.get("note") or card_dict.get("back") or ""
    for line in src.splitlines():
        line = line.strip()
        if not line: continue
        m = re.match(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]\s*(.+)$", line)
        if m:
            options.append({"letter": m.group(1).upper(), "text": m.group(2).strip()})
    correct_letter = None
    back_first = (card_dict.get("back") or "").strip().split("\n")[0]
    m_corr = re.match(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]", back_first)
    if m_corr:
        correct_letter = m_corr.group(1).upper()

    # Esli est' seed — meshaem
    if shuffle_seed is not None and options:
        correct_text = None
        if correct_letter:
            for o in options:
                if o["letter"] == correct_letter:
                    correct_text = o["text"]; break
        import random as _r
        rnd = _r.Random((shuffle_seed << 8) ^ (card_dict.get("id") or 0))
        rnd.shuffle(options)
        new_letters = ["A", "B", "C", "D", "E", "F", "G", "H"]
        for i, o in enumerate(options):
            o["letter"] = new_letters[i] if i < len(new_letters) else str(i + 1)
        if correct_text is not None:
            for o in options:
                if o["text"] == correct_text:
                    correct_letter = o["letter"]; break

    return options, correct_letter


@app.route("/deck/<int:deck_id>/live/start", methods=["POST"])
@login_required
def live_start(deck_id):
    """Uchitel' sozdayet zhivuyu sessiyu."""
    user = current_user()
    if not can_manage_content(user):
        abort(403)
    count = max(3, min(int(request.form.get("count", 10)), 50))
    time_per_q = max(10, min(int(request.form.get("time_per_q", 20)), 120))

    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)
    cards_raw = conn.execute(
        "SELECT id FROM cards WHERE deck_id=? ORDER BY RANDOM() LIMIT ?",
        (deck_id, count)
    ).fetchall()
    if len(cards_raw) < 3:
        conn.close()
        flash("Нужно минимум 3 карты в колоде", "error")
        return redirect(url_for("deck_view", deck_id=deck_id))

    # Generiruyem unikal'nyy kod
    for _ in range(20):
        code = _gen_live_code()
        if not conn.execute("SELECT id FROM live_sessions WHERE code=? AND status!='finished'",
                            (code,)).fetchone():
            break

    cur = conn.execute(
        "INSERT INTO live_sessions (code, deck_id, host_id, question_count, time_per_q, shuffle_seed) VALUES (?,?,?,?,?,?)",
        (code, deck_id, user["id"], len(cards_raw), time_per_q, secrets.randbelow(10**9)+1)
    )
    sess_id = cur.lastrowid
    for pos, c in enumerate(cards_raw):
        conn.execute("INSERT INTO live_session_cards (session_id, position, card_id) VALUES (?,?,?)",
                     (sess_id, pos, c["id"]))
    conn.commit(); conn.close()
    return redirect(url_for("live_host", code=code))


@app.route("/live/create", methods=["GET", "POST"])
@login_required
def live_create():
    """Stranitsa sozdaniya live testa cherez menyu (vmesto knopki v deck)."""
    user = current_user()
    if not can_manage_content(user):
        abort(403)
    conn = db.get_conn()
    if request.method == "POST":
        mode = request.form.get("mode", "deck")  # deck / category
        deck_id = request.form.get("deck_id", type=int)
        category_id = request.form.get("category_id", type=int)
        count = max(3, min(int(request.form.get("count", 10)), 50))
        time_per_q = max(10, min(int(request.form.get("time_per_q", 20)), 120))
        host_role = request.form.get("host_role", "observer")
        if host_role not in ("observer", "participant"):
            host_role = "observer"

        # Pulim karty
        if mode == "category" and category_id:
            cat = conn.execute("SELECT * FROM categories WHERE id=?", (category_id,)).fetchone()
            if not cat:
                conn.close()
                flash("Категория не найдена", "error")
                return redirect(url_for("live_create"))
            card_ids, decks = _category_card_pool(conn, user, category_id, limit=count)
            if len(card_ids) < 3:
                conn.close()
                flash(f"В категории «{cat['name']}» меньше 3 карт", "error")
                return redirect(url_for("live_create"))
            deck_id = decks[0]["id"]  # predstavitel'nyy
            cards_ids_for_session = card_ids
        else:
            deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
            if not deck or not can_view_deck(user, dict(deck)):
                conn.close()
                flash("Колода не найдена", "error")
                return redirect(url_for("live_create"))
            cards_raw = conn.execute(
                "SELECT id FROM cards WHERE deck_id=? ORDER BY RANDOM() LIMIT ?",
                (deck_id, count)
            ).fetchall()
            if len(cards_raw) < 3:
                conn.close()
                flash("В колоде нужно минимум 3 карты", "error")
                return redirect(url_for("live_create"))
            cards_ids_for_session = [c["id"] for c in cards_raw]

        for _ in range(20):
            code = _gen_live_code()
            if not conn.execute("SELECT id FROM live_sessions WHERE code=? AND status!='finished'",
                                (code,)).fetchone():
                break

        cur = conn.execute(
            """INSERT INTO live_sessions (code, deck_id, host_id, host_role, question_count, time_per_q, shuffle_seed)
               VALUES (?,?,?,?,?,?,?)""",
            (code, deck_id, user["id"], host_role, len(cards_ids_for_session), time_per_q, secrets.randbelow(10**9)+1)
        )
        sess_id = cur.lastrowid
        for pos, cid in enumerate(cards_ids_for_session):
            conn.execute("INSERT INTO live_session_cards (session_id, position, card_id) VALUES (?,?,?)",
                         (sess_id, pos, cid))

        # Esli host = uchasnik — avto-prisoedinyaem
        if host_role == "participant":
            conn.execute("INSERT INTO live_participants (session_id, user_id) VALUES (?, ?)",
                         (sess_id, user["id"]))

        conn.commit(); conn.close()
        return redirect(url_for("live_host", code=code))

    # GET: pokazyvaem formу sozdaniya
    # Sobiraem kategorii i ikh kolody
    if user["org_id"]:
        cats_raw = conn.execute("""
            SELECT c.id, c.name, c.icon, c.parent_id,
                pc.name AS parent_name
            FROM categories c
            LEFT JOIN categories pc ON pc.id=c.parent_id
            WHERE c.org_id=? ORDER BY pc.name, c.name
        """, (user["org_id"],)).fetchall()
        decks_raw = conn.execute("""
            SELECT d.*, (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt
            FROM decks d WHERE d.org_id=? ORDER BY d.created_at DESC
        """, (user["org_id"],)).fetchall()
    else:
        cats_raw = conn.execute("""
            SELECT c.id, c.name, c.icon, c.parent_id,
                pc.name AS parent_name
            FROM categories c
            LEFT JOIN categories pc ON pc.id=c.parent_id
            WHERE c.owner_id=? ORDER BY pc.name, c.name
        """, (user["id"],)).fetchall()
        decks_raw = conn.execute("""
            SELECT d.*, (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cnt
            FROM decks d WHERE d.owner_id=? ORDER BY d.created_at DESC
        """, (user["id"],)).fetchall()

    decks = [dict(d) for d in decks_raw if d["cnt"] >= 3]
    conn.close()
    # Pre-select via ?category_id= i ?count=
    preselect_category = request.args.get("category_id", type=int)
    preselect_count = request.args.get("count", type=int) or 10
    if preselect_count < 3: preselect_count = 10
    if preselect_count > 50: preselect_count = 50
    return render_template("live_create.html",
        decks=decks,
        categories=[dict(c) for c in cats_raw],
        preselect_category=preselect_category,
        preselect_count=preselect_count)


@app.route("/live/history")
@login_required
def live_history():
    """Istoriya zavershennyh live-testov dlya tekuschego polzovatelya."""
    user = current_user()
    conn = db.get_conn()
    sessions = conn.execute("""
        SELECT s.*,
            d.name AS deck_name, d.icon AS deck_icon,
            u.username AS host_username,
            (SELECT COUNT(*) FROM live_participants WHERE session_id=s.id) AS player_count,
            (SELECT score FROM live_participants WHERE session_id=s.id AND user_id=?) AS my_score,
            (SELECT correct_count FROM live_participants WHERE session_id=s.id AND user_id=?) AS my_correct,
            (SELECT 1 FROM live_participants WHERE session_id=s.id AND user_id=?) AS i_was_player,
            (s.host_id = ?) AS i_was_host
        FROM live_sessions s
        JOIN decks d ON d.id=s.deck_id
        JOIN users u ON u.id=s.host_id
        WHERE s.status='finished'
          AND (s.host_id=? OR EXISTS(SELECT 1 FROM live_participants WHERE session_id=s.id AND user_id=?))
        ORDER BY s.finished_at DESC LIMIT 50
    """, (user["id"], user["id"], user["id"], user["id"], user["id"], user["id"])).fetchall()
    conn.close()
    return render_template("live_history.html", sessions=sessions)


@app.route("/live/history/<code>")
@login_required
def live_history_view(code):
    """Detali odnogo zavershennogo testa: vse otvety vsekh polzovateley."""
    user = current_user()
    conn = db.get_conn()
    sess = conn.execute("""
        SELECT s.*, d.name AS deck_name, d.icon AS deck_icon, u.username AS host_username
        FROM live_sessions s JOIN decks d ON d.id=s.deck_id JOIN users u ON u.id=s.host_id
        WHERE s.code=?
    """, (code,)).fetchall()
    if not sess:
        conn.close(); abort(404)
    sess = sess[0]
    # Tol'ko host i uchasniki mogut smotret'
    is_host = sess["host_id"] == user["id"]
    is_player = conn.execute(
        "SELECT 1 FROM live_participants WHERE session_id=? AND user_id=?",
        (sess["id"], user["id"])
    ).fetchone() is not None
    if not is_host and not is_player:
        conn.close(); abort(403)

    # Voprosy
    questions = conn.execute("""
        SELECT lsc.position, c.id, c.front, c.back, c.note
        FROM live_session_cards lsc JOIN cards c ON c.id=lsc.card_id
        WHERE lsc.session_id=? ORDER BY lsc.position
    """, (sess["id"],)).fetchall()

    # Players + scores
    players = conn.execute("""
        SELECT p.*, u.username, u.full_name FROM live_participants p
        JOIN users u ON u.id=p.user_id
        WHERE p.session_id=? ORDER BY p.score DESC, p.correct_count DESC
    """, (sess["id"],)).fetchall()

    # Vse otvety: matritsa user x question
    answers = conn.execute("""
        SELECT user_id, question_idx, chosen, is_correct, time_taken
        FROM live_answers WHERE session_id=?
    """, (sess["id"],)).fetchall()
    by_user = {}
    for a in answers:
        by_user.setdefault(a["user_id"], {})[a["question_idx"]] = dict(a)

    # Razbiraem voprosy (s tem zhe shuffle seed dlya konsistentnosti)
    parsed = []
    seed = sess["shuffle_seed"] if "shuffle_seed" in sess.keys() else None
    for q in questions:
        qd = dict(q)
        opts, correct = _parse_card_options(qd, shuffle_seed=seed or None)
        parsed.append({"position": q["position"], "front": q["front"],
                       "options": opts, "correct": correct})

    conn.close()
    return render_template("live_history_view.html",
        sess=dict(sess), questions=parsed,
        players=[dict(p) for p in players],
        answers_by_user=by_user)


@app.route("/live/<code>/host")
@login_required
def live_host(code):
    """Stranitsa uchitelya (waiting room + upravlenie)."""
    user = current_user()
    conn = db.get_conn()
    sess = conn.execute("SELECT * FROM live_sessions WHERE code=?", (code,)).fetchone()
    if not sess or sess["host_id"] != user["id"]:
        conn.close(); abort(404)
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (sess["deck_id"],)).fetchone()
    conn.close()
    return render_template("live_host.html", sess=dict(sess), deck=dict(deck) if deck else None)


@app.route("/live/join", methods=["GET", "POST"])
@login_required
def live_join():
    """Stranitsa "vvedi kod" dlya studenta. GET ?code=XXX — avto-join."""
    # Avto-join cherez priglashenie v URL: /live/join?code=ABC123
    pre_code = (request.args.get("code") or "").strip().upper()
    if pre_code:
        conn = db.get_conn()
        sess = conn.execute("SELECT * FROM live_sessions WHERE code=?", (pre_code,)).fetchone()
        if sess and sess["status"] != "finished":
            user = current_user()
            conn.execute("INSERT OR IGNORE INTO live_participants (session_id, user_id) VALUES (?,?)",
                         (sess["id"], user["id"]))
            conn.commit(); conn.close()
            return redirect(url_for("live_play", code=pre_code))
        conn.close()
        if not sess:
            flash("Код не найден", "error")
        elif sess["status"] == "finished":
            flash("Тест уже завершён", "error")

    if request.method == "POST":
        code = request.form.get("code", "").strip().upper()
        if not code:
            flash("Введите код", "error")
            return redirect(url_for("live_join"))
        conn = db.get_conn()
        sess = conn.execute("SELECT * FROM live_sessions WHERE code=?", (code,)).fetchone()
        if not sess:
            conn.close()
            flash("Код не найден", "error")
            return redirect(url_for("live_join"))
        if sess["status"] == "finished":
            conn.close()
            flash("Тест уже завершён", "error")
            return redirect(url_for("live_join"))
        user = current_user()
        conn.execute("INSERT OR IGNORE INTO live_participants (session_id, user_id) VALUES (?,?)",
                     (sess["id"], user["id"]))
        conn.commit(); conn.close()
        return redirect(url_for("live_play", code=code))
    return render_template("live_join.html")


@app.route("/live/<code>/play")
@login_required
def live_play(code):
    """Stranitsa studenta — vidit voprosy v real time."""
    user = current_user()
    conn = db.get_conn()
    sess = conn.execute("SELECT * FROM live_sessions WHERE code=?", (code,)).fetchone()
    if not sess:
        conn.close(); abort(404)
    # Pribavlyaem (esli ne dobavlen)
    conn.execute("INSERT OR IGNORE INTO live_participants (session_id, user_id) VALUES (?,?)",
                 (sess["id"], user["id"]))
    conn.commit()
    conn.close()
    return render_template("live_play.html", code=code, sess=dict(sess))


def _live_auto_advance(conn, sess_d):
    """Server-side: esli vremya na vopros istelo — avto-perehod, ne otvetivshie poluchayut 0.
    Esli sessiya zomby (waiting/running > 4 chasov) — avto-zakryvaem chtoby ne grevat' API."""
    # Auto-kill zombie sessions
    if sess_d["status"] in ("waiting", "running"):
        created = sess_d.get("created_at") or sess_d.get("question_started_at")
        if created:
            try:
                cd = datetime.fromisoformat(created)
                if (datetime.utcnow() - cd).total_seconds() > 4 * 3600:
                    now = datetime.utcnow().isoformat()
                    conn.execute(
                        "UPDATE live_sessions SET status='finished', finished_at=? WHERE id=?",
                        (now, sess_d["id"])
                    )
                    conn.commit()
                    sess_d = dict(sess_d)
                    sess_d["status"] = "finished"
                    sess_d["finished_at"] = now
                    return sess_d
            except Exception:
                pass

    if sess_d["status"] != "running":
        return sess_d
    started = sess_d.get("question_started_at")
    if not started:
        return sess_d
    try:
        sd = datetime.fromisoformat(started)
    except Exception:
        return sess_d
    elapsed = (datetime.utcnow() - sd).total_seconds()
    grace = 2  # 2 sek na lateniyu/sinhronizatsiyu
    if elapsed < sess_d["time_per_q"] + grace:
        return sess_d

    # Vremya isteklo: vsem ne otvetivshim — wrong+0
    sess_id = sess_d["id"]
    cur_idx = sess_d["current_idx"]
    parts = conn.execute(
        "SELECT user_id FROM live_participants WHERE session_id=?",
        (sess_id,)
    ).fetchall()
    for p in parts:
        existing = conn.execute(
            "SELECT 1 FROM live_answers WHERE session_id=? AND user_id=? AND question_idx=?",
            (sess_id, p["user_id"], cur_idx)
        ).fetchone()
        if not existing:
            try:
                conn.execute("""INSERT INTO live_answers
                    (session_id, user_id, question_idx, chosen, is_correct, time_taken)
                    VALUES (?,?,?,?,?,?)""",
                    (sess_id, p["user_id"], cur_idx, "", 0, sess_d["time_per_q"]))
                conn.execute("""UPDATE live_participants SET wrong_count=wrong_count+1
                    WHERE session_id=? AND user_id=?""",
                    (sess_id, p["user_id"]))
            except Exception:
                pass

    # Avto-perehod
    next_idx = cur_idx + 1
    now = datetime.utcnow().isoformat()
    if next_idx >= sess_d["question_count"]:
        conn.execute("UPDATE live_sessions SET status='finished', finished_at=? WHERE id=?",
                     (now, sess_id))
        sess_d = dict(sess_d)
        sess_d["status"] = "finished"
        sess_d["finished_at"] = now
        # Achievements
        try:
            participants_full = conn.execute(
                "SELECT user_id FROM live_participants WHERE session_id=?",
                (sess_id,)
            ).fetchall()
            current_uid = session.get("user_id")
            for p in participants_full:
                new_achs = ach_mod.award_live_completed(conn, p["user_id"], was_host=False)
                if p["user_id"] == current_uid and new_achs:
                    existing = session.get("new_achievements", [])
                    existing.extend([a["key"] for a in new_achs])
                    session["new_achievements"] = list(set(existing))
            host_role_v = sess_d.get("host_role", "observer")
            if host_role_v != "participant":
                new_achs = ach_mod.award_live_completed(conn, sess_d["host_id"], was_host=True)
                if sess_d["host_id"] == current_uid and new_achs:
                    existing = session.get("new_achievements", [])
                    existing.extend([a["key"] for a in new_achs])
                    session["new_achievements"] = list(set(existing))
        except Exception as e:
            print("[live] auto achievement err:", e)
    else:
        conn.execute("""UPDATE live_sessions SET current_idx=?, question_started_at=? WHERE id=?""",
                     (next_idx, now, sess_id))
        sess_d = dict(sess_d)
        sess_d["current_idx"] = next_idx
        sess_d["question_started_at"] = now
    conn.commit()
    return sess_d


@app.route("/api/live/<code>/state")
@login_required
def live_api_state(code):
    """API: tekuschee sostoyanie sessii (dlya polling)."""
    user = current_user()
    conn = db.get_conn()
    sess = conn.execute("SELECT * FROM live_sessions WHERE code=?", (code,)).fetchone()
    if not sess:
        conn.close()
        return jsonify({"error": "not_found"}), 404
    sess_d = dict(sess)
    # Avto-perehod po istechenii vremeni
    sess_d = _live_auto_advance(conn, sess_d)
    is_host = sess_d["host_id"] == user["id"]

    # Uchasniki + scores
    parts_raw = conn.execute("""
        SELECT p.*, u.username, u.full_name
        FROM live_participants p
        JOIN users u ON u.id = p.user_id
        WHERE p.session_id=?
        ORDER BY p.score DESC, p.correct_count DESC
    """, (sess_d["id"],)).fetchall()
    participants = [dict(p) for p in parts_raw]

    # Tekuschiy vopros (esli running)
    current_q = None
    if sess_d["status"] == "running":
        cq = conn.execute("""
            SELECT lsc.position, c.id, c.front, c.back, c.note
            FROM live_session_cards lsc
            JOIN cards c ON c.id = lsc.card_id
            WHERE lsc.session_id=? AND lsc.position=?
        """, (sess_d["id"], sess_d["current_idx"])).fetchone()
        if cq:
            cd = {"id": cq["id"], "front": cq["front"], "back": cq["back"], "note": cq["note"]}
            seed = sess_d.get("shuffle_seed") if isinstance(sess_d, dict) else None
            options, correct_letter = _parse_card_options(cd, shuffle_seed=seed or None)
            current_q = {
                "idx": sess_d["current_idx"],
                "front": cd["front"],
                "options": options,
                "correct": correct_letter if is_host else None,  # studentu ne otdaem otvet
                "started_at": sess_d.get("question_started_at"),
                "time_per_q": sess_d["time_per_q"],
            }
            # Proveryaem otvetil li uzhe etot user
            ans = conn.execute(
                "SELECT chosen, is_correct FROM live_answers WHERE session_id=? AND user_id=? AND question_idx=?",
                (sess_d["id"], user["id"], sess_d["current_idx"])
            ).fetchone()
            if ans:
                current_q["my_answer"] = ans["chosen"]
                current_q["my_correct"] = bool(ans["is_correct"])

    conn.close()
    return jsonify({
        "status": sess_d["status"],
        "is_host": is_host,
        "host_role": sess_d.get("host_role", "observer"),
        "current_idx": sess_d["current_idx"],
        "question_count": sess_d["question_count"],
        "participants": participants,
        "question": current_q,
        "code": code,
    })


@app.route("/api/live/<code>/start", methods=["POST"])
@login_required
def live_api_start(code):
    """Uchitel' nazhimaet 'Start'."""
    user = current_user()
    conn = db.get_conn()
    sess = conn.execute("SELECT * FROM live_sessions WHERE code=?", (code,)).fetchone()
    if not sess or sess["host_id"] != user["id"]:
        conn.close(); abort(403)
    now = datetime.utcnow().isoformat()
    conn.execute("""UPDATE live_sessions SET status='running', current_idx=0,
                    started_at=?, question_started_at=? WHERE id=?""",
                 (now, now, sess["id"]))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/api/live/<code>/next", methods=["POST"])
@login_required
def live_api_next(code):
    """Uchitel' perehodit k sleduyushchemu voprosu."""
    user = current_user()
    conn = db.get_conn()
    sess = conn.execute("SELECT * FROM live_sessions WHERE code=?", (code,)).fetchone()
    if not sess or sess["host_id"] != user["id"]:
        conn.close(); abort(403)
    next_idx = sess["current_idx"] + 1
    if next_idx >= sess["question_count"]:
        conn.execute("UPDATE live_sessions SET status='finished', finished_at=? WHERE id=?",
                     (datetime.utcnow().isoformat(), sess["id"]))
        # Achievements vsem uchasnikam
        try:
            participants = conn.execute(
                "SELECT user_id FROM live_participants WHERE session_id=?",
                (sess["id"],)
            ).fetchall()
            for p in participants:
                new_achs = ach_mod.award_live_completed(conn, p["user_id"], was_host=False)
                if p["user_id"] == user["id"] and new_achs:
                    existing = session.get("new_achievements", [])
                    existing.extend([a["key"] for a in new_achs])
                    session["new_achievements"] = list(set(existing))
            # Hostu — was_host=True (esli on ne bil uchasnikom)
            host_role = sess["host_role"] if "host_role" in sess.keys() else "observer"
            if host_role != "participant":
                new_achs = ach_mod.award_live_completed(conn, sess["host_id"], was_host=True)
                if sess["host_id"] == user["id"] and new_achs:
                    existing = session.get("new_achievements", [])
                    existing.extend([a["key"] for a in new_achs])
                    session["new_achievements"] = list(set(existing))
        except Exception as e:
            print("[live] achievement err:", e)
    else:
        conn.execute("""UPDATE live_sessions SET current_idx=?, question_started_at=? WHERE id=?""",
                     (next_idx, datetime.utcnow().isoformat(), sess["id"]))
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/api/live/<code>/friends-to-invite")
@login_required
def live_api_friends_to_invite(code):
    """Spisok druzey s flagom uzhe-priglashen/uchasnik."""
    user = current_user()
    conn = db.get_conn()
    sess = conn.execute("SELECT * FROM live_sessions WHERE code=?", (code,)).fetchone()
    if not sess or sess["host_id"] != user["id"]:
        conn.close()
        return jsonify({"error": "forbidden"}), 403
    friends = conn.execute("""
        SELECT u.id, u.username, u.full_name, u.xp,
            COALESCE((SELECT 1 FROM live_participants
                      WHERE session_id=? AND user_id=u.id), 0) AS joined
        FROM friendships f
        JOIN users u ON (u.id = CASE WHEN f.from_id=? THEN f.to_id ELSE f.from_id END)
        WHERE (f.from_id=? OR f.to_id=?) AND f.status='accepted'
        ORDER BY u.xp DESC
    """, (sess["id"], user["id"], user["id"], user["id"])).fetchall()
    conn.close()
    return jsonify({"ok": True, "friends": [dict(f) for f in friends]})


@app.route("/api/live/<code>/invite/<username>", methods=["POST"])
@login_required
def live_api_invite(code, username):
    """Otpravlyaem uvedomlenie drugu so ssylkoy na live test."""
    user = current_user()
    conn = db.get_conn()
    sess = conn.execute("SELECT * FROM live_sessions WHERE code=?", (code,)).fetchone()
    if not sess or sess["host_id"] != user["id"]:
        conn.close()
        return jsonify({"error": "forbidden"}), 403
    target = conn.execute("SELECT * FROM users WHERE username=?", (username,)).fetchone()
    if not target or target["id"] == user["id"]:
        conn.close()
        return jsonify({"error": "user_not_found"}), 404
    # Tol'ko druz'yam
    is_friend = conn.execute("""
        SELECT 1 FROM friendships
        WHERE status='accepted'
          AND ((from_id=? AND to_id=?) OR (from_id=? AND to_id=?))
    """, (user["id"], target["id"], target["id"], user["id"])).fetchone()
    if not is_friend:
        conn.close()
        return jsonify({"error": "not_friends"}), 403
    _notify(conn, target["id"], "live_invite",
            f"🎮 @{user['username']} приглашает в Live test (код: {code})",
            f"/live/join?code={code}")
    conn.commit(); conn.close()
    return jsonify({"ok": True})


@app.route("/api/live/<code>/answer", methods=["POST"])
@login_required
def live_api_answer(code):
    """Student daet otvet."""
    user = current_user()
    if request.is_json:
        chosen = (request.json.get("chosen") or "")
    else:
        chosen = request.form.get("chosen") or ""
    chosen = chosen.strip().upper()
    conn = db.get_conn()
    sess = conn.execute("SELECT * FROM live_sessions WHERE code=?", (code,)).fetchone()
    if not sess:
        conn.close()
        return jsonify({"error": "not_found"}), 404
    if sess["status"] != "running":
        conn.close()
        return jsonify({"error": "not_running"}), 400

    # Host-observer ne mozhet otvechat'
    is_host = sess["host_id"] == user["id"]
    host_role = sess["host_role"] if "host_role" in sess.keys() else "observer"
    if is_host and host_role != "participant":
        conn.close()
        return jsonify({"error": "host_is_observer"}), 403

    # Avto-perehod (esli vremya isteklo poka byl ofline)
    sess_d = _live_auto_advance(conn, dict(sess))
    if sess_d["status"] != "running":
        conn.close()
        return jsonify({"error": "question_expired"}), 400

    # Poluchaem tekushchuyu kartu
    cq = conn.execute("""
        SELECT c.id, c.front, c.back, c.note FROM live_session_cards lsc
        JOIN cards c ON c.id = lsc.card_id
        WHERE lsc.session_id=? AND lsc.position=?
    """, (sess_d["id"], sess_d["current_idx"])).fetchone()
    if not cq:
        conn.close()
        return jsonify({"error": "no_question"}), 400
    options, correct_letter = _parse_card_options(dict(cq),
        shuffle_seed=(sess_d.get("shuffle_seed") if isinstance(sess_d, dict) else None) or None)
    is_correct = (chosen == correct_letter)

    # Vremya otveta — bonus za bystrotu
    started = sess_d["question_started_at"]
    time_taken = 0
    if started:
        try:
            sd = datetime.fromisoformat(started)
            time_taken = max(0, int((datetime.utcnow() - sd).total_seconds()))
        except Exception:
            pass

    # Score: 100 za pravil'nyy + bonus za bystrotu (max 50 ochkov)
    if is_correct:
        max_time = sess_d["time_per_q"]
        speed_bonus = max(0, int(50 * (1 - min(time_taken / max_time, 1))))
        score_gain = 100 + speed_bonus
    else:
        score_gain = 0

    # Esli host-uchasnik — ubedimsya chto on v participants (na sluchay esli auto-join ne srabotal)
    if is_host and host_role == "participant":
        conn.execute("INSERT OR IGNORE INTO live_participants (session_id, user_id) VALUES (?,?)",
                     (sess_d["id"], user["id"]))

    # Sokhranyaem otvet (igmoriruem dublikaty — pervyy otvet zaschityvaetsya)
    try:
        conn.execute("""INSERT INTO live_answers (session_id, user_id, question_idx, chosen, is_correct, time_taken)
                       VALUES (?,?,?,?,?,?)""",
                     (sess_d["id"], user["id"], sess_d["current_idx"], chosen, 1 if is_correct else 0, time_taken))
        # Updiruem score
        if is_correct:
            conn.execute("""UPDATE live_participants SET score=score+?, correct_count=correct_count+1
                           WHERE session_id=? AND user_id=?""",
                         (score_gain, sess_d["id"], user["id"]))
        else:
            conn.execute("""UPDATE live_participants SET wrong_count=wrong_count+1
                           WHERE session_id=? AND user_id=?""",
                         (sess_d["id"], user["id"]))
        conn.commit()
    except Exception:
        pass  # Dublikat — pervyy otvet uzhe est'
    conn.close()
    return jsonify({"ok": True, "is_correct": is_correct, "score_gain": score_gain})


# ====================================================================
# EXPORT REZUL'TATOV V EXCEL (dlya uchitelya/admina)
# ====================================================================

@app.route("/export/deck/<int:deck_id>")
@login_required
def export_deck_results(deck_id):
    """Eksport rezul'tatov po kolode v Excel (.xlsx).
    Dlya individuala: list kart s lichnym progressom.
    Dlya org admin/teacher: dva lista — po kartam + po studentam."""
    user = current_user()
    if not can_manage_content(user):
        abort(403)

    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)

    # === DANNYE PO KARTAM (vsegda) ===
    cards = conn.execute("""
        SELECT c.id, c.front, c.back, c.note,
            COALESCE(p.reviews, 0) AS reviews,
            COALESCE(p.lapses, 0) AS lapses,
            p.last_grade, p.last_reviewed,
            COALESCE(p.interval_days, 0) AS interval_days,
            COALESCE(p.is_favorite, 0) AS is_favorite,
            COALESCE(p.is_difficult, 0) AS is_difficult
        FROM cards c
        LEFT JOIN user_card_progress p ON p.card_id=c.id AND p.user_id=?
        WHERE c.deck_id=? ORDER BY c.id
    """, (user["id"], deck_id)).fetchall()

    # === DANNYE PO STUDENTAM (tol'ko dlya org) ===
    students = []
    if user["org_id"]:
        students = conn.execute("""
            SELECT u.id, u.username, u.full_name,
                (SELECT COUNT(*) FROM cards WHERE deck_id=?) AS total,
                (SELECT COUNT(*) FROM user_card_progress p
                    JOIN cards c ON c.id=p.card_id
                    WHERE c.deck_id=? AND p.user_id=u.id) AS attempted,
                (SELECT COUNT(*) FROM user_card_progress p
                    JOIN cards c ON c.id=p.card_id
                    WHERE c.deck_id=? AND p.user_id=u.id AND p.interval_days >= 7) AS learned,
                (SELECT COUNT(*) FROM reviews r
                    JOIN cards c ON c.id=r.card_id
                    WHERE c.deck_id=? AND r.user_id=u.id) AS attempts,
                (SELECT COUNT(*) FROM reviews r
                    JOIN cards c ON c.id=r.card_id
                    WHERE c.deck_id=? AND r.user_id=u.id AND r.grade >= 3) AS correct
            FROM users u WHERE u.org_id=? AND u.role='student'
            ORDER BY u.full_name, u.username
        """, (deck_id, deck_id, deck_id, deck_id, deck_id, user["org_id"])).fetchall()

    conn.close()

    # === Stroyim Excel ===
    from openpyxl import Workbook
    from openpyxl.styles import Font, Alignment, PatternFill
    from openpyxl.utils import get_column_letter
    from io import BytesIO

    wb = Workbook()

    # ---------- Sheet 1: KARTOCHKI ----------
    ws1 = wb.active
    ws1.title = "Карточки"

    ws1["A1"] = f"Колода: {deck['name']}"
    ws1["A1"].font = Font(bold=True, size=14)
    ws1.merge_cells("A1:H1")
    ws1["A2"] = f"Дата отчёта: {datetime.now().strftime('%d.%m.%Y %H:%M')} · карт: {len(cards)}"
    ws1["A2"].font = Font(italic=True, color="666666")
    ws1.merge_cells("A2:H2")

    headers1 = ["#", "Вопрос", "Ответ", "Объяснение", "Попыток", "Ошибок",
                "Последняя оценка", "Статус"]
    for col, h in enumerate(headers1, 1):
        c = ws1.cell(row=4, column=col, value=h)
        c.font = Font(bold=True, color="FFFFFF")
        c.fill = PatternFill("solid", fgColor="6366F1")
        c.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)

    for i, card in enumerate(cards, start=1):
        row = 4 + i
        ws1.cell(row=row, column=1, value=i)
        ws1.cell(row=row, column=2, value=card["front"]).alignment = Alignment(wrap_text=True, vertical="top")
        ws1.cell(row=row, column=3, value=card["back"]).alignment = Alignment(wrap_text=True, vertical="top")
        ws1.cell(row=row, column=4, value=card["note"] or "").alignment = Alignment(wrap_text=True, vertical="top")
        ws1.cell(row=row, column=5, value=card["reviews"])
        ws1.cell(row=row, column=6, value=card["lapses"])
        ws1.cell(row=row, column=7, value=card["last_grade"] if card["last_grade"] is not None else "—")
        # Status
        if card["interval_days"] >= 7:
            status = "✓ Изучено"
            color = "D1FAE5"
        elif card["is_difficult"]:
            status = "🔥 Трудная"
            color = "FEE2E2"
        elif card["reviews"] > 0:
            status = "📖 Изучается"
            color = "FEF3C7"
        else:
            status = "🆕 Новая"
            color = "F3F4F6"
        sc = ws1.cell(row=row, column=8, value=status)
        sc.fill = PatternFill("solid", fgColor=color)

    widths1 = [4, 38, 28, 28, 10, 10, 16, 14]
    for i, w in enumerate(widths1, 1):
        ws1.column_dimensions[get_column_letter(i)].width = w
    ws1.row_dimensions[4].height = 30

    # ---------- Sheet 2: STUDENTY (tol'ko dlya org) ----------
    if students:
        ws2 = wb.create_sheet("Студенты")
        ws2["A1"] = f"Журнал студентов: {deck['name']}"
        ws2["A1"].font = Font(bold=True, size=14)
        ws2.merge_cells("A1:H1")
        ws2["A2"] = f"Дата: {datetime.now().strftime('%d.%m.%Y %H:%M')} · студентов: {len(students)}"
        ws2["A2"].font = Font(italic=True, color="666666")
        ws2.merge_cells("A2:H2")

        headers2 = ["#", "Студент", "Логин", "Всего вопросов", "Изучено",
                    "Попыток", "Правильно", "Точность"]
        for col, h in enumerate(headers2, 1):
            c = ws2.cell(row=4, column=col, value=h)
            c.font = Font(bold=True, color="FFFFFF")
            c.fill = PatternFill("solid", fgColor="6366F1")
            c.alignment = Alignment(horizontal="center", vertical="center")

        for i, s in enumerate(students, start=1):
            row = 4 + i
            accuracy = round(s["correct"] / s["attempts"] * 100, 1) if s["attempts"] else 0
            ws2.cell(row=row, column=1, value=i)
            ws2.cell(row=row, column=2, value=s["full_name"] or s["username"])
            ws2.cell(row=row, column=3, value=s["username"])
            ws2.cell(row=row, column=4, value=s["total"])
            ws2.cell(row=row, column=5, value=s["learned"])
            ws2.cell(row=row, column=6, value=s["attempts"])
            ws2.cell(row=row, column=7, value=s["correct"])
            acc_cell = ws2.cell(row=row, column=8, value=f"{accuracy}%")
            if accuracy >= 80:
                acc_cell.fill = PatternFill("solid", fgColor="D1FAE5")
            elif accuracy >= 50:
                acc_cell.fill = PatternFill("solid", fgColor="FEF3C7")
            elif s["attempts"] > 0:
                acc_cell.fill = PatternFill("solid", fgColor="FEE2E2")

        widths2 = [4, 30, 18, 16, 12, 10, 12, 12]
        for i, w in enumerate(widths2, 1):
            ws2.column_dimensions[get_column_letter(i)].width = w
        ws2.row_dimensions[4].height = 30

    # === Otpravka ===
    out = BytesIO()
    wb.save(out)
    out.seek(0)

    safe_name = re.sub(r'[^\w\-]', '_', deck["name"])[:40]
    filename = f"{safe_name}_{datetime.now().strftime('%Y-%m-%d')}.xlsx"

    from flask import send_file
    return send_file(
        out,
        as_attachment=True,
        download_name=filename,
        mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )


@app.route("/export/deck/<int:deck_id>/pdf")
@login_required
def export_deck_pdf(deck_id):
    """Eksport kolody v PDF dlya pechati. Vopros + varianty (bez otmetki pravil'nogo)."""
    user = current_user()
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck or not can_view_deck(user, dict(deck)):
        conn.close(); abort(404)
    cards = conn.execute("SELECT * FROM cards WHERE deck_id=? ORDER BY id", (deck_id,)).fetchall()
    conn.close()

    if not cards:
        flash("В колоде нет вопросов", "error")
        return redirect(url_for("deck_view", deck_id=deck_id))

    # S kontrolnymi otvetami (s otvetami) ili bez (chistyy test)?
    with_answers = request.args.get("answers", "0") == "1"

    from io import BytesIO
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.units import cm
    from reportlab.lib import colors
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle
    from reportlab.pdfbase import pdfmetrics
    from reportlab.pdfbase.ttfonts import TTFont

    # Registriruem kirillicheskie shrifty (Windows DejaVu ili Arial)
    font_name = "Helvetica"
    try:
        # Probuyem DejaVu (krosse-platforma) iz reportlab
        from reportlab.rl_config import canvas_basefontname
        # Ishchem DejaVu v Windows
        for path in [
            r"C:\Windows\Fonts\arial.ttf",
            r"C:\Windows\Fonts\Arial.ttf",
            "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        ]:
            if Path(path).exists():
                pdfmetrics.registerFont(TTFont("CustomFont", path))
                font_name = "CustomFont"
                bold_path = path.replace(".ttf", "bd.ttf").replace("Arial", "arialbd").replace("arial", "arialbd")
                if Path(bold_path).exists():
                    pdfmetrics.registerFont(TTFont("CustomFont-Bold", bold_path))
                break
    except Exception:
        pass

    out = BytesIO()
    doc = SimpleDocTemplate(out, pagesize=A4,
                            leftMargin=2*cm, rightMargin=2*cm,
                            topMargin=2*cm, bottomMargin=2*cm)
    styles = getSampleStyleSheet()
    title_style = ParagraphStyle("Title", parent=styles["Title"], fontName=font_name,
                                  fontSize=20, spaceAfter=12, alignment=1)
    sub_style = ParagraphStyle("Sub", parent=styles["Normal"], fontName=font_name,
                                fontSize=10, textColor=colors.HexColor("#666666"),
                                alignment=1, spaceAfter=20)
    q_style = ParagraphStyle("Q", parent=styles["Normal"], fontName=font_name,
                              fontSize=12, leading=16, spaceAfter=6, spaceBefore=12)
    opt_style = ParagraphStyle("Opt", parent=styles["Normal"], fontName=font_name,
                                fontSize=11, leading=14, leftIndent=20, spaceAfter=2)
    ans_style = ParagraphStyle("Ans", parent=styles["Normal"], fontName=font_name,
                                fontSize=10, textColor=colors.HexColor("#10B981"),
                                leftIndent=20, spaceAfter=8, fontStyle="italic")

    story = []
    story.append(Paragraph(deck["icon"] + " " + deck["name"], title_style))
    story.append(Paragraph(
        f"Тест · {len(cards)} вопросов · {datetime.now().strftime('%d.%m.%Y')}",
        sub_style
    ))
    if not with_answers:
        # Polya dlya FIO i daty
        info_data = [["ФИО:", "_" * 50], ["Группа:", "_" * 30 + "  Дата: " + "_" * 20]]
        info_t = Table(info_data, colWidths=[3*cm, 14*cm])
        info_t.setStyle(TableStyle([
            ("FONTNAME", (0, 0), (-1, -1), font_name),
            ("FONTSIZE", (0, 0), (-1, -1), 11),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
        ]))
        story.append(info_t)
        story.append(Spacer(1, 0.5*cm))

    # Voprosy
    for i, c in enumerate(cards, 1):
        cd = dict(c)
        story.append(Paragraph(f"<b>{i}.</b> {cd['front']}", q_style))

        # Razbiraem note na varianty
        opts = []
        src = cd.get("note") or cd.get("back") or ""
        for line in src.splitlines():
            line = line.strip()
            if not line: continue
            m = re.match(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]\s*(.+)$", line)
            if m:
                opts.append((m.group(1).upper(), m.group(2).strip()))

        if opts:
            for letter, text in opts:
                story.append(Paragraph(f"<b>{letter})</b> {text}", opt_style))
        else:
            # Bez variantov — mesto dlya otveta
            if not with_answers:
                story.append(Spacer(1, 1.5*cm))

        if with_answers:
            # Vyderzhivayem pravil'nyy otvet ROBUSTNO:
            # 1. Pervaya stroka back — eto obychno "A) tekst"
            # 2. Esli net — pervaya stroka iz back kak est'
            back = (cd.get("back") or "").strip()
            first_line = back.split("\n")[0].strip() if back else ""
            correct_letter = None
            correct_text = ""

            # Probuyem vyderzhki bukvu + tekst iz pervoy stroki
            mb = re.match(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]\s*(.+)$", first_line)
            if mb:
                correct_letter = mb.group(1).upper()
                correct_text = mb.group(2).strip()
            elif first_line:
                # Pervaya stroka bez prefixa — esli est' opts, podbiraem po tekstu
                if opts:
                    for ll, txt in opts:
                        if txt.lower().strip() == first_line.lower().strip():
                            correct_letter = ll
                            correct_text = txt
                            break
                if not correct_text:
                    correct_text = first_line

            # Esli posle vsego — bukva est' no teksta net (tipa "Ответ: A"),
            # togda podtyagivaem tekst iz opts
            if correct_letter and not correct_text and opts:
                for ll, txt in opts:
                    if ll == correct_letter:
                        correct_text = txt; break

            if opts and correct_letter:
                story.append(Paragraph(
                    f"<b>Ответ:</b> {correct_letter}) {correct_text}", ans_style))
            elif correct_text:
                story.append(Paragraph(f"<b>Ответ:</b> {correct_text}", ans_style))
            else:
                story.append(Paragraph(f"<b>Ответ:</b> {back}", ans_style))

    doc.build(story)
    out.seek(0)

    safe_name = re.sub(r'[^\w\-]', '_', deck["name"])[:40]
    suffix = "ответы" if with_answers else "тест"
    filename = f"{safe_name}_{suffix}.pdf"

    from flask import send_file
    return send_file(out, as_attachment=True, download_name=filename, mimetype="application/pdf")


@app.route("/export/students")
@login_required
def export_students():
    """Eksport vsekh studentov organizatsii s obshchey statistikoy."""
    user = current_user()
    if user["role"] not in ("admin", "teacher"):
        abort(403)
    if not user["org_id"]:
        abort(400)

    conn = db.get_conn()
    # Polnoyy Otchyot: po kazhdomu studentu — vse kolody
    students = conn.execute("""
        SELECT u.id, u.username, u.full_name, u.xp, u.streak, u.last_study, u.created_at
        FROM users u WHERE u.org_id=? AND u.role='student'
        ORDER BY u.full_name, u.username
    """, (user["org_id"],)).fetchall()

    decks = conn.execute("""
        SELECT d.id, d.name FROM decks d WHERE d.org_id=? ORDER BY d.created_at DESC
    """, (user["org_id"],)).fetchall()

    from openpyxl import Workbook
    from openpyxl.styles import Font, Alignment, PatternFill
    from openpyxl.utils import get_column_letter
    from io import BytesIO

    wb = Workbook()

    # Sheet 1: Obshchaya statistika
    ws = wb.active
    ws.title = "Студенты"
    ws["A1"] = "Журнал учебного центра"
    ws["A1"].font = Font(bold=True, size=14)
    ws.merge_cells("A1:G1")
    ws["A2"] = f"Дата: {datetime.now().strftime('%d.%m.%Y %H:%M')}"
    ws["A2"].font = Font(italic=True, color="666666")
    ws.merge_cells("A2:G2")

    headers = ["#", "Студент", "Логин", "Зарегистрирован", "XP", "Streak", "Последнее изучение"]
    for col, h in enumerate(headers, 1):
        c = ws.cell(row=4, column=col, value=h)
        c.font = Font(bold=True, color="FFFFFF")
        c.fill = PatternFill("solid", fgColor="6366F1")
        c.alignment = Alignment(horizontal="center", vertical="center")

    for i, s in enumerate(students, 1):
        row = 4 + i
        ws.cell(row=row, column=1, value=i)
        ws.cell(row=row, column=2, value=s["full_name"] or s["username"])
        ws.cell(row=row, column=3, value=s["username"])
        ws.cell(row=row, column=4, value=(s["created_at"] or "")[:10])
        ws.cell(row=row, column=5, value=s["xp"] or 0)
        ws.cell(row=row, column=6, value=s["streak"] or 0)
        ws.cell(row=row, column=7, value=(s["last_study"] or "")[:10])

    widths = [4, 30, 18, 18, 10, 10, 20]
    for i, w in enumerate(widths, 1):
        ws.column_dimensions[get_column_letter(i)].width = w
    ws.row_dimensions[4].height = 30

    # Sheet 2: Po kolodam
    ws2 = wb.create_sheet("По колодам")
    ws2["A1"] = "Прогресс по тестам"
    ws2["A1"].font = Font(bold=True, size=14)

    # Zagolovok: # | Student | <kolod1> | <kolod2> | ...
    ws2.cell(row=3, column=1, value="#").font = Font(bold=True)
    ws2.cell(row=3, column=2, value="Студент").font = Font(bold=True)
    for j, d in enumerate(decks, start=3):
        c = ws2.cell(row=3, column=j, value=d["name"])
        c.font = Font(bold=True, color="FFFFFF")
        c.fill = PatternFill("solid", fgColor="8B5CF6")
        c.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)

    for i, s in enumerate(students, 1):
        row = 3 + i
        ws2.cell(row=row, column=1, value=i)
        ws2.cell(row=row, column=2, value=s["full_name"] or s["username"])
        for j, d in enumerate(decks, start=3):
            attempts = conn.execute("""
                SELECT COUNT(*) AS c, SUM(CASE WHEN grade>=3 THEN 1 ELSE 0 END) AS g
                FROM reviews r JOIN cards crd ON crd.id=r.card_id
                WHERE crd.deck_id=? AND r.user_id=?
            """, (d["id"], s["id"])).fetchone()
            if attempts and attempts["c"] > 0:
                acc = round(attempts["g"] / attempts["c"] * 100)
                cell = ws2.cell(row=row, column=j, value=f"{acc}%")
                if acc >= 80:
                    cell.fill = PatternFill("solid", fgColor="D1FAE5")
                elif acc >= 50:
                    cell.fill = PatternFill("solid", fgColor="FEF3C7")
                else:
                    cell.fill = PatternFill("solid", fgColor="FEE2E2")
            else:
                ws2.cell(row=row, column=j, value="—")

    ws2.column_dimensions["A"].width = 4
    ws2.column_dimensions["B"].width = 28
    for j in range(len(decks)):
        ws2.column_dimensions[get_column_letter(3 + j)].width = 18
    ws2.row_dimensions[3].height = 50

    conn.close()

    out = BytesIO()
    wb.save(out)
    out.seek(0)

    filename = f"Журнал_{datetime.now().strftime('%Y-%m-%d')}.xlsx"
    from flask import send_file
    return send_file(out, as_attachment=True, download_name=filename,
                     mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")


# ---------------------- import (text/file) ----------------------------------

@app.route("/import", methods=["GET", "POST"])
@login_required
def import_page():
    user = current_user()
    if not can_manage_content(user): abort(403)
    if request.method == "POST":
        deck_id = request.form.get("deck_id", type=int)
        new_deck_name = request.form.get("new_deck_name", "").strip()
        category_id = request.form.get("category_id", type=int)
        delimiter = request.form.get("delimiter", "|")
        text = request.form.get("text", "").strip()
        file = request.files.get("file")
        # Otladka — pokazyvayem chto poshlo s formy
        print(f"[IMPORT] form keys: {list(request.form.keys())}")
        print(f"[IMPORT] files keys: {list(request.files.keys())}")
        print(f"[IMPORT] file: filename={file.filename if file else None!r}, has_file={bool(file and file.filename)}, text_len={len(text)}")
        cards = []
        # Imya zalitogo fayla — ispol'zuem kak nazvanie kolody po umolchaniyu
        uploaded_filename = ""
        try:
            if file and file.filename:
                # Original'noe imya dlya kolody (s probelami i rashir')
                uploaded_filename = Path(file.filename).stem.replace("_", " ").strip()
                # Bezopasnoye imya fayla
                fname = secure_filename(file.filename) or f"upload_{secrets.token_hex(4)}{Path(file.filename).suffix}"
                # Ubedimsya chto sohranili rasshirenie
                if not Path(fname).suffix:
                    fname += Path(file.filename).suffix or ".bin"
                fpath = UPLOAD / fname
                file.save(str(fpath))
                print(f"[IMPORT] saved: {fpath} ({fpath.stat().st_size} bytes)")
                cards = importer.auto_parse(fpath, delimiter)
                print(f"[IMPORT] parsed {len(cards)} cards from {fname}")

                # FALLBACK dlya skanirovannyh PDF (kartinki bez tekstovogo sloya)
                # Esli kart 0 i fayl PDF — proveryaem ne skan li eto
                if not cards and fpath.suffix.lower() == ".pdf":
                    if importer.is_scanned_pdf(fpath):
                        if not ai_gen.is_available():
                            flash("Это сканированный PDF, для распознавания нужен AI. Загрузите PDF с текстовым слоем или используйте текстовый импорт.", "error")
                            fpath.unlink(missing_ok=True)
                            return redirect(url_for("import_page"))

                        # PROVERKA LIMITA: Free tier — 1 vision-import v mesyats, bez publikatsii
                        if not _check_vision_quota(user):
                            flash("⚠️ Лимит AI Vision исчерпан. Бесплатно — 1 раз в месяц. "
                                  "В будущем для большего лимита потребуется подписка.", "error")
                            fpath.unlink(missing_ok=True)
                            return redirect(url_for("import_page"))

                        # ZAPUSKAEM ASYNC JOB
                        jid = vision_jobs.create_job(
                            user_id=user["id"],
                            fpath=fpath,
                            filename_stem=uploaded_filename,
                            deck_id=deck_id,
                            new_deck_name=new_deck_name,
                            category_id=category_id,
                            lang=session.get("lang", "ru"),
                        )

                        def save_cb(job_id, cards):
                            return _save_vision_cards_to_deck(job_id, cards)

                        vision_jobs.start_vision_job(jid, save_cb)
                        # Idem na stranitsu progressa
                        return redirect(url_for("vision_progress", job_id=jid))

                fpath.unlink(missing_ok=True)
            elif text:
                cards = importer.parse_text(text, delimiter)
                if not cards: cards = importer.parse_mcq(text)
                if not cards: cards = importer.parse_qa_blocks(text)
            if not cards:
                flash("Не найдено карточек", "error")
                return redirect(url_for("import_page"))

            # AI auto-fill: esli mnogo kart bez otveta (back pust ili = note),
            # poprosim AI opredelit pravil'nye otvety (auto_find_answers: DeepSeek+Gemini)
            try:
                if ai_gen.is_available() or ai_gen.is_deepseek_available():
                    cards = ai_gen.auto_find_answers(cards, lang=session.get("lang", "ru"))
            except Exception as _afa_err:
                print(f"[import] auto_find_answers err (ignorируем): {_afa_err}")
        except Exception as e:
            flash(f"Ошибка: {e}", "error"); return redirect(url_for("import_page"))
        conn = db.get_conn()
        if deck_id:
            target = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
            if not target or not can_view_deck(user, dict(target)):
                conn.close(); abort(404)
            target_id = target["id"]
        else:
            # Prioritet: yavnoe imya > imya fayla > defolt s datoy
            target_name = new_deck_name or uploaded_filename or f"Импорт {datetime.now():%Y-%m-%d}"
            if user["org_id"]:
                cur = conn.execute("INSERT INTO decks (org_id, category_id, name, icon) VALUES (?, ?, ?, ?)",
                                  (user["org_id"], category_id, target_name, "📥"))
            else:
                cur = conn.execute("INSERT INTO decks (owner_id, category_id, name, icon) VALUES (?, ?, ?, ?)",
                                  (user["id"], category_id, target_name, "📥"))
            target_id = cur.lastrowid
        for c in cards:
            conn.execute("INSERT INTO cards (deck_id, front, back, note) VALUES (?, ?, ?, ?)",
                         (target_id, c["front"], c["back"], c.get("note", "")))
        conn.commit(); conn.close()
        flash(f"Импортировано {len(cards)} карточек", "success")
        return redirect(url_for("deck_view", deck_id=target_id))
    conn = db.get_conn()
    if user["org_id"]:
        decks = conn.execute("SELECT id, name, icon FROM decks WHERE org_id=? ORDER BY created_at DESC",
                             (user["org_id"],)).fetchall()
        cats = conn.execute("SELECT * FROM categories WHERE org_id=?", (user["org_id"],)).fetchall()
    else:
        decks = conn.execute("SELECT id, name, icon FROM decks WHERE owner_id=? ORDER BY created_at DESC",
                             (user["id"],)).fetchall()
        cats = conn.execute("SELECT * FROM categories WHERE owner_id=?", (user["id"],)).fetchall()
    conn.close()
    return render_template("import.html", decks=decks, categories=cats)


# ---------------------- VISION PDF — async job + progress -------------------

def _check_vision_quota(user) -> bool:
    """Free tier: 1 vision-import v mesyats (kalendarnyy).
    Paid plany: po limitu plana.
    Super-admin (vladelets sayta): bez limita.
    Beta-tester (otmechen super-adminom): bez limita.
    Kastomnye lim'ity (vision_limit_daily/monthly) zadannye v profile super-adminom — perekriyvayut default.

    Vozvrashchaem True esli mojno, False esli prevyshen lim."""
    # Super-adminy = bez limita (testirovaniye, podderzhka)
    if is_super_admin(user):
        return True

    conn = db.get_conn()
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0).isoformat()
    month_start = datetime.utcnow().replace(day=1, hour=0, minute=0, second=0).isoformat()

    used_today = conn.execute("""
        SELECT COUNT(*) AS c FROM ai_usage
        WHERE user_id=? AND kind='vision_pdf' AND created_at >= ?
    """, (user["id"], today_start)).fetchone()["c"]
    used_month = conn.execute("""
        SELECT COUNT(*) AS c FROM ai_usage
        WHERE user_id=? AND kind='vision_pdf' AND created_at >= ?
    """, (user["id"], month_start)).fetchone()["c"]
    conn.close()

    # KASTOMNYY DAILY (perekriyvayet vse ostal'noye esli zadan)
    custom_daily = user.get("vision_limit_daily")
    if custom_daily is not None:
        if used_today >= custom_daily:
            return False

    # KASTOMNYY MONTHLY
    custom_monthly = user.get("vision_limit_monthly")
    if custom_monthly is not None:
        if used_month >= custom_monthly:
            return False

    # Esli zadan hot' odin kastomnyy lim — proverki proshli, propuskaem
    if custom_daily is not None or custom_monthly is not None:
        return True

    # Beta-tester = bez limita (esli kastomnyh net)
    if user.get("is_beta_tester"):
        return True

    # DEFAULT po planu
    plan = billing.get_active_plan(user)
    limits = {
        "free": 1,
        "pro": 20,
        "team": 50,
        "school": 200,
    }
    return used_month < limits.get(plan, 1)


def _save_vision_cards_to_deck(job_id: str, cards: list[dict]) -> int:
    """Sokhranyaem karty v deck. Eto vyzyvayetsya iz fonovogo potoka,
    poetomu sami otkryvayem soedinenie s BD i flask app context."""
    job = vision_jobs.get_job(job_id)
    if not job:
        raise RuntimeError("Job not found")

    user_id = job["user_id"]
    deck_id = job.get("deck_id")
    new_deck_name = job.get("new_deck_name") or job.get("filename_stem") or f"AI Vision {datetime.now():%Y-%m-%d}"
    category_id = job.get("category_id")

    with app.app_context():
        conn = db.get_conn()
        user = conn.execute("SELECT * FROM users WHERE id=?", (user_id,)).fetchone()
        if not user:
            conn.close()
            raise RuntimeError("User not found")
        user_d = dict(user)

        # Free tier: ne razreshat publikatsiyu
        is_free_tier = billing.get_active_plan(user_d) == "free"

        if deck_id:
            target = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
            if not target:
                conn.close()
                raise RuntimeError("Deck not found")
            target_id = target["id"]
            # Appending to an existing deck → drop semantic near-duplicates.
            existing = conn.execute("SELECT front FROM cards WHERE deck_id=?", (target_id,)).fetchall()
            cards = ai_gen.dedup_semantic(cards, [r["front"] for r in existing])
        else:
            if user_d["org_id"]:
                cur = conn.execute(
                    "INSERT INTO decks (org_id, category_id, name, icon, is_public, created_via) VALUES (?, ?, ?, ?, 0, 'vision_pdf')",
                    (user_d["org_id"], category_id, new_deck_name, "🤖")
                )
            else:
                cur = conn.execute(
                    "INSERT INTO decks (owner_id, category_id, name, icon, is_public, created_via) VALUES (?, ?, ?, ?, 0, 'vision_pdf')",
                    (user_d["id"], category_id, new_deck_name, "🤖")
                )
            target_id = cur.lastrowid

        for c in cards:
            conn.execute(
                "INSERT INTO cards (deck_id, front, back, note) VALUES (?, ?, ?, ?)",
                (target_id, c["front"], c["back"], c.get("note", ""))
            )

        # Logiruyem AI usage
        conn.execute("""INSERT INTO ai_usage (user_id, org_id, kind, cards_generated)
                        VALUES (?, ?, ?, ?)""",
                     (user_d.get("id") if user_d.get("role") == "individual" else None,
                      user_d.get("org_id"),
                      "vision_pdf",
                      len(cards)))

        conn.commit()
        conn.close()
        return target_id


@app.route("/import/vision/<job_id>")
@login_required
def vision_progress(job_id):
    """Stranitsa progressa Vision PDF importa."""
    user = current_user()
    job = vision_jobs.get_job(job_id)
    if not job or job["user_id"] != user["id"]:
        flash("Задача не найдена или принадлежит другому пользователю", "error")
        return redirect(url_for("import_page"))
    return render_template("vision_progress.html", job=job, is_super_admin=is_super_admin(user))


@app.route("/api/import/vision/<job_id>/status")
@login_required
def vision_status_api(job_id):
    """JSON-status fonovoy zadachi (dlya AJAX-polling)."""
    user = current_user()
    job = vision_jobs.get_job(job_id)
    if not job or job["user_id"] != user["id"]:
        return jsonify({"error": "not_found"}), 404
    # Otdaem tol'ko bezopasnye polya
    return jsonify({
        "id": job["id"],
        "status": job["status"],
        "progress": job["progress"],
        "pages_done": job["pages_done"],
        "pages_total": job["pages_total"],
        "cards_found": job["cards_found"],
        "error": job.get("error"),
        "stage_msg": job.get("stage_msg") or "",
        "deck_id_created": job.get("deck_id_created"),
    })


@app.route("/api/import/vision/<job_id>/debug")
@login_required
def vision_debug_api(job_id):
    """SUPER-ADMIN ONLY: full job state dlya otladki."""
    user = current_user()
    if not is_super_admin(user):
        return jsonify({"error": "forbidden"}), 403
    job = vision_jobs.get_job(job_id)
    if not job:
        return jsonify({"error": "not_found"}), 404
    # Polnoye sostoyaniye job (krome rezultatov karts — slishkom mnogo)
    safe = {k: (str(v) if not isinstance(v, (str, int, float, bool, type(None), list, dict)) else v)
            for k, v in job.items() if k != "result_cards"}
    safe["result_cards_count"] = len(job.get("result_cards") or [])
    return jsonify(safe)


@app.route("/api/import/vision/recent")
@login_required
def vision_recent_jobs_api():
    """SUPER-ADMIN ONLY: posledniye 50 job'ov (vklyuchaya s diska)."""
    user = current_user()
    if not is_super_admin(user):
        return jsonify({"error": "forbidden"}), 403
    jobs = vision_jobs.list_recent_jobs_from_disk(limit=50)
    # Sortiruyem po vremeni
    return jsonify({"jobs": jobs, "count": len(jobs)})


@app.route("/api/admin/gemini-health")
@login_required
def gemini_health_check():
    """SUPER-ADMIN ONLY: testovyy zapros k Gemini chtoby uznat' rabotaet li.
    Otpravlyaem kroshechnyy text-zapros na obeih modelyah Vision i smotrim chto Google otvechayet."""
    user = current_user()
    if not is_super_admin(user):
        return jsonify({"error": "forbidden"}), 403

    import json as _json
    from urllib import request as _urlreq, error as _urlerr

    key = ai_gen._key()
    if not key:
        return jsonify({"error": "no_api_key", "message": "GEMINI_API_KEY ne nastroen"}), 500

    results = {}
    test_body = _json.dumps({
        "contents": [{"parts": [{"text": "Say 'OK' in JSON: {\"status\":\"OK\"}"}]}],
        "generationConfig": {"maxOutputTokens": 50, "responseMimeType": "application/json"},
    }).encode("utf-8")

    for model_url in [
        ai_gen.API_URL_VISION_PRIMARY,    # gemini-3.5-flash (latest)
        ai_gen.API_URL_VISION_FALLBACK,   # gemini-2.5-flash (fallback)
        ai_gen.API_URL,                    # gemini-3.5-flash (default text)
    ]:
        model_name = model_url.split("/models/")[-1].split(":")[0]
        url = f"{model_url}?key={key}"
        try:
            req = _urlreq.Request(url, data=test_body, method="POST",
                                  headers={"Content-Type": "application/json"})
            with _urlreq.urlopen(req, timeout=15) as resp:
                payload = _json.loads(resp.read().decode("utf-8"))
                txt = payload.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
                results[model_name] = {"status": "OK", "response": txt[:100]}
        except _urlerr.HTTPError as e:
            err_body = ""
            try:
                err_body = e.read().decode("utf-8", errors="replace")[:500]
            except Exception:
                pass
            results[model_name] = {
                "status": f"HTTP_{e.code}",
                "error": err_body,
                "is_quota": e.code == 429,
            }
        except Exception as e:
            results[model_name] = {"status": "ERROR", "error": f"{type(e).__name__}: {e}"}

    # Polnoe zaklyuchenie
    any_ok = any(r.get("status") == "OK" for r in results.values())
    return jsonify({
        "any_working": any_ok,
        "summary": "✅ Gemini рабочий" if any_ok else "❌ Все модели Gemini недоступны",
        "models": results,
        "key_present": bool(key),
        "key_prefix": key[:10] + "..." if key else None,
    })


# ---------------------- AI generation ---------------------------------------

import ai_gen_jobs as _aigen_jobs


@app.route("/ai", methods=["GET", "POST"])
@login_required
def ai_page():
    user = current_user()
    if not can_manage_content(user): abort(403)
    if not ai_gen.is_available():
        flash("AI не настроен (отсутствует ключ Gemini)", "error")
        return redirect(url_for("dashboard"))

    if request.method == "POST":
        kind = request.form.get("kind", "text")
        count = max(1, min(int(request.form.get("count", 10)), 50))
        deck_id = request.form.get("deck_id", type=int)
        new_deck_name = request.form.get("new_deck_name", "").strip()
        category_id = request.form.get("category_id", type=int)
        lang = session.get("lang", "ru")
        output_lang = request.form.get("output_lang", "auto").strip()
        if output_lang not in ("auto", "source", "ru", "en", "uz"):
            output_lang = "auto"
        quality = request.form.get("quality") == "1"

        # Limit check
        ok, used, limit = billing.check_ai_limit(user)
        if not ok:
            flash(f"Лимит AI достигнут: {used}/{limit} в месяц. Обновите план.", "error")
            return redirect(url_for("ai_page"))

        # Validate input before starting job
        label = ""
        gen_fn = None
        pdf_path_to_delete = None

        if kind == "text":
            text = request.form.get("text", "").strip()
            if len(text) < 50:
                flash("Текст слишком короткий (минимум 50 символов)", "error")
                return redirect(url_for("ai_page"))
            label = text[:60] + "..." if len(text) > 60 else text
            # Capture all values explicitly to avoid closure issues
            _text, _lang, _quality, _output_lang = text, lang, quality, output_lang
            gen_fn = lambda c, t=_text, l=_lang, q=_quality, ol=_output_lang: \
                ai_gen.generate_from_text(t, c, l, quality=q, output_lang=ol)

        elif kind == "topic":
            topic = request.form.get("topic", "").strip()
            difficulty = request.form.get("difficulty", "medium")
            if len(topic) < 3:
                flash("Тема слишком короткая (минимум 3 символа)", "error")
                return redirect(url_for("ai_page"))
            label = topic
            _topic, _lang, _diff, _quality, _output_lang = topic, lang, difficulty, quality, output_lang
            gen_fn = lambda c, tp=_topic, l=_lang, d=_diff, q=_quality, ol=_output_lang: \
                ai_gen.generate_from_topic(tp, c, l, d, quality=q, output_lang=ol)

        elif kind == "pdf":
            file = request.files.get("file")
            if not file or not file.filename:
                flash("Загрузите PDF файл", "error")
                return redirect(url_for("ai_page"))
            fname = secure_filename(file.filename)
            fpath = UPLOAD / fname
            file.save(str(fpath))
            label = fname
            pdf_path_to_delete = fpath
            _fpath, _lang, _quality, _output_lang = fpath, lang, quality, output_lang
            gen_fn = lambda c, fp=_fpath, l=_lang, q=_quality, ol=_output_lang: \
                ai_gen.generate_from_pdf(fp, c, l, quality=q, output_lang=ol)

        if not gen_fn:
            flash("Неизвестный тип генерации", "error")
            return redirect(url_for("ai_page"))

        # Save function — extract all needed values from request context NOW
        _user_id = user["id"]
        _org_id = user.get("org_id")
        _deck_id = deck_id
        _new_deck_name = new_deck_name
        _category_id = category_id
        _kind = kind
        _pdf_del = pdf_path_to_delete
        _user_dict = dict(user)  # copy to avoid sqlite3.Row issues in thread

        def save_fn(cards):
            billing.log_ai_usage(_user_dict, _kind, len(cards))
            conn = db.get_conn()
            try:
                if _deck_id:
                    target = conn.execute("SELECT * FROM decks WHERE id=?", (_deck_id,)).fetchone()
                    if not target:
                        raise ValueError("Колода не найдена")
                    target_id = target["id"]
                    # Appending to an existing deck → drop semantic near-duplicates.
                    _existing = conn.execute("SELECT front FROM cards WHERE deck_id=?", (target_id,)).fetchall()
                    cards = ai_gen.dedup_semantic(cards, [r["front"] for r in _existing])
                else:
                    tname = _new_deck_name or f"AI {datetime.now():%Y-%m-%d %H:%M}"
                    if _org_id:
                        cur = conn.execute(
                            "INSERT INTO decks (org_id, category_id, name, icon) VALUES (?,?,?,?)",
                            (_org_id, _category_id, tname, "🤖"))
                    else:
                        cur = conn.execute(
                            "INSERT INTO decks (owner_id, category_id, name, icon) VALUES (?,?,?,?)",
                            (_user_id, _category_id, tname, "🤖"))
                    target_id = cur.lastrowid
                for c in cards:
                    conn.execute(
                        "INSERT INTO cards (deck_id, front, back, note) VALUES (?,?,?,?)",
                        (target_id, c["front"], c["back"], c.get("note", "")))
                conn.commit()
                refresh_deck_content_flags(conn, target_id)
                conn.commit()
                return target_id
            finally:
                conn.close()
                if _pdf_del:
                    try: _pdf_del.unlink(missing_ok=True)
                    except: pass

        # Create background job and redirect to progress page
        jid = _aigen_jobs.create_job(user["id"], kind, count, label)
        _aigen_jobs.start_ai_gen_job(jid, gen_fn, save_fn)
        return redirect(url_for("ai_gen_progress", job_id=jid))

    # GET
    conn = db.get_conn()
    if user["org_id"]:
        decks = conn.execute("SELECT id, name, icon FROM decks WHERE org_id=? ORDER BY created_at DESC",
                             (user["org_id"],)).fetchall()
        cats = conn.execute("SELECT * FROM categories WHERE org_id=?", (user["org_id"],)).fetchall()
    else:
        decks = conn.execute("SELECT id, name, icon FROM decks WHERE owner_id=? ORDER BY created_at DESC",
                             (user["id"],)).fetchall()
        cats = conn.execute("SELECT * FROM categories WHERE owner_id=?", (user["id"],)).fetchall()
    conn.close()
    ok, used, limit = billing.check_ai_limit(user)
    return render_template("ai.html", decks=decks, categories=cats, used=used, limit=limit)


@app.route("/ai/progress/<job_id>")
@login_required
def ai_gen_progress(job_id):
    """Stranitsa progressa AI generatsii."""
    user = current_user()
    job = _aigen_jobs.get_job(job_id)
    if not job or job["user_id"] != user["id"]:
        flash("Задача не найдена", "error")
        return redirect(url_for("ai_page"))
    return render_template("ai_gen_progress.html", job=job)


@app.route("/api/ai/progress/<job_id>/status")
@login_required
def ai_gen_status_api(job_id):
    """JSON-status fonovoy zadachi AI gen (dlya AJAX-polling)."""
    user = current_user()
    job = _aigen_jobs.get_job(job_id)
    if not job or job["user_id"] != user["id"]:
        return jsonify({"error": "not_found"}), 404
    return jsonify({
        "status": job["status"],
        "progress": job["progress"],
        "cards_done": job["cards_done"],
        "cards_total": job["cards_total"],
        "stage_msg": job["stage_msg"],
        "result_deck_id": job["result_deck_id"],
        "error": job["error"],
    })


@app.route("/ai/photo", methods=["POST"])
@login_required
def ai_photo_page():
    """AI generatsiya kart s fotografiyami."""
    user = current_user()
    if not can_manage_content(user): abort(403)
    if not ai_gen.is_available():
        flash("AI не настроен", "error")
        return redirect(url_for("ai_page"))

    ok, used, limit = billing.check_ai_limit(user)
    if not ok:
        flash(f"Лимит AI достигнут: {used}/{limit}", "error")
        return redirect(url_for("ai_page"))

    topic = request.form.get("topic", "").strip()
    count = max(1, min(int(request.form.get("count", 10)), 20))  # max 20 for photo mode
    lang = session.get("lang", "ru")
    deck_id = request.form.get("deck_id", type=int)
    new_deck_name = request.form.get("new_deck_name", "").strip()
    category_id = request.form.get("category_id", type=int)

    if len(topic) < 3:
        flash("Тема слишком короткая", "error")
        return redirect(url_for("ai_page"))

    _user_id = user["id"]
    _org_id = user.get("org_id")
    _user_dict = dict(user)

    def save_fn(cards):
        billing.log_ai_usage(_user_dict, "photo_topic", len(cards))
        conn = db.get_conn()
        try:
            if deck_id:
                target = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
                if not target: raise ValueError("Колода не найдена")
                target_id = target["id"]
            else:
                tname = new_deck_name or f"📸 {topic[:40]}"
                if _org_id:
                    cur = conn.execute(
                        "INSERT INTO decks (org_id, category_id, name, icon) VALUES (?,?,?,?)",
                        (_org_id, category_id, tname, "📸"))
                else:
                    cur = conn.execute(
                        "INSERT INTO decks (owner_id, category_id, name, icon) VALUES (?,?,?,?)",
                        (_user_id, category_id, tname, "📸"))
                target_id = cur.lastrowid
            for c in cards:
                conn.execute(
                    "INSERT INTO cards (deck_id, front, back, note, image_url) VALUES (?,?,?,?,?)",
                    (target_id, c["front"], c["back"], c.get("note", ""), c.get("image_url", "")))
            conn.commit()
            refresh_deck_content_flags(conn, target_id)
            conn.commit()
            return target_id
        finally:
            conn.close()

    jid = _aigen_jobs.create_job(user["id"], "photo_topic", count, topic)
    _aigen_jobs.start_ai_photo_job(jid, topic, count, lang, save_fn)
    return redirect(url_for("ai_gen_progress", job_id=jid))


# ---------------------- billing ---------------------------------------------

@app.route("/billing")
@login_required
def billing_page():
    # Tarifnaya stranitsa vremenno otklyuchena. Vse plany — Free.
    return redirect(url_for("dashboard"))


@app.route("/billing/checkout/<plan>")
@login_required
def billing_checkout(plan):
    # Bezbolnenno otklyucheno
    return redirect(url_for("dashboard"))


@app.route("/billing/webhook", methods=["POST"])
def billing_webhook():
    payload = request.get_data()
    sig_header = request.headers.get("Stripe-Signature", "")
    ok = billing.handle_webhook(payload, sig_header)
    return ("OK", 200) if ok else ("Bad", 400)


# ---------------------- SUPPORT CHAT (polzovatel <-> super-admin) -----------

@app.route("/support")
@login_required
def support_page():
    """Spisok ticketov polzovatelya + forma novogo soobshcheniya."""
    user = current_user()
    conn = db.get_conn()
    if is_super_admin(user):
        # Super-admin vidit vse tikety
        tickets = conn.execute("""
            SELECT t.*, u.username AS user_username,
                (SELECT COUNT(*) FROM support_messages WHERE ticket_id=t.id AND is_admin=0 AND is_read=0) AS unread,
                (SELECT text FROM support_messages WHERE ticket_id=t.id ORDER BY created_at DESC LIMIT 1) AS last_text
            FROM support_tickets t
            JOIN users u ON u.id = t.user_id
            ORDER BY t.last_activity DESC
            LIMIT 100
        """).fetchall()
    else:
        tickets = conn.execute("""
            SELECT t.*,
                (SELECT COUNT(*) FROM support_messages WHERE ticket_id=t.id AND is_admin=1 AND is_read=0) AS unread,
                (SELECT text FROM support_messages WHERE ticket_id=t.id ORDER BY created_at DESC LIMIT 1) AS last_text
            FROM support_tickets t
            WHERE t.user_id=?
            ORDER BY t.last_activity DESC
        """, (user["id"],)).fetchall()
    conn.close()
    return render_template("support_list.html", tickets=tickets, is_admin=is_super_admin(user))


@app.route("/support/new", methods=["POST"])
@login_required
def support_new():
    """Sozdaet noviy ticket."""
    user = current_user()
    subject = (request.form.get("subject") or "").strip()[:200]
    text = (request.form.get("text") or "").strip()[:5000]
    if not text:
        flash("Введите сообщение", "error")
        return redirect(url_for("support_page"))
    conn = db.get_conn()
    cur = conn.execute(
        "INSERT INTO support_tickets (user_id, subject) VALUES (?, ?)",
        (user["id"], subject or "Без темы")
    )
    ticket_id = cur.lastrowid
    conn.execute(
        "INSERT INTO support_messages (ticket_id, sender_id, is_admin, text) VALUES (?, ?, 0, ?)",
        (ticket_id, user["id"], text)
    )
    conn.commit(); conn.close()
    return redirect(url_for("support_ticket", ticket_id=ticket_id))


@app.route("/support/<int:ticket_id>")
@login_required
def support_ticket(ticket_id):
    """Stranitsa odnogo ticketa s perepiskoy."""
    user = current_user()
    conn = db.get_conn()
    ticket = conn.execute("""
        SELECT t.*, u.username AS user_username
        FROM support_tickets t JOIN users u ON u.id = t.user_id
        WHERE t.id=?
    """, (ticket_id,)).fetchone()
    if not ticket:
        conn.close(); abort(404)
    # Dostup: vladelets ili super-admin
    if ticket["user_id"] != user["id"] and not is_super_admin(user):
        conn.close(); abort(403)
    messages = conn.execute("""
        SELECT m.*, u.username AS sender_username
        FROM support_messages m JOIN users u ON u.id = m.sender_id
        WHERE m.ticket_id=? ORDER BY m.created_at ASC
    """, (ticket_id,)).fetchall()
    # Otmetit kak prochitannye chuzhie soobshcheniya
    if is_super_admin(user):
        conn.execute("UPDATE support_messages SET is_read=1 WHERE ticket_id=? AND is_admin=0", (ticket_id,))
    else:
        conn.execute("UPDATE support_messages SET is_read=1 WHERE ticket_id=? AND is_admin=1", (ticket_id,))
    conn.commit(); conn.close()
    return render_template("support_chat.html", ticket=ticket, messages=messages, is_admin=is_super_admin(user))


@app.route("/support/<int:ticket_id>/reply", methods=["POST"])
@login_required
def support_reply(ticket_id):
    user = current_user()
    text = (request.form.get("text") or "").strip()[:5000]
    if not text:
        return redirect(url_for("support_ticket", ticket_id=ticket_id))
    conn = db.get_conn()
    ticket = conn.execute("SELECT * FROM support_tickets WHERE id=?", (ticket_id,)).fetchone()
    if not ticket:
        conn.close(); abort(404)
    if ticket["user_id"] != user["id"] and not is_super_admin(user):
        conn.close(); abort(403)
    is_admin_msg = 1 if is_super_admin(user) else 0
    conn.execute(
        "INSERT INTO support_messages (ticket_id, sender_id, is_admin, text) VALUES (?, ?, ?, ?)",
        (ticket_id, user["id"], is_admin_msg, text)
    )
    conn.execute(
        "UPDATE support_tickets SET last_activity=CURRENT_TIMESTAMP, status='open' WHERE id=?",
        (ticket_id,)
    )
    conn.commit(); conn.close()
    return redirect(url_for("support_ticket", ticket_id=ticket_id))


@app.route("/support/<int:ticket_id>/close", methods=["POST"])
@login_required
def support_close(ticket_id):
    user = current_user()
    conn = db.get_conn()
    ticket = conn.execute("SELECT * FROM support_tickets WHERE id=?", (ticket_id,)).fetchone()
    if not ticket:
        conn.close(); abort(404)
    if ticket["user_id"] != user["id"] and not is_super_admin(user):
        conn.close(); abort(403)
    conn.execute("UPDATE support_tickets SET status='closed' WHERE id=?", (ticket_id,))
    conn.commit(); conn.close()
    return redirect(url_for("support_page"))


# ---------------------- SUPER ADMIN — analitika dlya vladel'tsa sayta -------

@app.route("/superadmin/deck/<int:deck_id>/view")
@super_admin_required
def superadmin_deck_view(deck_id):
    """Super-admin: prosmotr LYUBOY kolody (vklyuchaya privatnye) v read-only rezhime.
    Ispol'zuyetsya iz top-decks tablitsy v /superadmin dlya audita."""
    user = current_user()
    conn = db.get_conn()
    deck = conn.execute("""SELECT d.*, c.name AS category_name FROM decks d
                            LEFT JOIN categories c ON c.id=d.category_id WHERE d.id=?""",
                        (deck_id,)).fetchone()
    if not deck:
        conn.close(); abort(404)
    cards_raw = conn.execute("""SELECT c.*, NULL AS ef, NULL AS interval_days,
                                       0 AS reviews, 0 AS lapses, NULL AS due_at
        FROM cards c WHERE c.deck_id=? ORDER BY c.id DESC""", (deck_id,)).fetchall()
    cards = [dict(c) for c in cards_raw]
    _opt_re = re.compile(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]?\s+(.+)$")
    for c in cards:
        c["level"] = 0
        c["difficulty"] = 0
        source = (c.get("note") or "").strip() or (c.get("back") or "")
        opts = []
        for line in source.split("\n"):
            m = _opt_re.match(line.strip())
            if m:
                opts.append({"letter": m.group(1).upper(), "text": m.group(2).strip()})
        if not opts and c.get("back"):
            for line in c["back"].split("\n"):
                m = _opt_re.match(line.strip())
                if m:
                    opts.append({"letter": m.group(1).upper(), "text": m.group(2).strip()})
        c["options"] = opts
        c["correct_letter"] = None
        if c.get("back") and opts:
            m = _opt_re.match(c["back"].strip().split("\n")[0].strip())
            if m:
                letter = m.group(1).upper()
                if any(o["letter"] == letter for o in opts):
                    c["correct_letter"] = letter
    # Vladelets dlya banner'a "vy smotrite chuzhuyu kolodu"
    owner = None
    if deck["owner_id"]:
        owner = conn.execute("SELECT id, username, full_name FROM users WHERE id=?",
                             (deck["owner_id"],)).fetchone()
    cats = []
    conn.close()
    return render_template("deck.html",
                           deck=deck, cards=cards, categories=cats,
                           can_edit=False,         # super-admin v read-only
                           admin_view=True,         # banner "audit mode"
                           admin_view_owner=dict(owner) if owner else None)


@app.route("/superadmin/deck-debug/<int:deck_id>")
@super_admin_required
def superadmin_deck_debug(deck_id):
    """Otladka: pokazyvaet skol'ko kart v deke i ih front/back. Tol'ko dlya super-admin."""
    conn = db.get_conn()
    deck = conn.execute("SELECT * FROM decks WHERE id=?", (deck_id,)).fetchone()
    if not deck:
        conn.close()
        return jsonify({"error": "deck not found"}), 404
    cards = conn.execute("SELECT id, front, back, length(note) as note_len FROM cards WHERE deck_id=? LIMIT 5", (deck_id,)).fetchall()
    cnt = conn.execute("SELECT COUNT(*) c FROM cards WHERE deck_id=?", (deck_id,)).fetchone()
    # Vladelets
    owner = None
    if deck["owner_id"]:
        u = conn.execute("SELECT id, username FROM users WHERE id=?", (deck["owner_id"],)).fetchone()
        owner = dict(u) if u else None
    conn.close()
    return jsonify({
        "deck_id": deck["id"],
        "deck_name": deck["name"],
        "owner_id": deck["owner_id"],
        "owner": owner,
        "org_id": deck["org_id"],
        "total_cards": cnt["c"],
        "first_5_cards": [dict(c) for c in cards],
    })


@app.route("/superadmin")
@super_admin_required
def superadmin_dashboard():
    """Glavnaya stranitsa analytiki vladeltsa sayta."""
    conn = db.get_conn()

    # Obshchaya statistika
    stats = {}
    stats["users_total"] = conn.execute("SELECT COUNT(*) AS c FROM users").fetchone()["c"]
    stats["users_today"] = conn.execute(
        "SELECT COUNT(*) AS c FROM users WHERE DATE(created_at) = DATE('now')"
    ).fetchone()["c"]
    stats["users_7d"] = conn.execute(
        "SELECT COUNT(*) AS c FROM users WHERE created_at >= datetime('now', '-7 days')"
    ).fetchone()["c"]
    stats["users_30d"] = conn.execute(
        "SELECT COUNT(*) AS c FROM users WHERE created_at >= datetime('now', '-30 days')"
    ).fetchone()["c"]

    # Aktivnyye polzovateli (otvetili hot' raz za period)
    stats["active_today"] = conn.execute("""
        SELECT COUNT(DISTINCT user_id) AS c FROM reviews
        WHERE DATE(reviewed_at) = DATE('now')
    """).fetchone()["c"]
    stats["active_7d"] = conn.execute("""
        SELECT COUNT(DISTINCT user_id) AS c FROM reviews
        WHERE reviewed_at >= datetime('now', '-7 days')
    """).fetchone()["c"]
    stats["active_30d"] = conn.execute("""
        SELECT COUNT(DISTINCT user_id) AS c FROM reviews
        WHERE reviewed_at >= datetime('now', '-30 days')
    """).fetchone()["c"]

    stats["decks_total"] = conn.execute("SELECT COUNT(*) AS c FROM decks").fetchone()["c"]
    stats["cards_total"] = conn.execute("SELECT COUNT(*) AS c FROM cards").fetchone()["c"]
    stats["reviews_total"] = conn.execute("SELECT COUNT(*) AS c FROM reviews").fetchone()["c"]
    stats["reviews_today"] = conn.execute(
        "SELECT COUNT(*) AS c FROM reviews WHERE DATE(reviewed_at) = DATE('now')"
    ).fetchone()["c"]
    stats["orgs_total"] = conn.execute("SELECT COUNT(*) AS c FROM organizations").fetchone()["c"]

    # Po rolyam
    by_role = conn.execute("""
        SELECT role, COUNT(*) AS c FROM users GROUP BY role
    """).fetchall()

    # Top users po XP
    top_users = conn.execute("""
        SELECT u.id, u.username, u.full_name, u.xp, u.streak, u.created_at,
            u.last_study, u.role, u.org_id,
            o.name AS org_name,
            (SELECT COUNT(*) FROM reviews WHERE user_id=u.id) AS reviews_count,
            (SELECT COUNT(*) FROM decks WHERE owner_id=u.id) AS my_decks
        FROM users u
        LEFT JOIN organizations o ON o.id = u.org_id
        ORDER BY u.xp DESC, u.id DESC LIMIT 30
    """).fetchall()

    # Aktivnost po dnyam (poslednie 30 dney)
    daily = conn.execute("""
        SELECT DATE(reviewed_at) AS d, COUNT(*) AS reviews,
            COUNT(DISTINCT user_id) AS users
        FROM reviews
        WHERE reviewed_at >= datetime('now', '-30 days')
        GROUP BY DATE(reviewed_at)
        ORDER BY d
    """).fetchall()

    # Registratsii po dnyam (30 dn)
    registrations = conn.execute("""
        SELECT DATE(created_at) AS d, COUNT(*) AS c FROM users
        WHERE created_at >= datetime('now', '-30 days')
        GROUP BY DATE(created_at) ORDER BY d
    """).fetchall()

    # Top kolod (po prokhodam)
    top_decks = conn.execute("""
        SELECT d.id, d.name, d.icon, d.is_public, d.owner_id, d.org_id,
            (SELECT username FROM users WHERE id=d.owner_id) AS owner_name,
            (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cards_count,
            (SELECT COUNT(*) FROM reviews r
             JOIN cards c ON c.id=r.card_id
             WHERE c.deck_id=d.id) AS reviews_count,
            (SELECT COUNT(DISTINCT r.user_id) FROM reviews r
             JOIN cards c ON c.id=r.card_id
             WHERE c.deck_id=d.id) AS unique_users
        FROM decks d
        ORDER BY reviews_count DESC LIMIT 20
    """).fetchall()

    # Igra-fichi: skol'ko popol'zovalos'
    games_usage = {
        "total_test_runs": conn.execute("""
            SELECT COALESCE(SUM(tests_played), 0) AS c FROM user_game_stats
        """).fetchone()["c"],
        "total_match_runs": conn.execute("""
            SELECT COALESCE(SUM(match_played), 0) AS c FROM user_game_stats
        """).fetchone()["c"],
        "total_duels_played": conn.execute("""
            SELECT COALESCE(SUM(duels_played), 0) AS c FROM user_game_stats
        """).fetchone()["c"],
        "total_live_played": conn.execute("""
            SELECT COALESCE(SUM(live_played + live_hosted), 0) AS c FROM user_game_stats
        """).fetchone()["c"],
    }

    # Skol'ko polzovateley ispol'zovali kazdyy rezhim hot' raz
    feature_users = {
        "tests": conn.execute("SELECT COUNT(*) AS c FROM user_game_stats WHERE tests_played > 0").fetchone()["c"],
        "match": conn.execute("SELECT COUNT(*) AS c FROM user_game_stats WHERE match_played > 0").fetchone()["c"],
        "duels": conn.execute("SELECT COUNT(*) AS c FROM user_game_stats WHERE duels_played > 0").fetchone()["c"],
        "live":  conn.execute("SELECT COUNT(*) AS c FROM user_game_stats WHERE live_played + live_hosted > 0").fetchone()["c"],
        "flashcards": conn.execute("""
            SELECT COUNT(DISTINCT user_id) AS c FROM user_card_progress
            WHERE reviews > 0
        """).fetchone()["c"],
    }

    # Tseli
    goals_stats = {
        "total":     conn.execute("SELECT COUNT(*) AS c FROM learning_goals").fetchone()["c"],
        "active":    conn.execute("SELECT COUNT(*) AS c FROM learning_goals WHERE status='active'").fetchone()["c"],
        "completed": conn.execute("SELECT COUNT(*) AS c FROM learning_goals WHERE status='completed'").fetchone()["c"],
        "abandoned": conn.execute("SELECT COUNT(*) AS c FROM learning_goals WHERE status='abandoned'").fetchone()["c"],
    }

    # Live test sessii
    live_stats = {
        "total":    conn.execute("SELECT COUNT(*) AS c FROM live_sessions").fetchone()["c"],
        "finished": conn.execute("SELECT COUNT(*) AS c FROM live_sessions WHERE status='finished'").fetchone()["c"],
        "running":  conn.execute("SELECT COUNT(*) AS c FROM live_sessions WHERE status='running'").fetchone()["c"],
    }
    duels_stats = {
        "total":    conn.execute("SELECT COUNT(*) AS c FROM duels").fetchone()["c"],
        "finished": conn.execute("SELECT COUNT(*) AS c FROM duels WHERE status='finished'").fetchone()["c"],
    }

    # ============================================================
    # === RASSHIRENNAYA ANALITIKA (dlya owner-only super-admina) ==
    # ============================================================

    # AI usage: vsego / segodnya / 7dn / 30dn
    ai_stats = {
        "total": conn.execute("SELECT COUNT(*) AS c FROM ai_usage").fetchone()["c"],
        "today": conn.execute("SELECT COUNT(*) AS c FROM ai_usage WHERE DATE(created_at)=DATE('now')").fetchone()["c"],
        "yesterday": conn.execute("SELECT COUNT(*) AS c FROM ai_usage WHERE DATE(created_at)=DATE('now','-1 day')").fetchone()["c"],
        "last_7d": conn.execute("SELECT COUNT(*) AS c FROM ai_usage WHERE created_at >= datetime('now','-7 days')").fetchone()["c"],
        "last_30d": conn.execute("SELECT COUNT(*) AS c FROM ai_usage WHERE created_at >= datetime('now','-30 days')").fetchone()["c"],
        "cards_total": conn.execute("SELECT COALESCE(SUM(cards_generated),0) AS c FROM ai_usage").fetchone()["c"],
        "cards_today": conn.execute("SELECT COALESCE(SUM(cards_generated),0) AS c FROM ai_usage WHERE DATE(created_at)=DATE('now')").fetchone()["c"],
    }
    # AI po dnyam (30 dn) dlya grafika
    ai_daily = conn.execute("""
        SELECT DATE(created_at) AS d, COUNT(*) AS calls,
               COALESCE(SUM(cards_generated),0) AS cards,
               COUNT(DISTINCT user_id) AS users
        FROM ai_usage
        WHERE created_at >= datetime('now','-30 days')
        GROUP BY DATE(created_at) ORDER BY d
    """).fetchall()
    # AI po vidam (text/topic/pdf/...)
    ai_by_kind = conn.execute("""
        SELECT kind, COUNT(*) AS c, COALESCE(SUM(cards_generated),0) AS cards
        FROM ai_usage GROUP BY kind ORDER BY c DESC
    """).fetchall()
    # Top AI-potrebiteli
    ai_top_users = conn.execute("""
        SELECT u.id, u.username, u.full_name, u.role,
               COUNT(*) AS calls,
               COALESCE(SUM(au.cards_generated),0) AS cards,
               MAX(au.created_at) AS last_call
        FROM ai_usage au
        JOIN users u ON u.id = au.user_id
        WHERE au.user_id IS NOT NULL
        GROUP BY u.id
        ORDER BY calls DESC LIMIT 15
    """).fetchall()

    # Online seychas (poslednie 2 minuty — bolee tochno chem 5)
    online_now = conn.execute("""
        SELECT id, username, full_name, role, last_seen, last_study, xp, streak
        FROM users
        WHERE last_seen >= datetime('now','-2 minutes')
        ORDER BY last_seen DESC LIMIT 50
    """).fetchall()
    # Aktivnye za chas
    active_hour = conn.execute("""
        SELECT COUNT(*) AS c FROM users
        WHERE last_seen >= datetime('now','-1 hour')
    """).fetchone()["c"]

    # Support tikety
    support_stats = {
        "total":  conn.execute("SELECT COUNT(*) AS c FROM support_tickets").fetchone()["c"],
        "open":   conn.execute("SELECT COUNT(*) AS c FROM support_tickets WHERE status='open'").fetchone()["c"],
        "closed": conn.execute("SELECT COUNT(*) AS c FROM support_tickets WHERE status='closed'").fetchone()["c"],
        "unanswered": conn.execute("""
            SELECT COUNT(*) AS c FROM support_tickets t
            WHERE t.status='open'
            AND NOT EXISTS (
                SELECT 1 FROM support_messages m
                WHERE m.ticket_id=t.id AND m.is_admin=1
            )
        """).fetchone()["c"],
        "today": conn.execute("""
            SELECT COUNT(*) AS c FROM support_tickets
            WHERE DATE(created_at)=DATE('now')
        """).fetchone()["c"],
    }
    # Posledniye 10 ticketov
    recent_tickets = conn.execute("""
        SELECT t.id, t.subject, t.status, t.created_at, t.last_activity,
               u.username AS user_username,
               (SELECT COUNT(*) FROM support_messages WHERE ticket_id=t.id) AS msg_count,
               (SELECT COUNT(*) FROM support_messages WHERE ticket_id=t.id AND is_admin=0 AND is_read=0) AS unread
        FROM support_tickets t
        JOIN users u ON u.id = t.user_id
        ORDER BY t.last_activity DESC LIMIT 10
    """).fetchall()

    # Sotsial nyy: chats / channels / study groups / tournaments
    social_stats = {
        "chats_total":   conn.execute("SELECT COUNT(*) AS c FROM chats").fetchone()["c"],
        "chats_dm":      conn.execute("SELECT COUNT(*) AS c FROM chats WHERE type='dm'").fetchone()["c"],
        "chats_group":   conn.execute("SELECT COUNT(*) AS c FROM chats WHERE type='group'").fetchone()["c"],
        "chats_channel": conn.execute("SELECT COUNT(*) AS c FROM chats WHERE type='channel'").fetchone()["c"],
        "messages_total": conn.execute("SELECT COUNT(*) AS c FROM messages").fetchone()["c"],
        "messages_today": conn.execute("SELECT COUNT(*) AS c FROM messages WHERE DATE(created_at)=DATE('now')").fetchone()["c"],
        "study_groups": conn.execute("SELECT COUNT(*) AS c FROM study_groups").fetchone()["c"],
        "tournaments_total":    conn.execute("SELECT COUNT(*) AS c FROM tournaments").fetchone()["c"],
        "tournaments_running":  conn.execute("SELECT COUNT(*) AS c FROM tournaments WHERE status='running'").fetchone()["c"],
        "tournaments_finished": conn.execute("SELECT COUNT(*) AS c FROM tournaments WHERE status='finished'").fetchone()["c"],
        "friendships_total":    conn.execute("SELECT COUNT(*) AS c FROM friendships WHERE status='accepted'").fetchone()["c"] // 2,  # parnaya zapis'
        "notifications_total":  conn.execute("SELECT COUNT(*) AS c FROM notifications").fetchone()["c"],
    }

    # Posledniye 10 registratsiy (kto?)
    recent_users = conn.execute("""
        SELECT id, username, full_name, role, created_at, org_id, last_study
        FROM users
        ORDER BY created_at DESC LIMIT 10
    """).fetchall()

    # Marketplace: top public decks
    public_decks = conn.execute("""
        SELECT d.id, d.name, d.icon, d.owner_id, d.clones_count,
               u.username AS author,
               (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cards_count
        FROM decks d
        LEFT JOIN users u ON u.id = d.owner_id
        WHERE d.is_public = 1
        ORDER BY d.clones_count DESC LIMIT 10
    """).fetchall()

    # ============================================================
    # === SEGODNYA: chto proishodit na sayte segodnya =============
    # ============================================================
    def _scalar(sql):
        row = conn.execute(sql).fetchone()
        return (row["c"] if row else 0) or 0
    today_stats = {
        # Polzovateli
        "users_online":   _scalar("SELECT COUNT(DISTINCT id) AS c FROM users WHERE DATE(last_seen)=DATE('now')"),
        "users_active":   stats["active_today"],            # otvechali na voprosy (reviews)
        "users_new":      stats["users_today"],             # zaregistrirovalis'
        # Kontent
        "decks_new":      _scalar("SELECT COUNT(*) AS c FROM decks WHERE DATE(created_at)=DATE('now')"),
        "cards_new":      _scalar("SELECT COUNT(*) AS c FROM cards WHERE DATE(created_at)=DATE('now')"),
        "reviews":        stats["reviews_today"],
        # AI / import
        "ai_calls":       ai_stats["today"],
        "ai_cards":       ai_stats["cards_today"],
        "ai_imports":     _scalar("SELECT COUNT(*) AS c FROM ai_usage WHERE kind IN ('pdf','vision_pdf','text','topic') AND DATE(created_at)=DATE('now')"),
        "ai_vision":      _scalar("SELECT COUNT(*) AS c FROM ai_usage WHERE kind='vision_pdf' AND DATE(created_at)=DATE('now')"),
        # Igry
        "duels":          _scalar("SELECT COUNT(*) AS c FROM duels WHERE DATE(created_at)=DATE('now')"),
        "duels_finished": _scalar("SELECT COUNT(*) AS c FROM duels WHERE DATE(finished_at)=DATE('now') AND status='finished'"),
        "live":           _scalar("SELECT COUNT(*) AS c FROM live_sessions WHERE DATE(created_at)=DATE('now')"),
        "tournaments":    _scalar("SELECT COUNT(*) AS c FROM tournaments WHERE DATE(created_at)=DATE('now')"),
        # Sotsial'no
        "messages":       social_stats["messages_today"],
        # Tseli
        "goals_new":      _scalar("SELECT COUNT(*) AS c FROM learning_goals WHERE DATE(created_at)=DATE('now')"),
        "goals_done":     _scalar("SELECT COUNT(*) AS c FROM learning_goals WHERE DATE(completed_at)=DATE('now') AND status='completed'"),
        # Podderzhka
        "tickets":        support_stats["today"],
    }

    # Vchera dlya sravneniya (delta v %)
    yesterday_stats = {
        "users_online":   _scalar("SELECT COUNT(DISTINCT id) AS c FROM users WHERE DATE(last_seen)=DATE('now','-1 day')"),
        "users_active":   _scalar("SELECT COUNT(DISTINCT user_id) AS c FROM reviews WHERE DATE(reviewed_at)=DATE('now','-1 day')"),
        "users_new":      _scalar("SELECT COUNT(*) AS c FROM users WHERE DATE(created_at)=DATE('now','-1 day')"),
        "decks_new":      _scalar("SELECT COUNT(*) AS c FROM decks WHERE DATE(created_at)=DATE('now','-1 day')"),
        "cards_new":      _scalar("SELECT COUNT(*) AS c FROM cards WHERE DATE(created_at)=DATE('now','-1 day')"),
        "reviews":        _scalar("SELECT COUNT(*) AS c FROM reviews WHERE DATE(reviewed_at)=DATE('now','-1 day')"),
        "ai_calls":       ai_stats["yesterday"],
        "ai_imports":     _scalar("SELECT COUNT(*) AS c FROM ai_usage WHERE kind IN ('pdf','vision_pdf','text','topic') AND DATE(created_at)=DATE('now','-1 day')"),
        "duels":          _scalar("SELECT COUNT(*) AS c FROM duels WHERE DATE(created_at)=DATE('now','-1 day')"),
        "messages":       _scalar("SELECT COUNT(*) AS c FROM messages WHERE DATE(created_at)=DATE('now','-1 day')"),
    }

    # ============================================================
    # === KTO CHTO SDELAL: aktivnost' po kazhdomu polzovatelyu ===
    # ============================================================
    # Period iz URL param: today / week / month / all (po umolchaniyu = all)
    period = request.args.get("period", "all").lower()
    if period not in ("today", "week", "month", "all"):
        period = "all"

    if period == "today":
        clause_reviewed   = "AND DATE(reviewed_at)=DATE('now')"
        clause_created    = "AND DATE(created_at)=DATE('now')"
        clause_c_created  = "AND DATE(c.created_at)=DATE('now')"
        clause_ls_created = "AND DATE(ls.created_at)=DATE('now')"
        clause_completed  = "AND DATE(completed_at)=DATE('now')"
        period_label = "сегодня"
    elif period == "week":
        clause_reviewed   = "AND reviewed_at >= datetime('now','-7 days')"
        clause_created    = "AND created_at >= datetime('now','-7 days')"
        clause_c_created  = "AND c.created_at >= datetime('now','-7 days')"
        clause_ls_created = "AND ls.created_at >= datetime('now','-7 days')"
        clause_completed  = "AND completed_at >= datetime('now','-7 days')"
        period_label = "за неделю"
    elif period == "month":
        clause_reviewed   = "AND reviewed_at >= datetime('now','-30 days')"
        clause_created    = "AND created_at >= datetime('now','-30 days')"
        clause_c_created  = "AND c.created_at >= datetime('now','-30 days')"
        clause_ls_created = "AND ls.created_at >= datetime('now','-30 days')"
        clause_completed  = "AND completed_at >= datetime('now','-30 days')"
        period_label = "за месяц"
    else:
        clause_reviewed = clause_created = clause_c_created = clause_ls_created = clause_completed = ""
        period_label = "за всё время"

    sql = f"""
        SELECT
            u.id, u.username, u.full_name, u.role, u.xp, u.streak,
            u.created_at, u.last_seen, u.last_study, u.is_beta_tester,
            (SELECT COUNT(*) FROM decks
                WHERE owner_id=u.id {clause_created}) AS decks_created,
            (SELECT COUNT(*) FROM cards c JOIN decks d ON d.id=c.deck_id
                WHERE d.owner_id=u.id {clause_c_created}) AS cards_created,
            (SELECT COUNT(*) FROM reviews
                WHERE user_id=u.id {clause_reviewed}) AS reviews_total,
            (SELECT COUNT(*) FROM ai_usage
                WHERE user_id=u.id {clause_created}) AS ai_calls,
            (SELECT COALESCE(SUM(cards_generated),0) FROM ai_usage
                WHERE user_id=u.id {clause_created}) AS ai_cards,
            (SELECT COUNT(*) FROM duels
                WHERE (player1_id=u.id OR player2_id=u.id) {clause_created}) AS duels_played,
            (SELECT COUNT(*) FROM live_participants lp
                JOIN live_sessions ls ON ls.id=lp.session_id
                WHERE lp.user_id=u.id {clause_ls_created}) AS live_played,
            COALESCE((SELECT match_played FROM user_game_stats WHERE user_id=u.id), 0) AS match_played,
            COALESCE((SELECT tests_played FROM user_game_stats WHERE user_id=u.id), 0) AS tests_played_total,
            (SELECT COUNT(*) FROM messages
                WHERE user_id=u.id {clause_created}) AS messages_sent,
            (SELECT COUNT(*) FROM learning_goals
                WHERE user_id=u.id {clause_created}) AS goals_total,
            (SELECT COUNT(*) FROM learning_goals
                WHERE user_id=u.id AND status='completed' {clause_completed}) AS goals_done
        FROM users u
        ORDER BY
            CASE WHEN u.last_seen IS NULL THEN 1 ELSE 0 END,
            u.last_seen DESC,
            u.xp DESC
        LIMIT 100
    """
    user_activity = conn.execute(sql).fetchall()

    conn.close()
    return render_template("superadmin.html",
        stats=stats,
        by_role=[dict(r) for r in by_role],
        top_users=[dict(u) for u in top_users],
        daily=[dict(d) for d in daily],
        registrations=[dict(r) for r in registrations],
        top_decks=[dict(d) for d in top_decks],
        games_usage=games_usage,
        feature_users=feature_users,
        goals_stats=goals_stats,
        live_stats=live_stats,
        duels_stats=duels_stats,
        # New blocks
        ai_stats=ai_stats,
        ai_daily=[dict(d) for d in ai_daily],
        ai_by_kind=[dict(k) for k in ai_by_kind],
        ai_top_users=[dict(u) for u in ai_top_users],
        online_now=[dict(u) for u in online_now],
        active_hour=active_hour,
        support_stats=support_stats,
        recent_tickets=[dict(t) for t in recent_tickets],
        social_stats=social_stats,
        recent_users=[dict(u) for u in recent_users],
        public_decks=[dict(d) for d in public_decks],
        today_stats=today_stats,
        yesterday_stats=yesterday_stats,
        user_activity=[dict(u) for u in user_activity],
        activity_period=period,
        activity_period_label=period_label,
    )


# === ANALYTICS DASHBOARD: posescheniya, geo, ustroystva =====================

@app.route("/superadmin/analytics")
@super_admin_required
def superadmin_analytics():
    """Stranitsa analitiki posescheniy."""
    days = request.args.get("days", 30, type=int)
    if days not in (1, 7, 30, 90, 365):
        days = 30

    summary       = analytics.get_summary(days=days)
    by_country    = analytics.get_by_country(days=days, limit=50)
    by_city       = analytics.get_by_city(days=days, limit=50)
    daily         = analytics.get_daily(days=days)
    by_device     = analytics.get_by_device(days=days)
    by_browser    = analytics.get_by_browser(days=days, limit=10)
    by_os         = analytics.get_by_os(days=days, limit=10)
    top_pages     = analytics.get_top_pages(days=days, limit=30)
    top_referrers = analytics.get_top_referrers(days=days, limit=20)
    recent_visits = analytics.get_recent_visits(limit=50)
    hourly_today  = analytics.get_hourly_today()

    conn = db.get_conn()
    try:
        online_now = conn.execute("""
            SELECT v.ip, v.country, v.country_name, v.city, v.path,
                   v.device_type, v.browser, v.os,
                   u.username,
                   MAX(v.created_at) AS last_seen
            FROM visits v
            LEFT JOIN users u ON u.id = v.user_id
            WHERE v.created_at >= datetime('now', '-5 minutes')
                  AND v.device_type != 'bot'
                  AND (v.country IS NULL OR v.country != 'LOCAL')
                  AND (v.user_id IS NULL OR v.user_id NOT IN (SELECT id FROM users WHERE username IN ('slezul99@gmail.com','aza')))
                  AND v.path NOT LIKE '/api/%'
            GROUP BY v.session_id
            ORDER BY last_seen DESC LIMIT 50
        """).fetchall()
    finally:
        conn.close()

    return render_template("superadmin_analytics.html",
        days=days, summary=summary,
        by_country=by_country, by_city=by_city, daily=daily,
        by_device=by_device, by_browser=by_browser, by_os=by_os,
        top_pages=top_pages, top_referrers=top_referrers,
        recent_visits=recent_visits, hourly_today=hourly_today,
        online_now=[dict(r) for r in online_now],
    )


@app.route("/superadmin/analytics/reset-geo", methods=["POST"])
@super_admin_required
def superadmin_analytics_reset_geo():
    """One-off cleanup: clear geo that was recorded from Cloudflare edge IPs."""
    n = analytics.reset_geo()
    flash(f"Гео-данные очищены у {n} записей. Новые визиты будут с правильной геолокацией.", "success")
    return redirect(url_for("superadmin_analytics"))


@app.route("/api/superadmin/analytics/live")
@super_admin_required
def superadmin_analytics_live():
    """API: posledniye REAL-USER posescheniya (no bots, no LOCAL)."""
    after_id = request.args.get("after_id", 0, type=int)
    conn = db.get_conn()
    try:
        rows = conn.execute("""
            SELECT v.id, v.ip, v.country, v.country_name, v.city, v.path,
                   v.device_type, v.browser, v.os, v.created_at,
                   u.username
            FROM visits v
            LEFT JOIN users u ON u.id = v.user_id
            WHERE v.id > ?
                  AND v.device_type != 'bot'
                  AND (v.country IS NULL OR v.country != 'LOCAL')
                  AND v.path NOT LIKE '/api/%'
            ORDER BY v.id DESC LIMIT 50
        """, (after_id,)).fetchall()
    finally:
        conn.close()
    return jsonify({"visits": [dict(r) for r in rows]})


@app.route("/superadmin/user/<int:user_id>")
@super_admin_required
def superadmin_user_detail(user_id):
    """Detalnyy razbor odnogo polzovatelya."""
    conn = db.get_conn()
    u = conn.execute("""
        SELECT u.*, o.name AS org_name FROM users u
        LEFT JOIN organizations o ON o.id = u.org_id
        WHERE u.id=?
    """, (user_id,)).fetchone()
    if not u:
        conn.close(); abort(404)
    user_d = dict(u)

    # Ego activity
    user_d["reviews_total"] = conn.execute(
        "SELECT COUNT(*) AS c FROM reviews WHERE user_id=?", (user_id,)
    ).fetchone()["c"]
    user_d["cards_attempted"] = conn.execute(
        "SELECT COUNT(*) AS c FROM user_card_progress WHERE user_id=? AND reviews > 0", (user_id,)
    ).fetchone()["c"]
    user_d["cards_learned"] = conn.execute(
        "SELECT COUNT(*) AS c FROM user_card_progress WHERE user_id=? AND interval_days >= 7",
        (user_id,)
    ).fetchone()["c"]

    # Aktivnost po dnyam
    activity = conn.execute("""
        SELECT DATE(reviewed_at) AS d, COUNT(*) AS c FROM reviews
        WHERE user_id=? AND reviewed_at >= datetime('now', '-30 days')
        GROUP BY DATE(reviewed_at) ORDER BY d
    """, (user_id,)).fetchall()

    # Ego kolody
    decks = conn.execute("""
        SELECT d.id, d.name, d.icon,
            (SELECT COUNT(*) FROM cards WHERE deck_id=d.id) AS cards_count
        FROM decks d WHERE d.owner_id=?
    """, (user_id,)).fetchall()

    # Game stats
    game_stats = conn.execute(
        "SELECT * FROM user_game_stats WHERE user_id=?", (user_id,)
    ).fetchone()

    # Tseli
    goals_list = conn.execute("""
        SELECT * FROM learning_goals WHERE user_id=? ORDER BY created_at DESC LIMIT 10
    """, (user_id,)).fetchall()

    # Reviews po kolodam (kakimi pol'zovalsya)
    deck_usage = conn.execute("""
        SELECT d.id, d.name, d.icon,
            COUNT(r.id) AS reviews_count,
            MAX(r.reviewed_at) AS last_used
        FROM reviews r
        JOIN cards c ON c.id = r.card_id
        JOIN decks d ON d.id = c.deck_id
        WHERE r.user_id=?
        GROUP BY d.id ORDER BY reviews_count DESC LIMIT 20
    """, (user_id,)).fetchall()

    conn.close()
    return render_template("superadmin_user.html",
        u=user_d,
        activity=[dict(a) for a in activity],
        decks=[dict(d) for d in decks],
        game_stats=dict(game_stats) if game_stats else None,
        goals_list=[dict(g) for g in goals_list],
        deck_usage=[dict(d) for d in deck_usage],
    )


@app.route("/superadmin/user/<int:user_id>/toggle-beta", methods=["POST"])
@super_admin_required
def superadmin_toggle_beta(user_id):
    """Pereklyuchaet flag is_beta_tester u polzovatelya.
    Beta-tester poluchaet bezlimit AI Vision + mozhet publikat vision_pdf kolody."""
    conn = db.get_conn()
    user = conn.execute("SELECT id, is_beta_tester FROM users WHERE id=?", (user_id,)).fetchone()
    if not user:
        conn.close()
        return jsonify({"ok": False, "error": "user_not_found"}), 404
    new_state = 0 if user["is_beta_tester"] else 1
    conn.execute("UPDATE users SET is_beta_tester=? WHERE id=?", (new_state, user_id))
    conn.commit()
    conn.close()
    return jsonify({"ok": True, "is_beta_tester": new_state})


@app.route("/superadmin/user/<int:user_id>/set-role", methods=["POST"])
@super_admin_required
def superadmin_set_role(user_id):
    """Menyaet rol' polzovatelya. TOL'KO slezul99@gmail.com mozhet eto delat'.
    body: {"role": "admin" | "teacher" | "student" | "individual"}"""
    me = current_user()
    # Tol'ko vladelets — ne lyuboy super-admin
    if not me or me.get("username") != "slezul99@gmail.com":
        return jsonify({"ok": False, "error": "forbidden"}), 403

    new_role = (request.form.get("role") or "").strip().lower()
    if new_role not in ("admin", "teacher", "student", "individual"):
        return jsonify({"ok": False, "error": "invalid_role"}), 400

    conn = db.get_conn()
    target = conn.execute("SELECT id, username, role FROM users WHERE id=?", (user_id,)).fetchone()
    if not target:
        conn.close()
        return jsonify({"ok": False, "error": "user_not_found"}), 404
    conn.execute("UPDATE users SET role=? WHERE id=?", (new_role, user_id))
    conn.commit()
    conn.close()
    log_security("ROLE_CHANGED",
                 f"by={me['username']} target={target['username']} {target['role']}->{new_role}")
    return jsonify({"ok": True, "role": new_role})


@app.route("/superadmin/user/<int:user_id>/vision-limits", methods=["POST"])
@super_admin_required
def superadmin_set_vision_limits(user_id):
    """Ustanavlivaet kastomnye lim'ity AI Vision dlya polzovatelya.
    body: {"daily": int|null, "monthly": int|null}
    null = sbrosit' (vernutsya k defaultu po planu)
    0 = polnost'yu zapretit'
    """
    data = request.get_json(silent=True) or {}
    daily = data.get("daily")
    monthly = data.get("monthly")

    # Validatsia: dolzhno byt' int >= 0 ili None
    def _clean(v):
        if v is None or v == "" or v == "null":
            return None
        try:
            n = int(v)
            return max(0, min(n, 9999))  # razumnyy diapazon
        except (TypeError, ValueError):
            return None

    daily = _clean(daily)
    monthly = _clean(monthly)

    conn = db.get_conn()
    user = conn.execute("SELECT id FROM users WHERE id=?", (user_id,)).fetchone()
    if not user:
        conn.close()
        return jsonify({"ok": False, "error": "user_not_found"}), 404

    conn.execute(
        "UPDATE users SET vision_limit_daily=?, vision_limit_monthly=? WHERE id=?",
        (daily, monthly, user_id)
    )
    conn.commit()
    conn.close()
    return jsonify({"ok": True, "daily": daily, "monthly": monthly})


@app.route("/superadmin/user/<int:user_id>/ai-limits", methods=["POST"])
@super_admin_required
def superadmin_set_ai_limits(user_id):
    """Ustanavlivaet kastomnye lim'ity OBYCHNOGO AI (text/topic/pdf generation).
    body: {"daily": int|null, "monthly": int|null}"""
    data = request.get_json(silent=True) or {}
    daily = data.get("daily")
    monthly = data.get("monthly")

    def _clean(v):
        if v is None or v == "" or v == "null":
            return None
        try:
            n = int(v)
            return max(0, min(n, 9999))
        except (TypeError, ValueError):
            return None

    daily = _clean(daily)
    monthly = _clean(monthly)

    conn = db.get_conn()
    user = conn.execute("SELECT id FROM users WHERE id=?", (user_id,)).fetchone()
    if not user:
        conn.close()
        return jsonify({"ok": False, "error": "user_not_found"}), 404

    conn.execute(
        "UPDATE users SET ai_limit_daily=?, ai_limit_monthly=? WHERE id=?",
        (daily, monthly, user_id)
    )
    conn.commit()
    conn.close()
    return jsonify({"ok": True, "daily": daily, "monthly": monthly})


# ---------------------- main ------------------------------------------------

# Iniciializatsiya BD pri importe modulya — sjabotaet i pri gunicorn (production)
# i pri pryamom zapuske `python app.py` (lokalno).
try:
    db.init_db()
    billing.init_billing_tables()
    analytics.init_analytics_tables()
except Exception as _e:
    print(f"[INIT] DB init error: {_e}")

# Auto-seed marketplace v2 (idempotent — uses INSERT OR IGNORE; running twice is safe).
# Gated by app_migrations table so it runs only once.
try:
    _conn = db.get_conn()
    _seeded = _conn.execute(
        "SELECT 1 FROM app_migrations WHERE key='marketplace_v2_seed'"
    ).fetchone()
    _has_subjects = _conn.execute(
        "SELECT COUNT(*) FROM mp_subjects"
    ).fetchone()[0]
    _conn.close()
    if not _seeded or _has_subjects == 0:
        print("[INIT] Seeding marketplace v2 ...")
        import seed_marketplace  # noqa: F401  (running it as a side effect)
        _conn = db.get_conn()
        _conn.execute(
            "INSERT OR IGNORE INTO app_migrations (key) VALUES ('marketplace_v2_seed')"
        )
        _conn.commit()
        _conn.close()
        print("[INIT] Marketplace v2 seeded.")
except Exception as _e:
    print(f"[INIT] Marketplace seed error: {_e}")

# Auto-seed marketplace EXTRA (B1/B2/IELTS/TOEFL/Calculus/Statistics/SQL/Algorithms/etc.)
# Runs once after v2 seed. Idempotent.
try:
    _conn = db.get_conn()
    _extra = _conn.execute(
        "SELECT 1 FROM app_migrations WHERE key='marketplace_extra_seed'"
    ).fetchone()
    _conn.close()
    if not _extra:
        print("[INIT] Seeding marketplace extra (18 collections) ...")
        import seed_marketplace_extra  # noqa: F401
        # Force-recompute has_mcq/has_terms for all decks (new ones have NULL flags)
        _conn = db.get_conn()
        _null_decks = _conn.execute(
            "SELECT id FROM decks WHERE has_mcq IS NULL OR has_terms IS NULL"
        ).fetchall()
        for _row in _null_decks:
            try:
                refresh_deck_content_flags(_conn, _row[0])
            except Exception:
                pass
        if _null_decks:
            print(f"[INIT] Refreshed flags for {len(_null_decks)} new seeded decks")
        _conn.execute(
            "INSERT OR IGNORE INTO app_migrations (key) VALUES ('marketplace_extra_seed')"
        )
        _conn.commit()
        _conn.close()
        print("[INIT] Marketplace extra seeded.")
except Exception as _e:
    print(f"[INIT] Marketplace extra seed error: {_e}")

# Auto-seed marketplace HISTORY subject (Древний мир / Средние века / Новое время / XX век).
# Runs once after the extra seed. Idempotent (INSERT OR IGNORE / get_or_create).
try:
    _conn = db.get_conn()
    _hist = _conn.execute(
        "SELECT 1 FROM app_migrations WHERE key='marketplace_history_seed_v2'"
    ).fetchone()
    _conn.close()
    if not _hist:
        print("[INIT] Seeding marketplace history subject ...")
        import seed_marketplace_history  # noqa: F401
        _conn = db.get_conn()
        _null_decks = _conn.execute(
            "SELECT id FROM decks WHERE has_mcq IS NULL OR has_terms IS NULL"
        ).fetchall()
        for _row in _null_decks:
            try:
                refresh_deck_content_flags(_conn, _row[0])
            except Exception:
                pass
        _conn.execute(
            "INSERT OR IGNORE INTO app_migrations (key) VALUES ('marketplace_history_seed_v2')"
        )
        _conn.commit()
        _conn.close()
        print("[INIT] Marketplace history seeded.")
except Exception as _e:
    print(f"[INIT] Marketplace history seed error: {_e}")

# Auto-seed UZ/EN translations for the History deck cards (front_uz/back_uz/
# note_uz + _en columns), so mobile users on uz/en see localized questions
# instead of the Russian originals (api_v1.tests._localize_card /
# api_v1.study._serialize_card). Idempotent — updates only rows with empty
# front_uz.
try:
    _conn = db.get_conn()
    _hist_tr = _conn.execute(
        "SELECT 1 FROM app_migrations WHERE key='marketplace_history_translations_seed'"
    ).fetchone()
    _conn.close()
    if not _hist_tr:
        print("[INIT] Seeding marketplace history translations ...")
        import seed_marketplace_history_translations  # noqa: F401
        _conn = db.get_conn()
        _conn.execute(
            "INSERT OR IGNORE INTO app_migrations (key) VALUES ('marketplace_history_translations_seed')"
        )
        _conn.commit()
        _conn.close()
        print("[INIT] Marketplace history translations seeded.")
except Exception as _e:
    print(f"[INIT] Marketplace history translations seed error: {_e}")

# Always-on safety: any deck with NULL flags gets recomputed at every startup.
# Cheap (only NULL decks) and ensures Test/Flashcards buttons are correct.
try:
    _conn = db.get_conn()
    _null_decks = _conn.execute(
        "SELECT id FROM decks WHERE has_mcq IS NULL OR has_terms IS NULL"
    ).fetchall()
    if _null_decks:
        print(f"[INIT] Refreshing flags for {len(_null_decks)} decks with NULL flags...")
        for _row in _null_decks:
            try:
                refresh_deck_content_flags(_conn, _row[0])
            except Exception:
                pass
        _conn.commit()
        print(f"[INIT] Done.")
    _conn.close()
except Exception as _e:
    print(f"[INIT] Always-on flag refresh error: {_e}")

# One-time forced refresh of ALL seeded marketplace decks (in case prior migration
# computed wrong flags before we started checking the front field).
try:
    _conn = db.get_conn()
    _forced = _conn.execute(
        "SELECT 1 FROM app_migrations WHERE key='refresh_seeded_flags_v4_force'"
    ).fetchone()
    if not _forced:
        _seeded = _conn.execute(
            "SELECT id FROM decks WHERE created_via='seed'"
        ).fetchall()
        if _seeded:
            print(f"[INIT] Force-refreshing {len(_seeded)} seeded decks...")
            for _row in _seeded:
                try:
                    refresh_deck_content_flags(_conn, _row[0])
                except Exception:
                    pass
            print(f"[INIT] Forced refresh done.")
        _conn.execute(
            "INSERT OR IGNORE INTO app_migrations (key) VALUES ('refresh_seeded_flags_v4_force')"
        )
        _conn.commit()
    _conn.close()
except Exception as _e:
    print(f"[INIT] Force refresh error: {_e}")

# One-time fix: refresh has_mcq/has_terms for any deck that still has NULL flags.
# Independent of seed markers — handles the case where seeded decks ran but flags
# weren't computed in the same boot. Runs ONCE per app_migrations key.
try:
    _conn = db.get_conn()
    _refreshed = _conn.execute(
        "SELECT 1 FROM app_migrations WHERE key='refresh_seeded_flags_v1'"
    ).fetchone()
    if not _refreshed:
        _null_decks = _conn.execute(
            "SELECT id FROM decks WHERE has_mcq IS NULL OR has_terms IS NULL"
        ).fetchall()
        if _null_decks:
            print(f"[INIT] Force-refreshing flags for {len(_null_decks)} decks with NULL flags...")
            for _row in _null_decks:
                try:
                    refresh_deck_content_flags(_conn, _row[0])
                except Exception:
                    pass
            print(f"[INIT] Done — {len(_null_decks)} decks now have proper flags")
        _conn.execute(
            "INSERT OR IGNORE INTO app_migrations (key) VALUES ('refresh_seeded_flags_v1')"
        )
        _conn.commit()
    _conn.close()
except Exception as _e:
    print(f"[INIT] Refresh flags error: {_e}")

# Auto-seed UZ + EN translations for marketplace seeded "terms"-style decks
# (Phrasal Verbs, IELTS Vocabulary, Tech Vocab, Marketing, Finance, Accounting, Entrepreneurship).
# Runs once. Idempotent.
try:
    _conn = db.get_conn()
    _trans = _conn.execute(
        "SELECT 1 FROM app_migrations WHERE key='marketplace_translations_v1'"
    ).fetchone()
    _conn.close()
    if not _trans:
        print("[INIT] Seeding marketplace translations (UZ + EN)...")
        import seed_marketplace_translations  # noqa: F401
        _conn = db.get_conn()
        _conn.execute(
            "INSERT OR IGNORE INTO app_migrations (key) VALUES ('marketplace_translations_v1')"
        )
        _conn.commit()
        _conn.close()
        print("[INIT] Translations seeded.")
except Exception as _e:
    print(f"[INIT] Translations seed error: {_e}")


if __name__ == "__main__":
    print("=" * 50)
    print("  QuizAIPro v3 — http://localhost:5000")
    print(f"  Google: {'YES' if config.has_google() else 'NO'}")
    print(f"  Stripe: {'YES' if config.has_stripe() else 'NO'}")
    print(f"  AI:     {'YES' if ai_gen.is_available() else 'NO'}")
    print("=" * 50)
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)), debug=False)


