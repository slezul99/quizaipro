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

# Shared definition of evolution stages for the Knowledge Tree
EVOLUTION_STAGES = [
    {"key": "seed", "start_days": 0, "next_stage_days": 3},
    {"key": "sprout", "start_days": 3, "next_stage_days": 7},
    {"key": "young_tree", "start_days": 7, "next_stage_days": 14},
    {"key": "blooming_tree", "start_days": 14, "next_stage_days": 30},
    {"key": "ancient_tree", "start_days": 30, "next_stage_days": 60},
    {"key": "legendary_tree", "start_days": 60, "next_stage_days": None},
]

# Slovar' dlya bystrogo dostupa
ACH_BY_KEY = {a["key"]: a for a in ACHIEVEMENTS}

# EN/UZ translations of each achievement (name, desc). RU is the default above.
ACH_I18N = {
    "en": {
        "first_step": ("First Step", "Learn your first card"),
        "ten_cards": ("Ten", "Learn 10 cards"),
        "hundred_cards": ("Century", "Learn 100 cards"),
        "thousand_cards": ("Thousandaire", "Learn 1000 cards"),
        "streak_3": ("Warming Up", "3 days in a row"),
        "streak_7": ("Week of Power", "7 days in a row"),
        "streak_30": ("Flawless Month", "30 days in a row"),
        "streak_100": ("King of Discipline", "100 days in a row"),
        "perfect_test": ("Perfect Test", "Score 100% on a test"),
        "speed_demon": ("Speed Demon", "Finish top-3 in a Live test"),
        "xp_500": ("Little Star", "Earn 500 XP"),
        "xp_2000": ("Rising Star", "Earn 2000 XP"),
        "xp_10000": ("Superstar", "Earn 10000 XP"),
        "early_bird": ("Early Bird", "Study before 7 AM"),
        "night_owl": ("Night Owl", "Study after midnight"),
        "weekend_warrior": ("Weekend Warrior", "Study on Saturday or Sunday"),
        "deck_master": ("Deck Master", "Master all cards in a deck"),
        "goal_done": ("Goal-Getter", "Complete your daily goal"),
        "goal_x5": ("Overachiever", "Complete your goal 5 times"),
        "first_test": ("First Test", "Complete your first test"),
        "test_x10": ("Tester", "Complete 10 tests"),
        "test_x50": ("Test Master", "Complete 50 tests"),
        "first_match": ("First Match", "Play your first Match"),
        "match_x10": ("Matcher", "Play 10 Matches"),
        "first_duel": ("First Duel", "Play your first duel"),
        "duel_x10": ("Duelist", "Play 10 duels"),
        "duel_win": ("Duel Victory", "Win your first duel"),
        "duel_win_x5": ("Serial Winner", "Win 5 duels"),
        "duel_win_x20": ("Duel Champion", "Win 20 duels"),
        "first_live": ("First Live Game", "Play a Live test"),
        "live_host": ("Host", "Host your first Live test"),
        "live_x10": ("Live Player", "Play 10 Live tests"),
    },
    "uz": {
        "first_step": ("Birinchi qadam", "Birinchi kartangizni o'rganing"),
        "ten_cards": ("O'nlik", "10 ta karta o'rganing"),
        "hundred_cards": ("Yuzlik", "100 ta karta o'rganing"),
        "thousand_cards": ("Minglik", "1000 ta karta o'rganing"),
        "streak_3": ("Qizib olmoqda", "Ketma-ket 3 kun"),
        "streak_7": ("Kuch haftasi", "Ketma-ket 7 kun"),
        "streak_30": ("Uzluksiz oy", "Ketma-ket 30 kun"),
        "streak_100": ("Intizom qiroli", "Ketma-ket 100 kun"),
        "perfect_test": ("Mukammal test", "Testni 100% bajaring"),
        "speed_demon": ("Tezlik jini", "Live testda top-3 ga kiring"),
        "xp_500": ("Yulduzcha", "500 XP to'plang"),
        "xp_2000": ("Ko'tarilayotgan yulduz", "2000 XP to'plang"),
        "xp_10000": ("Superyulduz", "10000 XP to'plang"),
        "early_bird": ("Erta qush", "Ertalab 7 gacha o'qing"),
        "night_owl": ("Tungi boyqush", "Yarim tundan keyin o'qing"),
        "weekend_warrior": ("Dam olish jangchisi", "Shanba yoki yakshanba kuni o'qing"),
        "deck_master": ("To'plam ustasi", "To'plamdagi barcha kartalarni o'zlashtiring"),
        "goal_done": ("Maqsadli", "Kunlik maqsadni bajaring"),
        "goal_x5": ("Ortig'i bilan", "Maqsadni 5 marta bajaring"),
        "first_test": ("Birinchi test", "Birinchi testni bajaring"),
        "test_x10": ("Sinovchi", "10 ta test bajaring"),
        "test_x50": ("Test ustasi", "50 ta test bajaring"),
        "first_match": ("Birinchi juftlik", "Birinchi Match o'ynang"),
        "match_x10": ("Moslashtiruvchi", "10 ta Match o'ynang"),
        "first_duel": ("Birinchi duel", "Birinchi duelni o'ynang"),
        "duel_x10": ("Duelchi", "10 ta duel o'ynang"),
        "duel_win": ("Duel g'alabasi", "Birinchi duelda g'alaba qozoning"),
        "duel_win_x5": ("Ketma-ket g'olib", "5 ta duelda g'alaba qozoning"),
        "duel_win_x20": ("Duel chempioni", "20 ta duelda g'alaba qozoning"),
        "first_live": ("Birinchi jonli o'yin", "Live testda o'ynang"),
        "live_host": ("Boshlovchi", "Birinchi Live testni o'tkazing"),
        "live_x10": ("Jonli o'yinchi", "10 ta Live test o'ynang"),
    },
}


