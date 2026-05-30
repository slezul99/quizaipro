# -*- coding: utf-8 -*-
"""Seed script: creates Marketplace v2 subjects, collections, decks, cards.
Run once: python seed_marketplace.py
Safe to re-run — uses INSERT OR IGNORE for subjects/collections."""
import db

conn = db.get_conn()
c = conn.cursor()

# ─────────────────────────────────────────────
# HELPER
# ─────────────────────────────────────────────
def upsert_subject(slug, ru, en, uz, desc_ru, desc_en, desc_uz, icon, color, color2, sort):
    c.execute("""INSERT OR IGNORE INTO mp_subjects
        (slug,title_ru,title_en,title_uz,desc_ru,desc_en,desc_uz,icon,color,color2,sort_order)
        VALUES (?,?,?,?,?,?,?,?,?,?,?)""",
        (slug,ru,en,uz,desc_ru,desc_en,desc_uz,icon,color,color2,sort))
    row = c.execute("SELECT id FROM mp_subjects WHERE slug=?", (slug,)).fetchone()
    return row[0]

def upsert_collection(slug, subj_id, ru, en, uz, dru, den, duz, icon, c1, c2, level, tags, sort):
    c.execute("""INSERT OR IGNORE INTO collections
        (slug,subject_id,subject_slug,title_ru,title_en,title_uz,
         desc_ru,desc_en,desc_uz,icon,color,color2,level,tags,sort_order,is_active)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,1)""",
        (slug,subj_id,slug.split("-")[0],ru,en,uz,dru,den,duz,icon,c1,c2,level,tags,sort))
    row = c.execute("SELECT id FROM collections WHERE slug=?", (slug,)).fetchone()
    return row[0]

def get_or_create_deck(owner_id, name, icon, desc, deck_type="mcq"):
    row = c.execute("SELECT id FROM decks WHERE owner_id=? AND name=?", (owner_id, name)).fetchone()
    if row:
        return row[0]
    c.execute("""INSERT INTO decks (owner_id,name,icon,description,is_public,deck_type,created_via)
        VALUES (?,?,?,?,1,?,'seed')""", (owner_id, name, icon, desc, deck_type))
    return c.lastrowid

def link_deck(coll_id, deck_id, sort):
    c.execute("INSERT OR IGNORE INTO collection_decks (collection_id,deck_id,sort_order) VALUES (?,?,?)",
              (coll_id, deck_id, sort))

def add_cards(deck_id, cards):
    """cards = list of (front, back, note)"""
    existing = c.execute("SELECT COUNT(*) FROM cards WHERE deck_id=?", (deck_id,)).fetchone()[0]
    if existing > 0:
        return  # already seeded
    for front, back, note in cards:
        c.execute("INSERT INTO cards (deck_id,front,back,note) VALUES (?,?,?,?)",
                  (deck_id, front, back, note))

# ─────────────────────────────────────────────
# SYSTEM USER (owner of all seeded decks)
# ─────────────────────────────────────────────
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

# ─────────────────────────────────────────────
# 1. ENGLISH
# ─────────────────────────────────────────────
eng_id = upsert_subject(
    "english", "Английский язык", "English", "Ingliz tili",
    "Коллекции для изучения английского: от A1 до C2, грамматика, лексика, IELTS, TOEFL",
    "Collections for learning English: A1 to C2, grammar, vocabulary, IELTS, TOEFL",
    "Ingliz tilini o'rganish: A1 dan C2 gacha, grammatika, leksika, IELTS, TOEFL",
    "🇬🇧", "#3b82f6", "#6366f1", 1)

# English A1
a1_id = upsert_collection("english-a1", eng_id,
    "A1 Beginner", "A1 Beginner", "A1 Boshlang'ich",
    "Самые первые шаги в английском. Алфавит, числа, приветствия, базовые фразы.",
    "Your very first steps in English. Alphabet, numbers, greetings, basic phrases.",
    "Ingliz tilida birinchi qadamlar. Alifbo, raqamlar, salomlashish, asosiy iboralar.",
    "🌱", "#10b981", "#059669", "beginner", "A1,beginner,CEFR", 10)

