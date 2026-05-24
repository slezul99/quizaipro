# -*- coding: utf-8 -*-
"""Demo-kolody i primery dlya tour. Multilingual: RU / EN / UZ.

Ispol'zuetsya:
- /api/install-demo-decks (Pomoschnik → Установить демо)
- /static/demo_examples/* (gotovye fayly dlya importa, otdayutsya kak yest')
"""

# ============================================================
# DEMO KOLODY (po 3 dlya kazhdogo yazyka)
# ============================================================
# Format: (front, back_letter+text, note_with_options)

_DEMO_DECKS_RU = [
    {
        "icon": "📘",
        "name": "Английский для начинающих",
        "cards": [
            ("Я ___ студент.", "B) am", "A) is\nB) am\nC) are\nD) be"),
            ("Она ___ из Узбекистана.", "A) is", "A) is\nB) am\nC) are\nD) was"),
            ("Они ___ мои друзья.", "C) are", "A) is\nB) am\nC) are\nD) be"),
            ("___ ты говоришь по-английски?", "A) Do", "A) Do\nB) Does\nC) Are\nD) Is"),
            ("Он ___ в футбол каждый день.", "B) plays", "A) play\nB) plays\nC) playing\nD) played"),
            ("У меня ___ яблоко.", "A) an", "A) an\nB) a\nC) the\nD) —"),
            ("На столе ___ много книг.", "C) are", "A) is\nB) was\nC) are\nD) be"),
            ("Моя сестра ___ врач.", "B) is", "A) am\nB) is\nC) are\nD) be"),
            ("Как ___ тебя зовут?", "A) is", "A) is\nB) are\nC) am\nD) be"),
            ("Где ты ___ живёшь?", "B) do", "A) does\nB) do\nC) is\nD) are"),
        ],
    },
    {
        "icon": "🧮",
        "name": "Математика 5 класс",
        "cards": [
            ("Сколько будет 7 × 8?", "B) 56", "A) 54\nB) 56\nC) 58\nD) 64"),
            ("Найди периметр квадрата со стороной 5 см.", "C) 20 см", "A) 10 см\nB) 15 см\nC) 20 см\nD) 25 см"),
            ("Реши: 144 ÷ 12 = ?", "A) 12", "A) 12\nB) 14\nC) 16\nD) 11"),
            ("Сколько градусов в прямом угле?", "B) 90°", "A) 60°\nB) 90°\nC) 120°\nD) 180°"),
            ("Найди 25% от 200.", "C) 50", "A) 25\nB) 40\nC) 50\nD) 75"),
            ("Треугольник со всеми равными сторонами называется...", "A) Равносторонний", "A) Равносторонний\nB) Равнобедренный\nC) Прямоугольный\nD) Тупоугольный"),
            ("Реши: (15 + 5) × 2 = ?", "B) 40", "A) 25\nB) 40\nC) 30\nD) 35"),
            ("Сколько минут в 2 часах 30 минутах?", "C) 150", "A) 130\nB) 140\nC) 150\nD) 160"),
            ("Площадь прямоугольника со сторонами 4 и 6.", "B) 24", "A) 20\nB) 24\nC) 28\nD) 30"),
            ("Наименьшее число из: 0.5, 0.45, 0.51, 0.499", "A) 0.45", "A) 0.45\nB) 0.5\nC) 0.499\nD) 0.51"),
        ],
    },
    {
        "icon": "📚",
        "name": "English Grammar — Past Simple",
        "cards": [
            ("Yesterday I ___ to the cinema.", "B) went", "A) go\nB) went\nC) goes\nD) gone"),
            ("She ___ a beautiful song last night.", "A) sang", "A) sang\nB) sing\nC) sings\nD) sung"),
            ("They ___ football two days ago.", "C) played", "A) plays\nB) playing\nC) played\nD) play"),
            ("___ you finish your homework yesterday?", "A) Did", "A) Did\nB) Do\nC) Does\nD) Was"),
            ("He ___ not come to the party.", "B) did", "A) was\nB) did\nC) is\nD) does"),
            ("We ___ in London for two weeks.", "A) stayed", "A) stayed\nB) stay\nC) staying\nD) stays"),
            ("My father ___ a new car last month.", "C) bought", "A) buys\nB) buying\nC) bought\nD) buyed"),
            ("Where ___ you born?", "A) were", "A) were\nB) was\nC) did\nD) are"),
            ("She ___ tired after work.", "B) was", "A) were\nB) was\nC) is\nD) are"),
            ("I ___ this book last summer.", "C) read", "A) reads\nB) reading\nC) read\nD) readed"),
        ],
    },
]

