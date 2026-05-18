# -*- coding: utf-8 -*-
"""Sistema achievements (dostizheniyа) dlya QuizPro."""

ACHIEVEMENTS = [
    # Pervye shagi
    {"key": "first_step", "icon": "🌱", "name": "Первый шаг", "desc": "Изучи свою первую карту", "xp": 10},
    {"key": "ten_cards", "icon": "📚", "name": "Десятка", "desc": "Изучи 10 карт", "xp": 20},
    {"key": "hundred_cards", "icon": "💯", "name": "Сотня", "desc": "Изучи 100 карт", "xp": 100},
    {"key": "thousand_cards", "icon": "🏆", "name": "Тысячник", "desc": "Изучи 1000 карт", "xp": 500},

    # Streak
    {"key": "streak_3", "icon": "🔥", "name": "На разогреве", "desc": "3 дня подряд", "xp": 30},
    {"key": "streak_7", "icon": "⚡", "name": "Неделя силы", "desc": "7 дней подряд", "xp": 70},
    {"key": "streak_30", "icon": "💪", "name": "Месяц без пропусков", "desc": "30 дней подряд", "xp": 300},
    {"key": "streak_100", "icon": "👑", "name": "Король дисциплины", "desc": "100 дней подряд", "xp": 1000},

    # Tochnost'
    {"key": "perfect_test", "icon": "🎯", "name": "Идеальный тест", "desc": "Пройди тест на 100%", "xp": 50},
    {"key": "speed_demon", "icon": "⚡", "name": "Скоростной демон", "desc": "Live test за топ-3", "xp": 80},

    # XP
    {"key": "xp_500", "icon": "⭐", "name": "Звездочка", "desc": "Набери 500 XP", "xp": 50},
    {"key": "xp_2000", "icon": "🌟", "name": "Восходящая звезда", "desc": "Набери 2000 XP", "xp": 200},
    {"key": "xp_10000", "icon": "✨", "name": "Суперзвезда", "desc": "Набери 10000 XP", "xp": 1000},

    # Spetsial'nye
    {"key": "early_bird", "icon": "🐦", "name": "Жаворонок", "desc": "Учись до 7 утра", "xp": 30},
    {"key": "night_owl", "icon": "🦉", "name": "Сова", "desc": "Учись после полуночи", "xp": 30},
    {"key": "weekend_warrior", "icon": "⚔️", "name": "Боец выходного дня", "desc": "Учись в субботу или воскресенье", "xp": 25},
    {"key": "deck_master", "icon": "🎓", "name": "Мастер колоды", "desc": "Усвой все карты в колоде", "xp": 150},

    # Dailygoal
    {"key": "goal_done", "icon": "✅", "name": "Целеустремлённый", "desc": "Выполни дневную цель", "xp": 30},
    {"key": "goal_x5", "icon": "🚀", "name": "Перевыполнение", "desc": "Выполни цель 5 раз", "xp": 100},

    # Igrovye dostizheniya
    {"key": "first_test", "icon": "📝", "name": "Первый тест", "desc": "Пройди первый тест", "xp": 20},
    {"key": "test_x10", "icon": "📋", "name": "Тестировщик", "desc": "Пройди 10 тестов", "xp": 80},
    {"key": "test_x50", "icon": "🧠", "name": "Мастер тестов", "desc": "Пройди 50 тестов", "xp": 250},

    {"key": "first_match", "icon": "🎯", "name": "Первая пара", "desc": "Сыграй первый Match", "xp": 20},
    {"key": "match_x10", "icon": "🧩", "name": "Сопоставитель", "desc": "Сыграй 10 Match-ей", "xp": 100},

    {"key": "first_duel", "icon": "⚔️", "name": "Первая дуэль", "desc": "Сыграй первую дуэль", "xp": 30},
    {"key": "duel_x10", "icon": "🛡", "name": "Дуэлянт", "desc": "Сыграй 10 дуэлей", "xp": 150},
    {"key": "duel_win", "icon": "🏅", "name": "Победа в дуэли", "desc": "Выиграй первую дуэль", "xp": 50},
    {"key": "duel_win_x5", "icon": "🥇", "name": "Серийный победитель", "desc": "Выиграй 5 дуэлей", "xp": 200},
    {"key": "duel_win_x20", "icon": "👑", "name": "Чемпион дуэлей", "desc": "Выиграй 20 дуэлей", "xp": 500},

    {"key": "first_live", "icon": "🎮", "name": "Первая live-игра", "desc": "Сыграй в Live test", "xp": 30},
    {"key": "live_host", "icon": "🎤", "name": "Ведущий", "desc": "Проведи свой первый Live test", "xp": 50},
    {"key": "live_x10", "icon": "📡", "name": "Live-игрок", "desc": "Сыграй 10 Live test-ов", "xp": 150},
]

# Slovar' dlya bystrogo dostupa
ACH_BY_KEY = {a["key"]: a for a in ACHIEVEMENTS}