dk = get_or_create_deck(OWNER, "A1 Greetings & Introductions", "👋", "Basic greetings and self-introduction phrases", "terms")
link_deck(a1_id, dk, 1)
add_cards(dk, [
    ("Hello / Hi", "Привет / Здравствуйте", "Informal: Hi. Formal: Hello."),
    ("Good morning", "Доброе утро", "Used before noon."),
    ("Good afternoon", "Добрый день", "Used from noon to ~6pm."),
    ("Good evening", "Добрый вечер", "Used after ~6pm."),
    ("Good night", "Спокойной ночи", "Said when going to sleep or leaving late."),
    ("What is your name?", "Как вас зовут?", "Formal question. Informal: What's your name?"),
    ("My name is ...", "Меня зовут ...", "Standard self-introduction."),
    ("Nice to meet you", "Приятно познакомиться", "Said when meeting someone for the first time."),
    ("How are you?", "Как дела?", "Common greeting. Reply: Fine, thanks / I'm good."),
    ("I'm fine, thank you", "Я в порядке, спасибо", "Standard polite reply."),
    ("Where are you from?", "Откуда вы?", "Asking about someone's country/city."),
    ("I am from ...", "Я из ...", "E.g. I am from Uzbekistan."),
    ("How old are you?", "Сколько вам лет?", "Asking age."),
    ("I am ... years old", "Мне ... лет", "E.g. I am 20 years old."),
    ("Goodbye / Bye", "До свидания / Пока", "Formal: Goodbye. Informal: Bye."),
    ("See you later", "До встречи", "Casual farewell."),
    ("Please", "Пожалуйста", "Used when making a request."),
    ("Thank you", "Спасибо", "Expressing gratitude."),
    ("You're welcome", "Пожалуйста (не за что)", "Reply to 'thank you'."),
    ("Sorry / Excuse me", "Извините / Простите", "Apologising or getting attention."),
])

dk2 = get_or_create_deck(OWNER, "A1 Numbers & Colors", "🔢", "Numbers 1-100 and basic colors", "terms")
link_deck(a1_id, dk2, 2)
add_cards(dk2, [
    ("one / 1", "один", ""), ("two / 2", "два", ""), ("three / 3", "три", ""),
    ("four / 4", "четыре", ""), ("five / 5", "пять", ""), ("six / 6", "шесть", ""),
    ("seven / 7", "семь", ""), ("eight / 8", "восемь", ""), ("nine / 9", "девять", ""),
    ("ten / 10", "десять", ""), ("twenty / 20", "двадцать", ""), ("fifty / 50", "пятьдесят", ""),
    ("hundred / 100", "сто", ""), ("red", "красный", "The color of fire."),
    ("blue", "синий / голубой", "Sky is blue."), ("green", "зелёный", "Color of grass."),
    ("yellow", "жёлтый", "Color of the sun."), ("black", "чёрный", "Opposite of white."),
    ("white", "белый", "Opposite of black."), ("orange", "оранжевый", "Color of an orange."),
])

# English A2
a2_id = upsert_collection("english-a2", eng_id,
    "A2 Elementary", "A2 Elementary", "A2 Elementar",
    "Расширяем словарный запас. Настоящее, прошедшее время, повседневные темы.",
    "Expanding vocabulary. Present, past tense, everyday topics.",
    "Lug'atni kengaytirish. Hozirgi, o'tgan zamon, kundalik mavzular.",
    "📗", "#3b82f6", "#2563eb", "beginner", "A2,elementary,CEFR", 20)

dk3 = get_or_create_deck(OWNER, "A2 Daily Routines", "🌅", "Vocabulary for describing your daily routine", "terms")
link_deck(a2_id, dk3, 1)
add_cards(dk3, [
    ("wake up", "просыпаться", "I wake up at 7am."),
    ("get up", "вставать с кровати", "I get up and make coffee."),
    ("have breakfast", "завтракать", "I have breakfast at 8am."),
    ("go to work / school", "идти на работу / в школу", ""),
    ("have lunch", "обедать", "Lunch is usually at noon."),
    ("come home", "приходить домой", "I come home at 6pm."),
    ("have dinner", "ужинать", "We have dinner together."),
    ("watch TV", "смотреть телевизор", ""),
    ("go to bed", "ложиться спать", "I go to bed at 11pm."),
    ("brush teeth", "чистить зубы", "Brush teeth twice a day."),
    ("take a shower", "принимать душ", ""),
    ("get dressed", "одеваться", ""),
    ("cook", "готовить еду", "I cook dinner every day."),
    ("clean the house", "убирать дом", ""),
    ("do homework", "делать домашнее задание", ""),
    ("exercise / work out", "заниматься спортом", ""),
    ("read a book", "читать книгу", ""),
    ("check email", "проверять почту", ""),
    ("meet friends", "встречаться с друзьями", ""),
    ("go shopping", "ходить за покупками", ""),
])

