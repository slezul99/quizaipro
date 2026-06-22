# -*- coding: utf-8 -*-
"""Marketplace seed: extra topics for the existing "Естественные науки" subject.

Adds two genuinely-new topic collections — География and Анатомия — under the
established `science` subject (Естественные науки / Tabiiy fanlar), each with a
10-question MCQ deck. RU is authored; en/uz card translations are filled by
seed_marketplace_i18n_auto from marketplace_translations.json. Titles are
localized ru/en/uz inline.

History note: an earlier version of this seed also created standalone
"Точные науки" / "Естественные науки" subjects, which duplicated the existing
"Математика" and "Естественные науки". Those duplicates are retired by the
mp_science_dedup_v1 migration in app.py; this seed now only adds the unique
topics so fresh databases come up clean.

Safe to re-run — get_or_create / INSERT OR IGNORE, translated names refreshed
idempotently.
"""
import db

conn = db.get_conn()
c = conn.cursor()

sci = c.execute("SELECT id FROM mp_subjects WHERE slug='science'").fetchone()
if not sci:
    print("[seed_science] base 'science' subject missing — skipping.")
    conn.close()
    raise SystemExit
SCIENCE_ID = sci[0]

sys_user = c.execute("SELECT id FROM users WHERE username='quizaipro_system'").fetchone()
if not sys_user:
    from werkzeug.security import generate_password_hash
    import secrets
    c.execute("""INSERT INTO users (username,password_hash,role,full_name,lang)
        VALUES ('quizaipro_system',?,?,?,?)""",
        (generate_password_hash(secrets.token_hex(32)), 'individual', 'QuizAIPro Library', 'en'))
    OWNER = c.lastrowid
else:
    OWNER = sys_user[0]


def upsert_collection(slug, ru, en, uz, dru, den, duz, icon, c1, c2, level, tags, sort):
    c.execute("""INSERT OR IGNORE INTO collections
        (slug,subject_id,subject_slug,title_ru,title_en,title_uz,
         desc_ru,desc_en,desc_uz,icon,color,color2,level,tags,sort_order,is_active)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,1)""",
        (slug, SCIENCE_ID, "science", ru, en, uz, dru, den, duz,
         icon, c1, c2, level, tags, sort))
    # keep it parented to science + refresh localized fields (idempotent)
    c.execute("""UPDATE collections SET subject_id=?, subject_slug='science',
        title_en=?, title_uz=?, desc_en=?, desc_uz=? WHERE slug=?""",
        (SCIENCE_ID, en, uz, den, duz, slug))
    return c.execute("SELECT id FROM collections WHERE slug=?", (slug,)).fetchone()[0]


def get_or_create_deck(name, name_en, name_uz, icon, desc, desc_en, desc_uz):
    r = c.execute("SELECT id FROM decks WHERE owner_id=? AND name=?",
                  (OWNER, name)).fetchone()
    if r:
        did = r[0]
    else:
        c.execute("""INSERT INTO decks (owner_id,name,icon,description,is_public,deck_type,created_via)
            VALUES (?,?,?,?,1,'mcq','seed')""", (OWNER, name, icon, desc))
        did = c.lastrowid
    c.execute("""UPDATE decks SET name_en=?, name_uz=?,
                 description_en=?, description_uz=?, is_public=1 WHERE id=?""",
              (name_en, name_uz, desc_en, desc_uz, did))
    return did


def link_deck(coll_id, deck_id, sort=1):
    c.execute("""INSERT OR IGNORE INTO collection_decks
        (collection_id,deck_id,sort_order) VALUES (?,?,?)""",
        (coll_id, deck_id, sort))


def add_cards(deck_id, cards):
    if c.execute("SELECT COUNT(*) FROM cards WHERE deck_id=?", (deck_id,)).fetchone()[0] > 0:
        return
    for f, b, n in cards:
        c.execute("INSERT INTO cards (deck_id,front,back,note) VALUES (?,?,?,?)",
                  (deck_id, f, b, n))


print("[seed_science] Starting...")

# ── География ───────────────────────────────────────────────────────────
geo_col = upsert_collection("geography",
    "География", "Geography", "Geografiya",
    "Материки, океаны, столицы и природные рекорды.",
    "Continents, oceans, capitals and natural records.",
    "Materiklar, okeanlar, poytaxtlar va tabiat rekordlari.",
    "🌍", "#10b981", "#059669", "beginner", "география,материки,природа", 5)
