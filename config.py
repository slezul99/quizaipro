# -*- coding: utf-8 -*-
"""Konfig: Google OAuth + Stripe + plans."""
import os
from pathlib import Path

BASE = Path(__file__).resolve().parent

# === Google OAuth ===
# Polozhi gugle credentials iz Google Cloud Console:
# https://console.cloud.google.com → APIs & Services → Credentials
# OAuth 2.0 Client ID, type "Web application"
# Authorized redirect URI: http://localhost:5000/auth/google/callback
GOOGLE_CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID", "").strip()
GOOGLE_CLIENT_SECRET = os.environ.get("GOOGLE_CLIENT_SECRET", "").strip()

# Esli klyuchi ne v env, ishchem v google_oauth.txt
_g_file = BASE / "google_oauth.txt"
if _g_file.exists() and not GOOGLE_CLIENT_ID:
    lines = _g_file.read_text(encoding="utf-8").strip().splitlines()
    if len(lines) >= 2:
        GOOGLE_CLIENT_ID = lines[0].strip()
        GOOGLE_CLIENT_SECRET = lines[1].strip()


# === Stripe ===
# Klyuchi iz Stripe Dashboard → Developers → API keys
STRIPE_PUBLISHABLE_KEY = os.environ.get("STRIPE_PUBLISHABLE_KEY", "").strip()
STRIPE_SECRET_KEY      = os.environ.get("STRIPE_SECRET_KEY", "").strip()
STRIPE_WEBHOOK_SECRET  = os.environ.get("STRIPE_WEBHOOK_SECRET", "").strip()

_s_file = BASE / "stripe_keys.txt"
if _s_file.exists() and not STRIPE_SECRET_KEY:
    lines = _s_file.read_text(encoding="utf-8").strip().splitlines()
    if len(lines) >= 2:
        STRIPE_PUBLISHABLE_KEY = lines[0].strip()
        STRIPE_SECRET_KEY      = lines[1].strip()
        if len(lines) >= 3:
            STRIPE_WEBHOOK_SECRET = lines[2].strip()


# === Tarify ===
PLANS = {
    "free": {
        "name": "Free",
        "price_usd": 0,
        "stripe_price_id": "",
        "limits": {
            "max_decks": 5,
            "max_cards_per_deck": 50,
            "ai_generations_per_month": 10,
            "max_students": 0,   # tol'ko individual'nyy
        },
    },
    "pro_individual": {
        "name": "Pro (Individual)",
        "price_usd": 9,
        "stripe_price_id": os.environ.get("STRIPE_PRICE_PRO_IND", ""),
        "limits": {
            "max_decks": 999,
            "max_cards_per_deck": 9999,
            "ai_generations_per_month": 200,
            "max_students": 0,
        },
    },
    "team": {
        "name": "Team (Korporativnyy)",
        "price_usd": 49,
        "stripe_price_id": os.environ.get("STRIPE_PRICE_TEAM", ""),
        "limits": {
            "max_decks": 9999,
            "max_cards_per_deck": 9999,
            "ai_generations_per_month": 500,
            "max_students": 50,
        },
    },
    "school": {
        "name": "School (Bolshie tsentry)",
        "price_usd": 149,
        "stripe_price_id": os.environ.get("STRIPE_PRICE_SCHOOL", ""),
        "limits": {
            "max_decks": 99999,
            "max_cards_per_deck": 99999,
            "ai_generations_per_month": 2000,
            "max_students": 500,
        },
    },
}


def has_google():
    return bool(GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET)


def has_stripe():
    return bool(STRIPE_SECRET_KEY)
