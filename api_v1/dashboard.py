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

# Mechanical XP-event labels for the level-journey feed. The branded reward
# titles (titles/frames/themes) stay Russian by product decision; only these
# template phrases are localized.
_XP_EVENT_PHRASES = {
    "ru": {"card_studied": "Изучена карта", "test_passed": "Пройден тест", "achievement": "Достижение"},
    "en": {"card_studied": "Card studied", "test_passed": "Test passed", "achievement": "Achievement"},
    "uz": {"card_studied": "Karta o‘rganildi", "test_passed": "Test topshirildi", "achievement": "Yutuq"},
}


def _resolve_lang(user):
    lang = request.args.get("lang") or (user["lang"] if user and "lang" in user.keys() else None)
    return lang if lang in ("ru", "en", "uz") else "ru"

def _xp_summary(xp):
    import achievements as ach_mod
    info = ach_mod.calculate_level_info(xp)
    return {
        "current_xp": info["total_xp"],
        "level": info["level"],
        "xp_in_current_level": info["xp_in_current_level"],
        "xp_for_next_level": info["xp_for_next_level"],
    }


def _streak_summary(user_row):
    streak = user_row["streak"] or 0
    max_streak = user_row["max_streak"] if "max_streak" in user_row.keys() else streak
    if max_streak is None or max_streak < streak:
        max_streak = streak
    last_study = (user_row["last_study"] or "")[:10]
    today = datetime.utcnow().date().isoformat()
    
    # Dynamic calculations of evolution stages on backend (single source of truth)
    from achievements import EVOLUTION_STAGES
    
    current_stage = EVOLUTION_STAGES[0]
    for stage in EVOLUTION_STAGES:
        if streak >= stage["start_days"]:
            current_stage = stage
            
    curr_idx = EVOLUTION_STAGES.index(current_stage)
    next_stage = None
    if curr_idx < len(EVOLUTION_STAGES) - 1:
        next_stage = EVOLUTION_STAGES[curr_idx + 1]
        
    if next_stage is None:
        progress_ratio = 1.0
        days_remaining = 0
        next_stage_data = None
    else:
        days_in_stage = next_stage["start_days"] - current_stage["start_days"]
        days_completed = streak - current_stage["start_days"]
        progress_ratio = float(days_completed) / days_in_stage
        progress_ratio = max(0.0, min(1.0, progress_ratio))
        days_remaining = next_stage["start_days"] - streak
        next_stage_data = {
            "key": next_stage["key"],
            "start_days": next_stage["start_days"]
        }
        
    current_stage_data = {
        "key": current_stage["key"],
        "start_days": current_stage["start_days"],
        "next_stage_days": current_stage["next_stage_days"]
    }
    
    return {
        "current_streak": streak,
        "max_streak": max_streak,
        "today_completed": last_study == today,
        "last_activity_date": last_study or None,
        "current_stage": current_stage_data,
        "next_stage": next_stage_data,
        "progress_ratio": progress_ratio,
        "days_remaining": days_remaining,
    }