# English Grammar
gram_id = upsert_collection("english-grammar", eng_id,
    "Грамматика английского", "English Grammar", "Ingliz tili grammatikasi",
    "Времена, артикли, предлоги, модальные глаголы — всё что нужно для грамотной речи.",
    "Tenses, articles, prepositions, modal verbs — everything for correct English.",
    "Zamonlar, artikllar, predloglar, modal fe'llar — to'g'ri ingliz tili uchun hamma narsa.",
    "📐", "#8b5cf6", "#6366f1", "intermediate", "grammar,tenses,articles", 30)

dk4 = get_or_create_deck(OWNER, "Present Simple vs Present Continuous", "⏱️",
    "When to use Present Simple and Present Continuous", "mcq")
link_deck(gram_id, dk4, 1)
add_cards(dk4, [
    ("She ___ (work) every day.\nA) works\nB) is working\nC) work\nD) working",
     "A) works", "Present Simple for habits/routines. She works every day."),
    ("Right now he ___ (play) video games.\nA) plays\nB) play\nC) is playing\nD) played",
     "C) is playing", "Present Continuous for actions happening NOW."),
    ("I always ___ (drink) coffee in the morning.\nA) am drinking\nB) drink\nC) drinks\nD) drank",
     "B) drink", "Always = habit → Present Simple."),
    ("Look! The cat ___ (sleep) on my laptop.\nA) sleeps\nB) slept\nC) is sleeping\nD) sleep",
     "C) is sleeping", "Look! = right now → Present Continuous."),
    ("Water ___ (boil) at 100°C.\nA) is boiling\nB) boils\nC) boil\nD) boiled",
     "B) boils", "Scientific fact → Present Simple."),
    ("They ___ (build) a new mall near my house this month.\nA) build\nB) built\nC) are building\nD) builds",
     "C) are building", "Temporary action in progress → Present Continuous."),
    ("He never ___ (eat) fast food.\nA) is eating\nB) eats\nC) eat\nD) ate",
     "B) eats", "Never = frequency adverb → Present Simple."),
    ("I ___ (not understand) this question.\nA) am not understanding\nB) don't understand\nC) not understand\nD) isn't understanding",
     "B) don't understand", "State verbs (understand, know, like) don't use Continuous."),
    ("She ___ (study) for her exam all week.\nA) studies\nB) study\nC) is studying\nD) studied",
     "C) is studying", "Temporary extended action → Present Continuous."),
    ("The sun ___ (rise) in the east.\nA) is rising\nB) rises\nC) rise\nD) rose",
     "B) rises", "Permanent fact → Present Simple."),
])

# English Vocabulary
vocab_id = upsert_collection("english-vocabulary", eng_id,
    "Словарный запас", "English Vocabulary", "Ingliz tili lug'ati",
    "Тематические словари: еда, путешествия, работа, технологии, эмоции.",
    "Thematic vocabulary: food, travel, work, technology, emotions.",
    "Mavzuli lug'at: ovqat, sayohat, ish, texnologiya, his-tuyg'ular.",
    "📖", "#f59e0b", "#ef4444", "intermediate", "vocabulary,words,themes", 40)

dk5 = get_or_create_deck(OWNER, "Technology Vocabulary", "💻", "Modern tech words every learner needs", "terms")
link_deck(vocab_id, dk5, 1)
add_cards(dk5, [
    ("software", "программное обеспечение", "Apps, operating systems, programs."),
    ("hardware", "аппаратное обеспечение", "Physical parts: CPU, RAM, keyboard."),
    ("to update", "обновлять", "Install the latest version."),
    ("to download", "скачивать", "Get a file from the internet."),
    ("to upload", "загружать", "Send a file to the internet/server."),
    ("password", "пароль", "Secret code to access an account."),
    ("username", "имя пользователя", "Your login name."),
    ("browser", "браузер", "Chrome, Firefox, Safari."),
    ("search engine", "поисковик", "Google, Yandex, Bing."),
    ("Wi-Fi", "беспроводной интернет", "Wireless internet connection."),
    ("to charge", "заряжать", "Charge your phone before the trip."),
    ("battery", "батарея / аккумулятор", "My battery is at 5%."),
    ("screen", "экран", "The display of a device."),
    ("keyboard", "клавиатура", "You type on a keyboard."),
    ("mouse", "мышь", "Computer pointing device."),
    ("cloud storage", "облачное хранилище", "Google Drive, iCloud, Dropbox."),
    ("notification", "уведомление", "A message alert from an app."),
    ("app / application", "приложение", "Instagram, WhatsApp are apps."),
    ("to crash", "зависать / вылетать", "My app crashed and I lost my work."),
    ("backup", "резервная копия", "Always make a backup of your files."),
])

