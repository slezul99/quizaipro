# -*- coding: utf-8 -*-
"""SQLite database layer dlya QuizPro. Multi-tenant: org/role/group/category."""
import sqlite3
from pathlib import Path
import os

# Production (Railway): /data/quizpro.db (persistent volume)
# Lokal'no: <project>/quizpro.db
_DATA_DIR = os.environ.get("DATA_DIR") or str(Path(__file__).resolve().parent)
DB_PATH = Path(_DATA_DIR) / "quizpro.db"
DB_PATH.parent.mkdir(parents=True, exist_ok=True)


def get_conn():
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db():
    """Sozdayot tablitsy esli ih net."""
    conn = get_conn()
    c = conn.cursor()
    c.executescript("""
    -- Organizatsii (uchebnye centry). Individual'nye user'y - org_id IS NULL.
    CREATE TABLE IF NOT EXISTS organizations (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT NOT NULL,
        slug         TEXT UNIQUE,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP
    );

    -- Polzovateli. role: admin/teacher/student/individual
    CREATE TABLE IF NOT EXISTS users (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        org_id       INTEGER,            -- NULL = individual
        username     TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        role         TEXT NOT NULL DEFAULT 'individual',
        full_name    TEXT DEFAULT '',
        lang         TEXT DEFAULT 'ru',
        xp           INTEGER DEFAULT 0,
        streak       INTEGER DEFAULT 0,
        last_study   TEXT,
        daily_goal   INTEGER DEFAULT 20,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(org_id, username),
        FOREIGN KEY(org_id) REFERENCES organizations(id) ON DELETE CASCADE
    );

    -- Gruppy (tol'ko v korporativnom rejime)
    CREATE TABLE IF NOT EXISTS groups (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        org_id       INTEGER NOT NULL,
        name         TEXT NOT NULL,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(org_id) REFERENCES organizations(id) ON DELETE CASCADE
    );

    -- Polzovatel' v gruppe (mnogo-ko-mnogo)
    CREATE TABLE IF NOT EXISTS group_members (
        group_id     INTEGER NOT NULL,
        user_id      INTEGER NOT NULL,
        PRIMARY KEY(group_id, user_id),
        FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Kategorii (tema/predmet). org_id NULL = lichnaya kategoriya individuala.
    -- parent_id = NULL znachit eto root (Английский), ne NULL = podkategoriya (Beginner)
    CREATE TABLE IF NOT EXISTS categories (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        org_id       INTEGER,
        owner_id     INTEGER,            -- dlya individualnyh
        parent_id    INTEGER,            -- ssylka na roditel'skuyu kategoriyu (ierarchiya)
        name         TEXT NOT NULL,
        icon         TEXT DEFAULT '📁',
        color        TEXT DEFAULT '#3b82f6',
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(org_id) REFERENCES organizations(id) ON DELETE CASCADE,
        FOREIGN KEY(owner_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(parent_id) REFERENCES categories(id) ON DELETE CASCADE
    );

    -- Kolody (= testy). Mogut otnosit'sya k kategorii i organizatsii ili k owner_id.
    CREATE TABLE IF NOT EXISTS decks (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        org_id       INTEGER,
        owner_id     INTEGER,            -- individualnyy hozhain (esli net org)
        category_id  INTEGER,
        name         TEXT NOT NULL,
        icon         TEXT DEFAULT '📚',
        description  TEXT DEFAULT '',
        is_public    INTEGER DEFAULT 0,
        clones_count INTEGER DEFAULT 0,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(org_id) REFERENCES organizations(id) ON DELETE CASCADE,
        FOREIGN KEY(owner_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE SET NULL
    );

    -- Karty
    CREATE TABLE IF NOT EXISTS cards (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        deck_id      INTEGER NOT NULL,
        front        TEXT NOT NULL,
        back         TEXT NOT NULL,
        note         TEXT DEFAULT '',
        image_url    TEXT DEFAULT '',
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(deck_id) REFERENCES decks(id) ON DELETE CASCADE
    );

    -- Progress polzovatelya po karte (na uroven' user-a, ne karty!)
    -- Tak student vidit svoy progress po obshchey karte, drugoy student - svoy.
    CREATE TABLE IF NOT EXISTS user_card_progress (
        user_id      INTEGER NOT NULL,
        card_id      INTEGER NOT NULL,
        ef           REAL DEFAULT 2.5,
        interval_days INTEGER DEFAULT 0,
        reviews      INTEGER DEFAULT 0,
        lapses       INTEGER DEFAULT 0,
        due_at       TEXT,
        last_grade   INTEGER,
        last_reviewed TEXT,
        PRIMARY KEY(user_id, card_id),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(card_id) REFERENCES cards(id) ON DELETE CASCADE
    );

    -- Log vseh povtoreniy
    CREATE TABLE IF NOT EXISTS reviews (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id      INTEGER NOT NULL,
        card_id      INTEGER NOT NULL,
        grade        INTEGER NOT NULL,
        reviewed_at  TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(card_id) REFERENCES cards(id) ON DELETE CASCADE
    );

    -- Achievements (dostizheniya)
    CREATE TABLE IF NOT EXISTS user_achievements (
        user_id      INTEGER NOT NULL,
        ach_key      TEXT NOT NULL,
        unlocked_at  TEXT DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(user_id, ach_key),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Druzhba mezhdu polzovatelyami (oba storony posle accept)
    CREATE TABLE IF NOT EXISTS friendships (
        from_id      INTEGER NOT NULL,
        to_id        INTEGER NOT NULL,
        status       TEXT DEFAULT 'pending', -- pending, accepted
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(from_id, to_id),
        FOREIGN KEY(from_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(to_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Uvedomleniya
    CREATE TABLE IF NOT EXISTS notifications (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id      INTEGER NOT NULL,
        type         TEXT NOT NULL,
        message      TEXT NOT NULL,
        link         TEXT DEFAULT '',
        is_read      INTEGER DEFAULT 0,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_notif_user ON notifications(user_id, is_read);

    -- CHATS / GROUPS / CHANNELS
    CREATE TABLE IF NOT EXISTS chats (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        type         TEXT NOT NULL,        -- dm / group / channel
        name         TEXT DEFAULT '',
        owner_id     INTEGER,
        is_public    INTEGER DEFAULT 0,    -- dlya kanalov (mozhno naydtit')
        avatar       TEXT DEFAULT '💬',
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(owner_id) REFERENCES users(id) ON DELETE SET NULL
    );

    CREATE TABLE IF NOT EXISTS chat_members (
        chat_id      INTEGER NOT NULL,
        user_id      INTEGER NOT NULL,
        role         TEXT DEFAULT 'member',  -- owner / admin / member
        joined_at    TEXT DEFAULT CURRENT_TIMESTAMP,
        last_read_at TEXT,
        PRIMARY KEY(chat_id, user_id),
        FOREIGN KEY(chat_id) REFERENCES chats(id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_chat_members_user ON chat_members(user_id);

    CREATE TABLE IF NOT EXISTS messages (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id      INTEGER NOT NULL,
        user_id      INTEGER NOT NULL,
        content      TEXT NOT NULL,
        is_pinned    INTEGER DEFAULT 0,
        edited_at    TEXT,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(chat_id) REFERENCES chats(id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_msg_chat ON messages(chat_id, created_at);

    -- Reactions na messages
    CREATE TABLE IF NOT EXISTS message_reactions (
        message_id   INTEGER NOT NULL,
        user_id      INTEGER NOT NULL,
        emoji        TEXT NOT NULL,
        PRIMARY KEY(message_id, user_id, emoji),
        FOREIGN KEY(message_id) REFERENCES messages(id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_reactions_msg ON message_reactions(message_id);

    -- STUDY GROUPS (komandы dlya sovmesnogo izucheniya)
    CREATE TABLE IF NOT EXISTS study_groups (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT NOT NULL,
        owner_id     INTEGER NOT NULL,
        description  TEXT DEFAULT '',
        avatar       TEXT DEFAULT '🎓',
        is_public    INTEGER DEFAULT 1,
        chat_id      INTEGER,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(owner_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(chat_id) REFERENCES chats(id) ON DELETE SET NULL
    );

    CREATE TABLE IF NOT EXISTS study_group_members (
        group_id     INTEGER NOT NULL,
        user_id      INTEGER NOT NULL,
        role         TEXT DEFAULT 'member',
        joined_at    TEXT DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(group_id, user_id),
        FOREIGN KEY(group_id) REFERENCES study_groups(id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Kolody, dobavlennye v gruppu
    CREATE TABLE IF NOT EXISTS study_group_decks (
        group_id     INTEGER NOT NULL,
        deck_id      INTEGER NOT NULL,
        added_by     INTEGER,
        added_at     TEXT DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(group_id, deck_id),
        FOREIGN KEY(group_id) REFERENCES study_groups(id) ON DELETE CASCADE,
        FOREIGN KEY(deck_id) REFERENCES decks(id) ON DELETE CASCADE,
        FOREIGN KEY(added_by) REFERENCES users(id) ON DELETE SET NULL
    );

    -- DUELS (1vs1 multiplayer quiz)
    CREATE TABLE IF NOT EXISTS duels (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        player1_id   INTEGER NOT NULL,
        player2_id   INTEGER NOT NULL,
        deck_id      INTEGER NOT NULL,
        question_count INTEGER DEFAULT 5,
        time_per_q   INTEGER DEFAULT 15,
        status       TEXT DEFAULT 'pending', -- pending / running / finished / declined
        current_idx  INTEGER DEFAULT 0,
        question_started_at TEXT,
        winner_id    INTEGER,
        p1_score     INTEGER DEFAULT 0,
        p2_score     INTEGER DEFAULT 0,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        finished_at  TEXT,
        FOREIGN KEY(player1_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(player2_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(deck_id) REFERENCES decks(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS duel_cards (
        duel_id      INTEGER NOT NULL,
        position     INTEGER NOT NULL,
        card_id      INTEGER NOT NULL,
        PRIMARY KEY(duel_id, position),
        FOREIGN KEY(duel_id) REFERENCES duels(id) ON DELETE CASCADE,
        FOREIGN KEY(card_id) REFERENCES cards(id) ON DELETE CASCADE
    );

    -- TOURNAMENTS (turnir s bracket)
    CREATE TABLE IF NOT EXISTS tournaments (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT NOT NULL,
        creator_id   INTEGER NOT NULL,
        deck_id      INTEGER NOT NULL,
        size         INTEGER NOT NULL,
        status       TEXT DEFAULT 'open',
        winner_id    INTEGER,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        finished_at  TEXT,
        FOREIGN KEY(creator_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(deck_id) REFERENCES decks(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS tournament_players (
        tournament_id INTEGER NOT NULL,
        user_id       INTEGER NOT NULL,
        slot          INTEGER NOT NULL,
        joined_at     TEXT DEFAULT CURRENT_TIMESTAMP,
        eliminated_at TEXT,
        PRIMARY KEY(tournament_id, user_id),
        FOREIGN KEY(tournament_id) REFERENCES tournaments(id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS tournament_matches (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id INTEGER NOT NULL,
        round        INTEGER NOT NULL,
        bracket_pos  INTEGER NOT NULL,
        player1_id   INTEGER,
        player2_id   INTEGER,
        winner_id    INTEGER,
        duel_id      INTEGER,
        status       TEXT DEFAULT 'pending',
        FOREIGN KEY(tournament_id) REFERENCES tournaments(id) ON DELETE CASCADE,
        FOREIGN KEY(duel_id) REFERENCES duels(id) ON DELETE SET NULL
    );

    CREATE TABLE IF NOT EXISTS duel_answers (
        duel_id      INTEGER NOT NULL,
        user_id      INTEGER NOT NULL,
        question_idx INTEGER NOT NULL,
        chosen       TEXT,
        is_correct   INTEGER DEFAULT 0,
        time_taken   INTEGER DEFAULT 0,
        score_gain   INTEGER DEFAULT 0,
        answered_at  TEXT DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(duel_id, user_id, question_idx),
        FOREIGN KEY(duel_id) REFERENCES duels(id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    CREATE INDEX IF NOT EXISTS idx_users_org ON users(org_id);
    CREATE INDEX IF NOT EXISTS idx_decks_org ON decks(org_id);
    CREATE INDEX IF NOT EXISTS idx_decks_owner ON decks(owner_id);
    CREATE INDEX IF NOT EXISTS idx_cards_deck ON cards(deck_id);
    CREATE INDEX IF NOT EXISTS idx_progress_user ON user_card_progress(user_id);
    CREATE INDEX IF NOT EXISTS idx_progress_due ON user_card_progress(due_at);
    CREATE INDEX IF NOT EXISTS idx_reviews_user ON reviews(user_id, reviewed_at);

    -- LIVE TEST: sessii, uchasniki i otvety
    CREATE TABLE IF NOT EXISTS live_sessions (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        code         TEXT UNIQUE NOT NULL,
        deck_id      INTEGER NOT NULL,
        host_id      INTEGER NOT NULL,
        host_role    TEXT DEFAULT 'observer',  -- observer / participant
        question_count INTEGER DEFAULT 10,
        time_per_q   INTEGER DEFAULT 20,
        status       TEXT DEFAULT 'waiting',
        current_idx  INTEGER DEFAULT 0,
        started_at   TEXT,
        finished_at  TEXT,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        question_started_at TEXT,
        FOREIGN KEY(deck_id) REFERENCES decks(id) ON DELETE CASCADE,
        FOREIGN KEY(host_id) REFERENCES users(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS live_session_cards (
        session_id   INTEGER NOT NULL,
        position     INTEGER NOT NULL,
        card_id      INTEGER NOT NULL,
        PRIMARY KEY(session_id, position),
        FOREIGN KEY(session_id) REFERENCES live_sessions(id) ON DELETE CASCADE,
        FOREIGN KEY(card_id) REFERENCES cards(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS live_participants (
        session_id   INTEGER NOT NULL,
        user_id      INTEGER NOT NULL,
        joined_at    TEXT DEFAULT CURRENT_TIMESTAMP,
        score        INTEGER DEFAULT 0,
        correct_count INTEGER DEFAULT 0,
        wrong_count  INTEGER DEFAULT 0,
        PRIMARY KEY(session_id, user_id),
        FOREIGN KEY(session_id) REFERENCES live_sessions(id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS live_answers (
        session_id   INTEGER NOT NULL,
        user_id      INTEGER NOT NULL,
        question_idx INTEGER NOT NULL,
        chosen       TEXT,
        is_correct   INTEGER DEFAULT 0,
        time_taken   INTEGER DEFAULT 0,
        answered_at  TEXT DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(session_id, user_id, question_idx),
        FOREIGN KEY(session_id) REFERENCES live_sessions(id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    -- Tikety podderzhki (chat polzovatelya s super-adminom)
    CREATE TABLE IF NOT EXISTS support_tickets (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id       INTEGER NOT NULL,
        subject       TEXT,
        status        TEXT DEFAULT 'open',  -- open / closed
        last_activity TEXT DEFAULT CURRENT_TIMESTAMP,
        created_at    TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_support_user ON support_tickets(user_id);
    CREATE INDEX IF NOT EXISTS idx_support_status ON support_tickets(status, last_activity);

    -- Soobshcheniya v podderzhkę
    CREATE TABLE IF NOT EXISTS support_messages (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket_id    INTEGER NOT NULL,
        sender_id    INTEGER NOT NULL,
        is_admin     INTEGER DEFAULT 0,
        text         TEXT NOT NULL,
        is_read      INTEGER DEFAULT 0,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(ticket_id) REFERENCES support_tickets(id) ON DELETE CASCADE,
        FOREIGN KEY(sender_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_support_msg_ticket ON support_messages(ticket_id);
    """)
    # Dobavlyaem parent_id v sushchestvuyushchuyu BD esli kolonki net (migratsiya)
    try:
        c.execute("ALTER TABLE categories ADD COLUMN parent_id INTEGER REFERENCES categories(id) ON DELETE CASCADE")
    except sqlite3.OperationalError:
        pass  # Kolonka uzhe est'
    c.execute("CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id)")
    # Dobavlyaem image_url v cards (migratsiya sushchestvuyushchey BD)
    try:
        c.execute("ALTER TABLE cards ADD COLUMN image_url TEXT DEFAULT ''")
    except sqlite3.OperationalError:
        pass
    # Dobavlyaem daily_goal v users (migratsiya)
    try:
        c.execute("ALTER TABLE users ADD COLUMN daily_goal INTEGER DEFAULT 20")
    except sqlite3.OperationalError:
        pass
    # is_public i clones_count v decks (marketplace)
    try:
        c.execute("ALTER TABLE decks ADD COLUMN is_public INTEGER DEFAULT 0")
    except sqlite3.OperationalError:
        pass
    try:
        c.execute("ALTER TABLE decks ADD COLUMN clones_count INTEGER DEFAULT 0")
    except sqlite3.OperationalError:
        pass
    # Privacy nastroyki polzovatelya
    try:
        c.execute("ALTER TABLE users ADD COLUMN profile_public INTEGER DEFAULT 1")
    except sqlite3.OperationalError:
        pass
    try:
        c.execute("ALTER TABLE users ADD COLUMN show_in_leaderboard INTEGER DEFAULT 1")
    except sqlite3.OperationalError:
        pass
    try:
        c.execute("ALTER TABLE users ADD COLUMN allow_friend_requests INTEGER DEFAULT 1")
    except sqlite3.OperationalError:
        pass
    # Messages: is_pinned, edited_at
    try:
        c.execute("ALTER TABLE messages ADD COLUMN is_pinned INTEGER DEFAULT 0")
    except sqlite3.OperationalError:
        pass
    try:
        c.execute("ALTER TABLE messages ADD COLUMN edited_at TEXT")
    except sqlite3.OperationalError:
        pass
    # Live: host_role
    try:
        c.execute("ALTER TABLE live_sessions ADD COLUMN host_role TEXT DEFAULT 'observer'")
    except sqlite3.OperationalError:
        pass
    # Live: shuffle_seed dlya peremeshivaniya variantov A/B/C
    try:
        c.execute("ALTER TABLE live_sessions ADD COLUMN shuffle_seed INTEGER DEFAULT 0")
    except sqlite3.OperationalError:
        pass
    # Duels: shuffle_seed
    try:
        c.execute("ALTER TABLE duels ADD COLUMN shuffle_seed INTEGER DEFAULT 0")
    except sqlite3.OperationalError:
        pass
    # Tablitsa schyotchikov igr per-user
    c.execute("""
        CREATE TABLE IF NOT EXISTS user_game_stats (
            user_id      INTEGER PRIMARY KEY,
            tests_played   INTEGER DEFAULT 0,
            tests_correct  INTEGER DEFAULT 0,
            tests_total_q  INTEGER DEFAULT 0,
            match_played   INTEGER DEFAULT 0,
            match_total_pairs INTEGER DEFAULT 0,
            match_best_time INTEGER DEFAULT 0,
            duels_played   INTEGER DEFAULT 0,
            duels_won      INTEGER DEFAULT 0,
            duels_lost     INTEGER DEFAULT 0,
            duels_draw     INTEGER DEFAULT 0,
            live_played    INTEGER DEFAULT 0,
            live_hosted    INTEGER DEFAULT 0,
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
        )
    """)
    # Profil': bio + custom tsvet avatara
    try:
        c.execute("ALTER TABLE users ADD COLUMN bio TEXT DEFAULT ''")
    except sqlite3.OperationalError:
        pass
    try:
        c.execute("ALTER TABLE users ADD COLUMN avatar_color TEXT DEFAULT ''")
    except sqlite3.OperationalError:
        pass
    # Flashcards: izbrannoe i trudnost' (manual)
    try:
        c.execute("ALTER TABLE user_card_progress ADD COLUMN is_favorite INTEGER DEFAULT 0")
    except sqlite3.OperationalError:
        pass
    try:
        c.execute("ALTER TABLE user_card_progress ADD COLUMN is_difficult INTEGER DEFAULT 0")
    except sqlite3.OperationalError:
        pass
    # Welcome tour pokazan li polzovatelyu
    try:
        c.execute("ALTER TABLE users ADD COLUMN welcome_shown INTEGER DEFAULT 0")
    except sqlite3.OperationalError:
        pass

    # last_seen: lyuboy zapros (chtoby znat' kto online seyz)
    try:
        c.execute("ALTER TABLE users ADD COLUMN last_seen TEXT")
    except sqlite3.OperationalError:
        pass

    # MIGRATSIYA: ispravlyaem last_seen format s "T" na " " — strokovoye sravneniye s SQLite datetime
    try:
        c.execute("UPDATE users SET last_seen = REPLACE(last_seen, 'T', ' ') WHERE last_seen LIKE '%T%'")
    except sqlite3.OperationalError:
        pass

    # is_beta_tester: bezlimit AI Vision dlya beta-testerov (super-admin upravlyaet)
    try:
        c.execute("ALTER TABLE users ADD COLUMN is_beta_tester INTEGER DEFAULT 0")
    except sqlite3.OperationalError:
        pass

    # vision_limit_monthly / vision_limit_daily: kastomnye limity AI Vision na polzovatelya
    # NULL = ispolzovat' default po planu (1/mes na free i t.d.)
    # 0 = polnost'yu zapretit'
    # > 0 = konkretnoe chislo
    try:
        c.execute("ALTER TABLE users ADD COLUMN vision_limit_monthly INTEGER")
    except sqlite3.OperationalError:
        pass
    try:
        c.execute("ALTER TABLE users ADD COLUMN vision_limit_daily INTEGER")
    except sqlite3.OperationalError:
        pass

    # ai_limit_monthly / ai_limit_daily: kastomnye limity OBYCHNOGO AI (text/topic/pdf generation)
    try:
        c.execute("ALTER TABLE users ADD COLUMN ai_limit_monthly INTEGER")
    except sqlite3.OperationalError:
        pass
    try:
        c.execute("ALTER TABLE users ADD COLUMN ai_limit_daily INTEGER")
    except sqlite3.OperationalError:
        pass

    # Avto-otmechaem ranniyh beta-testerov (Saidxon, Malika, farida)
    # Hardcoded usernames — chtoby sozdat' im bezlimit srazu posle deploya
    try:
        c.execute("""
            UPDATE users SET is_beta_tester = 1
            WHERE LOWER(username) IN ('saidxon', 'malika.', 'farida')
              AND (is_beta_tester IS NULL OR is_beta_tester = 0)
        """)
    except sqlite3.OperationalError:
        pass
    # Tip kolody: mcq (testy s variantami) ili terms (slovari/terminy/pravila)
    try:
        c.execute("ALTER TABLE decks ADD COLUMN deck_type TEXT DEFAULT 'mcq'")
    except sqlite3.OperationalError:
        pass

    # Otkuda kolodu sozdana (manual, import, ai_text, ai_topic, ai_pdf, vision_pdf...)
    # Nuzhno chtoby pomnit' ogranicheniya (naprimer, vision_pdf na free — bez publikatsii)
    try:
        c.execute("ALTER TABLE decks ADD COLUMN created_via TEXT DEFAULT ''")
    except sqlite3.OperationalError:
        pass

    # === Flagi soderzhimogo kolody (dlya bystrogo otobrazheniya knopok) ===
    # has_mcq=1 esli est' hot' odna karta s variantami (A) B) C) D))
    # has_terms=1 esli est' hot' odna karta bez variantov (slovar'/termin)
    # NULL = eshchyo ne podschitano (migratsia)
    try:
        c.execute("ALTER TABLE decks ADD COLUMN has_mcq INTEGER DEFAULT NULL")
    except sqlite3.OperationalError:
        pass
    try:
        c.execute("ALTER TABLE decks ADD COLUMN has_terms INTEGER DEFAULT NULL")
    except sqlite3.OperationalError:
        pass

    # === LEARNING GOALS ===
    c.execute("""
        CREATE TABLE IF NOT EXISTS learning_goals (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id      INTEGER NOT NULL,
            title        TEXT NOT NULL,
            target_type  TEXT NOT NULL,    -- 'deck' ili 'category'
            target_id    INTEGER NOT NULL,
            difficulty   TEXT DEFAULT 'medium',  -- easy / medium / hard
            start_date   TEXT NOT NULL,
            end_date     TEXT NOT NULL,
            total_cards  INTEGER DEFAULT 0,
            daily_quota  INTEGER DEFAULT 10,
            status       TEXT DEFAULT 'active',  -- active / completed / failed / abandoned
            exam_required INTEGER DEFAULT 1,
            exam_passed  INTEGER DEFAULT 0,
            exam_score   REAL,
            extensions   INTEGER DEFAULT 0,      -- skol'ko raz prodlevali
            created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
            completed_at TEXT,
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
        )
    """)
    c.execute("CREATE INDEX IF NOT EXISTS idx_goals_user ON learning_goals(user_id, status)")
    # Migratsii: solo_mode + tochnoe vremya
    try:
        c.execute("ALTER TABLE learning_goals ADD COLUMN solo_mode INTEGER DEFAULT 0")
    except sqlite3.OperationalError:
        pass
    try:
        c.execute("ALTER TABLE learning_goals ADD COLUMN start_at TEXT")
    except sqlite3.OperationalError:
        pass
    try:
        c.execute("ALTER TABLE learning_goals ADD COLUMN end_at TEXT")
    except sqlite3.OperationalError:
        pass

    # Mini-tseli na segodnya (dop k dnevnoy norme)
    c.execute("""
        CREATE TABLE IF NOT EXISTS goal_daily_extras (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            goal_id      INTEGER NOT NULL,
            date         TEXT NOT NULL,
            extra_quota  INTEGER NOT NULL,
            done         INTEGER DEFAULT 0,
            FOREIGN KEY(goal_id) REFERENCES learning_goals(id) ON DELETE CASCADE
        )
    """)
    c.execute("CREATE INDEX IF NOT EXISTS idx_extras_goal_date ON goal_daily_extras(goal_id, date)")

    # Otmetka "ne pokazyvat segodnya" dlya napominaniya
    c.execute("""
        CREATE TABLE IF NOT EXISTS goal_reminders_dismissed (
            user_id      INTEGER NOT NULL,
            date         TEXT NOT NULL,
            PRIMARY KEY(user_id, date)
        )
    """)

    # === ISTORIYA TESTOV: kazhdaya popytka kak strochka ===
    c.execute("""
        CREATE TABLE IF NOT EXISTS test_attempts (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id      INTEGER NOT NULL,
            scope_type   TEXT NOT NULL,        -- 'deck' / 'category'
            scope_id     INTEGER NOT NULL,
            scope_name   TEXT,                 -- nazvanie kolody / kategorii (chtoby ne JOIN-it')
            total_q      INTEGER NOT NULL,
            correct      INTEGER NOT NULL,
            wrong        INTEGER NOT NULL,
            score_pct    REAL NOT NULL,
            duration_sec INTEGER DEFAULT 0,
            is_perfect   INTEGER DEFAULT 0,
            started_at   TEXT,
            finished_at  TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
        )
    """)
    c.execute("CREATE INDEX IF NOT EXISTS idx_test_attempts_user ON test_attempts(user_id, finished_at DESC)")
    c.execute("CREATE INDEX IF NOT EXISTS idx_test_attempts_scope ON test_attempts(scope_type, scope_id, finished_at DESC)")

    # === Detali otvetov v ramkakh kazhdoy popytki testa ===
    c.execute("""
        CREATE TABLE IF NOT EXISTS test_attempt_answers (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            attempt_id   INTEGER NOT NULL,
            position     INTEGER NOT NULL,        -- 1, 2, 3...
            card_id      INTEGER,                 -- mozhet byt' NULL esli karta udalena
            front        TEXT NOT NULL,           -- snapshot voprosa (na sluchay esli karta izmenitsya)
            back         TEXT NOT NULL,           -- snapshot pravil'nogo otveta
            note         TEXT,                    -- snapshot variantov MCQ
            chosen       TEXT,                    -- chto vybral polzovatel' (bukva A/B/C/...)
            correct      TEXT,                    -- pravil'naya bukva
            is_correct   INTEGER NOT NULL,        -- 1 / 0
            FOREIGN KEY(attempt_id) REFERENCES test_attempts(id) ON DELETE CASCADE,
            FOREIGN KEY(card_id) REFERENCES cards(id) ON DELETE SET NULL
        )
    """)
    c.execute("CREATE INDEX IF NOT EXISTS idx_test_answers_attempt ON test_attempt_answers(attempt_id, position)")

    # === TUTOR CHAT HISTORY ===
    c.execute("""
        CREATE TABLE IF NOT EXISTS tutor_conversations (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id      INTEGER NOT NULL,
            title        TEXT NOT NULL DEFAULT 'Новый чат',
            pinned       INTEGER DEFAULT 0,
            created_at   TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at   TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
        )
    """)
    c.execute("CREATE INDEX IF NOT EXISTS idx_tutor_conv_user ON tutor_conversations(user_id, updated_at)")

    c.execute("""
        CREATE TABLE IF NOT EXISTS tutor_messages (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            conversation_id INTEGER NOT NULL,
            user_id         INTEGER NOT NULL,
            role            TEXT NOT NULL CHECK(role IN ('user','assistant')),
            content         TEXT NOT NULL,
            created_at      TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(conversation_id) REFERENCES tutor_conversations(id) ON DELETE CASCADE,
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
        )
    """)
    c.execute("CREATE INDEX IF NOT EXISTS idx_tutor_msg_conv ON tutor_messages(conversation_id, created_at)")

    # === COLLECTIONS (Tematicheskie nabory kolod dlya marketplace) ===
    c.execute("""
        CREATE TABLE IF NOT EXISTS collections (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            slug         TEXT UNIQUE NOT NULL,        -- URL-friendly id: 'english-beginner'
            title_ru     TEXT NOT NULL,
            title_en     TEXT NOT NULL,
            title_uz     TEXT NOT NULL,
            desc_ru      TEXT DEFAULT '',
            desc_en      TEXT DEFAULT '',
            desc_uz      TEXT DEFAULT '',
            icon         TEXT DEFAULT '📚',
            color        TEXT DEFAULT '#6366f1',      -- gradient start color
            color2       TEXT DEFAULT '#8b5cf6',      -- gradient end color
            level        TEXT DEFAULT '',             -- 'beginner' / 'intermediate' / 'advanced'
            tags         TEXT DEFAULT '',             -- comma-separated
            sort_order   INTEGER DEFAULT 0,
            is_active    INTEGER DEFAULT 1,
            created_at   TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    c.execute("""
        CREATE TABLE IF NOT EXISTS collection_decks (
            collection_id INTEGER NOT NULL,
            deck_id       INTEGER NOT NULL,
            sort_order    INTEGER DEFAULT 0,
            PRIMARY KEY(collection_id, deck_id),
            FOREIGN KEY(collection_id) REFERENCES collections(id) ON DELETE CASCADE,
            FOREIGN KEY(deck_id) REFERENCES decks(id) ON DELETE CASCADE
        )
    """)
    c.execute("CREATE INDEX IF NOT EXISTS idx_coll_decks ON collection_decks(collection_id, sort_order)")

    # === MIGRATE: refresh has_mcq/has_terms for all existing decks ===
    # Proveryaem BOTH note AND back (starye kolody hranili varianty v back).
    # Esli ranee migrate proshla s nepravil'nym regex — flag mig_v2 zastavit recompute.
    import re as _re_db
    _opt_re_db = _re_db.compile(r"^\s*([A-Da-dА-Гa-г1-4])\s*[\)\.\:\-]\s*\S", _re_db.MULTILINE)

    # Sluzhebnaya tablitsa dlya version-flag migratsiy
    c.execute("""
        CREATE TABLE IF NOT EXISTS app_migrations (
            key TEXT PRIMARY KEY,
            done_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    mig_done = c.execute(
        "SELECT 1 FROM app_migrations WHERE key='mcq_terms_v3_front'"
    ).fetchone()

    try:
        if mig_done:
            decks_to_refresh = c.execute(
                "SELECT id FROM decks WHERE has_mcq IS NULL OR has_terms IS NULL"
            ).fetchall()
        else:
            # Check note + back + front for all decks (v3 adds front field check)
            decks_to_refresh = c.execute("SELECT id FROM decks").fetchall()

        for row in decks_to_refresh:
            did = row[0]
            cards = c.execute(
                "SELECT note, back, front FROM cards WHERE deck_id=?", (did,)
            ).fetchall()
            has_mcq = 0
            has_terms = 0
            for card in cards:
                note = (card[0] or "")
                back = (card[1] or "")
                front = (card[2] or "")
                # Check all three fields for MCQ pattern
                is_mcq = False
                for fld in (note, back, front):
                    matches = _opt_re_db.findall(fld)
                    if len({m.upper() for m in matches}) >= 2:
                        is_mcq = True
                        break
                if is_mcq:
                    has_mcq = 1
                else:
                    has_terms = 1
                if has_mcq and has_terms:
                    break
            c.execute("UPDATE decks SET has_mcq=?, has_terms=? WHERE id=?",
                      (has_mcq, has_terms, did))

        if decks_to_refresh:
            print(f"[DB] Migrated has_mcq/has_terms for {len(decks_to_refresh)} decks (v3)")
        if not mig_done:
            c.execute(
                "INSERT OR IGNORE INTO app_migrations (key) VALUES ('mcq_terms_v3_front')"
            )
    except Exception as e:
        print(f"[DB] Migration has_mcq/has_terms error: {e}")

    # === MARKETPLACE v2: Subjects + Learning Paths ===
    # mp_subjects — top-level subject cards (English, Math, Programming, ...)
    c.execute("""
        CREATE TABLE IF NOT EXISTS mp_subjects (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            slug         TEXT UNIQUE NOT NULL,
            title_ru     TEXT NOT NULL,
            title_en     TEXT NOT NULL,
            title_uz     TEXT NOT NULL,
            desc_ru      TEXT DEFAULT '',
            desc_en      TEXT DEFAULT '',
            desc_uz      TEXT DEFAULT '',
            icon         TEXT DEFAULT '📚',
            color        TEXT DEFAULT '#6366f1',
            color2       TEXT DEFAULT '#8b5cf6',
            sort_order   INTEGER DEFAULT 0,
            is_active    INTEGER DEFAULT 1,
            created_at   TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    c.execute("CREATE INDEX IF NOT EXISTS idx_mp_subjects_slug ON mp_subjects(slug)")

    # Add subject_id FK to collections (nullable — old collections stay as-is)
    try:
        c.execute("ALTER TABLE collections ADD COLUMN subject_id INTEGER REFERENCES mp_subjects(id) ON DELETE SET NULL")
    except Exception:
        pass
    try:
        c.execute("ALTER TABLE collections ADD COLUMN subject_slug TEXT DEFAULT ''")
    except Exception:
        pass
    try:
        c.execute("ALTER TABLE collections ADD COLUMN view_count INTEGER DEFAULT 0")
    except Exception:
        pass

    # learning_paths — ordered sequence of collections/decks
    c.execute("""
        CREATE TABLE IF NOT EXISTS learning_paths (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            slug         TEXT UNIQUE NOT NULL,
            subject_id   INTEGER REFERENCES mp_subjects(id) ON DELETE SET NULL,
            title_ru     TEXT NOT NULL,
            title_en     TEXT NOT NULL,
            title_uz     TEXT NOT NULL,
            desc_ru      TEXT DEFAULT '',
            desc_en      TEXT DEFAULT '',
            desc_uz      TEXT DEFAULT '',
            icon         TEXT DEFAULT '🎯',
            color        TEXT DEFAULT '#6366f1',
            color2       TEXT DEFAULT '#8b5cf6',
            difficulty   TEXT DEFAULT 'beginner',
            estimated_hours INTEGER DEFAULT 0,
            sort_order   INTEGER DEFAULT 0,
            is_active    INTEGER DEFAULT 1,
            created_at   TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    c.execute("CREATE INDEX IF NOT EXISTS idx_lp_subject ON learning_paths(subject_id)")

    c.execute("""
        CREATE TABLE IF NOT EXISTS learning_path_steps (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            path_id        INTEGER NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
            step_order     INTEGER NOT NULL,
            step_type      TEXT NOT NULL DEFAULT 'collection',  -- 'collection' | 'deck'
            collection_id  INTEGER REFERENCES collections(id) ON DELETE CASCADE,
            deck_id        INTEGER REFERENCES decks(id) ON DELETE CASCADE,
            title_ru       TEXT DEFAULT '',
            title_en       TEXT DEFAULT '',
            title_uz       TEXT DEFAULT '',
            is_required    INTEGER DEFAULT 1
        )
    """)
    c.execute("CREATE INDEX IF NOT EXISTS idx_lp_steps_path ON learning_path_steps(path_id, step_order)")

    conn.commit()
    conn.close()
    print(f"[DB] Initialized: {DB_PATH}")


if __name__ == "__main__":
    init_db()
