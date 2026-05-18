# -*- coding: utf-8 -*-
"""Sistema obuchayuschih celey (learning goals)."""
from datetime import datetime, date, timedelta


# === Mnozhiteli slozhnosti ===
DIFFICULTY_REVIEWS = {
    "easy":   1,
    "medium": 2,
    "hard":   3,
}

# === Bonusy XP ===
DAILY_QUOTA_XP = 30
DAILY_EXTRA_XP = 15
GOAL_COMPLETE_XP = 200
GOAL_EXAM_XP = 300


def collect_card_ids(conn, user, target_type: str, target_id: int) -> list[int]:
    """Sobiraet vse card_id po deck/category."""
    if target_type == "deck":
        rows = conn.execute(
            "SELECT id FROM cards WHERE deck_id=? ORDER BY id", (target_id,)
        ).fetchall()
        return [r["id"] for r in rows]
    if target_type == "category":
        cat_ids = [target_id]
        children = conn.execute(
            "SELECT id FROM categories WHERE parent_id=?", (target_id,)
        ).fetchall()
        cat_ids.extend([c["id"] for c in children])
        ph = ",".join("?" * len(cat_ids))
        if user["org_id"]:
            decks = conn.execute(
                f"SELECT id FROM decks WHERE org_id=? AND category_id IN ({ph})",
                (user["org_id"], *cat_ids)
            ).fetchall()
        else:
            decks = conn.execute(
                f"SELECT id FROM decks WHERE owner_id=? AND category_id IN ({ph})",
                (user["id"], *cat_ids)
            ).fetchall()
        if not decks:
            return []
        deck_ph = ",".join("?" * len(decks))
        cards = conn.execute(
            f"SELECT id FROM cards WHERE deck_id IN ({deck_ph}) ORDER BY id",
            [d["id"] for d in decks]
        ).fetchall()
        return [c["id"] for c in cards]
    return []


