# -*- coding: utf-8 -*-
"""Kontent stranitsy /help na 3 yazykah.
Kazhdaya sektsiya — dict s:
  id: yakor (anchor)
  icon, title, body_html (chistyy HTML, mozhno s ssylkami)
"""


# Russian
HELP_RU = {
    "page_title": "Как пользоваться QuizPro",
    "page_subtitle": "Шаг за шагом — от первой колоды до экзамена",
    "toc_label": "Разделы",
    "support_title": "Не нашли ответ?",
    "support_text": "Напишите нам, мы реально читаем все сообщения и стараемся помочь быстро.",
    "support_btn": "Написать в поддержку",
    "sections": [
        {
            "id": "start", "icon": "🚀", "nav": "С чего начать",
            "title": "🚀 С чего начать (3 минуты)",
            "body": """
<p class="text-slate-700 mb-4">Если вы только что зарегистрировались — пройдите эти 4 шага и сразу получите ценность.</p>
<div class="space-y-3">
  <div class="flex gap-3 p-3 rounded-xl bg-indigo-50">
    <span class="text-2xl flex-shrink-0">1️⃣</span>
    <div>
      <div class="font-bold">Создайте первую колоду</div>
      <p class="text-sm text-slate-600">Перейдите на <a href="/dashboard" class="text-indigo-600 hover:underline">Dashboard</a> → нажмите <b>+ Новая колода</b>. Назовите её, например, «Английский — базовые слова». Колода — это набор карточек по одной теме.</p>
    </div>
  </div>
  <div class="flex gap-3 p-3 rounded-xl bg-emerald-50">
    <span class="text-2xl flex-shrink-0">2️⃣</span>
    <div>
      <div class="font-bold">Добавьте карты — 3 способа</div>
      <ul class="text-sm text-slate-600 list-disc pl-4 mt-1 space-y-1">
        <li><b>Вручную:</b> в колоде → + Карта → введите вопрос и ответ</li>
        <li><b>Импорт:</b> загрузите .pdf/.docx/.txt или вставьте текст</li>
        <li><b>AI:</b> на /ai введите тему — AI создаст 10-30 вопросов за 20 секунд</li>
      </ul>
    </div>
  </div>
  <div class="flex gap-3 p-3 rounded-xl bg-purple-50">
    <span class="text-2xl flex-shrink-0">3️⃣</span>
    <div>
      <div class="font-bold">Учитесь через Flashcards</div>
      <p class="text-sm text-slate-600">В колоде нажмите 🃏 <b>Flashcards</b>. Карточка переворачивается — оцените «Сложно/Хорошо/Легко». Алгоритм SM-2 покажет каждую карту в момент когда вы начинаете забывать.</p>
    </div>
  </div>
  <div class="flex gap-3 p-3 rounded-xl bg-amber-50">
    <span class="text-2xl flex-shrink-0">4️⃣</span>
    <div>
      <div class="font-bold">Поставьте цель</div>
      <p class="text-sm text-slate-600">На <a href="/goals" class="text-indigo-600 hover:underline">Цели</a> → + Новая цель. Выберите колоду, срок, уровень. Система сама посчитает сколько карт делать в день.</p>
    </div>
  </div>
</div>
"""
        },
        {
            "id": "decks", "icon": "📚", "nav": "Колоды и карты",
            "title": "📚 Колоды и карты",
            "body": """
<p class="text-slate-700 mb-3"><b>Колода</b> — это набор карточек на одну тему. Например: «Английский — Beginner» или «Биология — Клетка».</p>
<h3 class="font-bold text-lg mt-4 mb-2">Структура карты</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><b>Вопрос (front)</b> — то что показывается первым</li>
  <li><b>Ответ (back)</b> — правильный ответ</li>
  <li><b>Объяснение (note)</b> — для тестов с вариантами: A) ... B) ... C) ...</li>
  <li><b>Изображение</b> — можно прикрепить картинку к вопросу</li>
</ul>
<h3 class="font-bold text-lg mt-4 mb-2">Кнопки в колоде</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><b>📝 Тест</b> — пройти тест с вариантами ответов</li>
  <li><b>🃏 Flashcards</b> — учить карточки с переворотом</li>
  <li><b>🎯 Match</b> — игра на скорость (соединить пары)</li>
  <li><b>🎮 Live test</b> — групповой тест в реальном времени</li>
  <li><b>📊 Excel / 📄 PDF</b> — скачать журнал или распечатать тест</li>
  <li><b>💾 JSON</b> — резервная копия колоды</li>
  <li><b>📋 Дубль</b> — создать копию колоды</li>
  <li><b>🌐 Опубликовать</b> — выложить в маркетплейс</li>
</ul>
"""
        },
        {
            "id": "import", "icon": "📥", "nav": "Импорт и AI",
            "title": "📥 Импорт и AI",
            "body": """
<h3 class="font-bold text-lg mb-2">Импорт из файла</h3>
<p class="text-slate-700 text-sm mb-2">Поддерживаются: <code>.txt</code>, <code>.csv</code>, <code>.docx</code>, <code>.pdf</code>.</p>
<div class="bg-slate-50 rounded-xl p-4 text-sm font-mono mb-3 whitespace-pre-line">1. Что такое HTML?
A) Язык программирования
B) Язык разметки ✓
C) База данных

2. Сколько планет в Солнечной системе?
A) 7
B) 8 ✓
C) 9
D) 10</div>
<p class="text-xs text-slate-500 mb-4">Знак <code>✓</code> отмечает правильный ответ. Нумерация (1., 1), 1-) — игнорируется.</p>
<p class="text-sm text-slate-700">Также можно простой формат: <code>Вопрос | Ответ | Объяснение</code> на каждой строке.</p>
<h3 class="font-bold text-lg mt-5 mb-2">🤖 AI генерация</h3>
<p class="text-slate-700 text-sm mb-3">На странице <a href="/ai" class="text-indigo-600 hover:underline">AI</a> можно:</p>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><b>По теме:</b> «Английская грамматика — Past Simple» → AI создаст 15 вопросов</li>
  <li><b>По тексту:</b> вставьте лекцию — AI выделит ключевые понятия</li>
  <li><b>По PDF:</b> загрузите PDF учебника — AI прочитает и сгенерирует вопросы</li>
</ul>
<p class="text-xs text-slate-500 mt-2">⏱ Генерация занимает 10-30 секунд. AI может ошибиться — всегда проверяйте.</p>
"""
        },
        {
            "id": "flashcards", "icon": "🃏", "nav": "Flashcards",
            "title": "🃏 Flashcards (главный режим обучения)",
            "body": """
<p class="text-slate-700 mb-3">Это сердце QuizPro. Карточки появляются ровно когда вы начинаете забывать — это <b>SM-2 алгоритм</b>, доказанный наукой с 1985 года.</p>
<h3 class="font-bold text-lg mt-3 mb-2">Как работает</h3>
<ol class="text-sm text-slate-700 list-decimal pl-5 space-y-1">
  <li>Открываете карту → видите вопрос</li>
  <li>Думаете → нажимаете «Перевернуть» (или <code>Space</code>)</li>
  <li>Видите ответ → оцениваете честно</li>
</ol>
<div class="grid grid-cols-3 gap-2 mt-3">
  <div class="bg-orange-50 rounded-xl p-3 text-center text-sm">
    <div class="font-bold">😣 Сложно</div>
    <div class="text-xs text-slate-600">Через 1 день</div>
  </div>
  <div class="bg-emerald-50 rounded-xl p-3 text-center text-sm">
    <div class="font-bold">👍 Хорошо</div>
    <div class="text-xs text-slate-600">Через 3 дня</div>
  </div>
  <div class="bg-blue-50 rounded-xl p-3 text-center text-sm">
    <div class="font-bold">⭐ Легко</div>
    <div class="text-xs text-slate-600">Через неделю</div>
  </div>
</div>
<h3 class="font-bold text-lg mt-4 mb-2">Хоткеи</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><code>Space</code> — перевернуть</li>
  <li><code>← / →</code> — пред / след</li>
  <li><code>F</code> — избранное ⭐</li>
  <li><code>D</code> — пометить трудной 🔥</li>
  <li><code>1 / 2 / 3</code> — оценить</li>
</ul>
"""
        },
        {
            "id": "test", "icon": "📝", "nav": "Тесты",
            "title": "📝 Тесты с вариантами",
            "body": """
<p class="text-slate-700 mb-3">Подходит для проверки знаний — отвечаете на вопросы с 4 вариантами, в конце получаете разбор всех ошибок.</p>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li>Выбираете количество вопросов (5/10/25/50/100)</li>
  <li>Случайный порядок (включается галочкой)</li>
  <li>«Только трудные» — карты где вы чаще всего ошибались</li>
  <li>Варианты ответов перемешиваются — нельзя запомнить «правильный всегда A»</li>
  <li>В конце — детальный разбор всех ошибок</li>
</ul>
"""
        },
        {
            "id": "match", "icon": "🎯", "nav": "Match",
            "title": "🎯 Match — игра на скорость",
            "body": """
<p class="text-slate-700 mb-3">Соедините термин с определением быстрее всех. Доступно для колод-словарей.</p>
<p class="text-sm text-slate-700">Слева — вопросы, справа — ответы (перемешаны). Кликаете пару — если правильно, исчезают. Цель — пройти за минимальное время. Лучшее время сохраняется.</p>
"""
        },
        {
            "id": "duels", "icon": "⚔️", "nav": "Дуэли",
            "title": "⚔️ Дуэли (1 на 1)",
            "body": """
<p class="text-slate-700 mb-3">Сразитесь с другом по выбранной колоде или категории. Кто быстрее и точнее — побеждает.</p>
<ol class="text-sm text-slate-700 list-decimal pl-5 space-y-1">
  <li>Откройте профиль друга или зайдите в <a href="/leaderboard" class="text-indigo-600 hover:underline">Лидерборд</a></li>
  <li>Нажмите ⚔️ Вызвать → выберите колоду</li>
  <li>Друг получит уведомление и присоединится</li>
  <li>5 вопросов на скорость, оба видят результаты в реальном времени</li>
</ol>
<p class="text-xs text-slate-500 mt-2">Победитель получает +50 XP. Серия побед даёт достижения.</p>
"""
        },
        {
            "id": "live", "icon": "🎮", "nav": "Live test",
            "title": "🎮 Live test (групповой)",
            "body": """
<p class="text-slate-700 mb-3">Это как Kahoot — учитель запускает тест, студенты входят по коду, отвечают одновременно, видят таблицу лидеров в реальном времени.</p>
<ol class="text-sm text-slate-700 list-decimal pl-5 space-y-1">
  <li>Игры → 🎮 Live test (создать) → выберите колоду или категорию</li>
  <li>Получаете 6-значный код и пригласительную ссылку</li>
  <li>Студенты заходят на <code>/live/join</code> или просто переходят по ссылке</li>
  <li>Когда все собрались — Старт</li>
  <li>За скорость и правильность — больше очков</li>
</ol>
<p class="text-sm text-slate-700 mt-3">После теста — детальный разбор кто что отвечал.</p>
"""
        },
        {
            "id": "goals", "icon": "🎯", "nav": "Цели",
            "title": "🎯 Цели — для серьёзного обучения",
            "body": """
<p class="text-slate-700 mb-3">Вы говорите «Хочу пройти эту колоду за 30 дней» — система сама делит работу на дни и напоминает.</p>
<div class="grid md:grid-cols-3 gap-2">
  <div class="bg-green-50 rounded-xl p-3 text-sm">
    <div class="font-bold">😌 Легко</div>
    <div class="text-xs text-slate-600">×1 повтор</div>
  </div>
  <div class="bg-amber-50 rounded-xl p-3 text-sm">
    <div class="font-bold">💪 Норма</div>
    <div class="text-xs text-slate-600">×2 повтора</div>
  </div>
  <div class="bg-red-50 rounded-xl p-3 text-sm">
    <div class="font-bold">🔥 Сложно</div>
    <div class="text-xs text-slate-600">×3 повтора</div>
  </div>
</div>
<h3 class="font-bold text-lg mt-4 mb-2">Что делает система</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li>Считает сколько карт надо в день</li>
  <li>Показывает план: Flashcards / тесты / дуэли / live</li>
  <li>Напоминает каждый день</li>
  <li>Если отстаёте — поддержит, можно продлить срок</li>
  <li>В конце — финальный экзамен на 60% (вопросы из тех где чаще ошибались)</li>
  <li>Сдали → +500 XP + цель завершена ✅</li>
</ul>
<p class="text-sm text-slate-700 mt-3">Можно режим <b>«Соло»</b> — без рекомендаций по дуэлям и live.</p>
"""
        },
        {
            "id": "categories", "icon": "📁", "nav": "Категории",
            "title": "📁 Категории",
            "body": """
<p class="text-slate-700 mb-3">Группируйте колоды по предметам/уровням. Например: «Английский» → подкатегории «Beginner / Elementary / Intermediate». Каждая колода привязывается к одной категории.</p>
<p class="text-sm text-slate-700">На странице категории нажмите 🎮 <b>Играть</b> — учить ВСЕ колоды категории одновременно.</p>
"""
        },
        {
            "id": "social", "icon": "💬", "nav": "Соц. функции",
            "title": "💬 Соц. функции",
            "body": """
<ul class="text-sm text-slate-700 space-y-2">
  <li><b>👥 Друзья</b> — добавляйте, видите их прогресс, вызывайте на дуэли</li>
  <li><b>💬 Чаты</b> — личные сообщения с друзьями</li>
  <li><b>📡 Каналы</b> — групповые чаты и объявления</li>
  <li><b>🎓 Учебные группы</b> — общие колоды + общая статистика + чат</li>
  <li><b>🌐 Маркет</b> — публичные колоды от других, можно копировать</li>
  <li><b>🏆 Топ</b> — лидерборд по XP среди всех</li>
</ul>
"""
        },
        {
            "id": "xp", "icon": "⭐", "nav": "XP и достижения",
            "title": "⭐ XP, streak и достижения",
            "body": """
<ul class="text-sm text-slate-700 space-y-2">
  <li><b>⭐ XP</b> — очки опыта. +3 за правильный, +5 за «Легко», +50 за победу в дуэли, +500 за экзамен.</li>
  <li><b>🔥 Streak</b> — дни подряд занятий. Пропустили день → сбрасывается.</li>
  <li><b>🏆 Достижения</b> — открываются автоматически. На странице <a href="/achievements" class="text-indigo-600 hover:underline">Достижения</a>.</li>
  <li><b>🎯 Дневная цель</b> — настраивается в Настройках. По умолчанию 20 карт.</li>
</ul>
"""
        },
        {
            "id": "faq", "icon": "❓", "nav": "Частые вопросы",
            "title": "❓ Частые вопросы",
            "body": """
<div class="space-y-3">
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Я учитель в учебном центре. С чего начать?</summary>
    <p class="text-sm text-slate-700 mt-2">Зарегистрируйтесь в режиме «🏢 Учебный центр» → создайте колоды → создайте логины студентам в Управлении пользователями. У вас будет дашборд с прогрессом всех учеников.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Что делать если забыл пароль?</summary>
    <p class="text-sm text-slate-700 mt-2">Если вы в учебном центре — обратитесь к админу/учителю, у них есть кнопка «🔑 Сбросить пароль». Если индивидуальный — напишите нам.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Как сделать колоду публичной?</summary>
    <p class="text-sm text-slate-700 mt-2">В колоде нажмите 🌐 «Опубликовать». Появится в маркетплейсе — другие смогут её скопировать.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Можно ли скачать свои данные?</summary>
    <p class="text-sm text-slate-700 mt-2">Да. В колоде → 💾 JSON — резервная копия. Можно импортировать обратно или передать другому.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Сайт работает на телефоне?</summary>
    <p class="text-sm text-slate-700 mt-2">Да, полностью адаптирован. Flashcards поддерживают свайпы. Можно добавить «На главный экран» и пользоваться как приложением.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Что делать если AI не работает?</summary>
    <p class="text-sm text-slate-700 mt-2">Может быть превышен дневной лимит. Подождите час или попробуйте на следующий день.</p>
  </details>
</div>
"""
        },
    ]
}


