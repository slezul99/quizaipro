# -*- coding: utf-8 -*-
"""Marketplace seed: two science subjects with topic collections.

Subjects:
  • Точные науки   / Exact Sciences   / Aniq fanlar
       Математика, Алгебра, Геометрия, Физика
  • Естественные науки / Natural Sciences / Tabiiy fanlar
       Биология, Химия, География, Анатомия

Each topic is one collection holding a starter MCQ deck of 10 questions.
Cards are stored in the canonical format — question in `front`, lettered
options in `note`, correct answer in `back` — so the web test flow
(app.py:_parse_card_options) and the mobile flow (api_v1/tests.py) both build
a valid test. RU is the authored language; en/uz card translations are filled
by seed_marketplace_i18n_auto from marketplace_translations.json. Subject/
collection/deck titles are localized ru/en/uz inline.

Safe to re-run — INSERT OR IGNORE / get_or_create, and translated names are
refreshed idempotently.
"""
import db

conn = db.get_conn()
c = conn.cursor()


def upsert_subject(slug, ru, en, uz, dru, den, duz, icon, color, color2, sort):
    c.execute("""INSERT OR IGNORE INTO mp_subjects
        (slug,title_ru,title_en,title_uz,desc_ru,desc_en,desc_uz,
         icon,color,color2,sort_order,is_active)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,1)""",
        (slug, ru, en, uz, dru, den, duz, icon, color, color2, sort))
    return c.execute("SELECT id FROM mp_subjects WHERE slug=?", (slug,)).fetchone()[0]


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


def upsert_collection(slug, subj_id_, subj_slug, ru, en, uz, dru, den, duz,
                      icon, c1, c2, level, tags, sort):
    c.execute("""INSERT OR IGNORE INTO collections
        (slug,subject_id,subject_slug,title_ru,title_en,title_uz,
         desc_ru,desc_en,desc_uz,icon,color,color2,level,tags,sort_order,is_active)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,1)""",
        (slug, subj_id_, subj_slug, ru, en, uz, dru, den, duz,
         icon, c1, c2, level, tags, sort))
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
    # localized names/descriptions — idempotent refresh
    c.execute("""UPDATE decks SET name_en=?, name_uz=?,
                 description_en=?, description_uz=? WHERE id=?""",
              (name_en, name_uz, desc_en, desc_uz, did))
    return did


def link_deck(coll_id, deck_id, sort=1):
    c.execute("""INSERT OR IGNORE INTO collection_decks
        (collection_id,deck_id,sort_order) VALUES (?,?,?)""",
        (coll_id, deck_id, sort))


def add_cards(deck_id, cards):
    """cards = list of (front_question, back_answer, note_options)."""
    if c.execute("SELECT COUNT(*) FROM cards WHERE deck_id=?", (deck_id,)).fetchone()[0] > 0:
        return
    for f, b, n in cards:
        c.execute("INSERT INTO cards (deck_id,front,back,note) VALUES (?,?,?,?)",
                  (deck_id, f, b, n))


print("[seed_science] Starting...")

# ════════════════════════════════════════════════════════════════════════
#  Subject 1 — Точные науки / Exact Sciences / Aniq fanlar
# ════════════════════════════════════════════════════════════════════════
exact_id = upsert_subject(
    "exact-sciences", "Точные науки", "Exact Sciences", "Aniq fanlar",
    "Математика, алгебра, геометрия и физика — фундамент точного знания.",
    "Mathematics, algebra, geometry and physics — the foundation of exact knowledge.",
    "Matematika, algebra, geometriya va fizika — aniq bilim poydevori.",
    "📐", "#2563eb", "#1e40af", 7)

# ── Математика ──────────────────────────────────────────────────────────
m_col = upsert_collection("math-basics", exact_id, "exact-sciences",
    "Математика", "Mathematics", "Matematika",
    "Арифметика, проценты, дроби и базовые вычисления.",
    "Arithmetic, percentages, fractions and basic calculations.",
    "Arifmetika, foizlar, kasrlar va asosiy hisob-kitoblar.",
    "🔢", "#3b82f6", "#2563eb", "beginner", "математика,арифметика,точные науки", 1)
m_dk = get_or_create_deck("Математика — основы", "Mathematics — basics", "Matematika — asoslar",
    "🔢", "Базовый тест по математике", "Basic mathematics test", "Matematikadan asosiy test")