# ─────────────────────────────────────────────
# 2. MATHEMATICS
# ─────────────────────────────────────────────
math_id = upsert_subject(
    "mathematics", "Математика", "Mathematics", "Matematika",
    "Алгебра, геометрия, статистика, подготовка к экзаменам.",
    "Algebra, geometry, statistics, exam preparation.",
    "Algebra, geometriya, statistika, imtihonga tayyorgarlik.",
    "🔢", "#f59e0b", "#ef4444", 2)

alg_id = upsert_collection("math-algebra", math_id,
    "Алгебра", "Algebra", "Algebra",
    "Уравнения, неравенства, функции, прогрессии.",
    "Equations, inequalities, functions, progressions.",
    "Tenglamalar, tengsizliklar, funksiyalar, progressiyalar.",
    "➕", "#f59e0b", "#f97316", "intermediate", "algebra,equations,math", 10)

dk6 = get_or_create_deck(OWNER, "Algebra Fundamentals", "🔣", "Core algebra concepts and formulas", "mcq")
link_deck(alg_id, dk6, 1)
add_cards(dk6, [
    ("What is x if 2x + 6 = 14?\nA) x = 3\nB) x = 4\nC) x = 5\nD) x = 10",
     "B) x = 4", "2x = 14 - 6 = 8, x = 4."),
    ("Simplify: 3(x + 4)\nA) 3x + 4\nB) 3x + 7\nC) 3x + 12\nD) x + 12",
     "C) 3x + 12", "Distributive property: 3·x + 3·4 = 3x + 12."),
    ("What is the slope of y = 3x - 5?\nA) -5\nB) 3\nC) -3\nD) 5",
     "B) 3", "In y = mx + b, m is the slope. Here m = 3."),
    ("Solve: x² = 25\nA) x = 5\nB) x = -5\nC) x = ±5\nD) x = 625",
     "C) x = ±5", "Square root of 25 is ±5."),
    ("What is the value of 2³?\nA) 6\nB) 8\nC) 9\nD) 16",
     "B) 8", "2³ = 2 × 2 × 2 = 8."),
    ("Factor: x² - 9\nA) (x-3)(x-3)\nB) (x+3)(x-3)\nC) (x+9)(x-1)\nD) (x-9)(x+1)",
     "B) (x+3)(x-3)", "Difference of squares: a²-b² = (a+b)(a-b)."),
    ("If f(x) = 2x + 1, what is f(3)?\nA) 5\nB) 6\nC) 7\nD) 8",
     "C) 7", "f(3) = 2(3) + 1 = 7."),
    ("What is the y-intercept of y = 4x + 7?\nA) 4\nB) -7\nC) 7\nD) 0",
     "C) 7", "In y = mx + b, b is the y-intercept. Here b = 7."),
    ("Solve: 3x - 2 = 10\nA) x = 2\nB) x = 3\nC) x = 4\nD) x = 6",
     "C) x = 4", "3x = 12, x = 4."),
    ("What is the sum of the arithmetic sequence 1+2+3+...+10?\nA) 45\nB) 50\nC) 55\nD) 60",
     "C) 55", "Formula: n(n+1)/2 = 10×11/2 = 55."),
])

geo_id = upsert_collection("math-geometry", math_id,
    "Геометрия", "Geometry", "Geometriya",
    "Площади, объёмы, теоремы, углы, координатная геометрия.",
    "Areas, volumes, theorems, angles, coordinate geometry.",
    "Yuzalar, hajmlar, teoremalar, burchaklar, koordinata geometriyasi.",
    "📐", "#ef4444", "#dc2626", "intermediate", "geometry,shapes,math", 20)

