# -*- coding: utf-8 -*-
"""Marketplace seed: adds the "История" (History) subject with 4 collections.

Subject:  История / History / Tarix
Collections:
  • Древний мир        (Ancient World)
  • Средние века       (Middle Ages)
  • Новое время        (Early Modern era)
  • XX век и мировые войны (20th Century & World Wars)

Each collection gets one starter MCQ deck (~10 cards). Cards are stored in the
canonical format — question in `front`, lettered options in `note`, correct
answer in `back` — so both the web test flow (app.py:_parse_card_options) and
the mobile test flow (api_v1/tests.py) build a valid test, and flashcards show
a clean question on both platforms.

Subject/collection titles + descriptions are localized ru/en/uz, matching the
existing 5 subjects. Card content is in Russian (primary audience).

Safe to re-run — uses INSERT OR IGNORE / get_or_create.
"""
import db

conn = db.get_conn()
c = conn.cursor()


# ── Subject ────────────────────────────────────────────────────────────────
def upsert_subject(slug, ru, en, uz, dru, den, duz, icon, color, color2, sort):
    c.execute("""INSERT OR IGNORE INTO mp_subjects
        (slug,title_ru,title_en,title_uz,desc_ru,desc_en,desc_uz,
         icon,color,color2,sort_order,is_active)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,1)""",
        (slug, ru, en, uz, dru, den, duz, icon, color, color2, sort))
    return c.execute("SELECT id FROM mp_subjects WHERE slug=?", (slug,)).fetchone()[0]


hist_id = upsert_subject(
    "history", "История", "History", "Tarix",
    "Всемирная история: древний мир, средние века, новое и новейшее время.",
    "World history: ancient world, middle ages, modern and contemporary era.",
    "Jahon tarixi: qadimgi dunyo, oʻrta asrlar, yangi va eng yangi davr.",
    "🏛️", "#a16207", "#854d0e", 6)


# ── System owner for seeded decks (same account the other seeds use) ────────
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


def upsert_collection(slug, subj_id_, ru, en, uz, dru, den, duz, icon, c1, c2, level, tags, sort):
    c.execute("""INSERT OR IGNORE INTO collections
        (slug,subject_id,subject_slug,title_ru,title_en,title_uz,
         desc_ru,desc_en,desc_uz,icon,color,color2,level,tags,sort_order,is_active)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,1)""",
        (slug, subj_id_, "history", ru, en, uz, dru, den, duz,
         icon, c1, c2, level, tags, sort))
    return c.execute("SELECT id FROM collections WHERE slug=?", (slug,)).fetchone()[0]


def get_or_create_deck(name, icon, desc, deck_type="mcq"):
    r = c.execute("SELECT id FROM decks WHERE owner_id=? AND name=?",
                  (OWNER, name)).fetchone()
    if r:
        return r[0]
    c.execute("""INSERT INTO decks (owner_id,name,icon,description,is_public,deck_type,created_via)
        VALUES (?,?,?,?,1,?,'seed')""", (OWNER, name, icon, desc, deck_type))
    return c.lastrowid


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


print("[seed_history] Starting...")


# ── Древний мир ────────────────────────────────────────────────────────────
anc_id = upsert_collection("history-ancient", hist_id,
    "Древний мир", "Ancient World", "Qadimgi dunyo",
    "Египет, Греция, Рим, Месопотамия — колыбель цивилизаций.",
    "Egypt, Greece, Rome, Mesopotamia — the cradle of civilization.",
    "Misr, Yunoniston, Rim, Mesopotamiya — sivilizatsiya beshigi.",
    "🏺", "#a16207", "#854d0e", "beginner", "история,древний мир,античность", 10)

dk = get_or_create_deck("Древний мир: основы", "🏺",
    "Цивилизации древности: Египет, Греция, Рим", "mcq")