def check_and_award(conn, user_id):
    """Proveryaet vse pravila i dobavlyayet novye achievements.
    Vozvrashhayet spisok TOL'KO chto razblokirovannyh — chtoby pokazat' notifikatsiyu."""
    from datetime import datetime

    # Tekuschie achievements
    unlocked = {row["ach_key"] for row in conn.execute(
        "SELECT ach_key FROM user_achievements WHERE user_id=?", (user_id,)
    ).fetchall()}

    # Dannye polzovatelya
    user = conn.execute("SELECT * FROM users WHERE id=?", (user_id,)).fetchone()
    if not user:
        return []

    # Statistika
    learned_count = conn.execute("""
        SELECT COUNT(*) AS c FROM user_card_progress
        WHERE user_id=? AND interval_days >= 7
    """, (user_id,)).fetchone()["c"] or 0

    streak = user["streak"] or 0
    xp = user["xp"] or 0

    new_unlocks = []

    def award(key):
        if key in unlocked:
            return
        conn.execute("INSERT OR IGNORE INTO user_achievements (user_id, ach_key) VALUES (?,?)",
                     (user_id, key))
        ach = ACH_BY_KEY.get(key)
        if ach:
            new_unlocks.append(ach)
            unlocked.add(key)
            # Bonus XP
            conn.execute("UPDATE users SET xp = xp + ? WHERE id=?", (ach["xp"], user_id))

    # Pravila
    if learned_count >= 1: award("first_step")
    if learned_count >= 10: award("ten_cards")
    if learned_count >= 100: award("hundred_cards")
    if learned_count >= 1000: award("thousand_cards")

    if streak >= 3: award("streak_3")
    if streak >= 7: award("streak_7")
    if streak >= 30: award("streak_30")
    if streak >= 100: award("streak_100")

    if xp >= 500: award("xp_500")
    if xp >= 2000: award("xp_2000")
    if xp >= 10000: award("xp_10000")

    # Vremya sutok (UTC)
    now = datetime.utcnow()
    if now.hour < 7:
        award("early_bird")
    if now.hour >= 0 and now.hour < 4:
        award("night_owl")
    if now.weekday() >= 5:  # 5=sat, 6=sun
        award("weekend_warrior")

    # Idealnyy test (proveryayetsya iz vneshnego koda)
    return new_unlocks


def award_perfect_test(conn, user_id):
    """Vyzyvaetsya kogda polzovatel' proshyel test na 100%."""
    new_unlocks = []
    if not conn.execute(
        "SELECT 1 FROM user_achievements WHERE user_id=? AND ach_key='perfect_test'",
        (user_id,)
    ).fetchone():
        conn.execute("INSERT INTO user_achievements (user_id, ach_key) VALUES (?,'perfect_test')",
                     (user_id,))
        ach = ACH_BY_KEY["perfect_test"]
        conn.execute("UPDATE users SET xp = xp + ? WHERE id=?", (ach["xp"], user_id))
        new_unlocks.append(ach)
    return new_unlocks


def award_goal_done(conn, user_id):
    """Vyzvaetsya kogda dnevnaya tsel' vypolnena."""
    new_unlocks = []
    if not conn.execute(
        "SELECT 1 FROM user_achievements WHERE user_id=? AND ach_key='goal_done'",
        (user_id,)
    ).fetchone():
        conn.execute("INSERT INTO user_achievements (user_id, ach_key) VALUES (?,'goal_done')",
                     (user_id,))
        ach = ACH_BY_KEY["goal_done"]
        conn.execute("UPDATE users SET xp = xp + ? WHERE id=?", (ach["xp"], user_id))
        new_unlocks.append(ach)
    return new_unlocks


def get_user_achievements(conn, user_id):
    """Vozvrashayet spisok vseh achievements s flagom unlocked."""
    unlocked = {row["ach_key"]: row["unlocked_at"]
                for row in conn.execute(
                    "SELECT ach_key, unlocked_at FROM user_achievements WHERE user_id=?",
                    (user_id,)
                ).fetchall()}

    result = []
    for ach in ACHIEVEMENTS:
        item = dict(ach)
        item["unlocked"] = ach["key"] in unlocked
        item["unlocked_at"] = unlocked.get(ach["key"])
        result.append(item)
    return result


def _award(conn, user_id, key, unlocked_set, new_unlocks):
    """Helper: vydaet achievement esli ego eshchyo net."""
    if key in unlocked_set:
        return
    conn.execute("INSERT OR IGNORE INTO user_achievements (user_id, ach_key) VALUES (?,?)",
                 (user_id, key))
    ach = ACH_BY_KEY.get(key)
    if ach:
        conn.execute("UPDATE users SET xp = xp + ? WHERE id=?", (ach["xp"], user_id))
        new_unlocks.append(ach)
        unlocked_set.add(key)


def _ensure_stats_row(conn, user_id):
    conn.execute("INSERT OR IGNORE INTO user_game_stats (user_id) VALUES (?)", (user_id,))


