# -*- coding: utf-8 -*-
"""Isolated /api/v1 JSON REST layer for the mobile app.

Registered as a single Flask Blueprint from app.py — does not modify or depend
on the existing session-based web auth (auth.py). See api_v1.jwt_auth for the
token system and api_v1.auth for the Phase-1 authentication endpoints.
"""
from .ai_generation import ai_generation_bp
from .auth import auth_bp
from .dashboard import dashboard_bp
from .library import library_bp
from .marketplace import marketplace_bp
from .study import decks_bp, study_bp
from .tests import test_questions_bp, tests_bp
from .tutor import tutor_bp

__all__ = [
    "ai_generation_bp", "auth_bp", "dashboard_bp", "library_bp", "marketplace_bp",
    "decks_bp", "study_bp", "test_questions_bp", "tests_bp", "tutor_bp",
]