dk7 = get_or_create_deck(OWNER, "Geometry Formulas", "📏", "Essential geometry formulas and theorems", "mcq")
link_deck(geo_id, dk7, 1)
add_cards(dk7, [
    ("Area of a rectangle with length 8 and width 5?\nA) 13\nB) 26\nC) 40\nD) 80",
     "C) 40", "Area = length × width = 8 × 5 = 40."),
    ("Area of a circle with radius 7? (π≈3.14)\nA) 21.98\nB) 43.96\nC) 153.86\nD) 44",
     "C) 153.86", "Area = πr² = 3.14 × 49 ≈ 153.86."),
    ("Perimeter of a square with side 6?\nA) 12\nB) 24\nC) 36\nD) 6",
     "B) 24", "Perimeter = 4 × side = 4 × 6 = 24."),
    ("Sum of angles in a triangle?\nA) 90°\nB) 180°\nC) 270°\nD) 360°",
     "B) 180°", "All triangles have interior angles summing to 180°."),
    ("Hypotenuse of right triangle with legs 3 and 4?\nA) 5\nB) 6\nC) 7\nD) 12",
     "A) 5", "Pythagorean theorem: 3²+4²=9+16=25, √25=5."),
    ("Volume of a cube with side 3?\nA) 9\nB) 18\nC) 27\nD) 81",
     "C) 27", "Volume = side³ = 3³ = 27."),
    ("Circumference of circle with radius 5? (π≈3.14)\nA) 15.7\nB) 31.4\nC) 78.5\nD) 10",
     "B) 31.4", "Circumference = 2πr = 2 × 3.14 × 5 = 31.4."),
    ("Area of triangle with base 10 and height 6?\nA) 30\nB) 60\nC) 16\nD) 32",
     "A) 30", "Area = ½ × base × height = ½ × 10 × 6 = 30."),
    ("How many degrees in a right angle?\nA) 45°\nB) 90°\nC) 180°\nD) 360°",
     "B) 90°", "A right angle is exactly 90 degrees."),
    ("Volume of cylinder with r=3, h=10? (π≈3.14)\nA) 94.2\nB) 188.4\nC) 282.6\nD) 30",
     "C) 282.6", "V = πr²h = 3.14 × 9 × 10 = 282.6."),
])

# ─────────────────────────────────────────────
# 3. PROGRAMMING
# ─────────────────────────────────────────────
prog_id = upsert_subject(
    "programming", "Программирование", "Programming", "Dasturlash",
    "Python, JavaScript, HTML/CSS, SQL, алгоритмы и структуры данных.",
    "Python, JavaScript, HTML/CSS, SQL, algorithms and data structures.",
    "Python, JavaScript, HTML/CSS, SQL, algoritmlar va ma'lumotlar tuzilmalari.",
    "💻", "#8b5cf6", "#6366f1", 3)

py_id = upsert_collection("programming-python", prog_id,
    "Python", "Python", "Python",
    "Основы Python: синтаксис, типы данных, функции, ООП, библиотеки.",
    "Python basics: syntax, data types, functions, OOP, libraries.",
    "Python asoslari: sintaksis, ma'lumot turlari, funksiyalar, OOP, kutubxonalar.",
    "🐍", "#10b981", "#059669", "beginner", "python,programming,coding", 10)

dk8 = get_or_create_deck(OWNER, "Python Basics Quiz", "🐍", "Test your Python fundamentals", "mcq")
link_deck(py_id, dk8, 1)
add_cards(dk8, [
    ("What does print('Hello') do?\nA) Stores 'Hello'\nB) Deletes 'Hello'\nC) Displays 'Hello' on screen\nD) Creates a variable",
     "C) Displays 'Hello' on screen", "print() outputs text to the console."),
    ("Which data type is x = 3.14?\nA) int\nB) str\nC) bool\nD) float",
     "D) float", "Numbers with decimal points are floats."),
    ("How do you create a list in Python?\nA) x = (1,2,3)\nB) x = [1,2,3]\nC) x = {1,2,3}\nD) x = <1,2,3>",
     "B) x = [1,2,3]", "Lists use square brackets []."),
    ("What is len([1, 2, 3, 4])?\nA) 3\nB) 4\nC) 5\nD) 10",
     "B) 4", "len() returns the number of items. The list has 4 items."),
    ("How do you start a for loop?\nA) loop x in range(5):\nB) for x in range(5):\nC) foreach x in range(5):\nD) repeat x in range(5):",
     "B) for x in range(5):", "Python uses 'for x in iterable:' syntax."),
    ("What does // do in Python?\nA) Division\nB) Floor division\nC) Modulo\nD) Power",
     "B) Floor division", "5 // 2 = 2 (rounds down)."),
    ("How do you define a function?\nA) function greet():\nB) def greet():\nC) func greet():\nD) define greet():",
     "B) def greet():", "Python uses 'def' keyword for functions."),
    ("What is the output of 2 ** 3?\nA) 6\nB) 8\nC) 9\nD) 5",
     "B) 8", "** is the power operator. 2³ = 8."),
    ("Which keyword is used to check a condition?\nA) check\nB) when\nC) if\nD) test",
     "C) if", "Python uses if/elif/else for conditions."),
    ("What does range(5) produce?\nA) [1,2,3,4,5]\nB) [0,1,2,3,4]\nC) [0,1,2,3,4,5]\nD) [1,2,3,4]",
     "B) [0,1,2,3,4]", "range(5) starts at 0 and goes up to (not including) 5."),
])

