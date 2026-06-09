# -*- coding: utf-8 -*-
"""Read-only dashboard endpoints for the mobile /api/v1 layer.

Field-mapping notes (Phase 2 — pragmatic choices, no schema changes):
  - `users` has no leveling system. "level" / "xp_in_current_level" /
    "xp_for_next_level" are derived with a flat 100-XP-per-level rule —
    a placeholder until a real leveling design exists.
  - `users` only stores the *current* `streak` (no historical maximum),
    so "max_streak" is reported equal to "current_streak".
  - There is no dedicated activity-log table. `/dashboard/activity` items
    are synthesized by grouping `reviews` rows per (deck, day) — each
    group becomes one "study_session" item.
"""
from datetime import datetime

from flask import Blueprint, g, jsonify, request

import db

from . import jwt_auth

dashboard_bp = Blueprint("api_v1_dashboard", __name__, url_prefix="/api/v1/dashboard")

XP_PER_LEVEL = 100


def _xp_summary(xp):
    xp = xp or 0
    return {
        "current_xp": xp,
        "level": xp // XP_PER_LEVEL + 1,
        "xp_in_current_level": xp % XP_PER_LEVEL,
        "xp_for_next_level": XP_PER_LEVEL,
    }


def _streak_summary(user_row):
    streak = user_row["streak"] or 0
    last_study = (user_row["last_study"] or "")[:10]
    today = datetime.utcnow().date().isoformat()
    return {
        "current_streak": streak,
        "max_streak": streak,
        "today_completed": last_study == today,
        "last_activity_date": last_study or None,
    }


@dashboard_bp.route("", methods=["GET"])
@jwt_auth.jwt_required
def get_dashboard():
    user = g.current_user
    conn = db.get_conn()
    try:
        now = datetime.utcnow().isoformat()
        today_start = datetime.utcnow().date().isoformat()

        if user["org_id"]:
            deck_filter, deck_param = "d.org_id=?", user["org_id"]
        else:
            deck_filter, deck_param = "d.owner_id=?", user["id"]

        due_row = conn.execute(f"""
            SELECT
                COUNT(*) AS total_due,
                SUM(CASE WHEN p.due_at IS NOT NULL AND p.due_at < ? THEN 1 ELSE 0 END) AS overdue
            FROM cards crd
            JOIN decks d ON d.id = crd.deck_id
            LEFT JOIN user_card_progress p ON p.card_id = crd.id AND p.user_id = ?
            WHERE {deck_filter} AND (p.due_at IS NULL OR p.due_at <= ?)
        """, (today_start, user["id"], deck_param, now)).fetchone()
        total_due = due_row["total_due"] or 0
        overdue = due_row["overdue"] or 0

        today_reviews = conn.execute("""
            SELECT COUNT(*) AS c FROM reviews
            WHERE user_id=? AND DATE(reviewed_at) = DATE('now')
        """, (user["id"],)).fetchone()["c"] or 0

        unread = conn.execute(
            "SELECT COUNT(*) AS c FROM notifications WHERE user_id=? AND is_read=0",
            (user["id"],)
        ).fetchone()["c"] or 0
    finally:
        conn.close()

    daily_goal = user["daily_goal"] or 20
    display_name = user["full_name"] or user["username"]

    return jsonify({"data": {
        "xp": _xp_summary(user["xp"]),
        "streak": _streak_summary(user),
        "daily_goal": {"target_cards": daily_goal, "completed_cards": today_reviews},
        "due_reviews": {
            "total_due": total_due,
            "overdue": overdue,
            "due_today": max(total_due - overdue, 0),
        },
        "user_display_name": display_name,
        "unread_notifications": unread,
    }})


@dashboard_bp.route("/activity", methods=["GET"])
@jwt_auth.jwt_required
def get_activity():
    user = g.current_user
    limit = request.args.get("limit", default=10, type=int) or 10
    limit = max(1, min(limit, 50))

    conn = db.get_conn()
    try:
        rows = conn.execute("""
            SELECT d.id AS deck_id, d.name AS deck_name, DATE(r.reviewed_at) AS day,
                   COUNT(*) AS cards_reviewed,
                   SUM(CASE WHEN r.grade=5 THEN 5 WHEN r.grade=4 THEN 3 ELSE 1 END) AS xp_earned,
                   MAX(r.reviewed_at) AS last_reviewed_at
            FROM reviews r
            JOIN cards c ON c.id = r.card_id
            JOIN decks d ON d.id = c.deck_id
            WHERE r.user_id=?
            GROUP BY d.id, DATE(r.reviewed_at)
            ORDER BY last_reviewed_at DESC
            LIMIT ?
        """, (user["id"], limit)).fetchall()
    finally:
        conn.close()

    items = [{
        "id": f"{row['deck_id']}_{row['day']}",
        "type": "study_session",
        "title": row["deck_name"],
        "cards_reviewed": row["cards_reviewed"],
        "xp_earned": row["xp_earned"] or 0,
        "created_at": row["last_reviewed_at"],
    } for row in rows]

    return jsonify({"data": items})