def localize(items, lang):
    """Return achievement items with name/desc swapped to `lang` (RU = default)."""
    tr = ACH_I18N.get(lang)
    if not tr:
        return items
    out = []
    for it in items:
        d = dict(it)
        pair = tr.get(d.get("key"))
        if pair:
            d["name"], d["desc"] = pair
        out.append(d)
    return out


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


def xp_required(L):
    """Option E: XP required to go from level L to L+1, capped at 1000 XP."""
    return min(50 * L + 50, 1000)



def calculate_level_info(xp):
    """Calculates user level info based on cumulative XP under Option E."""
    if xp is None:
        xp = 0
    L = 1
    remaining_xp = xp
    while True:
        req = xp_required(L)
        if remaining_xp >= req:
            remaining_xp -= req
            L += 1
        else:
            break

    req = xp_required(L)
    progress_ratio = remaining_xp / float(req) if req > 0 else 0.0

    # Determine Tier: Novice (1-5), Scholar (6-15), Master (16-30), Sage (31-50), Grandmaster (51-100), Legend (101+)
    if L <= 5:
        tier_key = "novice"
        tier_name = "Novice"
        min_level = 1
        max_level = 5
    elif L <= 15:
        tier_key = "scholar"
        tier_name = "Scholar"
        min_level = 6
        max_level = 15
    elif L <= 30:
        tier_key = "master"
        tier_name = "Master"
        min_level = 16
        max_level = 30
    elif L <= 50:
        tier_key = "sage"
        tier_name = "Sage"
        min_level = 31
        max_level = 50
    elif L <= 100:
        tier_key = "grandmaster"
        tier_name = "Grandmaster"
        min_level = 51
        max_level = 100
    else:
        tier_key = "legend"
        tier_name = "Legend"
        min_level = 101
        max_level = 9999

    return {
        "level": L,
        "total_xp": xp,
        "xp_in_current_level": remaining_xp,
        "xp_for_next_level": req,
        "progress_ratio": progress_ratio,
        "tier": {
            "key": tier_key,
            "name": tier_name,
            "min_level": min_level,
            "max_level": max_level
        }
    }