geo_dk = get_or_create_deck("География — основы", "Geography — basics", "Geografiya — asoslar",
    "🌍", "Базовый тест по географии", "Basic geography test", "Geografiyadan asosiy test")
link_deck(geo_col, geo_dk, 1)
add_cards(geo_dk, [
    ("Какой океан самый большой?", "A) Тихий", "A) Тихий\nB) Атлантический\nC) Индийский\nD) Северный Ледовитый"),
    ("Какая гора самая высокая в мире?", "C) Эверест", "A) Эльбрус\nB) Килиманджаро\nC) Эверест\nD) Монблан"),
    ("Сколько материков на Земле?", "B) 6", "A) 5\nB) 6\nC) 7\nD) 4"),
    ("Какой город — столица Франции?", "D) Париж", "A) Лондон\nB) Берлин\nC) Рим\nD) Париж"),
    ("Какая жаркая пустыня самая большая?", "B) Сахара", "A) Гоби\nB) Сахара\nC) Калахари\nD) Атакама"),
    ("На каком материке расположен Египет?", "C) Африка", "A) Азия\nB) Европа\nC) Африка\nD) Австралия"),
    ("Какое озеро самое глубокое в мире?", "D) Байкал", "A) Виктория\nB) Каспийское\nC) Танганьика\nD) Байкал"),
    ("Какой материк самый большой по площади?", "B) Евразия", "A) Африка\nB) Евразия\nC) Северная Америка\nD) Антарктида"),
    ("Какой город — столица Узбекистана?", "C) Ташкент", "A) Самарканд\nB) Бухара\nC) Ташкент\nD) Алматы"),
    ("Как называется линия нулевой широты?", "B) экватор", "A) меридиан\nB) экватор\nC) тропик\nD) полюс"),
])

# ── Анатомия ────────────────────────────────────────────────────────────
an_col = upsert_collection("anatomy",
    "Анатомия", "Anatomy", "Anatomiya",
    "Органы, кости, кровь и системы тела человека.",
    "Organs, bones, blood and the systems of the human body.",
    "Organlar, suyaklar, qon va inson tanasi tizimlari.",
    "🫀", "#34d399", "#10b981", "intermediate", "анатомия,тело,человек", 6)
an_dk = get_or_create_deck("Анатомия человека — основы", "Human anatomy — basics", "Inson anatomiyasi — asoslar",
    "🫀", "Базовый тест по анатомии человека", "Basic human anatomy test", "Inson anatomiyasidan asosiy test")
link_deck(an_col, an_dk, 1)
add_cards(an_dk, [
    ("Сколько камер в сердце человека?", "C) 4", "A) 2\nB) 3\nC) 4\nD) 5"),
    ("Какая кость самая крупная в теле человека?", "A) бедренная", "A) бедренная\nB) плечевая\nC) большеберцовая\nD) лучевая"),
    ("Какой орган отвечает за дыхание?", "B) лёгкие", "A) сердце\nB) лёгкие\nC) печень\nD) желудок"),
    ("Сколько костей у взрослого человека?", "B) 206", "A) 201\nB) 206\nC) 215\nD) 198"),
    ("Какой орган вырабатывает желчь?", "B) печень", "A) почки\nB) печень\nC) селезёнка\nD) поджелудочная железа"),
    ("Какой орган фильтрует кровь и образует мочу?", "B) почки", "A) печень\nB) почки\nC) лёгкие\nD) сердце"),
    ("Сколько отделов в позвоночнике человека?", "C) 5", "A) 3\nB) 4\nC) 5\nD) 6"),
    ("Какой орган является центром нервной системы?", "B) головной мозг", "A) сердце\nB) головной мозг\nC) печень\nD) лёгкие"),
    ("Как называются красные кровяные клетки?", "B) эритроциты", "A) лейкоциты\nB) эритроциты\nC) тромбоциты\nD) нейроны"),
    ("В каком органе пища переваривается желудочным соком?", "B) желудок", "A) кишечник\nB) желудок\nC) пищевод\nD) печень"),
])

conn.commit()
conn.close()
print("[seed_science] Done — География + Анатомия added to 'Естественные науки'.")