@dashboard_bp.route("/level-journey", methods=["GET"])
@jwt_auth.jwt_required
def get_level_journey():
    user = g.current_user
    phrases = _XP_EVENT_PHRASES[_resolve_lang(user)]
    import achievements as ach_mod
    info = ach_mod.calculate_level_info(user["xp"])
    
    # Build milestones road
    milestone_levels = [5, 10, 15, 20, 30, 50, 75, 100]
    milestones = []
    for ml in milestone_levels:
        if ml == 5:
            desc = "Титул: Ученик познания | Рамка: Бронзовая лоза | Тема: Бронзовый рассвет"
        elif ml == 10:
            desc = "Титул: Ученый Архива | Рамка: Серебряные руны | Тема: Серебряный туман"
        elif ml == 15:
            desc = "Титул: Мастер памяти | Рамка: Эфирный кристалл"
        elif ml == 20:
            desc = "Титул: Хранитель пламени | Рамка: Золотой феникс | Тема: Золотое затмение"
        elif ml == 30:
            desc = "Титул: Архимаг мудрости | Рамка: Звездный астрал"
        elif ml == 50:
            desc = "Титул: Великий магистр вечности | Рамка: Космическая сингулярность | Тема: Космический Обсидиан"
        elif ml == 75:
            desc = "Титул: Страж Нексуса | Рамка: Рамка Стража Нексуса"
        elif ml == 100:
            desc = "Титул: Легендарная сингулярность | Рамка: Легендарный Звездный Огонь | Тема: Легендарный Звездный Огонь"
        else:
            desc = f"Миля уровня {ml}"
        
        milestones.append({
            "level": ml,
            "reward_desc": desc,
            "unlocked": info["level"] >= ml
        })

    conn = db.get_conn()
    try:
        # Fetch reviews, tests, achievements
        review_rows = conn.execute("""
            SELECT 'flashcard_review' AS event_type,
                   (CASE WHEN grade=5 THEN 5 WHEN grade=4 THEN 3 WHEN grade=3 THEN 1 ELSE 0 END) AS xp_gained,
                   reviewed_at AS timestamp
            FROM reviews
            WHERE user_id = ? AND grade >= 3
            ORDER BY reviewed_at DESC
            LIMIT 20
        """, (user["id"],)).fetchall()

        test_rows = conn.execute("""
            SELECT 'test_attempt' AS event_type,
                   scope_name AS scope_name,
                   COALESCE(xp_earned, (correct * 3 + (CASE WHEN is_perfect = 1 THEN 5 ELSE 0 END))) AS xp_gained,
                   finished_at AS timestamp
            FROM test_attempts
            WHERE user_id = ?
            ORDER BY finished_at DESC
            LIMIT 20
        """, (user["id"],)).fetchall()

        ach_rows = conn.execute("""
            SELECT 'achievement' AS event_type,
                   ach_key,
                   unlocked_at AS timestamp
            FROM user_achievements
            WHERE user_id = ?
            ORDER BY unlocked_at DESC
            LIMIT 20
        """, (user["id"],)).fetchall()
    finally:
        conn.close()

    events = []
    for r in review_rows:
        events.append({
            "event_type": r["event_type"],
            "description": phrases["card_studied"],
            "xp_gained": r["xp_gained"],
            "timestamp": r["timestamp"]
        })
    for r in test_rows:
        events.append({
            "event_type": r["event_type"],
            "description": f"{phrases['test_passed']}: {r['scope_name']}",
            "xp_gained": r["xp_gained"],
            "timestamp": r["timestamp"]
        })
    for r in ach_rows:
        ach_key = r["ach_key"]
        ach_def = ach_mod.ACH_BY_KEY.get(ach_key)
        name = ach_def["name"] if ach_def else ach_key
        xp_gained = ach_def["xp"] if ach_def else 0
        events.append({
            "event_type": r["event_type"],
            "description": f"{phrases['achievement']}: {name}",
            "xp_gained": xp_gained,
            "timestamp": r["timestamp"]
        })

    events.sort(key=lambda x: x["timestamp"] or "", reverse=True)
    recent_xp_events = events[:15]

    return jsonify({
        "level": info["level"],
        "total_xp": info["total_xp"],
        "xp_in_current_level": info["xp_in_current_level"],
        "xp_for_next_level": info["xp_for_next_level"],
        "progress_ratio": info["progress_ratio"],
        "tier": info["tier"],
        "milestones": milestones,
        "recent_xp_events": recent_xp_events
    })


@dashboard_bp.route("/streak-journey", methods=["GET"])
@jwt_auth.jwt_required