link_deck(m_col, m_dk, 1)
add_cards(m_dk, [
    ("Сколько будет 7 × 8?", "B) 56", "A) 54\nB) 56\nC) 48\nD) 64"),
    ("Чему равен квадратный корень из 144?", "C) 12", "A) 14\nB) 11\nC) 12\nD) 13"),
    ("Сколько градусов в прямом угле?", "B) 90", "A) 45\nB) 90\nC) 180\nD) 360"),
    ("Какое из чисел является простым?", "C) 7", "A) 9\nB) 15\nC) 7\nD) 21"),
    ("Сколько будет 15% от 200?", "B) 30", "A) 20\nB) 30\nC) 15\nD) 45"),
    ("Чему равно 2 в степени 5?", "C) 32", "A) 10\nB) 25\nC) 32\nD) 16"),
    ("Сколько минут в 3 часах?", "C) 180", "A) 120\nB) 150\nC) 180\nD) 240"),
    ("Какая дробь равна 0,5?", "B) 1/2", "A) 1/3\nB) 1/2\nC) 1/4\nD) 2/3"),
    ("Чему равна сумма углов треугольника?", "B) 180°", "A) 90°\nB) 180°\nC) 270°\nD) 360°"),
    ("Сколько будет 100 ÷ 4?", "B) 25", "A) 20\nB) 25\nC) 40\nD) 50"),
])

# ── Алгебра ─────────────────────────────────────────────────────────────
a_col = upsert_collection("algebra", exact_id, "exact-sciences",
    "Алгебра", "Algebra", "Algebra",
    "Уравнения, степени, формулы сокращённого умножения.",
    "Equations, powers and algebraic identities.",
    "Tenglamalar, darajalar va algebraik ayniyatlar.",
    "➗", "#6366f1", "#4f46e5", "intermediate", "алгебра,уравнения,точные науки", 2)
a_dk = get_or_create_deck("Алгебра — основы", "Algebra — basics", "Algebra — asoslar",
    "➗", "Базовый тест по алгебре", "Basic algebra test", "Algebradan asosiy test")
link_deck(a_col, a_dk, 1)
add_cards(a_dk, [
    ("Решите уравнение: x + 5 = 12. Чему равен x?", "B) 7", "A) 5\nB) 7\nC) 17\nD) 6"),
    ("Чему равно a², если a = 9?", "B) 81", "A) 18\nB) 81\nC) 72\nD) 90"),
    ("Упростите выражение: 3x + 2x", "A) 5x", "A) 5x\nB) 6x\nC) 5\nD) 6x²"),
    ("Решите уравнение: 2x = 10. Чему равен x?", "A) 5", "A) 5\nB) 8\nC) 20\nD) 12"),
    ("Чему равно (a + b)²?", "B) a² + 2ab + b²", "A) a² + b²\nB) a² + 2ab + b²\nC) a² − b²\nD) 2ab"),
    ("При каком значении x: x − 3 = 0?", "C) 3", "A) 0\nB) −3\nC) 3\nD) 1"),
    ("Чему равен факториал 5! ?", "B) 120", "A) 25\nB) 120\nC) 60\nD) 100"),
    ("Чему равен дискриминант квадратного уравнения?", "A) b² − 4ac", "A) b² − 4ac\nB) b² + 4ac\nC) 2a\nD) −b/2a"),
    ("Решите уравнение: x / 2 = 6. Чему равен x?", "C) 12", "A) 3\nB) 8\nC) 12\nD) 4"),
    ("Чему равен log₁₀(1000)?", "B) 3", "A) 2\nB) 3\nC) 10\nD) 100"),
])

# ── Геометрия ───────────────────────────────────────────────────────────
g_col = upsert_collection("geometry", exact_id, "exact-sciences",
    "Геометрия", "Geometry", "Geometriya",
    "Фигуры, углы, площади и теорема Пифагора.",
    "Shapes, angles, areas and the Pythagorean theorem.",
    "Shakllar, burchaklar, yuzalar va Pifagor teoremasi.",
    "📐", "#0ea5e9", "#0284c7", "beginner", "геометрия,фигуры,точные науки", 3)
g_dk = get_or_create_deck("Геометрия — основы", "Geometry — basics", "Geometriya — asoslar",
    "📐", "Базовый тест по геометрии", "Basic geometry test", "Geometriyadan asosiy test")