_DEMO_DECKS_EN = [
    {
        "icon": "📘",
        "name": "Beginner English",
        "cards": [
            ("I ___ a student.", "B) am", "A) is\nB) am\nC) are\nD) be"),
            ("She ___ from Uzbekistan.", "A) is", "A) is\nB) am\nC) are\nD) was"),
            ("They ___ my friends.", "C) are", "A) is\nB) am\nC) are\nD) be"),
            ("___ you speak English?", "A) Do", "A) Do\nB) Does\nC) Are\nD) Is"),
            ("He ___ football every day.", "B) plays", "A) play\nB) plays\nC) playing\nD) played"),
            ("I have ___ apple.", "A) an", "A) an\nB) a\nC) the\nD) —"),
            ("There ___ many books on the table.", "C) are", "A) is\nB) was\nC) are\nD) be"),
            ("My sister ___ a doctor.", "B) is", "A) am\nB) is\nC) are\nD) be"),
            ("What ___ your name?", "A) is", "A) is\nB) are\nC) am\nD) be"),
            ("Where ___ you live?", "B) do", "A) does\nB) do\nC) is\nD) are"),
        ],
    },
    {
        "icon": "🧮",
        "name": "Math grade 5",
        "cards": [
            ("How much is 7 × 8?", "B) 56", "A) 54\nB) 56\nC) 58\nD) 64"),
            ("Find the perimeter of a square with side 5 cm.", "C) 20 cm", "A) 10 cm\nB) 15 cm\nC) 20 cm\nD) 25 cm"),
            ("Solve: 144 ÷ 12 = ?", "A) 12", "A) 12\nB) 14\nC) 16\nD) 11"),
            ("How many degrees in a right angle?", "B) 90°", "A) 60°\nB) 90°\nC) 120°\nD) 180°"),
            ("Find 25% of 200.", "C) 50", "A) 25\nB) 40\nC) 50\nD) 75"),
            ("A triangle with all equal sides is called...", "A) Equilateral", "A) Equilateral\nB) Isosceles\nC) Right-angled\nD) Obtuse"),
            ("Solve: (15 + 5) × 2 = ?", "B) 40", "A) 25\nB) 40\nC) 30\nD) 35"),
            ("How many minutes in 2 hours 30 minutes?", "C) 150", "A) 130\nB) 140\nC) 150\nD) 160"),
            ("Area of a rectangle with sides 4 and 6.", "B) 24", "A) 20\nB) 24\nC) 28\nD) 30"),
            ("The smallest number among: 0.5, 0.45, 0.51, 0.499", "A) 0.45", "A) 0.45\nB) 0.5\nC) 0.499\nD) 0.51"),
        ],
    },
    {
        "icon": "📚",
        "name": "English Grammar — Past Simple",
        "cards": [
            ("Yesterday I ___ to the cinema.", "B) went", "A) go\nB) went\nC) goes\nD) gone"),
            ("She ___ a beautiful song last night.", "A) sang", "A) sang\nB) sing\nC) sings\nD) sung"),
            ("They ___ football two days ago.", "C) played", "A) plays\nB) playing\nC) played\nD) play"),
            ("___ you finish your homework yesterday?", "A) Did", "A) Did\nB) Do\nC) Does\nD) Was"),
            ("He ___ not come to the party.", "B) did", "A) was\nB) did\nC) is\nD) does"),
            ("We ___ in London for two weeks.", "A) stayed", "A) stayed\nB) stay\nC) staying\nD) stays"),
            ("My father ___ a new car last month.", "C) bought", "A) buys\nB) buying\nC) bought\nD) buyed"),
            ("Where ___ you born?", "A) were", "A) were\nB) was\nC) did\nD) are"),
            ("She ___ tired after work.", "B) was", "A) were\nB) was\nC) is\nD) are"),
            ("I ___ this book last summer.", "C) read", "A) reads\nB) reading\nC) read\nD) readed"),
        ],
    },
]