# English
HELP_EN = {
    "page_title": "How to use QuizPro",
    "page_subtitle": "Step by step — from your first deck to the final exam",
    "toc_label": "Sections",
    "support_title": "Didn't find an answer?",
    "support_text": "Write to us, we really read all messages and try to help quickly.",
    "support_btn": "Contact support",
    "sections": [
        {
            "id": "start", "icon": "🚀", "nav": "Quick start",
            "title": "🚀 Quick start (3 minutes)",
            "body": """
<p class="text-slate-700 mb-4">If you just signed up — follow these 4 steps and you'll get value right away.</p>
<div class="space-y-3">
  <div class="flex gap-3 p-3 rounded-xl bg-indigo-50">
    <span class="text-2xl flex-shrink-0">1️⃣</span>
    <div>
      <div class="font-bold">Create your first deck</div>
      <p class="text-sm text-slate-600">Go to <a href="/dashboard" class="text-indigo-600 hover:underline">Dashboard</a> → click <b>+ New deck</b>. Give it a name like "English — basics". A deck = a set of cards on one topic.</p>
    </div>
  </div>
  <div class="flex gap-3 p-3 rounded-xl bg-emerald-50">
    <span class="text-2xl flex-shrink-0">2️⃣</span>
    <div>
      <div class="font-bold">Add cards — 3 ways</div>
      <ul class="text-sm text-slate-600 list-disc pl-4 mt-1 space-y-1">
        <li><b>Manually:</b> in deck → + Card → enter question and answer</li>
        <li><b>Import:</b> upload .pdf/.docx/.txt or paste text</li>
        <li><b>AI:</b> on /ai enter a topic — AI creates 10-30 questions in 20 seconds</li>
      </ul>
    </div>
  </div>
  <div class="flex gap-3 p-3 rounded-xl bg-purple-50">
    <span class="text-2xl flex-shrink-0">3️⃣</span>
    <div>
      <div class="font-bold">Study with Flashcards</div>
      <p class="text-sm text-slate-600">In a deck click 🃏 <b>Flashcards</b>. Card flips — rate "Hard/Good/Easy". The SM-2 algorithm shows each card right when you start to forget.</p>
    </div>
  </div>
  <div class="flex gap-3 p-3 rounded-xl bg-amber-50">
    <span class="text-2xl flex-shrink-0">4️⃣</span>
    <div>
      <div class="font-bold">Set a goal</div>
      <p class="text-sm text-slate-600">On <a href="/goals" class="text-indigo-600 hover:underline">Goals</a> → + New goal. Pick a deck, deadline, level. The system splits the work into daily chunks.</p>
    </div>
  </div>
</div>
"""
        },
        {
            "id": "decks", "icon": "📚", "nav": "Decks & cards",
            "title": "📚 Decks and cards",
            "body": """
<p class="text-slate-700 mb-3">A <b>deck</b> = a set of cards on one topic. Like "English — Beginner" or "Biology — The Cell".</p>
<h3 class="font-bold text-lg mt-4 mb-2">Card structure</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><b>Front</b> — what's shown first</li>
  <li><b>Back</b> — the correct answer</li>
  <li><b>Note</b> — for MCQ tests: A) ... B) ... C) ...</li>
  <li><b>Image</b> — you can attach a picture to the question</li>
</ul>
<h3 class="font-bold text-lg mt-4 mb-2">Buttons in a deck</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><b>📝 Test</b> — multiple choice quiz</li>
  <li><b>🃏 Flashcards</b> — flip cards study</li>
  <li><b>🎯 Match</b> — speed game (match pairs)</li>
  <li><b>🎮 Live test</b> — group quiz in real time</li>
  <li><b>📊 Excel / 📄 PDF</b> — download journal or printable test</li>
  <li><b>💾 JSON</b> — deck backup</li>
  <li><b>📋 Duplicate</b> — copy of the deck</li>
  <li><b>🌐 Publish</b> — share to marketplace</li>
</ul>
"""
        },
        {
            "id": "import", "icon": "📥", "nav": "Import & AI",
            "title": "📥 Import and AI",
            "body": """
<h3 class="font-bold text-lg mb-2">Import from file</h3>
<p class="text-slate-700 text-sm mb-2">Supported: <code>.txt</code>, <code>.csv</code>, <code>.docx</code>, <code>.pdf</code>.</p>
<div class="bg-slate-50 rounded-xl p-4 text-sm font-mono mb-3 whitespace-pre-line">1. What is HTML?
A) A programming language
B) A markup language ✓
C) A database

2. How many planets in the Solar System?
A) 7
B) 8 ✓
C) 9
D) 10</div>
<p class="text-xs text-slate-500 mb-4"><code>✓</code> marks the correct answer. Numbering (1., 1), 1-) is auto-stripped.</p>
<p class="text-sm text-slate-700">Or simple format: <code>Question | Answer | Note</code> per line.</p>
<h3 class="font-bold text-lg mt-5 mb-2">🤖 AI generation</h3>
<p class="text-slate-700 text-sm mb-3">On the <a href="/ai" class="text-indigo-600 hover:underline">AI</a> page you can:</p>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><b>From topic:</b> "English grammar — Past Simple" → AI creates 15 questions</li>
  <li><b>From text:</b> paste a lecture — AI extracts key concepts</li>
  <li><b>From PDF:</b> upload a textbook PDF — AI reads and generates questions</li>
</ul>
<p class="text-xs text-slate-500 mt-2">⏱ Takes 10-30 seconds. AI can make mistakes — always verify.</p>
"""
        },
        {
            "id": "flashcards", "icon": "🃏", "nav": "Flashcards",
            "title": "🃏 Flashcards (the main study mode)",
            "body": """
<p class="text-slate-700 mb-3">The heart of QuizPro. Cards appear right when you start forgetting — this is the <b>SM-2 algorithm</b>, scientifically proven since 1985.</p>
<h3 class="font-bold text-lg mt-3 mb-2">How it works</h3>
<ol class="text-sm text-slate-700 list-decimal pl-5 space-y-1">
  <li>Open card → see the question</li>
  <li>Think → press "Flip" (or <code>Space</code>)</li>
  <li>See answer → rate honestly</li>
</ol>
<div class="grid grid-cols-3 gap-2 mt-3">
  <div class="bg-orange-50 rounded-xl p-3 text-center text-sm">
    <div class="font-bold">😣 Hard</div>
    <div class="text-xs text-slate-600">In 1 day</div>
  </div>
  <div class="bg-emerald-50 rounded-xl p-3 text-center text-sm">
    <div class="font-bold">👍 Good</div>
    <div class="text-xs text-slate-600">In 3 days</div>
  </div>
  <div class="bg-blue-50 rounded-xl p-3 text-center text-sm">
    <div class="font-bold">⭐ Easy</div>
    <div class="text-xs text-slate-600">In a week</div>
  </div>
</div>
<h3 class="font-bold text-lg mt-4 mb-2">Hotkeys</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><code>Space</code> — flip</li>
  <li><code>← / →</code> — prev / next</li>
  <li><code>F</code> — favorite ⭐</li>
  <li><code>D</code> — mark as hard 🔥</li>
  <li><code>1 / 2 / 3</code> — rate</li>
</ul>
"""
        },
        {
            "id": "test", "icon": "📝", "nav": "Tests",
            "title": "📝 Multiple choice tests",
            "body": """
<p class="text-slate-700 mb-3">For knowledge checks — answer 4-option questions, get a full review of mistakes at the end.</p>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li>Pick number of questions (5/10/25/50/100)</li>
  <li>Random order (toggle)</li>
  <li>"Hard only" — cards you fail most often</li>
  <li>Options shuffled each time — can't memorize "answer is always A"</li>
  <li>Detailed mistakes review at the end</li>
</ul>
"""
        },
        {
            "id": "match", "icon": "🎯", "nav": "Match",
            "title": "🎯 Match — speed game",
            "body": """
<p class="text-slate-700 mb-3">Match terms with definitions as fast as possible. Available for terms decks.</p>
<p class="text-sm text-slate-700">Left — questions, right — answers (shuffled). Click a pair — if correct they disappear. Goal: finish in minimum time. Best time is saved.</p>
"""
        },
        {
            "id": "duels", "icon": "⚔️", "nav": "Duels",
            "title": "⚔️ Duels (1 vs 1)",
            "body": """
<p class="text-slate-700 mb-3">Battle a friend on a chosen deck or category. Faster + more accurate wins.</p>
<ol class="text-sm text-slate-700 list-decimal pl-5 space-y-1">
  <li>Open friend's profile or go to <a href="/leaderboard" class="text-indigo-600 hover:underline">Leaderboard</a></li>
  <li>Click ⚔️ Challenge → pick a deck</li>
  <li>Friend gets a notification</li>
  <li>5 questions on speed, both see results in real time</li>
</ol>
<p class="text-xs text-slate-500 mt-2">Winner gets +50 XP. Win streaks unlock achievements.</p>
"""
        },
        {
            "id": "live", "icon": "🎮", "nav": "Live test",
            "title": "🎮 Live test (group)",
            "body": """
<p class="text-slate-700 mb-3">Like Kahoot — teacher starts a quiz, students join with code, answer simultaneously, see leaderboard live.</p>
<ol class="text-sm text-slate-700 list-decimal pl-5 space-y-1">
  <li>Games → 🎮 Live test (create) → pick a deck or category</li>
  <li>Get a 6-character code and invitation link</li>
  <li>Students go to <code>/live/join</code> or click the link directly</li>
  <li>When everyone joined — Start</li>
  <li>Speed + correctness = more points</li>
</ol>
<p class="text-sm text-slate-700 mt-3">After the test — full breakdown of who answered what.</p>
"""
        },
        {
            "id": "goals", "icon": "🎯", "nav": "Goals",
            "title": "🎯 Goals — for serious learning",
            "body": """
<p class="text-slate-700 mb-3">Say "I want to finish this deck in 30 days" — system splits it into daily chunks and reminds you.</p>
<div class="grid md:grid-cols-3 gap-2">
  <div class="bg-green-50 rounded-xl p-3 text-sm">
    <div class="font-bold">😌 Easy</div>
    <div class="text-xs text-slate-600">×1 review</div>
  </div>
  <div class="bg-amber-50 rounded-xl p-3 text-sm">
    <div class="font-bold">💪 Normal</div>
    <div class="text-xs text-slate-600">×2 reviews</div>
  </div>
  <div class="bg-red-50 rounded-xl p-3 text-sm">
    <div class="font-bold">🔥 Hard</div>
    <div class="text-xs text-slate-600">×3 reviews</div>
  </div>
</div>
<h3 class="font-bold text-lg mt-4 mb-2">What the system does</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li>Calculates cards/day needed</li>
  <li>Shows plan: Flashcards / tests / duels / live</li>
  <li>Reminds every day</li>
  <li>If you fall behind — supports you, lets you extend deadline</li>
  <li>Final exam at 60% (questions from cards you fail most)</li>
  <li>Pass → +500 XP + goal completed ✅</li>
</ul>
<p class="text-sm text-slate-700 mt-3"><b>Solo mode</b> — no duel/live recommendations.</p>
"""
        },
        {
            "id": "categories", "icon": "📁", "nav": "Categories",
            "title": "📁 Categories",
            "body": """
<p class="text-slate-700 mb-3">Group decks by subject/level. Like "English" → subcategories "Beginner / Elementary / Intermediate". Each deck links to one category.</p>
<p class="text-sm text-slate-700">On a category page click 🎮 <b>Play</b> — study ALL decks of that category at once.</p>
"""
        },
        {
            "id": "social", "icon": "💬", "nav": "Social",
            "title": "💬 Social features",
            "body": """
<ul class="text-sm text-slate-700 space-y-2">
  <li><b>👥 Friends</b> — add, see their progress, challenge to duels</li>
  <li><b>💬 Chats</b> — direct messages</li>
  <li><b>📡 Channels</b> — group chats and announcements</li>
  <li><b>🎓 Study groups</b> — shared decks + stats + chat</li>
  <li><b>🌐 Marketplace</b> — public decks from others, copy-able</li>
  <li><b>🏆 Top</b> — XP leaderboard</li>
</ul>
"""
        },
        {
            "id": "xp", "icon": "⭐", "nav": "XP & achievements",
            "title": "⭐ XP, streak and achievements",
            "body": """
<ul class="text-sm text-slate-700 space-y-2">
  <li><b>⭐ XP</b> — experience points. +3 per correct, +5 for "Easy", +50 for duel win, +500 for exam.</li>
  <li><b>🔥 Streak</b> — consecutive study days. Skip a day → resets.</li>
  <li><b>🏆 Achievements</b> — auto-unlocked. See <a href="/achievements" class="text-indigo-600 hover:underline">Achievements</a>.</li>
  <li><b>🎯 Daily goal</b> — set in Settings. Default 20 cards.</li>
</ul>
"""
        },
        {
            "id": "faq", "icon": "❓", "nav": "FAQ",
            "title": "❓ Frequently asked questions",
            "body": """
<div class="space-y-3">
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">I'm a teacher in a learning center. Where to start?</summary>
    <p class="text-sm text-slate-700 mt-2">Sign up as "🏢 Learning center" → create decks → create student logins in User Management. You'll get a dashboard with all students' progress.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">What if I forgot my password?</summary>
    <p class="text-sm text-slate-700 mt-2">If you're in a learning center — contact admin/teacher, they have a "🔑 Reset password" button. If individual — write to us.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">How to make a deck public?</summary>
    <p class="text-sm text-slate-700 mt-2">In a deck press 🌐 "Publish". It will appear in the marketplace — others can copy.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Can I download my data?</summary>
    <p class="text-sm text-slate-700 mt-2">Yes. In a deck → 💾 JSON — backup. Can be re-imported or shared.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Does it work on mobile?</summary>
    <p class="text-sm text-slate-700 mt-2">Yes, fully responsive. Flashcards support swipes. You can "Add to Home Screen" and use as an app.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">What if AI doesn't work?</summary>
    <p class="text-sm text-slate-700 mt-2">Daily limit may be exceeded. Wait an hour or try the next day.</p>
  </details>
</div>
"""
        },
    ]
}