def award_test_completed(conn, user_id, perfect=False):
    """Posle prokhozhdeniya testa."""
    _ensure_stats_row(conn, user_id)
    conn.execute("UPDATE user_game_stats SET tests_played = tests_played + 1 WHERE user_id=?",
                 (user_id,))
    row = conn.execute("SELECT tests_played FROM user_game_stats WHERE user_id=?",
                       (user_id,)).fetchone()
    n = row["tests_played"] if row else 0
    unlocked = {r["ach_key"] for r in conn.execute(
        "SELECT ach_key FROM user_achievements WHERE user_id=?", (user_id,)).fetchall()}
    new_unlocks = []
    if n >= 1: _award(conn, user_id, "first_test", unlocked, new_unlocks)
    if n >= 10: _award(conn, user_id, "test_x10", unlocked, new_unlocks)
    if n >= 50: _award(conn, user_id, "test_x50", unlocked, new_unlocks)
    if perfect:
        _award(conn, user_id, "perfect_test", unlocked, new_unlocks)
    return new_unlocks


def award_match_completed(conn, user_id, pairs=0, time_sec=0):
    """Posle Match-igry."""
    _ensure_stats_row(conn, user_id)
    conn.execute("""UPDATE user_game_stats
        SET match_played = match_played + 1,
            match_total_pairs = match_total_pairs + ?,
            match_best_time = CASE WHEN match_best_time = 0 OR match_best_time > ? THEN ? ELSE match_best_time END
        WHERE user_id=?""", (pairs, time_sec, time_sec, user_id))
    row = conn.execute("SELECT match_played FROM user_game_stats WHERE user_id=?",
                       (user_id,)).fetchone()
    n = row["match_played"] if row else 0
    unlocked = {r["ach_key"] for r in conn.execute(
        "SELECT ach_key FROM user_achievements WHERE user_id=?", (user_id,)).fetchall()}
    new_unlocks = []
    if n >= 1: _award(conn, user_id, "first_match", unlocked, new_unlocks)
    if n >= 10: _award(conn, user_id, "match_x10", unlocked, new_unlocks)
    return new_unlocks


def award_duel_completed(conn, user_id, won=False, lost=False, draw=False):
    """Posle dueli."""
    _ensure_stats_row(conn, user_id)
    fields = ["duels_played = duels_played + 1"]
    if won: fields.append("duels_won = duels_won + 1")
    if lost: fields.append("duels_lost = duels_lost + 1")
    if draw: fields.append("duels_draw = duels_draw + 1")
    conn.execute(f"UPDATE user_game_stats SET {', '.join(fields)} WHERE user_id=?", (user_id,))
    row = conn.execute("SELECT duels_played, duels_won FROM user_game_stats WHERE user_id=?",
                       (user_id,)).fetchone()
    n = row["duels_played"] if row else 0
    nw = row["duels_won"] if row else 0
    unlocked = {r["ach_key"] for r in conn.execute(
        "SELECT ach_key FROM user_achievements WHERE user_id=?", (user_id,)).fetchall()}
    new_unlocks = []
    if n >= 1: _award(conn, user_id, "first_duel", unlocked, new_unlocks)
    if n >= 10: _award(conn, user_id, "duel_x10", unlocked, new_unlocks)
    if nw >= 1: _award(conn, user_id, "duel_win", unlocked, new_unlocks)
    if nw >= 5: _award(conn, user_id, "duel_win_x5", unlocked, new_unlocks)
    if nw >= 20: _award(conn, user_id, "duel_win_x20", unlocked, new_unlocks)
    return new_unlocks


def award_live_completed(conn, user_id, was_host=False):
    """Posle Live test-a."""
    _ensure_stats_row(conn, user_id)
    if was_host:
        conn.execute("UPDATE user_game_stats SET live_hosted = live_hosted + 1 WHERE user_id=?",
                     (user_id,))
    else:
        conn.execute("UPDATE user_game_stats SET live_played = live_played + 1 WHERE user_id=?",
                     (user_id,))
    row = conn.execute("SELECT live_played, live_hosted FROM user_game_stats WHERE user_id=?",
                       (user_id,)).fetchone()
    np = row["live_played"] if row else 0
    nh = row["live_hosted"] if row else 0
    unlocked = {r["ach_key"] for r in conn.execute(
        "SELECT ach_key FROM user_achievements WHERE user_id=?", (user_id,)).fetchall()}
    new_unlocks = []
    if np >= 1: _award(conn, user_id, "first_live", unlocked, new_unlocks)
    if np >= 10: _award(conn, user_id, "live_x10", unlocked, new_unlocks)
    if nh >= 1: _award(conn, user_id, "live_host", unlocked, new_unlocks)
    return new_unlocks


def get_user_game_stats(conn, user_id):
    """Vozvrashchaet schyotchiki igr per-user."""
    _ensure_stats_row(conn, user_id)
    row = conn.execute("SELECT * FROM user_game_stats WHERE user_id=?", (user_id,)).fetchone()
    if not row:
        return {}
    return dict(row)