link_deck(anc_id, dk, 1)
add_cards(dk, [
    ("Какая цивилизация построила пирамиды в Гизе?", "C) Египтяне",
     "A) Греки\nB) Римляне\nC) Египтяне\nD) Персы"),
    ("Кто был первым римским императором?", "B) Август (Октавиан)",
     "A) Юлий Цезарь\nB) Август (Октавиан)\nC) Нерон\nD) Константин"),
    ("В каком городе зародилась демократия?", "C) Афины",
     "A) Рим\nB) Спарта\nC) Афины\nD) Вавилон"),
    ("Какая река была основой древнеегипетской цивилизации?", "B) Нил",
     "A) Тигр\nB) Нил\nC) Евфрат\nD) Инд"),
    ("Кто создал огромную империю в IV веке до н. э. и не проиграл ни одной битвы?",
     "A) Александр Македонский",
     "A) Александр Македонский\nB) Ганнибал\nC) Цезарь\nD) Кир"),
    ("Как называли царей Древнего Египта?", "B) Фараоны",
     "A) Шахи\nB) Фараоны\nC) Цезари\nD) Султаны"),
    ("Какая цивилизация изобрела клинопись?", "B) Шумер (Месопотамия)",
     "A) Египет\nB) Шумер (Месопотамия)\nC) Китай\nD) Греция"),
    ("Кто считается автором «Илиады» и «Одиссеи»?", "B) Гомер",
     "A) Сократ\nB) Гомер\nC) Платон\nD) Аристотель"),
    ("Древнейший свод законов Вавилона назывался?", "A) Законы Хаммурапи",
     "A) Законы Хаммурапи\nB) Двенадцать таблиц\nC) Салическая правда\nD) Кодекс Юстиниана"),
    ("В каком году пала Западная Римская империя?", "B) 476 г.",
     "A) 410 г.\nB) 476 г.\nC) 800 г.\nD) 1453 г."),
])


# ── Средние века ───────────────────────────────────────────────────────────
med_id = upsert_collection("history-medieval", hist_id,
    "Средние века", "Middle Ages", "Oʻrta asrlar",
    "Феодализм, крестовые походы, Византия, рыцари и короли.",
    "Feudalism, crusades, Byzantium, knights and kings.",
    "Feodalizm, salib yurishlari, Vizantiya, ritsarlar va qirollar.",
    "🏰", "#7c3aed", "#6d28d9", "beginner", "история,средние века,феодализм", 20)

dk2 = get_or_create_deck("Средние века: основы", "🏰",
    "Феодализм, Византия, крестовые походы", "mcq")
link_deck(med_id, dk2, 1)
add_cards(dk2, [
    ("Как называлась система отношений «сеньор — вассал»?", "B) Феодализм",
     "A) Демократия\nB) Феодализм\nC) Капитализм\nD) Республика"),
    ("Как называли военно-религиозные походы на Восток в XI–XIII веках?",
     "B) Крестовые походы",
     "A) Реконкиста\nB) Крестовые походы\nC) Колонизация\nD) Переселение народов"),
    ("Столица Византийской империи?", "C) Константинополь",
     "A) Рим\nB) Афины\nC) Константинополь\nD) Александрия"),
    ("В каком году турки взяли Константинополь, завершив историю Византии?", "C) 1453 г.",
     "A) 1054 г.\nB) 1204 г.\nC) 1453 г.\nD) 1492 г."),
    ("Кто основал Монгольскую империю?", "B) Чингисхан",
     "A) Тамерлан\nB) Чингисхан\nC) Батый\nD) Хубилай"),
    ("Какая пандемия опустошила Европу в XIV веке?", "B) Чёрная смерть (чума)",
     "A) Холера\nB) Чёрная смерть (чума)\nC) Оспа\nD) Грипп"),
    ("Документ 1215 года, ограничивший власть короля Англии?",
     "A) Великая хартия вольностей",
     "A) Великая хартия вольностей\nB) Декларация независимости\nC) Золотая булла\nD) Нантский эдикт"),
    ("Кто возглавил французов в Столетней войне и стал национальной героиней?",
     "B) Жанна д'Арк",
     "A) Мария Стюарт\nB) Жанна д'Арк\nC) Елизавета I\nD) Екатерина Медичи"),
    ("В каком году произошёл раскол христианства на католичество и православие?",
     "A) 1054 г.",
     "A) 1054 г.\nB) 1204 г.\nC) 1517 г.\nD) 800 г."),
    ("Великий полководец и завоеватель, основавший империю со столицей в Самарканде?",
     "B) Тамерлан (Амир Темур)",
     "A) Чингисхан\nB) Тамерлан (Амир Темур)\nC) Батый\nD) Аттила"),
])


# ── Новое время ────────────────────────────────────────────────────────────
mod_id = upsert_collection("history-modern", hist_id,
    "Новое время", "Early Modern Era", "Yangi davr",
    "Великие открытия, Возрождение, революции XV–XIX веков.",
    "Great discoveries, the Renaissance, revolutions of the 15th–19th centuries.",
    "Buyuk kashfiyotlar, Uygʻonish davri, XV–XIX asr inqiloblari.",
    "🌍", "#0891b2", "#0e7490", "intermediate", "история,новое время,революции", 30)

dk3 = get_or_create_deck("Новое время: основы", "🌍",
    "Открытия, Возрождение, революции", "mcq")