def get_streak_journey():
    from datetime import timedelta
    user = g.current_user
    conn = db.get_conn()
    try:
        # Read-only fetch of user achievements
        ach_rows = conn.execute("""
            SELECT ach_key, unlocked_at 
            FROM user_achievements 
            WHERE user_id=? AND ach_key LIKE 'streak_%'
        """, (user["id"],)).fetchall()
        unlocked_ach = {r["ach_key"]: r["unlocked_at"] for r in ach_rows}

        # Single source of truth from achievements.py
        import achievements as ach_mod
        milestones_data = []
        rewards_history = []
        
        streak_achievements = [a for a in ach_mod.ACHIEVEMENTS if a["key"].startswith("streak_")]
        for a in streak_achievements:
            unlocked = a["key"] in unlocked_ach
            unlocked_at = unlocked_ach.get(a["key"])
            days = int(a["key"].split("_")[1])
            milestones_data.append({
                "key": a["key"],
                "days": days,
                "xp": a["xp"],
                "name": a["name"],
                "desc": a["desc"],
                "unlocked": unlocked,
                "unlocked_at": unlocked_at,
            })
            if unlocked:
                rewards_history.append({
                    "key": a["key"],
                    "name": a["name"],
                    "xp": a["xp"],
                    "unlocked_at": unlocked_at,
                })

        # Calculate calendar coverage for the last 30 calendar days (UTC)
        today = datetime.utcnow().date()
        start_date = today - timedelta(days=29)

        # Uses index range scan directly on (user_id, date) index
        history_rows = conn.execute("""
            SELECT DISTINCT active_date FROM (
                SELECT DATE(reviewed_at) AS active_date FROM reviews 
                WHERE user_id=? AND reviewed_at >= ?
                UNION
                SELECT DATE(finished_at) AS active_date FROM test_attempts 
                WHERE user_id=? AND finished_at >= ?
            )
            ORDER BY active_date DESC
        """, (user["id"], start_date.isoformat(), user["id"], start_date.isoformat())).fetchall()
        active_dates = [r["active_date"] for r in history_rows]

        streak_info = _streak_summary(user)

        return jsonify({
            "streak": streak_info,
            "milestones": milestones_data,
            "rewards_history": rewards_history,
            "calendar": {
                "start_date": start_date.isoformat(),
                "end_date": today.isoformat(),
                "active_dates": active_dates,
            }
        })
    finally:
        conn.close()


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

        # FSRS retention over all studied cards — same source of truth as the
        # web dashboard/deck pages (fsrs.deck_retention), so mobile never
        # recomputes the algorithm; it just renders what the backend returns.
        ret_rows = conn.execute("""
            SELECT p.reviews, p.stability, p.last_reviewed, p.interval_days, p.ef
            FROM user_card_progress p
            WHERE p.user_id=? AND p.reviews IS NOT NULL AND p.reviews > 0
        """, (user["id"],)).fetchall()
    finally:
        conn.close()

    import fsrs
    retention = fsrs.deck_retention([dict(r) for r in ret_rows])

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
        "retention": {
            "now": retention["now"],
            "forecast": retention["forecast"],
            "fading": retention["fading"],
            "studied": retention["studied"],
        },
        "user_display_name": display_name,
        "unread_notifications": unread,
    }})


import json
import re

def _parse_and_filter_test_options(chosen, correct, is_correct, note, back):
    _opt_re = re.compile(r"^([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]?\s+(.+)$")
    source = (note or "").strip() or (back or "")
    opts = {}
    for line in source.split("\n"):
        m = _opt_re.match(line.strip())
        if m:
            opts[m.group(1).upper()] = m.group(2).strip()
            
    if not opts and back:
        for line in back.split("\n"):
            m = _opt_re.match(line.strip())
            if m:
                opts[m.group(1).upper()] = m.group(2).strip()

    chosen_upper = (chosen or "").upper()
    correct_upper = (correct or "").upper()
    
    chosen_text = opts.get(chosen_upper, chosen)
    correct_text = opts.get(correct_upper, back or correct)
    
    if is_correct:
        return {
            "front": None,
            "is_correct": True,
            "correct_answer": correct_text,
            "selected_answer": None
        }
    else:
        return {
            "front": None,
            "is_correct": False,
            "correct_answer": correct_text,
            "selected_answer": chosen_text
        }