js_id = upsert_collection("programming-javascript", prog_id,
    "JavaScript", "JavaScript", "JavaScript",
    "Основы JS: переменные, функции, DOM, асинхронность, ES6+.",
    "JS basics: variables, functions, DOM, async, ES6+.",
    "JS asoslari: o'zgaruvchilar, funksiyalar, DOM, async, ES6+.",
    "🟨", "#f59e0b", "#d97706", "beginner", "javascript,js,web,frontend", 20)

dk9 = get_or_create_deck(OWNER, "JavaScript Fundamentals", "🟨", "Core JavaScript concepts quiz", "mcq")
link_deck(js_id, dk9, 1)
add_cards(dk9, [
    ("Which keyword declares a constant in JS?\nA) var\nB) let\nC) const\nD) static",
     "C) const", "const declares a variable that cannot be reassigned."),
    ("What does === check?\nA) Assignment\nB) Value only\nC) Value and type\nD) Type only",
     "C) Value and type", "=== is strict equality. 5 === '5' is false."),
    ("How do you write a comment in JS?\nA) # comment\nB) <!-- comment -->\nC) // comment\nD) /* comment",
     "C) // comment", "Single-line comments use //. Multi-line use /* */."),
    ("What is typeof 42?\nA) 'int'\nB) 'number'\nC) 'float'\nD) 'integer'",
     "B) 'number'", "JavaScript has one number type for all numbers."),
    ("How do you select an element by ID?\nA) document.query('#id')\nB) document.getElementById('id')\nC) document.select('id')\nD) document.find('#id')",
     "B) document.getElementById('id')", "getElementById is the classic DOM method."),
    ("What does console.log() do?\nA) Saves to database\nB) Prints to browser console\nC) Creates an alert\nD) Sends to server",
     "B) Prints to browser console", "Used for debugging — output appears in DevTools."),
    ("Which method adds an item to end of array?\nA) push()\nB) pop()\nC) shift()\nD) add()",
     "A) push()", "arr.push(item) adds to the end. pop() removes from end."),
    ("What is an arrow function?\nA) function() {}\nB) () => {}\nC) func() {}\nD) => function() {}",
     "B) () => {}", "Arrow functions: const greet = (name) => 'Hello ' + name;"),
    ("What does JSON stand for?\nA) Java Standard Object Notation\nB) JavaScript Object Notation\nC) Java Script Online Network\nD) JavaScript Online Notation",
     "B) JavaScript Object Notation", "JSON is a data format used for APIs."),
    ("How do you convert string '42' to number?\nA) int('42')\nB) Number('42')\nC) parse('42')\nD) toNumber('42')",
     "B) Number('42')", "Number(), parseInt(), or parseFloat() convert strings to numbers."),
])

# ─────────────────────────────────────────────
# 4. SCIENCE
# ─────────────────────────────────────────────
sci_id = upsert_subject(
    "science", "Естественные науки", "Science", "Tabiiy fanlar",
    "Биология, химия, физика — школьная и университетская программа.",
    "Biology, chemistry, physics — school and university curriculum.",
    "Biologiya, kimyo, fizika — maktab va universitet dasturi.",
    "🔬", "#10b981", "#059669", 4)

bio_id = upsert_collection("science-biology", sci_id,
    "Биология", "Biology", "Biologiya",
    "Клетка, генетика, эволюция, экология, анатомия человека.",
    "Cell biology, genetics, evolution, ecology, human anatomy.",
    "Hujayra biologiyasi, genetika, evolyutsiya, ekologiya, inson anatomiyasi.",
    "🧬", "#10b981", "#059669", "intermediate", "biology,science,cells", 10)