_DEMO_DECKS_UZ = [
    {
        "icon": "📘",
        "name": "Boshlovchilar uchun ingliz tili",
        "cards": [
            ("Men ___ talaba.", "B) am", "A) is\nB) am\nC) are\nD) be"),
            ("U (ayol) ___ Oʻzbekistondan.", "A) is", "A) is\nB) am\nC) are\nD) was"),
            ("Ular ___ mening doʻstlarim.", "C) are", "A) is\nB) am\nC) are\nD) be"),
            ("___ siz ingliz tilida gaplashasizmi?", "A) Do", "A) Do\nB) Does\nC) Are\nD) Is"),
            ("U (er.) har kuni futbol ___.", "B) plays", "A) play\nB) plays\nC) playing\nD) played"),
            ("Mening ___ olmam bor.", "A) an", "A) an\nB) a\nC) the\nD) —"),
            ("Stol ustida ko'p kitoblar ___.", "C) are", "A) is\nB) was\nC) are\nD) be"),
            ("Mening singlim ___ shifokor.", "B) is", "A) am\nB) is\nC) are\nD) be"),
            ("Sizning ismingiz ___?", "A) is", "A) is\nB) are\nC) am\nD) be"),
            ("Siz qayerda ___ yashaysiz?", "B) do", "A) does\nB) do\nC) is\nD) are"),
        ],
    },
    {
        "icon": "🧮",
        "name": "Matematika 5-sinf",
        "cards": [
            ("7 × 8 nechiga teng?", "B) 56", "A) 54\nB) 56\nC) 58\nD) 64"),
            ("Tomoni 5 sm boʻlgan kvadrat perimetrini toping.", "C) 20 sm", "A) 10 sm\nB) 15 sm\nC) 20 sm\nD) 25 sm"),
            ("Yechting: 144 ÷ 12 = ?", "A) 12", "A) 12\nB) 14\nC) 16\nD) 11"),
            ("To'g'ri burchak necha gradus?", "B) 90°", "A) 60°\nB) 90°\nC) 120°\nD) 180°"),
            ("200 ning 25% ini toping.", "C) 50", "A) 25\nB) 40\nC) 50\nD) 75"),
            ("Hamma tomonlari teng uchburchak ___ deyiladi.", "A) Teng tomonli", "A) Teng tomonli\nB) Teng yonli\nC) To'g'ri burchakli\nD) O'tkir burchakli"),
            ("Yechting: (15 + 5) × 2 = ?", "B) 40", "A) 25\nB) 40\nC) 30\nD) 35"),
            ("2 soat 30 daqiqada nechta daqiqa?", "C) 150", "A) 130\nB) 140\nC) 150\nD) 160"),
            ("Tomonlari 4 va 6 boʻlgan toʻrtburchak yuzasi.", "B) 24", "A) 20\nB) 24\nC) 28\nD) 30"),
            ("Eng kichik son: 0.5, 0.45, 0.51, 0.499", "A) 0.45", "A) 0.45\nB) 0.5\nC) 0.499\nD) 0.51"),
        ],
    },
    {
        "icon": "📚",
        "name": "Ingliz grammatikasi — Past Simple",
        "cards": [
            ("Yesterday I ___ to the cinema.", "B) went", "A) go\nB) went\nC) goes\nD) gone"),
            ("She ___ a beautiful song last night.", "A) sang", "A) sang\nB) sing\nC) sings\nD) sung"),
            ("They ___ football two days ago.", "C) played", "A) plays\nB) playing\nC) played\nD) play"),
            ("___ you finish your homework yesterday?", "A) Did", "A) Did\nB) Do\nC) Does\nD) Was"),
            ("He ___ not come to the party.", "B) did", "A) was\nB) did\nC) is\nD) does"),
            ("We ___ in London for two weeks.", "A) stayed", "A) stayed\nB) stay\nC) staying\nD) stays"),
            ("My father ___ a new car last month.", "C) bought", "A) buys\nB) buying\nC) bought\nD) buyed"),
            ("Where ___ you born?", "A) were", "A) were\nB) was\nC) did\nD) are"),
            ("She ___ tired after work.", "B) was", "A) were\nB) was\nC) is\nD) are"),
            ("I ___ this book last summer.", "C) read", "A) reads\nB) reading\nC) read\nD) readed"),
        ],
    },
]


def get_demo_decks(lang: str = "ru"):
    """Vozvrashchaet demo-kolody dlya yazyka. Default = ru."""
    if lang == "en":
        return _DEMO_DECKS_EN
    if lang == "uz":
        return _DEMO_DECKS_UZ
    return _DEMO_DECKS_RU