link_deck(mod_id, dk3, 1)
add_cards(dk3, [
    ("Кто в 1492 году достиг берегов Америки?", "B) Христофор Колумб",
     "A) Магеллан\nB) Христофор Колумб\nC) Васко да Гама\nD) Джеймс Кук"),
    ("Движение за реформу церкви в XVI веке, начатое Мартином Лютером?",
     "B) Реформация",
     "A) Возрождение\nB) Реформация\nC) Просвещение\nD) Контрреформация"),
    ("Кто возглавил первое кругосветное плавание?", "B) Фернан Магеллан",
     "A) Колумб\nB) Фернан Магеллан\nC) Дрейк\nD) Кук"),
    ("В каком году началась Великая французская революция?", "A) 1789 г.",
     "A) 1789 г.\nB) 1776 г.\nC) 1804 г.\nD) 1815 г."),
    ("Кто стал императором Франции в 1804 году?", "B) Наполеон Бонапарт",
     "A) Людовик XVI\nB) Наполеон Бонапарт\nC) Робеспьер\nD) Карл X"),
    ("В какой стране началась промышленная революция?", "C) Великобритания",
     "A) Франция\nB) Германия\nC) Великобритания\nD) США"),
    ("В каком году была принята Декларация независимости США?", "A) 1776 г.",
     "A) 1776 г.\nB) 1789 г.\nC) 1804 г.\nD) 1812 г."),
    ("Кто сформулировал теорию эволюции путём естественного отбора?", "B) Чарльз Дарвин",
     "A) Ньютон\nB) Чарльз Дарвин\nC) Мендель\nD) Пастер"),
    ("Эпоха культурного расцвета в Европе XIV–XVI веков?", "B) Возрождение (Ренессанс)",
     "A) Реформация\nB) Возрождение (Ренессанс)\nC) Барокко\nD) Просвещение"),
    ("В каком году отменили крепостное право в России?", "B) 1861 г.",
     "A) 1825 г.\nB) 1861 г.\nC) 1905 г.\nD) 1917 г."),
])


# ── XX век и мировые войны ─────────────────────────────────────────────────
cent_id = upsert_collection("history-20th-century", hist_id,
    "XX век и мировые войны", "20th Century & World Wars", "XX asr va jahon urushlari",
    "Мировые войны, революции, холодная война, космос.",
    "World wars, revolutions, the Cold War, the space race.",
    "Jahon urushlari, inqiloblar, sovuq urush, kosmik poyga.",
    "⚔️", "#dc2626", "#b91c1c", "intermediate", "история,XX век,войны", 40)

dk4 = get_or_create_deck("XX век: ключевые даты", "⚔️",
    "Мировые войны, холодная война, космос", "mcq")
link_deck(cent_id, dk4, 1)
add_cards(dk4, [
    ("В каком году началась Первая мировая война?", "B) 1914 г.",
     "A) 1905 г.\nB) 1914 г.\nC) 1918 г.\nD) 1939 г."),
    ("Революция 1917 года в России привела к власти?", "B) Большевиков",
     "A) Монархистов\nB) Большевиков\nC) Либералов\nD) Эсеров"),
    ("В каком году началась Вторая мировая война?", "B) 1939 г.",
     "A) 1936 г.\nB) 1939 г.\nC) 1941 г.\nD) 1945 г."),
    ("В каком году завершилась Вторая мировая война?", "C) 1945 г.",
     "A) 1943 г.\nB) 1944 г.\nC) 1945 г.\nD) 1946 г."),
    ("Как называлось противостояние СССР и США после 1945 года?", "B) Холодная война",
     "A) Горячая война\nB) Холодная война\nC) Мировая война\nD) Гражданская война"),
    ("Кто первым полетел в космос?", "B) Юрий Гагарин",
     "A) Армстронг\nB) Юрий Гагарин\nC) Королёв\nD) Терешкова"),
    ("В каком году человек впервые высадился на Луну?", "C) 1969 г.",
     "A) 1957 г.\nB) 1961 г.\nC) 1969 г.\nD) 1975 г."),
    ("В каком году распался СССР?", "C) 1991 г.",
     "A) 1985 г.\nB) 1989 г.\nC) 1991 г.\nD) 1993 г."),
    ("В каком году пала Берлинская стена?", "B) 1989 г.",
     "A) 1985 г.\nB) 1989 г.\nC) 1991 г.\nD) 1993 г."),
    ("Какая международная организация была создана в 1945 году для сохранения мира?",
     "B) ООН",
     "A) НАТО\nB) ООН\nC) ЕС\nD) Лига Наций"),
])


# ── Commit ──────────────────────────────────────────────────────────────────
conn.commit()
conn.close()
print("[seed_history] Done — 1 subject + 4 collections + 4 decks + 40 cards added")