dk10 = get_or_create_deck(OWNER, "Cell Biology Quiz", "🔬", "Test your knowledge of cell biology", "mcq")
link_deck(bio_id, dk10, 1)
add_cards(dk10, [
    ("What is the powerhouse of the cell?\nA) Nucleus\nB) Ribosome\nC) Mitochondria\nD) Vacuole",
     "C) Mitochondria", "Mitochondria produce ATP — the cell's energy currency."),
    ("Which organelle contains DNA?\nA) Ribosome\nB) Nucleus\nC) Golgi apparatus\nD) Lysosome",
     "B) Nucleus", "The nucleus stores genetic information (DNA)."),
    ("What is photosynthesis?\nA) Breaking down food\nB) Converting light to energy\nC) Cell division\nD) Protein synthesis",
     "B) Converting light to energy", "Plants convert sunlight + CO₂ + water → glucose + oxygen."),
    ("How many chromosomes do humans have?\nA) 23\nB) 46\nC) 48\nD) 64",
     "B) 46", "Humans have 46 chromosomes (23 pairs)."),
    ("What does DNA stand for?\nA) Deoxyribonucleic Acid\nB) Deoxyribose Nucleic Acid\nC) Double Nucleic Acid\nD) Deoxyribonuclear Acid",
     "A) Deoxyribonucleic Acid", "DNA carries genetic instructions for all living organisms."),
    ("Which blood type is the universal donor?\nA) A\nB) B\nC) AB\nD) O",
     "D) O", "Type O negative can donate to all blood types."),
    ("What is osmosis?\nA) Movement of solutes\nB) Movement of water through a membrane\nC) Cell division\nD) Protein folding",
     "B) Movement of water through a membrane", "Water moves from low to high solute concentration."),
    ("What is the basic unit of life?\nA) Atom\nB) Molecule\nC) Cell\nD) Organ",
     "C) Cell", "All living things are made of cells."),
    ("Which gas do plants absorb during photosynthesis?\nA) Oxygen\nB) Nitrogen\nC) Carbon dioxide\nD) Hydrogen",
     "C) Carbon dioxide", "Plants absorb CO₂ and release O₂."),
    ("What is mitosis?\nA) Sexual reproduction\nB) Cell division producing 2 identical cells\nC) Protein synthesis\nD) DNA replication only",
     "B) Cell division producing 2 identical cells", "Mitosis: 1 cell → 2 identical daughter cells."),
])

# ─────────────────────────────────────────────
# 5. BUSINESS
# ─────────────────────────────────────────────
biz_id = upsert_subject(
    "business", "Бизнес", "Business", "Biznes",
    "Маркетинг, финансы, бухгалтерия, предпринимательство.",
    "Marketing, finance, accounting, entrepreneurship.",
    "Marketing, moliya, buxgalteriya, tadbirkorlik.",
    "💼", "#f59e0b", "#d97706", 5)

mkt_id = upsert_collection("business-marketing", biz_id,
    "Маркетинг", "Marketing", "Marketing",
    "Основы маркетинга: 4P, целевая аудитория, digital, бренд.",
    "Marketing fundamentals: 4P, target audience, digital, brand.",
    "Marketing asoslari: 4P, maqsadli auditoriya, raqamli, brend.",
    "📣", "#f59e0b", "#ef4444", "beginner", "marketing,business,brand", 10)