link_deck(g_col, g_dk, 1)
add_cards(g_dk, [
    ("Чему равна сумма углов треугольника?", "B) 180°", "A) 90°\nB) 180°\nC) 360°\nD) 270°"),
    ("Какова формула площади круга?", "B) πr²", "A) 2πr\nB) πr²\nC) πd\nD) r²"),
    ("Сколько сторон у шестиугольника?", "B) 6", "A) 5\nB) 6\nC) 7\nD) 8"),
    ("Как называется треугольник со всеми равными сторонами?", "C) равносторонний", "A) прямоугольный\nB) равнобедренный\nC) равносторонний\nD) тупоугольный"),
    ("Чему равна площадь прямоугольника?", "B) длина × ширина", "A) длина + ширина\nB) длина × ширина\nC) 2(длина + ширина)\nD) сторона²"),
    ("Сколько градусов в развёрнутом угле?", "B) 180°", "A) 90°\nB) 180°\nC) 360°\nD) 45°"),
    ("Теорема Пифагора: a² + b² = ?", "C) c²", "A) c\nB) 2c\nC) c²\nD) ab"),
    ("Сколько граней у куба?", "B) 6", "A) 4\nB) 6\nC) 8\nD) 12"),
    ("Какова формула длины окружности?", "B) 2πr", "A) πr²\nB) 2πr\nC) πr\nD) r²"),
    ("Как называется отрезок, соединяющий центр и точку окружности?", "C) радиус", "A) диаметр\nB) хорда\nC) радиус\nD) касательная"),
])

# ── Физика ──────────────────────────────────────────────────────────────
p_col = upsert_collection("physics", exact_id, "exact-sciences",
    "Физика", "Physics", "Fizika",
    "Силы, энергия, электричество и единицы измерения.",
    "Forces, energy, electricity and units of measurement.",
    "Kuchlar, energiya, elektr va o'lchov birliklari.",
    "⚛️", "#8b5cf6", "#7c3aed", "intermediate", "физика,силы,точные науки", 4)
p_dk = get_or_create_deck("Физика — основы", "Physics — basics", "Fizika — asoslar",
    "⚛️", "Базовый тест по физике", "Basic physics test", "Fizikadan asosiy test")
link_deck(p_col, p_dk, 1)
add_cards(p_dk, [
    ("В каких единицах измеряется сила?", "C) Ньютон", "A) Джоуль\nB) Ватт\nC) Ньютон\nD) Паскаль"),
    ("Чему примерно равна скорость света в вакууме?", "B) 300 000 км/с", "A) 150 000 км/с\nB) 300 000 км/с\nC) 1 000 000 км/с\nD) 30 000 км/с"),
    ("Что измеряется в Амперах?", "C) сила тока", "A) напряжение\nB) сопротивление\nC) сила тока\nD) мощность"),
    ("Какая формула выражает второй закон Ньютона?", "A) F = ma", "A) F = ma\nB) E = mc²\nC) v = s/t\nD) P = UI"),
    ("В каких единицах измеряется энергия?", "B) Джоуль", "A) Ньютон\nB) Джоуль\nC) Ватт\nD) Вольт"),
    ("Какая частица имеет отрицательный заряд?", "C) электрон", "A) протон\nB) нейтрон\nC) электрон\nD) фотон"),
    ("Что измеряет термометр?", "B) температуру", "A) давление\nB) температуру\nC) массу\nD) скорость"),
    ("Чему примерно равно ускорение свободного падения на Земле?", "A) 9,8 м/с²", "A) 9,8 м/с²\nB) 3,0 м/с²\nC) 100 м/с²\nD) 1,6 м/с²"),
    ("В каких единицах измеряется электрическое напряжение?", "C) Вольт", "A) Ампер\nB) Ом\nC) Вольт\nD) Ватт"),
    ("Как называется превращение жидкости в газ?", "B) испарение", "A) конденсация\nB) испарение\nC) плавление\nD) кристаллизация"),
])

# ════════════════════════════════════════════════════════════════════════
#  Subject 2 — Естественные науки / Natural Sciences / Tabiiy fanlar
# ════════════════════════════════════════════════════════════════════════
nat_id = upsert_subject(
    "natural-sciences", "Естественные науки", "Natural Sciences", "Tabiiy fanlar",
    "Биология, химия, география и анатомия — науки о природе и жизни.",
    "Biology, chemistry, geography and anatomy — the sciences of nature and life.",
    "Biologiya, kimyo, geografiya va anatomiya — tabiat va hayot fanlari.",
    "🌿", "#16a34a", "#15803d", 8)

# ── Биология ────────────────────────────────────────────────────────────
b_col = upsert_collection("biology", nat_id, "natural-sciences",
    "Биология", "Biology", "Biologiya",
    "Клетки, органы, фотосинтез и наследственность.",
    "Cells, organs, photosynthesis and heredity.",
    "Hujayralar, organlar, fotosintez va irsiyat.",
    "🧬", "#22c55e", "#16a34a", "beginner", "биология,клетка,природа", 1)
b_dk = get_or_create_deck("Биология — основы", "Biology — basics", "Biologiya — asoslar",
    "🧬", "Базовый тест по биологии", "Basic biology test", "Biologiyadan asosiy test")