# Uzbek
HELP_UZ = {
    "page_title": "QuizPro dan qanday foydalanish",
    "page_subtitle": "Birinchi koloda dan imtihongacha — bosqichma-bosqich",
    "toc_label": "Bo'limlar",
    "support_title": "Javob topa olmadingizmi?",
    "support_text": "Bizga yozing — barcha xabarlarni o'qiymiz va tezda yordam berishga harakat qilamiz.",
    "support_btn": "Qo'llab-quvvatlashga yozish",
    "sections": [
        {
            "id": "start", "icon": "🚀", "nav": "Boshlash",
            "title": "🚀 Qaerdan boshlash (3 daqiqa)",
            "body": """
<p class="text-slate-700 mb-4">Yangi ro'yxatdan o'tdingizmi — quyidagi 4 bosqichni bajarib, darhol foydani his qiling.</p>
<div class="space-y-3">
  <div class="flex gap-3 p-3 rounded-xl bg-indigo-50">
    <span class="text-2xl flex-shrink-0">1️⃣</span>
    <div>
      <div class="font-bold">Birinchi koloda yarating</div>
      <p class="text-sm text-slate-600"><a href="/dashboard" class="text-indigo-600 hover:underline">Dashboard</a> ga kiring → <b>+ Yangi koloda</b> tugmasini bosing. Nom bering, masalan "Ingliz tili — boshlang'ich". Koloda — bir mavzudagi kartochkalar to'plami.</p>
    </div>
  </div>
  <div class="flex gap-3 p-3 rounded-xl bg-emerald-50">
    <span class="text-2xl flex-shrink-0">2️⃣</span>
    <div>
      <div class="font-bold">Kartalar qo'shing — 3 yo'l</div>
      <ul class="text-sm text-slate-600 list-disc pl-4 mt-1 space-y-1">
        <li><b>Qo'lda:</b> kolodada → + Karta → savol va javob kiriting</li>
        <li><b>Import:</b> .pdf/.docx/.txt yuklang yoki matn qo'ying</li>
        <li><b>AI:</b> /ai sahifasida mavzu kiriting — AI 20 soniyada 10-30 savol yaratadi</li>
      </ul>
    </div>
  </div>
  <div class="flex gap-3 p-3 rounded-xl bg-purple-50">
    <span class="text-2xl flex-shrink-0">3️⃣</span>
    <div>
      <div class="font-bold">Flashcards bilan o'qing</div>
      <p class="text-sm text-slate-600">Kolodada 🃏 <b>Flashcards</b> bosing. Karta aylantiriladi — "Qiyin/Yaxshi/Oson" baho bering. SM-2 algoritmi har bir kartani siz unuta boshlagan paytda ko'rsatadi.</p>
    </div>
  </div>
  <div class="flex gap-3 p-3 rounded-xl bg-amber-50">
    <span class="text-2xl flex-shrink-0">4️⃣</span>
    <div>
      <div class="font-bold">Maqsad qo'ying</div>
      <p class="text-sm text-slate-600"><a href="/goals" class="text-indigo-600 hover:underline">Maqsadlar</a> → + Yangi maqsad. Koloda, muddat, daraja tanlang. Tizim har kunlik kartalarni o'zi hisoblab chiqadi.</p>
    </div>
  </div>
</div>
"""
        },
        {
            "id": "decks", "icon": "📚", "nav": "Kolodalar",
            "title": "📚 Kolodalar va kartalar",
            "body": """
<p class="text-slate-700 mb-3"><b>Koloda</b> — bir mavzudagi kartochkalar to'plami. Masalan: "Ingliz tili — Beginner" yoki "Biologiya — Hujayra".</p>
<h3 class="font-bold text-lg mt-4 mb-2">Karta tuzilishi</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><b>Savol (front)</b> — birinchi ko'rsatiladigan</li>
  <li><b>Javob (back)</b> — to'g'ri javob</li>
  <li><b>Izoh (note)</b> — variantlar uchun: A) ... B) ... C) ...</li>
  <li><b>Rasm</b> — savolga rasm qo'shish mumkin</li>
</ul>
<h3 class="font-bold text-lg mt-4 mb-2">Kolodadagi tugmalar</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><b>📝 Test</b> — variantli test</li>
  <li><b>🃏 Flashcards</b> — aylanuvchi kartalar</li>
  <li><b>🎯 Match</b> — tezlik o'yini</li>
  <li><b>🎮 Live test</b> — guruhda jonli test</li>
  <li><b>📊 Excel / 📄 PDF</b> — jurnal yoki bosma test</li>
  <li><b>💾 JSON</b> — koloda zaxira</li>
  <li><b>📋 Nusxa</b> — koloda nusxasi</li>
  <li><b>🌐 Nashr</b> — bozorga chiqarish</li>
</ul>
"""
        },
        {
            "id": "import", "icon": "📥", "nav": "Import va AI",
            "title": "📥 Import va AI",
            "body": """
<h3 class="font-bold text-lg mb-2">Fayldan import</h3>
<p class="text-slate-700 text-sm mb-2">Qo'llab-quvvatlanadi: <code>.txt</code>, <code>.csv</code>, <code>.docx</code>, <code>.pdf</code>.</p>
<div class="bg-slate-50 rounded-xl p-4 text-sm font-mono mb-3 whitespace-pre-line">1. HTML nima?
A) Dasturlash tili
B) Belgilash tili ✓
C) Ma'lumotlar bazasi

2. Quyosh tizimida nechta sayyora bor?
A) 7
B) 8 ✓
C) 9
D) 10</div>
<p class="text-xs text-slate-500 mb-4"><code>✓</code> belgisi to'g'ri javobni bildiradi.</p>
<p class="text-sm text-slate-700">Yoki oddiy format: <code>Savol | Javob | Izoh</code> har bir qatorda.</p>
<h3 class="font-bold text-lg mt-5 mb-2">🤖 AI yaratish</h3>
<p class="text-slate-700 text-sm mb-3"><a href="/ai" class="text-indigo-600 hover:underline">AI</a> sahifasida:</p>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><b>Mavzu bo'yicha:</b> "Past Simple" → AI 15 savol yaratadi</li>
  <li><b>Matn bo'yicha:</b> ma'ruza qo'ying — AI asosiy tushunchalarni topadi</li>
  <li><b>PDF bo'yicha:</b> darslik PDF yuklang — AI o'qib savollar yaratadi</li>
</ul>
<p class="text-xs text-slate-500 mt-2">⏱ 10-30 soniya. AI xatolar qilishi mumkin — har doim tekshiring.</p>
"""
        },
        {
            "id": "flashcards", "icon": "🃏", "nav": "Flashcards",
            "title": "🃏 Flashcards (asosiy o'qish rejimi)",
            "body": """
<p class="text-slate-700 mb-3">QuizPro ning yuragi. Kartalar siz unuta boshlagan paytda paydo bo'ladi — bu <b>SM-2 algoritmi</b>, 1985 yildan beri ilmiy isbotlangan.</p>
<h3 class="font-bold text-lg mt-3 mb-2">Qanday ishlaydi</h3>
<ol class="text-sm text-slate-700 list-decimal pl-5 space-y-1">
  <li>Kartani oching → savolni ko'ring</li>
  <li>O'ylang → "Aylantirish" yoki <code>Space</code></li>
  <li>Javobni ko'ring → halol baho bering</li>
</ol>
<div class="grid grid-cols-3 gap-2 mt-3">
  <div class="bg-orange-50 rounded-xl p-3 text-center text-sm">
    <div class="font-bold">😣 Qiyin</div>
    <div class="text-xs text-slate-600">1 kundan keyin</div>
  </div>
  <div class="bg-emerald-50 rounded-xl p-3 text-center text-sm">
    <div class="font-bold">👍 Yaxshi</div>
    <div class="text-xs text-slate-600">3 kundan keyin</div>
  </div>
  <div class="bg-blue-50 rounded-xl p-3 text-center text-sm">
    <div class="font-bold">⭐ Oson</div>
    <div class="text-xs text-slate-600">Bir hafta keyin</div>
  </div>
</div>
<h3 class="font-bold text-lg mt-4 mb-2">Klaviatura</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li><code>Space</code> — aylantirish</li>
  <li><code>← / →</code> — oldingi / keyingi</li>
  <li><code>F</code> — sevimli ⭐</li>
  <li><code>D</code> — qiyin sifatida belgilash 🔥</li>
  <li><code>1 / 2 / 3</code> — baho berish</li>
</ul>
"""
        },
        {
            "id": "test", "icon": "📝", "nav": "Testlar",
            "title": "📝 Variantli testlar",
            "body": """
<p class="text-slate-700 mb-3">Bilim tekshirish uchun — 4 variantli savollar, oxirida xatolarni ko'rib chiqasiz.</p>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li>Savollar soni (5/10/25/50/100)</li>
  <li>Tasodifiy tartib</li>
  <li>"Faqat qiyinlari" — eng ko'p xato qilingan kartalar</li>
  <li>Variantlar har safar aralashtiriladi — "doim A" ni eslab qola olmaysiz</li>
  <li>Oxirida — barcha xatolarning batafsil tahlili</li>
</ul>
"""
        },
        {
            "id": "match", "icon": "🎯", "nav": "Match",
            "title": "🎯 Match — tezlik o'yini",
            "body": """
<p class="text-slate-700 mb-3">Atamalarni tezroq mosroq qiling. Lug'at kolodalar uchun.</p>
<p class="text-sm text-slate-700">Chap — savollar, o'ng — javoblar (aralashtirilgan). Juftlikni bosing — to'g'ri bo'lsa, yo'qoladi. Maqsad — minimal vaqtda yakunlash.</p>
"""
        },
        {
            "id": "duels", "icon": "⚔️", "nav": "Duellar",
            "title": "⚔️ Duellar (1 ga 1)",
            "body": """
<p class="text-slate-700 mb-3">Do'st bilan tanlangan kolodada bahslashing. Tezroq + aniqroq — g'olib.</p>
<ol class="text-sm text-slate-700 list-decimal pl-5 space-y-1">
  <li>Do'st profilini oching yoki <a href="/leaderboard" class="text-indigo-600 hover:underline">Reyting</a> ga kiring</li>
  <li>⚔️ Chaqirish → kolodani tanlang</li>
  <li>Do'st xabarnoma oladi</li>
  <li>5 savol tezlikka, ikkalangiz natijalarni real vaqtda ko'rasiz</li>
</ol>
<p class="text-xs text-slate-500 mt-2">G'olib +50 XP oladi.</p>
"""
        },
        {
            "id": "live", "icon": "🎮", "nav": "Live test",
            "title": "🎮 Live test (guruhda)",
            "body": """
<p class="text-slate-700 mb-3">Kahoot kabi — o'qituvchi testni boshlaydi, talabalar kod orqali kirishadi, hammasi bir vaqtda javob beradi, reyting jonli ko'rinadi.</p>
<ol class="text-sm text-slate-700 list-decimal pl-5 space-y-1">
  <li>O'yinlar → 🎮 Live test (yaratish) → koloda yoki kategoriya tanlang</li>
  <li>6 belgili kod va taklif havolasini olasiz</li>
  <li>Talabalar <code>/live/join</code> ga kiradi yoki havoladan o'tadi</li>
  <li>Hammalari yig'ilgach — Boshlash</li>
  <li>Tezlik + to'g'rilik = ko'proq ball</li>
</ol>
<p class="text-sm text-slate-700 mt-3">Testdan keyin — kim qanday javob berganligi haqida batafsil tahlil.</p>
"""
        },
        {
            "id": "goals", "icon": "🎯", "nav": "Maqsadlar",
            "title": "🎯 Maqsadlar — jiddiy o'qish uchun",
            "body": """
<p class="text-slate-700 mb-3">"Bu kolodani 30 kunda o'rganaman" deb ayting — tizim ishni har kunlik bo'laklarga ajratadi va eslatadi.</p>
<div class="grid md:grid-cols-3 gap-2">
  <div class="bg-green-50 rounded-xl p-3 text-sm">
    <div class="font-bold">😌 Oson</div>
    <div class="text-xs text-slate-600">×1 takrorlash</div>
  </div>
  <div class="bg-amber-50 rounded-xl p-3 text-sm">
    <div class="font-bold">💪 Normal</div>
    <div class="text-xs text-slate-600">×2 takrorlash</div>
  </div>
  <div class="bg-red-50 rounded-xl p-3 text-sm">
    <div class="font-bold">🔥 Qiyin</div>
    <div class="text-xs text-slate-600">×3 takrorlash</div>
  </div>
</div>
<h3 class="font-bold text-lg mt-4 mb-2">Tizim nima qiladi</h3>
<ul class="text-sm text-slate-700 list-disc pl-5 space-y-1">
  <li>Kunlik kartalar sonini hisoblaydi</li>
  <li>Reja: Flashcards / testlar / duellar / live</li>
  <li>Har kuni eslatadi</li>
  <li>Orqada qolsangiz — qo'llab-quvvatlaydi, muddatni uzaytirish mumkin</li>
  <li>Yakuniy imtihon 60% (eng ko'p xato qilgan kartalardan)</li>
  <li>Topshirsangiz → +500 XP + maqsad bajarildi ✅</li>
</ul>
<p class="text-sm text-slate-700 mt-3"><b>Solo rejim</b> — duel/live tavsiyalarsiz.</p>
"""
        },
        {
            "id": "categories", "icon": "📁", "nav": "Kategoriyalar",
            "title": "📁 Kategoriyalar",
            "body": """
<p class="text-slate-700 mb-3">Kolodalarni fan/daraja bo'yicha guruhlang. Masalan: "Ingliz tili" → "Beginner / Elementary / Intermediate".</p>
<p class="text-sm text-slate-700">Kategoriya sahifasida 🎮 <b>O'ynash</b> bosing — kategoriyaning BARCHA kolodalarini birga o'rganish.</p>
"""
        },
        {
            "id": "social", "icon": "💬", "nav": "Ijtimoiy",
            "title": "💬 Ijtimoiy funksiyalar",
            "body": """
<ul class="text-sm text-slate-700 space-y-2">
  <li><b>👥 Do'stlar</b> — qo'shing, ularning yutuqlarini ko'ring, duelga chaqiring</li>
  <li><b>💬 Suhbatlar</b> — shaxsiy xabarlar</li>
  <li><b>📡 Kanallar</b> — guruh suhbatlari</li>
  <li><b>🎓 O'quv guruhlar</b> — umumiy kolodalar + statistika + suhbat</li>
  <li><b>🌐 Bozor</b> — boshqalardan ochiq kolodalar</li>
  <li><b>🏆 Reyting</b> — XP bo'yicha</li>
</ul>
"""
        },
        {
            "id": "xp", "icon": "⭐", "nav": "XP va yutuqlar",
            "title": "⭐ XP, streak va yutuqlar",
            "body": """
<ul class="text-sm text-slate-700 space-y-2">
  <li><b>⭐ XP</b> — tajriba ballari. To'g'ri javob +3, "Oson" +5, duel g'alabasi +50, imtihon +500.</li>
  <li><b>🔥 Streak</b> — ketma-ket o'qish kunlari. Bir kun o'tkazib yuborsangiz → tushadi.</li>
  <li><b>🏆 Yutuqlar</b> — avtomatik ochiladi. <a href="/achievements" class="text-indigo-600 hover:underline">Yutuqlar</a> sahifasi.</li>
  <li><b>🎯 Kunlik maqsad</b> — Sozlamalarda. Standart 20 karta.</li>
</ul>
"""
        },
        {
            "id": "faq", "icon": "❓", "nav": "Savollar",
            "title": "❓ Tez-tez beriladigan savollar",
            "body": """
<div class="space-y-3">
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Men o'quv markazida o'qituvchiman. Qaerdan boshlayman?</summary>
    <p class="text-sm text-slate-700 mt-2">"🏢 O'quv markaz" rejimida ro'yxatdan o'ting → kolodalar yarating → talabalarga login yarating. Sizda barcha talabalar yutug'ini ko'rish dashboardi bo'ladi.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Parolni unutsam-chi?</summary>
    <p class="text-sm text-slate-700 mt-2">O'quv markazda bo'lsangiz — admin/o'qituvchiga murojaat qiling, ularda "🔑 Parolni tiklash" tugmasi bor. Individual bo'lsangiz — bizga yozing.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Kolodani ochiq qilish?</summary>
    <p class="text-sm text-slate-700 mt-2">Kolodada 🌐 "Nashr" ni bosing. Bozorda paydo bo'ladi — boshqalar nusxa ko'chirishi mumkin.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Ma'lumotlarimni yuklab olish?</summary>
    <p class="text-sm text-slate-700 mt-2">Ha. Kolodada → 💾 JSON — zaxira nusxasi.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">Telefonda ishlaydi?</summary>
    <p class="text-sm text-slate-700 mt-2">Ha, to'liq moslashgan. Flashcards swipe qo'llab-quvvatlaydi. "Bosh ekranga qo'shish" qilib ilova kabi ishlatish mumkin.</p>
  </details>
  <details class="bg-white/60 rounded-xl p-3">
    <summary class="font-bold cursor-pointer">AI ishlamasa?</summary>
    <p class="text-sm text-slate-700 mt-2">Kunlik chegara oshib ketgan bo'lishi mumkin. Bir soat kutib yoki ertasi kuni urinib ko'ring.</p>
  </details>
</div>
"""
        },
    ]
}


def get(lang: str) -> dict:
    if lang == "en":
        return HELP_EN
    if lang == "uz":
        return HELP_UZ
    return HELP_RU