dk11 = get_or_create_deck(OWNER, "Marketing Fundamentals", "📣", "Core marketing concepts and terminology", "terms")
link_deck(mkt_id, dk11, 1)
add_cards(dk11, [
    ("Target audience", "Целевая аудитория", "The specific group of people a product/service is aimed at."),
    ("Brand", "Бренд", "The identity and perception of a company or product."),
    ("USP (Unique Selling Proposition)", "Уникальное торговое предложение", "What makes your product different from competitors."),
    ("4P of Marketing", "4П маркетинга", "Product, Price, Place, Promotion."),
    ("Market segmentation", "Сегментация рынка", "Dividing the market into distinct groups of buyers."),
    ("ROI (Return on Investment)", "Возврат инвестиций", "ROI = (Gain - Cost) / Cost × 100%."),
    ("Conversion rate", "Конверсия", "% of visitors who take a desired action (buy, sign up)."),
    ("CTA (Call to Action)", "Призыв к действию", "Buy now, Sign up, Learn more — buttons/phrases."),
    ("SEO (Search Engine Optimization)", "Поисковая оптимизация", "Improving website visibility in search results."),
    ("Content marketing", "Контент-маркетинг", "Creating valuable content to attract and retain customers."),
    ("Funnel", "Воронка продаж", "Awareness → Interest → Decision → Action."),
    ("KPI (Key Performance Indicator)", "Ключевой показатель эффективности", "Measurable value showing how well goals are achieved."),
    ("B2B", "Бизнес для бизнеса", "Business selling to other businesses."),
    ("B2C", "Бизнес для потребителя", "Business selling directly to consumers."),
    ("Churn rate", "Отток клиентов", "% of customers who stop using a service in a period."),
    ("Lifetime value (LTV)", "Пожизненная ценность клиента", "Total revenue expected from one customer over time."),
    ("A/B testing", "A/B тестирование", "Comparing two versions to see which performs better."),
    ("Organic traffic", "Органический трафик", "Visitors who find you through unpaid search results."),
    ("Paid traffic", "Платный трафик", "Visitors from paid ads (Google Ads, Facebook Ads)."),
    ("Engagement rate", "Вовлечённость", "Likes + comments + shares / reach × 100%."),
])

# ─────────────────────────────────────────────
# LEARNING PATHS
# ─────────────────────────────────────────────
def upsert_path(slug, subj_id, ru, en, uz, dru, den, duz, icon, c1, c2, diff, hours, sort):
    c.execute("""INSERT OR IGNORE INTO learning_paths
        (slug,subject_id,title_ru,title_en,title_uz,desc_ru,desc_en,desc_uz,
         icon,color,color2,difficulty,estimated_hours,sort_order,is_active)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,1)""",
        (slug,subj_id,ru,en,uz,dru,den,duz,icon,c1,c2,diff,hours,sort))
    row = c.execute("SELECT id FROM learning_paths WHERE slug=?", (slug,)).fetchone()
    return row[0]

def add_path_step(path_id, order, step_type, coll_id=None, deck_id=None, ru="", en="", uz=""):
    c.execute("""INSERT OR IGNORE INTO learning_path_steps
        (path_id,step_order,step_type,collection_id,deck_id,title_ru,title_en,title_uz)
        VALUES (?,?,?,?,?,?,?,?)""",
        (path_id, order, step_type, coll_id, deck_id, ru, en, uz))

# English A1 Path
p1 = upsert_path("english-a1-path", eng_id,
    "Путь A1: Английский с нуля", "English A1 Learning Path", "A1 ingliz tili yo'li",
    "Полный путь для абсолютных новичков: приветствия, числа, распорядок дня.",
    "Complete path for absolute beginners: greetings, numbers, daily routines.",
    "Mutlaq yangi boshlovchilar uchun to'liq yo'l: salomlashish, raqamlar, kundalik tartib.",
    "🌱", "#10b981", "#059669", "beginner", 3, 1)
add_path_step(p1, 1, "collection", coll_id=a1_id, ru="Урок 1: Приветствия", en="Lesson 1: Greetings", uz="Dars 1: Salomlashish")
add_path_step(p1, 2, "collection", coll_id=a2_id, ru="Урок 2: Распорядок дня", en="Lesson 2: Daily Routines", uz="Dars 2: Kundalik tartib")
add_path_step(p1, 3, "collection", coll_id=vocab_id, ru="Урок 3: Технологии", en="Lesson 3: Technology", uz="Dars 3: Texnologiya")

# Python Path
p2 = upsert_path("python-beginner-path", prog_id,
    "Python с нуля", "Python from Scratch", "Python noldan",
    "Полный путь для начинающих программистов на Python.",
    "Complete path for Python beginners.",
    "Python boshlang'ichlari uchun to'liq yo'l.",
    "🐍", "#10b981", "#059669", "beginner", 5, 2)
add_path_step(p2, 1, "collection", coll_id=py_id, ru="Основы Python", en="Python Basics", uz="Python asoslari")
add_path_step(p2, 2, "collection", coll_id=js_id, ru="JavaScript после Python", en="JavaScript after Python", uz="Python'dan keyin JavaScript")

conn.commit()
conn.close()
print("✅ Marketplace v2 seeded successfully!")
print(f"   Subjects: English, Mathematics, Programming, Science, Business")
print(f"   Collections: A1, A2, Grammar, Vocabulary, Algebra, Geometry, Python, JS, Biology, Marketing")
print(f"   Learning Paths: English A1 Path, Python Path")