link_deck(b_col, b_dk, 1)
add_cards(b_dk, [
    ("Какой орган качает кровь по телу?", "C) сердце", "A) лёгкие\nB) печень\nC) сердце\nD) почки"),
    ("Какой газ выделяют растения при фотосинтезе?", "B) кислород", "A) углекислый газ\nB) кислород\nC) азот\nD) водород"),
    ("Какова основная единица строения живого организма?", "B) клетка", "A) атом\nB) клетка\nC) ткань\nD) орган"),
    ("В какой части растения в основном происходит фотосинтез?", "B) в листьях", "A) в корнях\nB) в листьях\nC) в стебле\nD) в цветке"),
    ("Сколько хромосом в клетке человека?", "B) 46", "A) 23\nB) 46\nC) 48\nD) 44"),
    ("Какой витамин вырабатывается в коже под действием солнца?", "C) витамин D", "A) витамин A\nB) витамин C\nC) витамин D\nD) витамин B12"),
    ("Какой орган дыхания у рыб?", "B) жабры", "A) лёгкие\nB) жабры\nC) кожа\nD) трахеи"),
    ("Какая молекула хранит наследственную информацию?", "B) ДНК", "A) РНК\nB) ДНК\nC) белок\nD) АТФ"),
    ("Какие животные выкармливают детёнышей молоком?", "C) млекопитающие", "A) птицы\nB) рептилии\nC) млекопитающие\nD) рыбы"),
    ("Как называется процесс деления клетки?", "A) митоз", "A) митоз\nB) фотосинтез\nC) дыхание\nD) осмос"),
])

# ── Химия ───────────────────────────────────────────────────────────────
h_col = upsert_collection("chemistry", nat_id, "natural-sciences",
    "Химия", "Chemistry", "Kimyo",
    "Элементы, формулы, кислоты и периодическая таблица.",
    "Elements, formulas, acids and the periodic table.",
    "Elementlar, formulalar, kislotalar va davriy jadval.",
    "⚗️", "#14b8a6", "#0d9488", "beginner", "химия,элементы,природа", 2)
h_dk = get_or_create_deck("Химия — основы", "Chemistry — basics", "Kimyo — asoslar",
    "⚗️", "Базовый тест по химии", "Basic chemistry test", "Kimyodan asosiy test")
link_deck(h_col, h_dk, 1)
add_cards(h_dk, [
    ("Какова химическая формула воды?", "A) H₂O", "A) H₂O\nB) CO₂\nC) O₂\nD) NaCl"),
    ("Какой газ необходим человеку для дыхания?", "C) кислород", "A) азот\nB) водород\nC) кислород\nD) гелий"),
    ("Каков химический символ золота?", "C) Au", "A) Ag\nB) Fe\nC) Au\nD) Gd"),
    ("Сколько атомов водорода в молекуле воды?", "B) 2", "A) 1\nB) 2\nC) 3\nD) 4"),
    ("Что показывает значение pH меньше 7?", "D) кислоту", "A) щёлочь\nB) нейтральную среду\nC) соль\nD) кислоту"),
    ("Какой химический элемент самый лёгкий?", "A) водород", "A) водород\nB) гелий\nC) кислород\nD) литий"),
    ("Каков химический символ натрия?", "C) Na", "A) N\nB) Ne\nC) Na\nD) Ni"),
    ("Как называется таблица химических элементов?", "A) таблица Менделеева", "A) таблица Менделеева\nB) таблица Ньютона\nC) таблица Дарвина\nD) таблица Эйнштейна"),
    ("Какой газ составляет около 78% атмосферы Земли?", "B) азот", "A) кислород\nB) азот\nC) углекислый газ\nD) аргон"),
    ("Как в быту называют соль NaCl?", "C) поваренная соль", "A) сода\nB) мел\nC) поваренная соль\nD) известь"),
])

# ── География ───────────────────────────────────────────────────────────
geo_col = upsert_collection("geography", nat_id, "natural-sciences",
    "География", "Geography", "Geografiya",
    "Материки, океаны, столицы и природные рекорды.",
    "Continents, oceans, capitals and natural records.",
    "Materiklar, okeanlar, poytaxtlar va tabiat rekordlari.",
    "🌍", "#10b981", "#059669", "beginner", "география,материки,природа", 3)
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
an_col = upsert_collection("anatomy", nat_id, "natural-sciences",
    "Анатомия", "Anatomy", "Anatomiya",
    "Органы, кости, кровь и системы тела человека.",
    "Organs, bones, blood and the systems of the human body.",
    "Organlar, suyaklar, qon va inson tanasi tizimlari.",
    "🫀", "#34d399", "#10b981", "intermediate", "анатомия,тело,человек", 4)
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
print("[seed_science] Done — 2 subjects, 8 collections, 80 cards.")