@dashboard_bp.route("/activity", methods=["GET"])
@jwt_auth.jwt_required
def get_activity():
    user = g.current_user
    limit = request.args.get("limit", default=10, type=int) or 10
    limit = max(1, min(limit, 50))

    conn = db.get_conn()
    try:
        rows = conn.execute("""
            SELECT * FROM (
                SELECT 
                    CAST(d.id AS TEXT) AS id,
                    d.name AS title,
                    'study_session' AS type,
                    COUNT(*) AS cards_reviewed,
                    SUM(CASE WHEN r.grade=5 THEN 5 WHEN r.grade=4 THEN 3 ELSE 1 END) AS xp_earned,
                    MAX(r.reviewed_at) AS created_at,
                    (
                        SELECT json_group_array(json_object(
                            'card_id', CAST(r2.card_id AS TEXT),
                            'front', c2.front,
                            'back', c2.back,
                            'explanation', c2.note,
                            'grade', r2.grade,
                            'xp_earned', CASE WHEN r2.grade=5 THEN 5 WHEN r2.grade=4 THEN 3 ELSE 1 END
                        ))
                        FROM reviews r2
                        JOIN cards c2 ON c2.id = r2.card_id
                        WHERE r2.user_id = r.user_id 
                          AND c2.deck_id = d.id 
                          AND DATE(r2.reviewed_at) = DATE(r.reviewed_at)
                    ) AS details
                FROM reviews r
                JOIN cards c ON c.id = r.card_id
                JOIN decks d ON d.id = c.deck_id
                WHERE r.user_id = ?
                GROUP BY d.id, DATE(r.reviewed_at)
                
                UNION ALL
                
                SELECT 
                    t.client_result_id AS id,
                    t.scope_name AS title,
                    'test_session' AS type,
                    t.total_q AS cards_reviewed,
                    COALESCE(t.xp_earned, (t.correct * 3 + (CASE WHEN t.is_perfect = 1 THEN 5 ELSE 0 END))) AS xp_earned,
                    t.finished_at AS created_at,
                    (
                        SELECT json_group_array(json_object(
                            'front', ta.front,
                            'back', ta.back,
                            'note', ta.note,
                            'chosen', ta.chosen,
                            'correct', ta.correct,
                            'is_correct', ta.is_correct,
                            'xp_earned', COALESCE(ta.xp_earned, CASE WHEN ta.is_correct = 1 THEN 3 ELSE 0 END)
                        ))
                        FROM test_attempt_answers ta
                        WHERE ta.attempt_id = t.id
                    ) AS details
                FROM test_attempts t
                WHERE t.user_id = ?
            )
            ORDER BY created_at DESC
            LIMIT ?
        """, (user["id"], user["id"], limit)).fetchall()
    finally:
        conn.close()

    items = []
    for row in rows:
        details_list = json.loads(row["details"]) if row["details"] else []
        parsed_details = []
        if row["type"] == "test_session":
            for d in details_list:
                is_correct = d.get("is_correct") == 1 or d.get("is_correct") is True
                filtered = _parse_and_filter_test_options(
                    d.get("chosen"), d.get("correct"), is_correct, d.get("note"), d.get("back")
                )
                filtered["front"] = d.get("front")
                parsed_details.append(filtered)
        else:
            parsed_details = details_list

        items.append({
            "id": row["id"] or "",
            "type": row["type"],
            "title": row["title"],
            "cards_reviewed": row["cards_reviewed"],
            "xp_earned": row["xp_earned"] or 0,
            "created_at": row["created_at"],
            "details": parsed_details
        })

    return jsonify({"data": items})