def calculate_quota(total_cards: int, days: int, difficulty: str) -> int:
    """Skol'ko otvetov v den' nado. min 5."""
    mult = DIFFICULTY_REVIEWS.get(difficulty, 2)
    total_reviews = total_cards * mult
    days = max(1, days)
    return max(5, (total_reviews + days - 1) // days)


def recommend_activities(daily_quota: int, difficulty: str, solo_mode: bool = False) -> dict:
    """Rekomenduyem skol'ko raz v den' chego delat.
    Vozvrashchaet diktiy {flashcards, tests, duels, live, total_minutes}"""
    if solo_mode:
        # Solo: tol'ko Flashcards + Test, bez duely/live
        return {
            "flashcards": int(daily_quota * 0.7),
            "tests_questions": int(daily_quota * 0.3),
            "duels": 0,
            "live": 0,
            "minutes": int(daily_quota * 0.5),  # ~30 sek na otvet v sredem
            "tests_count": max(1, int(daily_quota * 0.3 / 10)),  # po 10 voprosov v teste
            "solo_mode": True,
        }

    # S sotsial'nymi aktivnostyami
    if difficulty == "easy":
        return {
            "flashcards": int(daily_quota * 0.6),
            "tests_questions": int(daily_quota * 0.3),
            "duels": 1,
            "live": 0,
            "minutes": int(daily_quota * 0.5),
            "tests_count": max(1, int(daily_quota * 0.3 / 10)),
            "solo_mode": False,
        }
    if difficulty == "hard":
        return {
            "flashcards": int(daily_quota * 0.4),
            "tests_questions": int(daily_quota * 0.4),
            "duels": 2,
            "live": 1,
            "minutes": int(daily_quota * 0.7),
            "tests_count": max(2, int(daily_quota * 0.4 / 10)),
            "solo_mode": False,
        }
    # medium
    return {
        "flashcards": int(daily_quota * 0.5),
        "tests_questions": int(daily_quota * 0.4),
        "duels": 1,
        "live": 1,
        "minutes": int(daily_quota * 0.6),
        "tests_count": max(1, int(daily_quota * 0.4 / 10)),
        "solo_mode": False,
    }


def create_goal(conn, user, *, title: str, target_type: str, target_id: int,
                end_date: str, end_time: str = "23:59",
                difficulty: str = "medium",
                exam_required: bool = True,
                solo_mode: bool = False) -> int | None:
    """Sozdayet tsel' s tochnym vremenem ona istekayet."""
    cards = collect_card_ids(conn, user, target_type, target_id)
    if not cards:
        return None
    now = datetime.utcnow()
    today_iso = now.date().isoformat()
    try:
        end_d = date.fromisoformat(end_date)
    except Exception:
        return None
    # Tochnoe vremya istecheniya
    try:
        eh, em = map(int, (end_time or "23:59").split(":"))
    except Exception:
        eh, em = 23, 59
    end_dt = datetime.combine(end_d, datetime.min.time()).replace(hour=eh, minute=em)
    if end_dt <= now:
        return None
    # Skol'ko polnyh dney (s segodnyashnego do end_date vklyuchitelno)
    days = (end_d - now.date()).days + 1
    if days < 1: days = 1
    quota = calculate_quota(len(cards), days, difficulty)
    cur = conn.execute("""
        INSERT INTO learning_goals
            (user_id, title, target_type, target_id, difficulty,
             start_date, end_date, start_at, end_at,
             total_cards, daily_quota, exam_required, solo_mode)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (user["id"], title, target_type, target_id, difficulty,
          today_iso, end_date, now.isoformat(), end_dt.isoformat(),
          len(cards), quota, 1 if exam_required else 0,
          1 if solo_mode else 0))
    conn.commit()
    return cur.lastrowid


def get_today_progress(conn, user_id: int, goal: dict) -> dict:
    """Skol'ko ottvet'ov za segodnya."""
    target_type = goal["target_type"]
    target_id = goal["target_id"]
    if target_type == "deck":
        row = conn.execute("""
            SELECT COUNT(*) AS c FROM reviews r
            JOIN cards c ON c.id = r.card_id
            WHERE r.user_id=? AND c.deck_id=?
              AND DATE(r.reviewed_at) = DATE('now')
        """, (user_id, target_id)).fetchone()
        today_count = row["c"] if row else 0
    else:
        cat_ids = [target_id]
        ch = conn.execute("SELECT id FROM categories WHERE parent_id=?", (target_id,)).fetchall()
        cat_ids.extend([c["id"] for c in ch])
        ph = ",".join("?" * len(cat_ids))
        decks = conn.execute(
            f"SELECT id FROM decks WHERE category_id IN ({ph})", cat_ids
        ).fetchall()
        if not decks:
            today_count = 0
        else:
            deck_ph = ",".join("?" * len(decks))
            row = conn.execute(f"""
                SELECT COUNT(*) AS c FROM reviews r
                JOIN cards c ON c.id = r.card_id
                WHERE r.user_id=? AND c.deck_id IN ({deck_ph})
                  AND DATE(r.reviewed_at) = DATE('now')
            """, (user_id, *[d["id"] for d in decks])).fetchone()
            today_count = row["c"] if row else 0

    quota = goal["daily_quota"]
    extras = conn.execute("""
        SELECT COALESCE(SUM(extra_quota), 0) AS s FROM goal_daily_extras
        WHERE goal_id=? AND date = DATE('now')
    """, (goal["id"],)).fetchone()
    extra_quota = extras["s"] if extras else 0
    total_quota = quota + extra_quota
    return {
        "done": today_count,
        "quota": quota,
        "extra_quota": extra_quota,
        "total_quota": total_quota,
        "ratio": min(1.0, today_count / total_quota) if total_quota else 0,
        "completed": today_count >= total_quota,
    }


def get_overall_progress(conn, user_id: int, goal: dict) -> dict:
    cards = collect_card_ids_simple(conn, goal["target_type"], goal["target_id"])
    if not cards:
        return {"learned": 0, "attempted": 0, "total": 0, "ratio": 0}
    ph = ",".join("?" * len(cards))
    row = conn.execute(f"""
        SELECT
            COUNT(DISTINCT card_id) AS attempted,
            SUM(CASE WHEN interval_days >= 7 THEN 1 ELSE 0 END) AS learned
        FROM user_card_progress
        WHERE user_id=? AND card_id IN ({ph})
    """, (user_id, *cards)).fetchone()
    learned = row["learned"] or 0
    attempted = row["attempted"] or 0
    total = len(cards)
    return {
        "learned": learned,
        "attempted": attempted,
        "total": total,
        "ratio": learned / total if total else 0,
    }


def collect_card_ids_simple(conn, target_type: str, target_id: int) -> list[int]:
    if target_type == "deck":
        rows = conn.execute("SELECT id FROM cards WHERE deck_id=?", (target_id,)).fetchall()
        return [r["id"] for r in rows]
    if target_type == "category":
        cat_ids = [target_id]
        ch = conn.execute("SELECT id FROM categories WHERE parent_id=?", (target_id,)).fetchall()
        cat_ids.extend([c["id"] for c in ch])
        ph = ",".join("?" * len(cat_ids))
        decks = conn.execute(
            f"SELECT id FROM decks WHERE category_id IN ({ph})", cat_ids
        ).fetchall()
        if not decks: return []
        deck_ph = ",".join("?" * len(decks))
        rows = conn.execute(
            f"SELECT id FROM cards WHERE deck_id IN ({deck_ph})", [d["id"] for d in decks]
        ).fetchall()
        return [r["id"] for r in rows]
    return []


def is_behind_schedule(goal: dict, overall: dict) -> dict:
    """Otstaet li polzovatel'? Schitaem PO TOCHNOMU VREMENI a ne tol'ko po dnyam."""
    now = datetime.utcnow()
    end_at_str = goal.get("end_at") or goal.get("end_date")
    start_at_str = goal.get("start_at") or goal.get("start_date")
    try:
        if "T" in str(end_at_str):
            end_at = datetime.fromisoformat(end_at_str)
        else:
            end_at = datetime.combine(date.fromisoformat(end_at_str),
                                      datetime.min.time()).replace(hour=23, minute=59)
        if "T" in str(start_at_str):
            start_at = datetime.fromisoformat(start_at_str)
        else:
            start_at = datetime.combine(date.fromisoformat(start_at_str),
                                        datetime.min.time())
    except Exception:
        return {"behind": False, "days_left": 0, "expired": False}

    total_seconds = (end_at - start_at).total_seconds()
    elapsed_seconds = (now - start_at).total_seconds()
    if total_seconds < 1:
        return {"behind": False, "days_left": 0, "expired": True}

    expected_ratio = max(0, min(1.0, elapsed_seconds / total_seconds))
    actual_ratio = overall["ratio"]

    # 15% tolerantnost', no tol'ko esli proshlo bol'she 10% vremeni
    behind = (expected_ratio > 0.1) and (actual_ratio < expected_ratio - 0.15)

    seconds_left = max(0, (end_at - now).total_seconds())
    days_left = int(seconds_left // 86400)
    hours_left = int((seconds_left % 86400) // 3600)
    minutes_left = int((seconds_left % 3600) // 60)
    expired = seconds_left < 1

    return {
        "behind": behind,
        "expected_ratio": expected_ratio,
        "actual_ratio": actual_ratio,
        "days_left": days_left,
        "hours_left": hours_left,
        "minutes_left": minutes_left,
        "seconds_left": int(seconds_left),
        "expired": expired,
        "elapsed_pct": int(expected_ratio * 100),
    }


def add_extra_today(conn, goal_id: int, extra: int) -> bool:
    if extra < 1 or extra > 100:
        return False
    today = date.today().isoformat()
    conn.execute("""
        INSERT INTO goal_daily_extras (goal_id, date, extra_quota)
        VALUES (?, ?, ?)
    """, (goal_id, today, extra))
    conn.commit()
    return True


def extend_deadline(conn, goal_id: int, new_end_date: str, new_end_time: str = "23:59") -> bool:
    """Prodlevaem deadline + uvelichivaem schyotchik."""
    try:
        new_end = date.fromisoformat(new_end_date)
    except Exception:
        return False
    if new_end < date.today():
        return False
    goal = conn.execute("SELECT * FROM learning_goals WHERE id=?", (goal_id,)).fetchone()
    if not goal:
        return False
    try:
        eh, em = map(int, (new_end_time or "23:59").split(":"))
    except Exception:
        eh, em = 23, 59
    new_end_dt = datetime.combine(new_end, datetime.min.time()).replace(hour=eh, minute=em)
    if new_end_dt <= datetime.utcnow():
        return False
    days = (new_end - date.today()).days + 1
    if days < 1: days = 1
    quota = calculate_quota(goal["total_cards"], days, goal["difficulty"])
    conn.execute("""
        UPDATE learning_goals
        SET end_date=?, end_at=?, daily_quota=?, extensions = extensions + 1,
            status='active'
        WHERE id=?
    """, (new_end_date, new_end_dt.isoformat(), quota, goal_id))
    conn.commit()
    return True


def pick_exam_cards(conn, user_id: int, goal: dict, count: int) -> list[int]:
    """Karty s naibol'shim chislom oshibok."""
    cards = collect_card_ids_simple(conn, goal["target_type"], goal["target_id"])
    if not cards:
        return []
    ph = ",".join("?" * len(cards))
    rows = conn.execute(f"""
        SELECT c.id,
            COALESCE((SELECT COUNT(*) FROM reviews r
                      WHERE r.user_id=? AND r.card_id=c.id AND r.grade < 3), 0) AS wrong_count,
            COALESCE((SELECT last_grade FROM user_card_progress p
                      WHERE p.user_id=? AND p.card_id=c.id), 0) AS last_grade
        FROM cards c
        WHERE c.id IN ({ph})
        ORDER BY wrong_count DESC, last_grade ASC, RANDOM()
        LIMIT ?
    """, (user_id, user_id, *cards, count)).fetchall()
    return [r["id"] for r in rows]


def is_reminder_dismissed_today(conn, user_id: int) -> bool:
    today = date.today().isoformat()
    row = conn.execute(
        "SELECT 1 FROM goal_reminders_dismissed WHERE user_id=? AND date=?",
        (user_id, today)
    ).fetchone()
    return row is not None


def dismiss_reminder_today(conn, user_id: int):
    today = date.today().isoformat()
    conn.execute(
        "INSERT OR IGNORE INTO goal_reminders_dismissed (user_id, date) VALUES (?, ?)",
        (user_id, today)
    )
    conn.commit()


def get_active_goals_with_progress(conn, user_id: int) -> list[dict]:
    """Vse aktivnyye + segodnyashniy progress + rekomendatsii."""
    goals = conn.execute("""
        SELECT * FROM learning_goals
        WHERE user_id=? AND status='active'
        ORDER BY end_at ASC, end_date ASC
    """, (user_id,)).fetchall()
    result = []
    for g in goals:
        gd = dict(g)
        gd["today"] = get_today_progress(conn, user_id, gd)
        gd["overall"] = get_overall_progress(conn, user_id, gd)
        gd["status_info"] = is_behind_schedule(gd, gd["overall"])
        gd["recommend"] = recommend_activities(
            gd["daily_quota"], gd["difficulty"],
            solo_mode=bool(gd.get("solo_mode"))
        )
        # Imya target
        if g["target_type"] == "deck":
            d = conn.execute("SELECT name, icon FROM decks WHERE id=?", (g["target_id"],)).fetchone()
            gd["target_name"] = d["name"] if d else "(удалена)"
            gd["target_icon"] = d["icon"] if d else "📚"
        else:
            c = conn.execute("SELECT name, icon FROM categories WHERE id=?", (g["target_id"],)).fetchone()
            gd["target_name"] = c["name"] if c else "(удалена)"
            gd["target_icon"] = c["icon"] if c else "📁"
        result.append(gd)
    return result


def motivation_message(today_progress: dict, status_info: dict) -> str:
    if today_progress["completed"]:
        return "🔥 Дневная цель выполнена! Так держать!"
    if status_info.get("expired"):
        return "⏰ Срок истёк. Можно продлить или попробовать сдать экзамен."
    if status_info.get("behind"):
        days_left = status_info.get("days_left", 0)
        hours_left = status_info.get("hours_left", 0)
        if days_left == 0:
            return f"⚠️ Срок горит — осталось {hours_left} ч. Соберитесь, у вас получится!"
        return f"⚠️ Вы отстаёте. Осталось {days_left} дн. Не сдавайтесь!"
    ratio = today_progress["ratio"]
    if ratio >= 0.7: return "💪 Почти всё! Финальный рывок."
    if ratio >= 0.3: return "📚 Хороший темп, продолжайте!"
    return "🚀 Время заняться целью на сегодня"
