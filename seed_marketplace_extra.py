# -*- coding: utf-8 -*-
"""Marketplace extra seed: adds 18 new collections to existing 5 subjects.

English:    + B1, B2, Phrasal Verbs, IELTS, TOEFL
Math:       + Calculus, Statistics, Exam Prep
Programming:+ HTML/CSS, SQL, Algorithms, Data Structures
Science:    + Chemistry, Physics, General Science
Business:   + Finance, Accounting, Entrepreneurship

Safe to re-run — uses INSERT OR IGNORE.
"""
import db

conn = db.get_conn()
c = conn.cursor()

# Get existing subject IDs
def subj_id(slug):
    r = c.execute("SELECT id FROM mp_subjects WHERE slug=?", (slug,)).fetchone()
    return r[0] if r else None

eng_id  = subj_id("english")
math_id = subj_id("mathematics")
prog_id = subj_id("programming")
sci_id  = subj_id("science")
biz_id  = subj_id("business")

if not all([eng_id, math_id, prog_id, sci_id, biz_id]):
    print("[seed_extra] Subjects missing — run seed_marketplace.py first")
    conn.close()
    raise SystemExit(0)

# System owner for all seeded decks
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
        (slug, subj_id_, slug.split("-")[0], ru, en, uz, dru, den, duz,
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
    """cards = list of (front, back, note)"""
    if c.execute("SELECT COUNT(*) FROM cards WHERE deck_id=?", (deck_id,)).fetchone()[0] > 0:
        return
    for f, b, n in cards:
        c.execute("INSERT INTO cards (deck_id,front,back,note) VALUES (?,?,?,?)",
                  (deck_id, f, b, n))


print("[seed_extra] Starting...")


# ─────────────────────────────────────────────
# ENGLISH: B1, B2, Phrasal Verbs, IELTS, TOEFL
# ─────────────────────────────────────────────

# B1 Intermediate
b1_id = upsert_collection("english-b1", eng_id,
    "B1 Intermediate", "B1 Intermediate", "B1 Intermediate",
    "Уверенный средний уровень: условные предложения, перфект, модальные глаголы.",
    "Confident intermediate level: conditionals, perfect tenses, modal verbs.",
    "Ishonchli oʻrta daraja: shartli gaplar, perfect zamonlar, modal feʼllar.",
    "📘", "#3b82f6", "#2563eb", "intermediate", "B1,intermediate,CEFR", 50)

dk = get_or_create_deck("B1 Conditionals (If clauses)", "🔀",
    "First, second, third conditional questions", "mcq")
link_deck(b1_id, dk, 1)
add_cards(dk, [
    ("If I ___ (have) more time, I would travel.\nA) have\nB) had\nC) will have\nD) would have",
     "B) had", "Second conditional: if + past, would + base."),
    ("If it ___ (rain), we'll stay home.\nA) rains\nB) rained\nC) will rain\nD) had rained",
     "A) rains", "First conditional: real future possibility."),
    ("If I ___ (know), I would have helped.\nA) knew\nB) had known\nC) know\nD) would know",
     "B) had known", "Third conditional: past unreal — if + past perfect."),
    ("She would call you if she ___ (have) your number.\nA) has\nB) had\nC) would have\nD) will have",
     "B) had", "Second conditional in reverse order."),
    ("If you press this button, the door ___ (open).\nA) opens\nB) opened\nC) will open\nD) would open",
     "A) opens", "Zero conditional: general truth — if + present, present."),
    ("I ___ (call) you if I'd had your number yesterday.\nA) call\nB) called\nC) would have called\nD) will call",
     "C) would have called", "Third conditional: past unreal result."),
    ("Unless you ___ (hurry), you'll miss the bus.\nA) hurry\nB) hurried\nC) will hurry\nD) would hurry",
     "A) hurry", "Unless = if not. Same as first conditional."),
    ("If only I ___ (be) taller!\nA) am\nB) was\nC) were\nD) had been",
     "C) were", "Wishes use 'were' for all persons in formal English."),
    ("Provided that you ___ (finish) the report, you can leave.\nA) finish\nB) finished\nC) had finished\nD) will finish",
     "A) finish", "Provided that = if. First conditional structure."),
    ("If I ___ (be) you, I'd take the job.\nA) am\nB) was\nC) were\nD) had been",
     "C) were", "Hypothetical advice — second conditional with 'were'."),
])

dk2 = get_or_create_deck("B1 Present Perfect Mastery", "⏳",
    "When and how to use Present Perfect", "mcq")
link_deck(b1_id, dk2, 2)
add_cards(dk2, [
    ("I ___ (live) here for 10 years.\nA) live\nB) lived\nC) have lived\nD) am living",
     "C) have lived", "Present Perfect for ongoing action from past to now."),
    ("She ___ (just / finish) her homework.\nA) just finished\nB) has just finished\nC) just finishes\nD) had just finished",
     "B) has just finished", "'Just' with Present Perfect — recent action."),
    ("___ you ___ (ever / be) to Paris?\nA) Did, be\nB) Have, been\nC) Are, being\nD) Were, been",
     "B) Have, been", "Have you ever been? — life experience question."),
    ("I ___ (not see) him since Monday.\nA) don't see\nB) didn't see\nC) haven't seen\nD) wasn't seeing",
     "C) haven't seen", "Negative + 'since' — Present Perfect."),
    ("They ___ (already / leave) when I arrived.\nA) already left\nB) have already left\nC) had already left\nD) were already leaving",
     "C) had already left", "Past Perfect — action before another past action."),
    ("I ___ (work) here since 2020.\nA) work\nB) worked\nC) have worked\nD) am working",
     "C) have worked", "'Since' with specific point in time — Present Perfect."),
    ("How long ___ you ___ (study) English?\nA) did, study\nB) have, studied\nC) are, studying\nD) do, study",
     "B) have, studied", "How long? + ongoing action — Present Perfect."),
    ("She ___ (write) 3 books so far.\nA) writes\nB) wrote\nC) has written\nD) is writing",
     "C) has written", "'So far' = up to now — Present Perfect."),
    ("___ you ___ (finish) your dinner yet?\nA) Did, finish\nB) Have, finished\nC) Are, finishing\nD) Were, finishing",
     "B) Have, finished", "'Yet' in questions — Present Perfect."),
    ("I ___ (lose) my keys! Can you help?\nA) lose\nB) lost\nC) have lost\nD) am losing",
     "C) have lost", "Recent action with present consequence — Present Perfect."),
])


# B2 Upper Intermediate
b2_id = upsert_collection("english-b2", eng_id,
    "B2 Upper Intermediate", "B2 Upper Intermediate", "B2 Upper Intermediate",
    "Продвинутый уровень: сложные времена, инверсия, сослагательное наклонение.",
    "Advanced level: complex tenses, inversion, subjunctive.",
    "Yuqori daraja: murakkab zamonlar, inversiya, subjunktiv.",
    "📕", "#6366f1", "#4f46e5", "advanced", "B2,upper-intermediate,CEFR", 60)

dk3 = get_or_create_deck("B2 Inversion & Emphasis", "🔁",
    "Advanced inversion structures for emphasis", "mcq")
link_deck(b2_id, dk3, 1)
add_cards(dk3, [
    ("Hardly ___ when the rain started.\nA) we had arrived\nB) had we arrived\nC) we arrived\nD) did we arrive",
     "B) had we arrived", "Hardly... when triggers inversion: had + subject."),
    ("Not only ___ the project, but he also won the award.\nA) he completed\nB) did he complete\nC) had he completed\nD) was he completing",
     "B) did he complete", "Not only... but also — inversion."),
    ("Never ___ such a beautiful sunset.\nA) I have seen\nB) have I seen\nC) I had seen\nD) I saw",
     "B) have I seen", "Never at start of sentence — inversion."),
    ("Under no circumstances ___ leave the building.\nA) you should\nB) should you\nC) you would\nD) would you",
     "B) should you", "Under no circumstances — formal negative inversion."),
    ("Rarely ___ such talent in a young player.\nA) you see\nB) do you see\nC) have seen\nD) you have seen",
     "B) do you see", "Rarely at start — auxiliary + subject."),
    ("Little ___ that the surprise was for him.\nA) he knew\nB) did he know\nC) he had known\nD) was he knowing",
     "B) did he know", "Little = barely. Triggers inversion."),
    ("Should you ___ help, please call us.\nA) need\nB) needed\nC) needing\nD) to need",
     "A) need", "Conditional inversion: 'Should you need' = 'If you need'."),
    ("So beautiful ___ the view that we stayed for hours.\nA) was\nB) it was\nC) had been\nD) it had been",
     "A) was", "So + adjective at start — inversion of 'be'."),
    ("Only when she left ___ the truth.\nA) I realized\nB) did I realize\nC) had I realized\nD) was I realizing",
     "B) did I realize", "Only when... — inversion in main clause."),
    ("Were I ___ choose, I'd pick the blue one.\nA) to\nB) for\nC) of\nD) at",
     "A) to", "Were I to + base = If I had to. Formal conditional."),
])

# Phrasal Verbs
phr_id = upsert_collection("english-phrasal-verbs", eng_id,
    "Фразовые глаголы", "Phrasal Verbs", "Phrasal feʼllar",
    "Самые употребляемые фразовые глаголы с примерами.",
    "Most-used phrasal verbs with examples.",
    "Eng koʻp ishlatiladigan phrasal feʼllar misollar bilan.",
    "🔗", "#8b5cf6", "#7c3aed", "intermediate", "phrasal,verbs,collocations", 70)

dk4 = get_or_create_deck("Top 20 Phrasal Verbs", "💬",
    "Essential phrasal verbs for daily English", "terms")
link_deck(phr_id, dk4, 1)
add_cards(dk4, [
    ("give up", "сдаваться / бросать (привычку)", "Don't give up! / I gave up smoking 5 years ago."),
    ("look after", "заботиться о", "Can you look after my cat this weekend?"),
    ("look for", "искать", "I'm looking for my keys."),
    ("turn on / off", "включать / выключать", "Turn on the light. Turn off the TV."),
    ("get up", "вставать (с кровати)", "I get up at 7am every day."),
    ("get on (with)", "ладить с", "I get on well with my colleagues."),
    ("put on", "надевать", "Put on your coat — it's cold outside."),
    ("take off", "снимать (одежду) / взлетать", "Take off your shoes. The plane took off at 3pm."),
    ("come back", "возвращаться", "What time will you come back?"),
    ("go on", "продолжать / происходить", "Go on, tell me. What's going on here?"),
    ("find out", "узнавать / выяснять", "I found out the truth yesterday."),
    ("run out (of)", "заканчиваться", "We've run out of milk."),
    ("break down", "ломаться (о машине, человеке)", "The car broke down on the highway."),
    ("hang out", "тусоваться / проводить время", "We hang out every Friday."),
    ("show up", "появляться (на встрече)", "He didn't show up at the meeting."),
    ("set up", "организовывать / устанавливать", "We set up a new business."),
    ("work out", "тренироваться / получаться", "I work out 3 times a week. It worked out fine."),
    ("calm down", "успокаиваться", "Calm down, everything's okay."),
    ("look up", "искать (в словаре, интернете)", "Look up this word in the dictionary."),
    ("go through", "пережить / проходить через", "She's going through a difficult time."),
])

# IELTS
ielts_id = upsert_collection("english-ielts", eng_id,
    "IELTS Preparation", "IELTS Preparation", "IELTS Tayyorgarlik",
    "Подготовка к IELTS: словарный запас 7.0+, академический английский.",
    "IELTS prep: 7.0+ vocabulary, academic English.",
    "IELTS tayyorgarligi: 7.0+ lugʻat, akademik ingliz tili.",
    "🎓", "#0ea5e9", "#0284c7", "advanced", "IELTS,exam,academic", 80)

dk5 = get_or_create_deck("IELTS 7.0+ Vocabulary", "📚",
    "Academic vocabulary for high IELTS bands", "terms")
link_deck(ielts_id, dk5, 1)
add_cards(dk5, [
    ("substantial", "значительный, существенный", "There's been a substantial increase in prices."),
    ("ubiquitous", "вездесущий, повсеместный", "Smartphones are ubiquitous in modern life."),
    ("plausible", "правдоподобный", "His explanation sounds plausible."),
    ("inevitable", "неизбежный", "Change is inevitable in any growing company."),
    ("predominant", "преобладающий, основной", "The predominant factor is cost."),
    ("comprehensive", "всеобъемлющий, полный", "We need a comprehensive solution."),
    ("controversial", "спорный, противоречивый", "The decision was highly controversial."),
    ("significant", "значительный, важный", "There has been a significant improvement."),
    ("crucial", "критически важный", "Education plays a crucial role in society."),
    ("emerge", "появляться, возникать", "New evidence has emerged."),
    ("derive (from)", "происходить (от)", "The word derives from Latin."),
    ("undermine", "подрывать, ослаблять", "These actions undermine our credibility."),
    ("reinforce", "укреплять, усиливать", "This research reinforces our hypothesis."),
    ("alleviate", "облегчать, смягчать", "These measures will alleviate poverty."),
    ("exacerbate", "усугублять", "Stress can exacerbate health problems."),
    ("compelling", "убедительный", "She made a compelling argument."),
    ("scrutiny", "тщательное изучение", "His decisions came under intense scrutiny."),
    ("inherent", "присущий, свойственный", "There are inherent risks in any business."),
    ("sustainable", "устойчивый, долгосрочный", "We need sustainable solutions."),
    ("paradigm", "парадигма, образец", "This represents a paradigm shift."),
])

# TOEFL
toefl_id = upsert_collection("english-toefl", eng_id,
    "TOEFL Preparation", "TOEFL Preparation", "TOEFL Tayyorgarlik",
    "TOEFL iBT: чтение, аудирование, академическая лексика.",
    "TOEFL iBT: reading, listening, academic vocabulary.",
    "TOEFL iBT: oʻqish, tinglash, akademik lugʻat.",
    "🇺🇸", "#dc2626", "#b91c1c", "advanced", "TOEFL,exam,academic", 90)

dk6 = get_or_create_deck("TOEFL Reading Strategies", "📖",
    "Question types and strategies for TOEFL Reading", "mcq")
link_deck(toefl_id, dk6, 1)
add_cards(dk6, [
    ("In TOEFL reading, 'inference' means:\nA) Direct quote from text\nB) Logical conclusion not stated directly\nC) Word definition\nD) Author's name",
     "B) Logical conclusion not stated directly", "Inference questions ask about implied meanings."),
    ("Which is best for vocabulary questions?\nA) Skip them\nB) Use context clues\nC) Memorize all words\nD) Use a dictionary",
     "B) Use context clues", "Surrounding sentences usually reveal word meaning."),
    ("'According to paragraph 2' questions test:\nA) Inference\nB) Vocabulary\nC) Direct factual recall\nD) Tone",
     "C) Direct factual recall", "These questions need explicit information from text."),
    ("'Negative factual' questions ask which option is:\nA) The longest\nB) NOT mentioned\nC) The most important\nD) A summary",
     "B) NOT mentioned", "Watch for words like 'EXCEPT' or 'NOT'."),
    ("Best time per reading passage in TOEFL:\nA) 5 min\nB) 10 min\nC) 18 min\nD) 30 min",
     "C) 18 min", "TOEFL gives ~18 min per passage for 10 questions."),
    ("'Insert sentence' questions test:\nA) Grammar\nB) Vocabulary\nC) Coherence and logical flow\nD) Author's bias",
     "C) Coherence and logical flow", "Choose where the sentence fits best in the text."),
    ("Skim a passage means to:\nA) Read every word slowly\nB) Read quickly for main ideas\nC) Translate to native language\nD) Memorize all facts",
     "B) Read quickly for main ideas", "Skimming helps grasp the main topic fast."),
    ("'Author's purpose' questions test:\nA) Vocabulary\nB) Grammar\nC) Why author wrote that section\nD) Sentence structure",
     "C) Why author wrote that section", "Look at the function of a paragraph in the whole text."),
    ("Summary question selects:\nA) 3 main ideas from 6 options\nB) 1 best title\nC) Author's name\nD) All correct facts",
     "A) 3 main ideas from 6 options", "TOEFL summary: pick 3 best statements."),
    ("If you don't know an answer, you should:\nA) Leave it blank\nB) Skip and return\nC) Make a guess (no penalty)\nD) Restart the section",
     "C) Make a guess (no penalty)", "TOEFL has no penalty for wrong answers — always guess."),
])


# ─────────────────────────────────────────────
# MATHEMATICS: Calculus, Statistics, Exam Preparation
# ─────────────────────────────────────────────

calc_id = upsert_collection("math-calculus", math_id,
    "Математический анализ", "Calculus", "Matematik tahlil",
    "Производные, интегралы, пределы — основа высшей математики.",
    "Derivatives, integrals, limits — foundation of higher math.",
    "Hosilalar, integrallar, limitlar — yuqori matematikaning asosi.",
    "📈", "#ef4444", "#dc2626", "advanced", "calculus,derivatives,integrals", 30)

dk = get_or_create_deck("Calculus: Derivatives Basics", "📈",
    "Derivative rules and computations", "mcq")
link_deck(calc_id, dk, 1)
add_cards(dk, [
    ("d/dx of x²?\nA) x\nB) 2x\nC) x³/3\nD) 2",
     "B) 2x", "Power rule: d/dx(xⁿ) = n·xⁿ⁻¹."),
    ("d/dx of 5x³?\nA) 15x²\nB) 5x²\nC) x²\nD) 5/x²",
     "A) 15x²", "Pull constant: 5 · 3x² = 15x²."),
    ("d/dx of sin(x)?\nA) -cos(x)\nB) cos(x)\nC) tan(x)\nD) sec(x)",
     "B) cos(x)", "Standard derivative."),
    ("d/dx of cos(x)?\nA) sin(x)\nB) -sin(x)\nC) tan(x)\nD) -cos(x)",
     "B) -sin(x)", "Note the negative sign."),
    ("d/dx of eˣ?\nA) x·eˣ⁻¹\nB) eˣ\nC) eˣ⁺¹\nD) ln(x)",
     "B) eˣ", "Exponential is its own derivative."),
    ("d/dx of ln(x)?\nA) 1/x\nB) eˣ\nC) x\nD) ln(x)/x",
     "A) 1/x", "Natural log derivative."),
    ("d/dx of (3x + 5)?\nA) 3\nB) 5\nC) 3x\nD) 3 + 5x",
     "A) 3", "Constants disappear, x term becomes coefficient."),
    ("Chain rule for d/dx of (x²+1)³ gives:\nA) 3(x²+1)²\nB) 3(x²+1)² · 2x\nC) 6x³\nD) (x²+1)²",
     "B) 3(x²+1)² · 2x", "Outer derivative × inner derivative."),
    ("Derivative of constant 7 is:\nA) 7\nB) 1\nC) 0\nD) -7",
     "C) 0", "Derivative of any constant equals zero."),
    ("Product rule: d/dx(uv) =\nA) u·v\nB) u'·v'\nC) u'v + uv'\nD) u/v + v/u",
     "C) u'v + uv'", "Product rule formula."),
])

stat_id = upsert_collection("math-statistics", math_id,
    "Статистика", "Statistics", "Statistika",
    "Среднее, медиана, дисперсия, нормальное распределение.",
    "Mean, median, variance, normal distribution.",
    "Oʻrtacha, mediana, dispersiya, normal taqsimot.",
    "📊", "#f59e0b", "#d97706", "intermediate", "statistics,probability,data", 40)

dk2 = get_or_create_deck("Statistics Fundamentals", "📊",
    "Core statistical concepts", "mcq")
link_deck(stat_id, dk2, 1)
add_cards(dk2, [
    ("Mean of [2, 4, 6, 8, 10]?\nA) 5\nB) 6\nC) 7\nD) 8",
     "B) 6", "Sum (30) ÷ count (5) = 6."),
    ("Median of [3, 1, 4, 1, 5, 9, 2, 6]?\nA) 3.5\nB) 4\nC) 5\nD) 4.5",
     "A) 3.5", "Sorted: 1,1,2,3,4,5,6,9. Middle two = 3,4. Avg = 3.5."),
    ("Mode of [1, 2, 2, 3, 3, 3, 4]?\nA) 1\nB) 2\nC) 3\nD) 4",
     "C) 3", "Most frequent value is the mode."),
    ("Range of [12, 5, 8, 20, 15]?\nA) 5\nB) 12\nC) 15\nD) 20",
     "C) 15", "Max (20) − Min (5) = 15."),
    ("Probability of rolling a 6 on fair die?\nA) 1/2\nB) 1/3\nC) 1/6\nD) 1/12",
     "C) 1/6", "1 favorable outcome out of 6."),
    ("Probability of two heads in a row (fair coin)?\nA) 1/2\nB) 1/3\nC) 1/4\nD) 1/8",
     "C) 1/4", "1/2 × 1/2 = 1/4."),
    ("In a normal distribution, ~68% of data lies within:\nA) 1 standard deviation\nB) 2 std dev\nC) 3 std dev\nD) The mean",
     "A) 1 standard deviation", "68-95-99.7 rule."),
    ("Variance measures:\nA) Center of data\nB) Spread of data\nC) Highest value\nD) Sample size",
     "B) Spread of data", "Variance = average squared deviation from mean."),
    ("Standard deviation is:\nA) Mean of data\nB) Square root of variance\nC) Sum of values\nD) Range/2",
     "B) Square root of variance", "σ = √variance."),
    ("Correlation coefficient ranges from:\nA) 0 to 1\nB) -1 to 1\nC) 0 to 100\nD) -∞ to ∞",
     "B) -1 to 1", "−1 perfect negative, 0 no correlation, +1 perfect positive."),
])

exam_id = upsert_collection("math-exam-prep", math_id,
    "Подготовка к экзамену", "Exam Preparation", "Imtihonga Tayyorgarlik",
    "Тренировка к ЕГЭ / SAT / ACT по математике.",
    "Practice problems for SAT / ACT / GCSE math.",
    "Matematika imtihoniga tayyorgarlik (SAT, ACT).",
    "🎯", "#10b981", "#059669", "intermediate", "exam,SAT,GCSE,EGE", 50)

dk3 = get_or_create_deck("Math Exam Practice", "🎯",
    "Mixed problems for math exam prep", "mcq")
link_deck(exam_id, dk3, 1)
add_cards(dk3, [
    ("Solve: 3x + 7 = 22\nA) x = 4\nB) x = 5\nC) x = 6\nD) x = 7",
     "B) x = 5", "3x = 15, x = 5."),
    ("If y = 2x + 1 and x = 4, y = ?\nA) 7\nB) 8\nC) 9\nD) 10",
     "C) 9", "y = 2(4) + 1 = 9."),
    ("Simplify: 2(x + 3) - x\nA) x + 3\nB) x + 6\nC) 2x + 6\nD) x + 9",
     "B) x + 6", "2x + 6 - x = x + 6."),
    ("Solve: x² = 49\nA) x = 7\nB) x = -7\nC) x = ±7\nD) x = 14",
     "C) x = ±7", "Square root has both positive and negative solutions."),
    ("Area of circle, r=4? (π≈3.14)\nA) 12.56\nB) 25.12\nC) 50.24\nD) 100.48",
     "C) 50.24", "πr² = 3.14 × 16 = 50.24."),
    ("If 2x − 5 > 1, then:\nA) x > 3\nB) x < 3\nC) x > -3\nD) x < -3",
     "A) x > 3", "2x > 6, x > 3."),
    ("3⁴ = ?\nA) 12\nB) 27\nC) 64\nD) 81",
     "D) 81", "3 × 3 × 3 × 3 = 81."),
    ("Slope of line through (1,2) and (3,6)?\nA) 1\nB) 2\nC) 3\nD) 4",
     "B) 2", "(6-2)/(3-1) = 4/2 = 2."),
    ("Sum of interior angles of hexagon?\nA) 360°\nB) 540°\nC) 720°\nD) 900°",
     "C) 720°", "(n-2)·180° = 4·180° = 720°."),
    ("If sin(θ) = 0.5, θ in degrees?\nA) 30°\nB) 45°\nC) 60°\nD) 90°",
     "A) 30°", "sin(30°) = 0.5."),
])


# ─────────────────────────────────────────────
# PROGRAMMING: HTML/CSS, SQL, Algorithms, Data Structures
# ─────────────────────────────────────────────

html_id = upsert_collection("programming-html-css", prog_id,
    "HTML и CSS", "HTML/CSS", "HTML/CSS",
    "Основы веб-разработки: разметка, стили, адаптивный дизайн.",
    "Web fundamentals: markup, styling, responsive design.",
    "Web asoslari: belgilash, stillar, moslashuvchi dizayn.",
    "🎨", "#f97316", "#ea580c", "beginner", "html,css,web,frontend", 30)

dk = get_or_create_deck("HTML/CSS Basics Quiz", "🎨",
    "Essential HTML and CSS fundamentals", "mcq")
link_deck(html_id, dk, 1)
add_cards(dk, [
    ("Which tag creates a hyperlink?\nA) <link>\nB) <a>\nC) <href>\nD) <url>",
     "B) <a>", "<a href='...'> creates a clickable link."),
    ("How to add a CSS class in HTML?\nA) class='name'\nB) css='name'\nC) style='name'\nD) id='name'",
     "A) class='name'", "Use class attribute. id is for unique elements."),
    ("Which CSS property changes text color?\nA) text-color\nB) font-color\nC) color\nD) text-style",
     "C) color", "Just 'color' for text color."),
    ("Which is NOT a heading tag?\nA) <h1>\nB) <h6>\nC) <h7>\nD) <h3>",
     "C) <h7>", "HTML headings go from <h1> to <h6> only."),
    ("CSS to make element invisible but keep space:\nA) display: none\nB) visibility: hidden\nC) opacity: 0 only\nD) hidden: true",
     "B) visibility: hidden", "display:none removes from layout. visibility:hidden keeps space."),
    ("Which selector targets all <p> elements?\nA) #p\nB) .p\nC) p\nD) *p",
     "C) p", "Element selector — just the tag name."),
    ("Box model layers (outside in):\nA) margin, border, padding, content\nB) padding, margin, content, border\nC) border, padding, margin, content\nD) content, padding, border, margin",
     "A) margin, border, padding, content", "Margin > Border > Padding > Content."),
    ("Flexbox property to align items horizontally:\nA) align-items\nB) justify-content\nC) flex-direction\nD) gap",
     "B) justify-content", "justify-content controls main axis (default = horizontal)."),
    ("Make image responsive (full width):\nA) width: 100%\nB) max-width: 100%\nC) size: full\nD) responsive: true",
     "B) max-width: 100%", "max-width:100% prevents enlargement past natural size."),
    ("Which is a semantic HTML5 tag?\nA) <div>\nB) <span>\nC) <article>\nD) <table>",
     "C) <article>", "<article>, <section>, <nav>, <header> are semantic."),
])

sql_id = upsert_collection("programming-sql", prog_id,
    "SQL базы данных", "SQL", "SQL maʼlumotlar bazasi",
    "Запросы к базам данных: SELECT, JOIN, GROUP BY.",
    "Database queries: SELECT, JOIN, GROUP BY.",
    "Maʼlumotlar bazasiga soʻrovlar: SELECT, JOIN, GROUP BY.",
    "🗄️", "#06b6d4", "#0891b2", "intermediate", "sql,database,queries", 40)

dk2 = get_or_create_deck("SQL Fundamentals", "🗄️",
    "Essential SQL queries", "mcq")
link_deck(sql_id, dk2, 1)
add_cards(dk2, [
    ("Get all rows from 'users':\nA) GET * FROM users\nB) SELECT * FROM users\nC) FETCH * FROM users\nD) READ * FROM users",
     "B) SELECT * FROM users", "SELECT is the SQL keyword for retrieving data."),
    ("Filter rows where age > 18:\nA) SELECT * FROM users IF age > 18\nB) SELECT * FROM users WHERE age > 18\nC) SELECT * FROM users HAVING age > 18\nD) FILTER age > 18",
     "B) SELECT * FROM users WHERE age > 18", "WHERE filters individual rows."),
    ("Count all users:\nA) SELECT NUM(*) FROM users\nB) SELECT COUNT(*) FROM users\nC) SELECT TOTAL FROM users\nD) COUNT users",
     "B) SELECT COUNT(*) FROM users", "COUNT(*) returns the number of rows."),
    ("Sort by age descending:\nA) ORDER BY age DESC\nB) SORT BY age DESC\nC) ORDER age DESC\nD) ORDER BY age DOWN",
     "A) ORDER BY age DESC", "ORDER BY ... DESC sorts high to low."),
    ("Add a new row:\nA) ADD INTO users ...\nB) INSERT INTO users VALUES(...)\nC) NEW INTO users(...)\nD) APPEND users(...)",
     "B) INSERT INTO users VALUES(...)", "INSERT INTO ... VALUES(...) adds a row."),
    ("Update a row:\nA) UPDATE users SET name='X' WHERE id=1\nB) MODIFY users SET name='X'\nC) CHANGE users.name TO 'X'\nD) ALTER users SET name='X'",
     "A) UPDATE users SET name='X' WHERE id=1", "UPDATE table SET column=value WHERE condition."),
    ("Delete row with id=5:\nA) REMOVE FROM users WHERE id=5\nB) DELETE FROM users WHERE id=5\nC) DROP FROM users WHERE id=5\nD) ERASE users WHERE id=5",
     "B) DELETE FROM users WHERE id=5", "Always include WHERE — without it, deletes ALL rows."),
    ("Combine 'users' and 'orders' tables:\nA) UNION users, orders\nB) JOIN users WITH orders\nC) SELECT ... FROM users JOIN orders ON ...\nD) MERGE users, orders",
     "C) SELECT ... FROM users JOIN orders ON ...", "JOIN combines on a matching key."),
    ("Group by country and count users:\nA) SELECT country, COUNT(*) FROM users GROUP BY country\nB) SELECT country FROM users COUNT()\nC) GROUP users BY country\nD) AGGREGATE users BY country",
     "A) SELECT country, COUNT(*) FROM users GROUP BY country", "GROUP BY + aggregate function."),
    ("Get unique countries:\nA) SELECT UNIQUE country FROM users\nB) SELECT DISTINCT country FROM users\nC) SELECT ONLY country FROM users\nD) SELECT country WHERE UNIQUE",
     "B) SELECT DISTINCT country FROM users", "DISTINCT removes duplicates."),
])

algo_id = upsert_collection("programming-algorithms", prog_id,
    "Алгоритмы", "Algorithms", "Algoritmlar",
    "Сортировки, поиск, рекурсия, динамическое программирование.",
    "Sorting, searching, recursion, dynamic programming.",
    "Saralash, qidirish, rekursiya, dinamik dasturlash.",
    "⚙️", "#8b5cf6", "#7c3aed", "advanced", "algorithms,sorting,Big-O", 50)

dk3 = get_or_create_deck("Algorithms Quiz", "⚙️",
    "Common algorithms and complexity", "mcq")
link_deck(algo_id, dk3, 1)
add_cards(dk3, [
    ("Big O of binary search?\nA) O(n)\nB) O(log n)\nC) O(n²)\nD) O(1)",
     "B) O(log n)", "Each step halves the search space."),
    ("Big O of bubble sort?\nA) O(n)\nB) O(n log n)\nC) O(n²)\nD) O(2ⁿ)",
     "C) O(n²)", "Compares each pair → quadratic."),
    ("Big O of accessing array[i]?\nA) O(1)\nB) O(log n)\nC) O(n)\nD) O(n²)",
     "A) O(1)", "Direct memory access — constant time."),
    ("Best sort for nearly-sorted data?\nA) Bubble\nB) Quicksort\nC) Insertion sort\nD) Merge sort",
     "C) Insertion sort", "Insertion sort is O(n) on nearly-sorted input."),
    ("Big O of merge sort?\nA) O(n)\nB) O(n log n)\nC) O(n²)\nD) O(log n)",
     "B) O(n log n)", "Divide-and-conquer with merge step."),
    ("DFS uses which data structure?\nA) Queue\nB) Stack\nC) Heap\nD) Set",
     "B) Stack", "DFS = depth-first → stack (often via recursion)."),
    ("BFS uses:\nA) Queue\nB) Stack\nC) Tree\nD) Linked list",
     "A) Queue", "BFS = breadth-first → FIFO queue."),
    ("Recursion needs:\nA) Loop\nB) Base case\nC) Goto\nD) Global variable",
     "B) Base case", "Without base case, recursion never ends."),
    ("Dynamic programming relies on:\nA) Random search\nB) Brute force\nC) Memoization / overlapping subproblems\nD) Threading",
     "C) Memoization / overlapping subproblems", "DP stores subproblem results to avoid recomputation."),
    ("Hash table average lookup:\nA) O(1)\nB) O(log n)\nC) O(n)\nD) O(n²)",
     "A) O(1)", "Average constant. Worst case O(n) on collisions."),
])

ds_id = upsert_collection("programming-data-structures", prog_id,
    "Структуры данных", "Data Structures", "Maʼlumotlar tuzilmalari",
    "Массивы, списки, стеки, очереди, деревья, графы.",
    "Arrays, linked lists, stacks, queues, trees, graphs.",
    "Massivlar, roʻyxatlar, steklar, navbatlar, daraxtlar, graflar.",
    "🌳", "#10b981", "#059669", "advanced", "data-structures,trees,graphs", 60)

dk4 = get_or_create_deck("Data Structures Quiz", "🌳",
    "Common data structures", "mcq")
link_deck(ds_id, dk4, 1)
add_cards(dk4, [
    ("Stack follows which order?\nA) FIFO\nB) LIFO\nC) Random\nD) Priority",
     "B) LIFO", "Last In First Out — like a stack of plates."),
    ("Queue follows which order?\nA) FIFO\nB) LIFO\nC) Random\nD) Sorted",
     "A) FIFO", "First In First Out — like a real queue."),
    ("Linked list node contains:\nA) Only data\nB) Data and pointer to next\nC) Index\nD) Hash value",
     "B) Data and pointer to next", "Each node points to the next."),
    ("Binary tree: each node has at most:\nA) 1 child\nB) 2 children\nC) 3 children\nD) Unlimited",
     "B) 2 children", "Binary = 2."),
    ("Heap is used to implement:\nA) Stack\nB) Hash table\nC) Priority queue\nD) Linked list",
     "C) Priority queue", "Heap maintains min/max efficiently."),
    ("Hash table maps:\nA) Key to value\nB) Index to data\nC) Tree to graph\nD) Stack to queue",
     "A) Key to value", "Hash function transforms key into index."),
    ("Insertion in middle of array:\nA) O(1)\nB) O(log n)\nC) O(n)\nD) O(n²)",
     "C) O(n)", "Need to shift all subsequent elements."),
    ("Insertion at head of linked list:\nA) O(1)\nB) O(log n)\nC) O(n)\nD) O(n²)",
     "A) O(1)", "Just update the head pointer."),
    ("Graph with bidirectional edges is:\nA) Directed\nB) Undirected\nC) Weighted\nD) Cyclic",
     "B) Undirected", "Edges go both ways in undirected graphs."),
    ("Trie is best for:\nA) Sorting numbers\nB) Prefix-based string search\nC) Binary search\nD) Image storage",
     "B) Prefix-based string search", "Trie excels at autocomplete and dictionary lookups."),
])


# ─────────────────────────────────────────────
# SCIENCE: Chemistry, Physics, General Science
# ─────────────────────────────────────────────

chem_id = upsert_collection("science-chemistry", sci_id,
    "Химия", "Chemistry", "Kimyo",
    "Атомы, молекулы, реакции, периодическая таблица.",
    "Atoms, molecules, reactions, periodic table.",
    "Atomlar, molekulalar, reaksiyalar, davriy jadval.",
    "⚗️", "#06b6d4", "#0891b2", "intermediate", "chemistry,atoms,reactions", 30)

dk = get_or_create_deck("Chemistry Basics Quiz", "⚗️",
    "Periodic table and basic chemistry", "mcq")
link_deck(chem_id, dk, 1)
add_cards(dk, [
    ("Chemical symbol for water?\nA) HO\nB) H2O\nC) OH2\nD) H3O",
     "B) H2O", "Two hydrogen atoms + one oxygen."),
    ("Atomic number of Hydrogen?\nA) 0\nB) 1\nC) 2\nD) 8",
     "B) 1", "H = first element on periodic table."),
    ("Atomic number of Oxygen?\nA) 6\nB) 7\nC) 8\nD) 16",
     "C) 8", "O has 8 protons."),
    ("Salt's chemical formula?\nA) NaCl\nB) NaOH\nC) KCl\nD) HCl",
     "A) NaCl", "Sodium chloride."),
    ("pH of pure water?\nA) 0\nB) 7\nC) 10\nD) 14",
     "B) 7", "Neutral pH is 7."),
    ("Most abundant gas in atmosphere?\nA) Oxygen\nB) Nitrogen\nC) CO2\nD) Argon",
     "B) Nitrogen", "About 78% of Earth's atmosphere."),
    ("Element with symbol Au?\nA) Aluminum\nB) Argon\nC) Gold\nD) Silver",
     "C) Gold", "Aurum (Latin)."),
    ("Number of protons = atomic number?\nA) Yes\nB) No\nC) Sometimes\nD) Only metals",
     "A) Yes", "Atomic number = number of protons."),
    ("CO2 is:\nA) Carbon monoxide\nB) Carbon dioxide\nC) Carbonate\nD) Carbide",
     "B) Carbon dioxide", "CO = monoxide. CO2 = dioxide."),
    ("Acid + Base →\nA) Salt + Water\nB) Gas + Solid\nC) Heat only\nD) Nothing",
     "A) Salt + Water", "Neutralization reaction."),
])

phys_id = upsert_collection("science-physics", sci_id,
    "Физика", "Physics", "Fizika",
    "Механика, электричество, оптика, термодинамика.",
    "Mechanics, electricity, optics, thermodynamics.",
    "Mexanika, elektr, optika, termodinamika.",
    "🔭", "#3b82f6", "#2563eb", "intermediate", "physics,mechanics,energy", 40)

dk2 = get_or_create_deck("Physics Basics Quiz", "🔭",
    "Forces, energy, and motion", "mcq")
link_deck(phys_id, dk2, 1)
add_cards(dk2, [
    ("Speed of light in vacuum?\nA) 300 km/s\nB) 3 × 10⁸ m/s\nC) 3 × 10⁵ m/s\nD) 1000 m/s",
     "B) 3 × 10⁸ m/s", "About 300,000 km/s."),
    ("Newton's 1st law is about:\nA) F = ma\nB) Action and reaction\nC) Inertia\nD) Gravity",
     "C) Inertia", "Object stays at rest or in motion unless force acts."),
    ("F = ma is which law?\nA) 1st\nB) 2nd\nC) 3rd\nD) Energy conservation",
     "B) 2nd", "Newton's 2nd law: Force = mass × acceleration."),
    ("Unit of force?\nA) Watt\nB) Joule\nC) Newton\nD) Pascal",
     "C) Newton", "Named after Isaac Newton."),
    ("Unit of energy?\nA) Newton\nB) Joule\nC) Volt\nD) Ohm",
     "B) Joule", "1 J = work done by 1 N over 1 m."),
    ("Acceleration due to gravity (Earth)?\nA) 5 m/s²\nB) 9.8 m/s²\nC) 12 m/s²\nD) 25 m/s²",
     "B) 9.8 m/s²", "Approximately 9.81 m/s²."),
    ("Light travels in:\nA) Sound waves\nB) Particles only\nC) Electromagnetic waves\nD) Nothing",
     "C) Electromagnetic waves", "Light is part of EM spectrum."),
    ("Ohm's law: V = ?\nA) I + R\nB) I × R\nC) I / R\nD) R / I",
     "B) I × R", "Voltage = Current × Resistance."),
    ("Energy can be:\nA) Created\nB) Destroyed\nC) Transformed\nD) Lost forever",
     "C) Transformed", "Conservation of energy: it changes form."),
    ("Frequency unit?\nA) Joule\nB) Watt\nC) Hertz\nD) Newton",
     "C) Hertz", "Hz = cycles per second."),
])

gensci_id = upsert_collection("science-general", sci_id,
    "Общая наука", "General Science", "Umumiy fan",
    "Общие научные факты по биологии, географии, астрономии.",
    "General scientific facts: biology, geography, astronomy.",
    "Umumiy ilmiy faktlar: biologiya, geografiya, astronomiya.",
    "🌍", "#8b5cf6", "#7c3aed", "beginner", "science,trivia,facts", 50)

dk3 = get_or_create_deck("Science Trivia", "🌍",
    "General knowledge in science", "mcq")
link_deck(gensci_id, dk3, 1)
add_cards(dk3, [
    ("Largest planet in solar system?\nA) Earth\nB) Mars\nC) Jupiter\nD) Saturn",
     "C) Jupiter", "Jupiter is bigger than all others combined."),
    ("How many bones in adult human?\nA) 106\nB) 206\nC) 306\nD) 406",
     "B) 206", "Adults have 206 bones (babies have ~270)."),
    ("Sun is what type of star?\nA) Red giant\nB) White dwarf\nC) Yellow dwarf\nD) Blue giant",
     "C) Yellow dwarf", "G-type main-sequence star."),
    ("Closest star to Earth (besides the Sun)?\nA) Sirius\nB) Polaris\nC) Proxima Centauri\nD) Vega",
     "C) Proxima Centauri", "About 4.24 light-years away."),
    ("Largest organ in human body?\nA) Brain\nB) Liver\nC) Skin\nD) Lungs",
     "C) Skin", "About 16% of body weight."),
    ("How long does Earth take to orbit Sun?\nA) 1 day\nB) 1 month\nC) 1 year\nD) 10 years",
     "C) 1 year", "365.25 days."),
    ("What does DNA stand for?\nA) Daily Nucleic Acid\nB) Deoxyribonucleic Acid\nC) Double Natural Atom\nD) Direct Neural Acid",
     "B) Deoxyribonucleic Acid", "Carries genetic information."),
    ("Largest ocean?\nA) Atlantic\nB) Indian\nC) Pacific\nD) Arctic",
     "C) Pacific", "Covers ~1/3 of Earth's surface."),
    ("Animal with the longest lifespan?\nA) Tortoise\nB) Greenland shark\nC) Elephant\nD) Whale",
     "B) Greenland shark", "Can live 400+ years."),
    ("How many continents are there?\nA) 5\nB) 6\nC) 7\nD) 8",
     "C) 7", "Africa, Antarctica, Asia, Australia, Europe, North America, South America."),
])


# ─────────────────────────────────────────────
# BUSINESS: Finance, Accounting, Entrepreneurship
# ─────────────────────────────────────────────

fin_id = upsert_collection("business-finance", biz_id,
    "Финансы", "Finance", "Moliya",
    "Инвестиции, акции, облигации, личные финансы.",
    "Investments, stocks, bonds, personal finance.",
    "Investitsiyalar, aksiyalar, obligatsiyalar, shaxsiy moliya.",
    "💰", "#10b981", "#059669", "intermediate", "finance,investing,money", 30)

dk = get_or_create_deck("Finance Fundamentals", "💰",
    "Personal finance and investing basics", "terms")
link_deck(fin_id, dk, 1)
add_cards(dk, [
    ("Asset", "Актив (имущество, приносящее выгоду)", "Cash, real estate, stocks are assets."),
    ("Liability", "Обязательство (долг)", "Loans, credit card debt are liabilities."),
    ("Equity", "Капитал (собственные средства)", "Equity = Assets − Liabilities."),
    ("Stock / Share", "Акция", "Ownership in a company."),
    ("Bond", "Облигация", "Loan to government/corporation, paying interest."),
    ("Dividend", "Дивиденд", "Profit share paid to shareholders."),
    ("Compound Interest", "Сложный процент", "Interest earned on interest — exponential growth."),
    ("Inflation", "Инфляция", "General rise in prices over time."),
    ("Bull market", "Бычий рынок (растущий)", "Period of rising stock prices."),
    ("Bear market", "Медвежий рынок (падающий)", "Period of falling stock prices, usually 20%+."),
    ("Diversification", "Диверсификация", "Spreading investments to reduce risk."),
    ("Risk tolerance", "Толерантность к риску", "How much volatility you can handle emotionally."),
    ("Liquidity", "Ликвидность", "How quickly an asset can be converted to cash."),
    ("Portfolio", "Портфель", "Collection of all your investments."),
    ("ETF", "Биржевой инвестфонд", "Basket of stocks traded like a single share."),
    ("Mutual fund", "Взаимный фонд", "Pool of money from many investors, managed by pros."),
    ("ROI", "Возврат инвестиций (Return on Investment)", "(Gain − Cost) / Cost × 100%."),
    ("Capital gains", "Доход от продажи актива", "Profit when selling an asset above purchase price."),
    ("Emergency fund", "Финансовая подушка безопасности", "3-6 months of expenses saved for emergencies."),
    ("Net worth", "Чистая стоимость", "Total assets minus total liabilities."),
])

acct_id = upsert_collection("business-accounting", biz_id,
    "Бухгалтерский учёт", "Accounting", "Buxgalteriya",
    "Баланс, P&L, дебет, кредит, основы учёта.",
    "Balance sheet, P&L, debits, credits, accounting basics.",
    "Balans, P&L, debet, kredit, hisob asoslari.",
    "📒", "#0ea5e9", "#0284c7", "intermediate", "accounting,bookkeeping,balance", 40)

dk2 = get_or_create_deck("Accounting Fundamentals", "📒",
    "Core accounting concepts", "terms")
link_deck(acct_id, dk2, 1)
add_cards(dk2, [
    ("Balance Sheet", "Бухгалтерский баланс", "Assets = Liabilities + Equity (snapshot at one moment)."),
    ("Income Statement / P&L", "Отчёт о прибылях и убытках", "Revenue − Expenses = Profit (over a period)."),
    ("Cash Flow Statement", "Отчёт о движении денежных средств", "Tracks actual cash in and out."),
    ("Revenue", "Выручка", "Total money earned from sales."),
    ("Expenses", "Расходы", "Costs of running the business."),
    ("Net Income", "Чистая прибыль", "Revenue minus all expenses and taxes."),
    ("Gross Profit", "Валовая прибыль", "Revenue minus cost of goods sold (COGS)."),
    ("COGS", "Себестоимость проданных товаров", "Direct costs of producing what you sell."),
    ("Accounts Receivable", "Дебиторская задолженность", "Money customers owe you."),
    ("Accounts Payable", "Кредиторская задолженность", "Money you owe to suppliers."),
    ("Debit", "Дебет", "Left side: increases assets and expenses."),
    ("Credit", "Кредит", "Right side: increases liabilities, equity, revenue."),
    ("Depreciation", "Амортизация (износ)", "Spreading the cost of an asset over its useful life."),
    ("Audit", "Аудит", "Independent verification of financial statements."),
    ("GAAP", "Общепринятые принципы бухучёта", "Generally Accepted Accounting Principles (US standard)."),
    ("Fiscal year", "Финансовый год", "12-month period a company uses for accounting."),
    ("Working capital", "Оборотный капитал", "Current Assets − Current Liabilities."),
    ("EBITDA", "Прибыль до вычета процентов, налогов, амортизации", "Earnings Before Interest, Taxes, Depreciation, Amortization."),
    ("Equity", "Капитал владельцев", "What's left after liabilities are paid."),
    ("Trial balance", "Пробный баланс", "List of all accounts to verify debits = credits."),
])

ent_id = upsert_collection("business-entrepreneurship", biz_id,
    "Предпринимательство", "Entrepreneurship", "Tadbirkorlik",
    "Идея, MVP, product-market fit, привлечение инвестиций.",
    "Idea, MVP, product-market fit, fundraising.",
    "Gʻoya, MVP, product-market fit, sarmoya jalb qilish.",
    "🚀", "#ec4899", "#db2777", "intermediate", "startup,entrepreneur,business", 50)

dk3 = get_or_create_deck("Entrepreneurship Glossary", "🚀",
    "Startup and business creation terms", "terms")
link_deck(ent_id, dk3, 1)
add_cards(dk3, [
    ("MVP", "Минимально жизнеспособный продукт", "Minimum Viable Product — simplest version users will pay for."),
    ("Product-Market Fit", "Соответствие продукта рынку", "When customers love the product so much they tell others."),
    ("Pivot", "Резкая смена стратегии", "Changing direction based on what you learned."),
    ("Burn rate", "Скорость расходования средств", "How much cash a startup loses per month."),
    ("Runway", "Срок жизни до конца денег", "Cash ÷ burn rate. How many months you can survive."),
    ("Bootstrapping", "Развитие без внешних инвестиций", "Funding the business from your own pocket / revenue."),
    ("Seed round", "Посевной раунд", "Earliest stage of fundraising, ~$50k–$2M."),
    ("Series A / B / C", "Серия A / B / C", "Subsequent funding rounds, larger amounts."),
    ("VC (Venture Capital)", "Венчурный капитал", "Investors funding high-risk, high-growth startups."),
    ("Angel investor", "Бизнес-ангел", "Wealthy individual investing personal money in early startups."),
    ("Equity financing", "Финансирование через капитал", "Raising money by selling ownership shares."),
    ("Term sheet", "Соглашение об условиях сделки", "Non-binding outline of investment terms."),
    ("Cap table", "Таблица капитала", "Spreadsheet of who owns how much equity."),
    ("Valuation", "Оценка компании", "How much the startup is worth."),
    ("Exit", "Выход (продажа компании или IPO)", "How investors get their money back: acquisition or IPO."),
    ("IPO", "Первичное публичное предложение", "Initial Public Offering — going public on stock exchange."),
    ("Unicorn", "Единорог (стартап оценкой $1B+)", "Privately-held startup valued at $1 billion or more."),
    ("Customer acquisition cost (CAC)", "Стоимость привлечения клиента", "Marketing $ spent ÷ number of new customers."),
    ("LTV (Lifetime Value)", "Пожизненная ценность клиента", "Total revenue from one customer over time."),
    ("Churn", "Отток клиентов", "% of customers who stop using a service per period."),
])

# ─────────────────────────────────────────────
# COMMIT
# ─────────────────────────────────────────────
conn.commit()
conn.close()
print("[seed_extra] Done — 18 collections + 18 decks + ~310 cards added")
