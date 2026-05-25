# -*- coding: utf-8 -*-
"""
QuizAIPro — Help/Tutorial content.
Полный гайд по сайту на 3 языках: RU / EN / UZ.

Структура:
- labels: переводы UI-надписей и кнопок
- topics: список тем с пошаговыми инструкциями (раскрывающиеся карточки)
- faq: список вопрос-ответ
"""


# ============================================================================
# RUSSIAN
# ============================================================================
HELP_RU = {
    "labels": {
        "useful": "Полезно знать",
        "try_now": "Попробуйте сейчас",
        "try_now_default": "Откройте раздел и попробуйте сами:",
        "installing": "Создаём…",
        "installed": "Готово! Перенаправляем…",
        "error": "Ошибка",
        "unknown": "неизвестная ошибка",
    },
    "topics": [
        {
            "emoji": "📚",
            "color": "linear-gradient(135deg, #6366f1, #8b5cf6)",
            "title": "Колоды и карточки",
            "sub": "Создание, редактирование, удаление",
            "intro": "<strong>Колода</strong> — это набор карточек по одной теме. Каждая <strong>карточка</strong> содержит вопрос и ответ. С них начинается всё обучение.",
            "steps": [
                "Откройте <strong>Главную</strong> и нажмите <code>+ Новая колода</code>. Введите название и выберите иконку (например 📘 для английского).",
                "Зайдите в созданную колоду и нажмите <code>+ Добавить карточку</code>. Каждая карточка может быть простым вопросом-ответом или MCQ (с 4 вариантами).",
                "Чтобы пометить правильный вариант — нажмите на него. Он подсветится зелёным.",
                "Карточки можно редактировать прямо в списке: кликаешь на текст и меняешь.",
                "Удалить карточку или колоду — кнопкой <code>×</code> справа.",
            ],
            "tip": "Иконку колоды можно поменять в любой момент — кликните на неё в шапке колоды и введите новый эмодзи.",
            "actionText": "Создайте свою первую колоду:",
            "actions": [
                {"url": "/dashboard", "label": "Перейти к колодам"},
            ],
        },
        {
            "emoji": "📥",
            "color": "linear-gradient(135deg, #10b981, #059669)",
            "title": "Импорт из файлов",
            "sub": "TXT, DOCX, PDF, Excel — массовая загрузка вопросов",
            "intro": "Если у вас уже есть готовый список вопросов — не нужно вбивать их по одному. Импортируйте сразу всю колоду из файла.",
            "steps": [
                "Откройте <strong>Импорт</strong> в боковом меню или из колоды.",
                "Выберите формат: <code>.txt</code> и <code>.csv</code> для простых тестов; <code>.docx</code> и <code>.pdf</code> для документов; <code>.xlsx</code> для таблиц.",
                "Скачайте <strong>пример файла</strong> в нужном формате — там видна структура (вопрос, варианты, правильный ответ).",
                "Загрузите свой файл — система определит формат и создаст колоду автоматически.",
                "Для PDF без чёткой структуры есть режим <strong>AI Vision</strong> — нейросеть сама достанет вопросы из картинок и сканов.",
            ],
            "tip": "Для PDF лучше использовать AI Vision если документ — скан или содержит сложную вёрстку. Это медленнее но точнее.",
            "actionText": "Загрузите свой первый файл:",
            "actions": [
                {"url": "/import", "label": "Открыть импорт"},
            ],
        },
        {
            "emoji": "🤖",
            "color": "linear-gradient(135deg, #f59e0b, #f97316)",
            "title": "AI-генерация вопросов",
            "sub": "Создаёт колоду из одной темы за минуту",
            "intro": "Не хочется придумывать вопросы вручную? AI сделает это за вас — просто опишите тему.",
            "steps": [
                "Откройте раздел <strong>AI</strong> в меню.",
                "Введите тему: например <em>«Глаголы неправильного спряжения в английском»</em> или <em>«Великая Отечественная война, 1941-1945»</em>.",
                "Выберите количество вопросов (от 5 до 50), уровень сложности и язык.",
                "Если хотите MCQ-тест — оставьте режим <strong>«с вариантами»</strong>. Если flashcards — выберите <strong>«термины»</strong>.",
                "Нажмите <strong>«Сгенерировать»</strong>. AI создаст готовую колоду за 20-60 секунд.",
            ],
            "tip": "Чем точнее опишете тему — тем релевантнее будут вопросы. Можно указать программу класса, учебник, эпоху, регион.",
            "actionText": "Попробуйте AI-генерацию:",
            "actions": [
                {"url": "/ai", "label": "Открыть AI-генерацию"},
            ],
        },
        {
            "emoji": "📝",
            "color": "linear-gradient(135deg, #3b82f6, #2563eb)",
            "title": "Тесты",
            "sub": "Проверяй знания и отслеживай прогресс",
            "intro": "Тест — это случайная выборка карточек с фиксированным временем. Самый быстрый способ проверить, что вы помните.",
            "steps": [
                "Откройте колоду и нажмите кнопку <strong>«Тест»</strong>.",
                "Выберите количество вопросов (10/25/50/100) и нужно ли перемешать.",
                "Можно включить режим <strong>«Только сложные»</strong> — будут только карточки с низким процентом правильных ответов.",
                "Во время теста — выбирайте ответ. После теста увидите сколько правильно, сколько неправильно, и какие карточки нужно повторить.",
                "Все тесты сохраняются в <strong>Истории тестов</strong> — можно вернуться и посмотреть какие были вопросы и ваши ответы.",
            ],
            "tip": "Кнопка <strong>📊 История</strong> на странице колоды покажет все ваши прохождения именно этой колоды — с временем и процентом.",
            "actionText": "Посмотрите свою историю тестов:",
            "actions": [
                {"url": "/test/history", "label": "История тестов"},
                {"url": "/dashboard", "label": "Запустить тест"},
            ],
        },
        {
            "emoji": "🃏",
            "color": "linear-gradient(135deg, #ec4899, #be185d)",
            "title": "Flashcards и Match",
            "sub": "Карточки-перевёртыши и игра в пары",
            "intro": "Для словарей и терминов есть два особых режима — без вариантов ответа.",
            "steps": [
                "<strong>Flashcards (карточки-перевёртыши):</strong> в колоде типа «термины» нажмите соответствующую кнопку. Карточка показывает термин, а вы вспоминаете определение и переворачиваете.",
                "Можно отметить «знаю» или «нужно повторить» — система запомнит и в следующий раз покажет первыми те, что вы плохо помните.",
                "<strong>Match (игра в пары):</strong> на одном экране показываются термины и определения вперемешку. Нужно как можно быстрее соединить пары.",
                "Match отслеживает время — соревнуйтесь с собой или одноклассниками.",
                "Чтобы создать колоду типа «термины» — при создании выберите тип <strong>«Слова и определения»</strong>.",
            ],
            "tip": "Flashcards идеальны для иностранных языков и определений. Match — лучше для повторения перед экзаменом, когда уже всё знакомо.",
            "actions": [],
        },
        {
            "emoji": "📁",
            "color": "linear-gradient(135deg, #8b5cf6, #6d28d9)",
            "title": "Категории",
            "sub": "Группируй колоды по темам и предметам",
            "intro": "Когда колод становится много — категории помогают навести порядок. Можно создать <strong>«Английский»</strong>, <strong>«История»</strong>, <strong>«Математика»</strong> и сортировать колоды по ним.",
            "steps": [
                "Откройте <strong>Категории</strong> в меню.",
                "Нажмите <strong>«+ Категория»</strong>, введите название и выберите иконку.",
                "Можно создавать <strong>подкатегории</strong> — например внутри «Английский» сделать «Грамматика» и «Лексика».",
                "При создании или редактировании колоды — выберите подходящую категорию.",
                "На главной странице колоды группируются по категориям. Можно фильтровать.",
            ],
            "tip": "Категории — необязательны. Если у вас 3-5 колод, можно обойтись без них. Но при 20+ колодах они сильно облегчают навигацию.",
            "actionText": "Создайте свою первую категорию:",
            "actions": [
                {"url": "/categories", "label": "Открыть категории"},
            ],
        },
        {
            "emoji": "🎯",
            "color": "linear-gradient(135deg, #14b8a6, #0d9488)",
            "title": "Цели и стрик",
            "sub": "Ставь ежедневные цели и не пропускай дни",
            "intro": "Постоянство важнее интенсивности. Ставьте небольшую ежедневную цель — и через месяц вы будете удивлены прогрессом.",
            "steps": [
                "Откройте <strong>Цели</strong> в меню.",
                "Нажмите <strong>«+ Новая цель»</strong>: например «Решать 20 карточек в день» или «Пройти 1 тест в день».",
                "Цели бывают разных типов: количество карточек, тестов, минут изучения.",
                "Каждый день когда выполняете цель — стрик увеличивается. Если пропустили день — стрик сгорает.",
                "Стрик показывается рядом с вашим именем. Достижения за длинные стрики — в разделе <strong>Достижения</strong>.",
            ],
            "tip": "Лучше маленькая выполнимая цель (10 карточек) которую вы будете делать каждый день, чем большая (100) которую забросите через неделю.",
            "actionText": "Поставьте свою первую цель:",
            "actions": [
                {"url": "/goals", "label": "Цели"},
                {"url": "/achievements", "label": "Достижения"},
            ],
        },
        {
            "emoji": "🏆",
            "color": "linear-gradient(135deg, #ef4444, #dc2626)",
            "title": "Достижения и XP",
            "sub": "Зарабатывай опыт и значки",
            "intro": "За каждое действие на сайте — карточку, тест, выполненную цель — вы получаете <strong>XP</strong> (очки опыта). Накопление XP открывает <strong>достижения</strong>.",
            "steps": [
                "XP начисляется автоматически — за создание колоды, прохождение теста, верный ответ.",
                "Уровень виден рядом с именем (звёздочка ⭐ + число XP).",
                "Достижения открываются при выполнении условий: пройти 10 тестов, получить 100% в одном тесте, держать стрик 7 дней.",
                "В разделе <strong>Достижения</strong> видны открытые и закрытые ачивки с подсказками.",
            ],
            "tip": "Не гонитесь за XP. Это просто индикатор активности. Важно — что вы реально учите, а не сколько XP накопили.",
            "actions": [
                {"url": "/achievements", "label": "Мои достижения"},
            ],
        },
        {
            "emoji": "🎮",
            "color": "linear-gradient(135deg, #06b6d4, #0891b2)",
            "title": "Live-игры",
            "sub": "Сражайтесь в реальном времени",
            "intro": "Live-игра — это режим многопользовательской викторины. Один создаёт игру, остальные подключаются по коду — как Kahoot.",
            "steps": [
                "Чтобы создать игру: откройте колоду и нажмите <strong>«Live»</strong>. Получите 6-значный код.",
                "Передайте код друзьям/одноклассникам — они зайдут в раздел <strong>Live → Подключиться</strong>.",
                "Когда все собрались — начните игру. На каждый вопрос — таймер.",
                "Очки начисляются за правильный ответ + бонус за скорость.",
                "В конце — таблица лидеров. Все Live-игры сохраняются в <strong>Live → История</strong>.",
            ],
            "tip": "Live идеален для уроков и квизов в группах. Создатель видит ответы каждого участника в реальном времени.",
            "actionText": "Запустите Live-игру:",
            "actions": [
                {"url": "/live/join", "label": "Подключиться"},
                {"url": "/dashboard", "label": "Создать (из колоды)"},
            ],
        },
        {
            "emoji": "📊",
            "color": "linear-gradient(135deg, #a855f7, #9333ea)",
            "title": "Статистика и прогресс",
            "sub": "Отслеживай слабые места и рост",
            "intro": "Раздел <strong>Статистика</strong> показывает всё что вы делали: какие колоды, какие тесты, какие карточки знаете лучше всего.",
            "steps": [
                "Откройте <strong>Статистика</strong> в меню.",
                "Графики: карточки в день, среднее время ответа, процент правильных по колодам.",
                "Список <strong>«Самые сложные карточки»</strong> — те, на которых вы чаще всего ошибаетесь. Их стоит повторить.",
                "В <strong>Истории тестов</strong> можно открыть любой пройденный тест и посмотреть детально: какие были вопросы, какие ваши ответы, где ошиблись.",
            ],
            "tip": "Заходите в статистику раз в неделю. Поймёте на чём «зависаете» и подкорректируете план.",
            "actions": [
                {"url": "/stats", "label": "Открыть статистику"},
                {"url": "/test/history", "label": "История тестов"},
            ],
        },
        {
            "emoji": "🌍",
            "color": "linear-gradient(135deg, #84cc16, #65a30d)",
            "title": "Публичные колоды",
            "sub": "Делитесь с другими и используйте чужие",
            "intro": "Любую свою колоду можно сделать <strong>публичной</strong> — её увидят все пользователи QuizAIPro. И наоборот, можно искать чужие колоды по темам.",
            "steps": [
                "Чтобы опубликовать свою колоду — откройте её и нажмите <strong>«Опубликовать»</strong>.",
                "Колоду можно <strong>скопировать</strong> к себе кнопкой клонирования — изменения у вас не повлияют на оригинал.",
                "Поиск публичных колод — главная страница, переключатель «Все колоды».",
                "Можно открыть профиль автора колоды и посмотреть его другие материалы.",
            ],
            "tip": "Хорошие колоды получают много клонирований. Это видно на статистике — мотивация делать качественный контент.",
            "actions": [],
        },
        {
            "emoji": "⚙️",
            "color": "linear-gradient(135deg, #64748b, #475569)",
            "title": "Настройки и профиль",
            "sub": "Язык, тема, приватность",
            "intro": "Все настройки — в правом верхнем углу: аватар → Настройки.",
            "steps": [
                "<strong>Язык:</strong> русский, английский, узбекский. Меняется в любой момент, контент тоже переведётся.",
                "<strong>Тёмная/Светлая тема:</strong> переключатель в шапке (☀️/🌙).",
                "<strong>Приватность профиля:</strong> можно скрыть профиль от других — тогда никто не увидит ваши публичные колоды и статистику.",
                "<strong>Изменить пароль/email</strong> — там же в Настройках.",
            ],
            "tip": "Если не нравится тёмная тема для текстов — переключите на светлую. Сайт полностью адаптирован под обе.",
            "actions": [
                {"url": "/settings", "label": "Открыть настройки"},
            ],
        },
    ],
    "faq": [
        {
            "q": "Сколько стоит QuizAIPro?",
            "a": "QuizAIPro — <strong>бесплатно</strong> для индивидуальных пользователей. Все базовые функции — колоды, тесты, импорт, AI-генерация — доступны без оплаты.",
        },
        {
            "q": "Сохраняются ли мои данные при выходе?",
            "a": "Да, всё сохраняется на серверах. Можете заходить с телефона, планшета и компьютера — увидите одни и те же колоды и прогресс.",
        },
        {
            "q": "Можно ли экспортировать колоду?",
            "a": "Да. На странице колоды есть кнопки экспорта в <strong>Excel</strong>, <strong>PDF</strong> и <strong>JSON</strong>. JSON удобен для переноса в другие приложения.",
        },
        {
            "q": "Что делать если AI-генерация не работает?",
            "a": "Скорее всего у вас закончилась дневная квота на AI. Проверьте лимит в разделе AI. Также возможно временная недоступность — попробуйте через несколько минут.",
        },
        {
            "q": "Как удалить аккаунт?",
            "a": "Напишите в поддержку — мы удалим аккаунт и все ваши данные в течение 24 часов.",
        },
        {
            "q": "Что значит цвет карточки в списке?",
            "a": "🌱 Новая — ещё не отвечали; 📖 Изучаемая — отвечаете правильно иногда; 💪 Сложная — часто ошибаетесь; ✨ Лёгкая — почти всегда правильно; 🎓 Освоенная — стабильно знаете.",
        },
        {
            "q": "Можно ли пройти тест без интернета?",
            "a": "Пока нет. Все тесты требуют подключения к серверу для записи результата в статистику. Оффлайн-режим планируется в будущем.",
        },
        {
            "q": "Чем отличается тест от Flashcards?",
            "a": "<strong>Тест</strong> — это проверка с автоматической оценкой и историей. <strong>Flashcards</strong> — это режим повторения без оценки, для самостоятельного запоминания.",
        },
    ],
}


# ============================================================================
# ENGLISH
# ============================================================================
HELP_EN = {
    "labels": {
        "useful": "Useful to know",
        "try_now": "Try it now",
        "try_now_default": "Open the section and try yourself:",
        "installing": "Creating…",
        "installed": "Done! Redirecting…",
        "error": "Error",
        "unknown": "unknown error",
    },
    "topics": [
        {
            "emoji": "📚",
            "color": "linear-gradient(135deg, #6366f1, #8b5cf6)",
            "title": "Decks and cards",
            "sub": "Create, edit, delete",
            "intro": "A <strong>deck</strong> is a set of cards on one topic. Each <strong>card</strong> contains a question and answer. Everything else builds on this.",
            "steps": [
                "Open <strong>Dashboard</strong> and click <code>+ New Deck</code>. Enter a name and pick an icon (e.g. 📘 for English).",
                "Open the deck and click <code>+ Add Card</code>. A card can be a simple Q&A or MCQ (with 4 options).",
                "To mark the correct option — click on it. It turns green.",
                "Edit cards directly in the list: click the text and change.",
                "Delete a card or deck — <code>×</code> button on the right.",
            ],
            "tip": "You can change the deck icon anytime — click on it in the deck header and enter a new emoji.",
            "actionText": "Create your first deck:",
            "actions": [
                {"url": "/dashboard", "label": "Go to decks"},
            ],
        },
        {
            "emoji": "📥",
            "color": "linear-gradient(135deg, #10b981, #059669)",
            "title": "Import from files",
            "sub": "TXT, DOCX, PDF, Excel — bulk question upload",
            "intro": "If you already have a list of questions — no need to type them one by one. Import the entire deck from a file.",
            "steps": [
                "Open <strong>Import</strong> in the side menu or from a deck.",
                "Choose format: <code>.txt</code> and <code>.csv</code> for simple tests; <code>.docx</code> and <code>.pdf</code> for documents; <code>.xlsx</code> for tables.",
                "Download a <strong>sample file</strong> in your format — you'll see the structure (question, options, correct answer).",
                "Upload your file — the system detects format and creates the deck automatically.",
                "For PDFs without clear structure, use <strong>AI Vision</strong> mode — it extracts questions from images and scans.",
            ],
            "tip": "For PDFs use AI Vision when document is a scan or has complex layout. Slower but more accurate.",
            "actionText": "Upload your first file:",
            "actions": [
                {"url": "/import", "label": "Open Import"},
            ],
        },
        {
            "emoji": "🤖",
            "color": "linear-gradient(135deg, #f59e0b, #f97316)",
            "title": "AI question generation",
            "sub": "Builds a deck from a topic in a minute",
            "intro": "Don't want to write questions manually? AI does it for you — just describe the topic.",
            "steps": [
                "Open <strong>AI</strong> in the menu.",
                "Enter a topic: e.g. <em>«Irregular verbs in English»</em> or <em>«World War II, 1939-1945»</em>.",
                "Choose the number of questions (5-50), difficulty level, and language.",
                "For MCQ test — leave <strong>«with options»</strong>. For flashcards — pick <strong>«terms»</strong>.",
                "Click <strong>«Generate»</strong>. AI creates a complete deck in 20-60 seconds.",
            ],
            "tip": "The more specific the topic, the more relevant the questions. You can specify grade, textbook, era, region.",
            "actionText": "Try AI generation:",
            "actions": [
                {"url": "/ai", "label": "Open AI generation"},
            ],
        },
        {
            "emoji": "📝",
            "color": "linear-gradient(135deg, #3b82f6, #2563eb)",
            "title": "Tests",
            "sub": "Check knowledge and track progress",
            "intro": "A test is a random selection of cards with a fixed time. Fastest way to check what you remember.",
            "steps": [
                "Open a deck and click <strong>«Test»</strong>.",
                "Choose the number of questions (10/25/50/100) and whether to shuffle.",
                "You can enable <strong>«Hard only»</strong> mode — only cards with low correctness percent.",
                "During the test, pick answers. After — see how many correct/incorrect, which cards to review.",
                "All tests are saved in <strong>Test History</strong> — you can revisit and see the questions and your answers.",
            ],
            "tip": "The <strong>📊 History</strong> button on the deck page shows all your runs of THIS deck — with time and percent.",
            "actionText": "View your test history:",
            "actions": [
                {"url": "/test/history", "label": "Test history"},
                {"url": "/dashboard", "label": "Start a test"},
            ],
        },
        {
            "emoji": "🃏",
            "color": "linear-gradient(135deg, #ec4899, #be185d)",
            "title": "Flashcards and Match",
            "sub": "Flip cards and pair-matching game",
            "intro": "For dictionaries and terms there are two special modes — no answer options.",
            "steps": [
                "<strong>Flashcards (flip cards):</strong> in a «terms» deck click the corresponding button. Card shows a term, you recall the definition and flip.",
                "Mark «I know» or «need review» — system remembers and shows weak cards first next time.",
                "<strong>Match (pairing game):</strong> terms and definitions appear shuffled on screen. Connect pairs as fast as possible.",
                "Match tracks time — compete with yourself or classmates.",
                "To create a «terms» deck — pick type <strong>«Words and definitions»</strong> when creating.",
            ],
            "tip": "Flashcards are perfect for foreign languages and definitions. Match is better for review before an exam, when you already know the basics.",
            "actions": [],
        },
        {
            "emoji": "📁",
            "color": "linear-gradient(135deg, #8b5cf6, #6d28d9)",
            "title": "Categories",
            "sub": "Group decks by topic or subject",
            "intro": "When you have many decks, categories help organize. Create <strong>«English»</strong>, <strong>«History»</strong>, <strong>«Math»</strong> and sort decks accordingly.",
            "steps": [
                "Open <strong>Categories</strong> in the menu.",
                "Click <strong>«+ Category»</strong>, enter a name, pick an icon.",
                "You can create <strong>subcategories</strong> — e.g. inside «English» make «Grammar» and «Vocabulary».",
                "When creating or editing a deck — pick the appropriate category.",
                "On the dashboard decks are grouped by category. You can filter.",
            ],
            "tip": "Categories are optional. With 3-5 decks you can skip them. But with 20+ decks they make navigation much easier.",
            "actionText": "Create your first category:",
            "actions": [
                {"url": "/categories", "label": "Open categories"},
            ],
        },
        {
            "emoji": "🎯",
            "color": "linear-gradient(135deg, #14b8a6, #0d9488)",
            "title": "Goals and streak",
            "sub": "Set daily goals and don't skip days",
            "intro": "Consistency beats intensity. Set a small daily goal — in a month you'll be amazed at the progress.",
            "steps": [
                "Open <strong>Goals</strong> in the menu.",
                "Click <strong>«+ New Goal»</strong>: e.g. «Solve 20 cards a day» or «Pass 1 test a day».",
                "Goals come in types: cards count, tests, study minutes.",
                "Every day you complete the goal — streak grows. Skip a day — streak resets.",
                "Streak is shown next to your name. Achievements for long streaks — in <strong>Achievements</strong>.",
            ],
            "tip": "Better a small achievable goal (10 cards) you do daily, than a big one (100) you abandon in a week.",
            "actionText": "Set your first goal:",
            "actions": [
                {"url": "/goals", "label": "Goals"},
                {"url": "/achievements", "label": "Achievements"},
            ],
        },
        {
            "emoji": "🏆",
            "color": "linear-gradient(135deg, #ef4444, #dc2626)",
            "title": "Achievements and XP",
            "sub": "Earn experience and badges",
            "intro": "For every action — card, test, completed goal — you earn <strong>XP</strong>. XP unlocks <strong>achievements</strong>.",
            "steps": [
                "XP is awarded automatically — for creating a deck, finishing a test, correct answers.",
                "Level shown next to your name (⭐ + XP number).",
                "Achievements unlock at conditions: pass 10 tests, score 100% on one test, hold 7-day streak.",
                "<strong>Achievements</strong> shows unlocked and locked badges with hints.",
            ],
            "tip": "Don't chase XP. It's just an activity indicator. What matters is what you really learn.",
            "actions": [
                {"url": "/achievements", "label": "My achievements"},
            ],
        },
        {
            "emoji": "🎮",
            "color": "linear-gradient(135deg, #06b6d4, #0891b2)",
            "title": "Live games",
            "sub": "Real-time multiplayer quizzes",
            "intro": "Live game is a multiplayer quiz mode. One creates the game, others join by code — like Kahoot.",
            "steps": [
                "To create: open a deck and click <strong>«Live»</strong>. Get a 6-digit code.",
                "Share the code with friends/classmates — they join via <strong>Live → Connect</strong>.",
                "When everyone's in — start. Each question has a timer.",
                "Points awarded for correct answer + speed bonus.",
                "At the end — leaderboard. All Live games saved in <strong>Live → History</strong>.",
            ],
            "tip": "Live is great for classes and group quizzes. The host sees each participant's answers in real time.",
            "actionText": "Start a Live game:",
            "actions": [
                {"url": "/live/join", "label": "Connect"},
                {"url": "/dashboard", "label": "Create (from a deck)"},
            ],
        },
        {
            "emoji": "📊",
            "color": "linear-gradient(135deg, #a855f7, #9333ea)",
            "title": "Stats and progress",
            "sub": "Track weak spots and growth",
            "intro": "<strong>Stats</strong> shows everything you've done: which decks, which tests, which cards you know best.",
            "steps": [
                "Open <strong>Stats</strong> in the menu.",
                "Charts: cards per day, average answer time, correctness % per deck.",
                "<strong>«Hardest cards»</strong> list — those you fail most often. Worth reviewing.",
                "In <strong>Test History</strong> you can open any test and see in detail: questions, your answers, where you went wrong.",
            ],
            "tip": "Check stats once a week. Spot what you're stuck on and adjust your plan.",
            "actions": [
                {"url": "/stats", "label": "Open stats"},
                {"url": "/test/history", "label": "Test history"},
            ],
        },
        {
            "emoji": "🌍",
            "color": "linear-gradient(135deg, #84cc16, #65a30d)",
            "title": "Public decks",
            "sub": "Share with others and use theirs",
            "intro": "Any of your decks can be made <strong>public</strong> — everyone on QuizAIPro will see it. And you can search public decks by topic.",
            "steps": [
                "To publish: open the deck and click <strong>«Publish»</strong>.",
                "A deck can be <strong>cloned</strong> with the clone button — your edits won't affect the original.",
                "Search public decks — dashboard, «All decks» toggle.",
                "You can open the author's profile and see their other materials.",
            ],
            "tip": "Good decks get many clones. Visible in stats — motivation to make quality content.",
            "actions": [],
        },
        {
            "emoji": "⚙️",
            "color": "linear-gradient(135deg, #64748b, #475569)",
            "title": "Settings and profile",
            "sub": "Language, theme, privacy",
            "intro": "All settings — top right: avatar → Settings.",
            "steps": [
                "<strong>Language:</strong> Russian, English, Uzbek. Switch anytime, content gets translated.",
                "<strong>Dark/Light theme:</strong> toggle in the header (☀️/🌙).",
                "<strong>Profile privacy:</strong> hide your profile from others — nobody sees your public decks or stats.",
                "<strong>Change password/email</strong> — same Settings.",
            ],
            "tip": "If you don't like dark theme for reading — switch to light. The site is fully adapted to both.",
            "actions": [
                {"url": "/settings", "label": "Open settings"},
            ],
        },
    ],
    "faq": [
        {
            "q": "How much does QuizAIPro cost?",
            "a": "QuizAIPro is <strong>free</strong> for individual users. All core features — decks, tests, import, AI generation — work without payment.",
        },
        {
            "q": "Is my data saved when I log out?",
            "a": "Yes, everything is saved on the servers. You can sign in from phone, tablet, or computer — same decks and progress.",
        },
        {
            "q": "Can I export a deck?",
            "a": "Yes. On the deck page — buttons for <strong>Excel</strong>, <strong>PDF</strong>, <strong>JSON</strong> export. JSON is convenient for transfer to other apps.",
        },
        {
            "q": "What if AI generation isn't working?",
            "a": "Most likely you've hit your daily AI quota. Check the limit in the AI section. Could also be a temporary outage — retry in a few minutes.",
        },
        {
            "q": "How do I delete my account?",
            "a": "Contact support — we'll delete the account and all your data within 24 hours.",
        },
        {
            "q": "What does the card color mean in the list?",
            "a": "🌱 New — not answered yet; 📖 Learning — sometimes correct; 💪 Hard — often wrong; ✨ Easy — almost always right; 🎓 Mastered — solid.",
        },
        {
            "q": "Can I take a test offline?",
            "a": "Not yet. All tests require server connection to log results into stats. Offline mode is planned for the future.",
        },
        {
            "q": "How is a Test different from Flashcards?",
            "a": "<strong>Test</strong> is graded with history. <strong>Flashcards</strong> is a no-grade review mode for self-paced memorization.",
        },
    ],
}


# ============================================================================
# UZBEK
# ============================================================================
HELP_UZ = {
    "labels": {
        "useful": "Bilish foydali",
        "try_now": "Hoziroq sinab ko'ring",
        "try_now_default": "Bo'limni oching va o'zingiz sinab ko'ring:",
        "installing": "Yaratilmoqda…",
        "installed": "Tayyor! Yo'naltirilmoqda…",
        "error": "Xato",
        "unknown": "noma'lum xato",
    },
    "topics": [
        {
            "emoji": "📚",
            "color": "linear-gradient(135deg, #6366f1, #8b5cf6)",
            "title": "Kolodalar va kartalar",
            "sub": "Yaratish, tahrirlash, o'chirish",
            "intro": "<strong>Koloda</strong> — bir mavzudagi kartalar to'plami. Har bir <strong>karta</strong> savol va javobni o'z ichiga oladi. Hamma narsa shu yerdan boshlanadi.",
            "steps": [
                "<strong>Bosh sahifa</strong> ni oching va <code>+ Yangi koloda</code> ni bosing. Nom va ikonkani tanlang (masalan ingliz tili uchun 📘).",
                "Yaratilgan kolodaga kiring va <code>+ Karta qo'shish</code> ni bosing. Karta oddiy savol-javob yoki 4 variantli MCQ bo'lishi mumkin.",
                "To'g'ri variantni belgilash uchun ustiga bosing. U yashil rangda yoritiladi.",
                "Kartalarni ro'yxatdan to'g'ridan-to'g'ri tahrirlash mumkin: matnga bosing va o'zgartiring.",
                "Karta yoki kolodani o'chirish — o'ngdagi <code>×</code> tugmasi orqali.",
            ],
            "tip": "Koloda ikonkasini istalgan vaqt o'zgartirish mumkin — koloda sarlavhasidagi ikonkaga bosing va yangi emoji kiriting.",
            "actionText": "Birinchi kolodangizni yarating:",
            "actions": [
                {"url": "/dashboard", "label": "Kolodalarga o'tish"},
            ],
        },
        {
            "emoji": "📥",
            "color": "linear-gradient(135deg, #10b981, #059669)",
            "title": "Fayldan import",
            "sub": "TXT, DOCX, PDF, Excel — savollarni ommaviy yuklash",
            "intro": "Tayyor savollar ro'yxati bo'lsa — birma-bir kiritish shart emas. Butun kolodani fayldan import qiling.",
            "steps": [
                "Yon menyudan yoki kolodadan <strong>Import</strong> ni oching.",
                "Formatni tanlang: oddiy testlar uchun <code>.txt</code> va <code>.csv</code>; hujjatlar uchun <code>.docx</code> va <code>.pdf</code>; jadvallar uchun <code>.xlsx</code>.",
                "Kerakli formatdagi <strong>namuna fayl</strong> ni yuklab oling — strukturani ko'rasiz (savol, variantlar, to'g'ri javob).",
                "Faylingizni yuklang — tizim formatni aniqlaydi va kolodani avtomatik yaratadi.",
                "Aniq tuzilmasiz PDF lar uchun <strong>AI Vision</strong> rejimi bor — neyron tarmoq rasmlar va skanlardan savollarni ajratib oladi.",
            ],
            "tip": "Hujjat skan bo'lsa yoki murakkab tuzilishi bo'lsa — PDF uchun AI Vision dan foydalaning. Sekin lekin aniqroq.",
            "actionText": "Birinchi faylni yuklang:",
            "actions": [
                {"url": "/import", "label": "Importni ochish"},
            ],
        },
        {
            "emoji": "🤖",
            "color": "linear-gradient(135deg, #f59e0b, #f97316)",
            "title": "AI savol generatsiyasi",
            "sub": "Bir mavzudan koloda 1 daqiqada",
            "intro": "Savollarni qo'lda yozishni xohlamaysizmi? AI buni siz uchun bajaradi — faqat mavzuni ta'riflang.",
            "steps": [
                "Menyudan <strong>AI</strong> bo'limini oching.",
                "Mavzu kiriting: masalan <em>«Ingliz tilidagi tartibsiz fe'llar»</em> yoki <em>«Ikkinchi jahon urushi, 1939-1945»</em>.",
                "Savollar sonini (5 dan 50 gacha), qiyinlik darajasini va tilni tanlang.",
                "MCQ-test xohlasangiz — <strong>«variantlar bilan»</strong> rejimini qoldiring. Flashcards uchun — <strong>«atamalar»</strong> ni tanlang.",
                "<strong>«Generatsiya»</strong> ni bosing. AI tayyor kolodani 20-60 soniyada yaratadi.",
            ],
            "tip": "Mavzuni qanchalik aniq ta'riflasangiz — savollar shunchalik mos bo'ladi. Sinf dasturi, darslik, davr, mintaqa ko'rsatish mumkin.",
            "actionText": "AI-generatsiyani sinab ko'ring:",
            "actions": [
                {"url": "/ai", "label": "AI-generatsiyani ochish"},
            ],
        },
        {
            "emoji": "📝",
            "color": "linear-gradient(135deg, #3b82f6, #2563eb)",
            "title": "Testlar",
            "sub": "Bilimni tekshiring va taraqqiyotni kuzating",
            "intro": "Test — belgilangan vaqt bilan kartalarning tasodifiy tanlovi. Eslab qolganingizni tekshirishning eng tez yo'li.",
            "steps": [
                "Kolodani oching va <strong>«Test»</strong> tugmasini bosing.",
                "Savollar sonini (10/25/50/100) va aralashtirish kerakligini tanlang.",
                "<strong>«Faqat qiyinlari»</strong> rejimini yoqishingiz mumkin — to'g'ri javoblar foizi past kartalar.",
                "Test paytida javoblarni tanlang. Testdan keyin — qanchasi to'g'ri/noto'g'ri va qaysi kartalarni takrorlash kerakligini ko'rasiz.",
                "Barcha testlar <strong>Test tarixi</strong> da saqlanadi — qaytib borib qanday savollar va javoblar bo'lganini ko'rishingiz mumkin.",
            ],
            "tip": "Koloda sahifasidagi <strong>📊 Tarix</strong> tugmasi MA'LUM SHU kolodaning barcha o'tishlarini ko'rsatadi — vaqt va foiz bilan.",
            "actionText": "Test tarixini ko'ring:",
            "actions": [
                {"url": "/test/history", "label": "Test tarixi"},
                {"url": "/dashboard", "label": "Testni boshlash"},
            ],
        },
        {
            "emoji": "🃏",
            "color": "linear-gradient(135deg, #ec4899, #be185d)",
            "title": "Flashcards va Match",
            "sub": "Aylantiriladigan kartalar va juftlik o'yini",
            "intro": "Lug'atlar va atamalar uchun ikki maxsus rejim bor — javob variantsiz.",
            "steps": [
                "<strong>Flashcards (aylantiriladigan kartalar):</strong> «atamalar» turidagi kolodada tegishli tugmani bosing. Karta atamani ko'rsatadi, siz ta'rifni eslab aylantirasiz.",
                "«Bilaman» yoki «takrorlash kerak» deb belgilang — tizim eslab qoladi va keyingi safar yomon eslaydiganlarini birinchi ko'rsatadi.",
                "<strong>Match (juftlik o'yini):</strong> ekranda atamalar va ta'riflar aralash chiqadi. Iloji boricha tezroq juftlash kerak.",
                "Match vaqtni kuzatadi — o'zingiz bilan yoki sinfdoshlar bilan musobaqalashing.",
                "«Atamalar» turidagi koloda yaratish uchun — yaratishda <strong>«So'zlar va ta'riflar»</strong> turini tanlang.",
            ],
            "tip": "Flashcards chet tillar va ta'riflar uchun ideal. Match — imtihondan oldin takrorlash uchun yaxshiroq, asosini bilganingizda.",
            "actions": [],
        },
        {
            "emoji": "📁",
            "color": "linear-gradient(135deg, #8b5cf6, #6d28d9)",
            "title": "Kategoriyalar",
            "sub": "Kolodalarni mavzu yoki fan bo'yicha guruhlash",
            "intro": "Kolodalar ko'payganda — kategoriyalar tartibga solishga yordam beradi. <strong>«Ingliz tili»</strong>, <strong>«Tarix»</strong>, <strong>«Matematika»</strong> yaratib, kolodalarni shularga ajrating.",
            "steps": [
                "Menyudan <strong>Kategoriyalar</strong> ni oching.",
                "<strong>«+ Kategoriya»</strong> ni bosing, nom va ikonkani tanlang.",
                "<strong>Subkategoriyalar</strong> yaratish mumkin — masalan «Ingliz tili» ichida «Grammatika» va «Lug'at».",
                "Koloda yaratishda yoki tahrirlashda — mos kategoriyani tanlang.",
                "Bosh sahifada kolodalar kategoriyalar bo'yicha guruhlanadi. Filtrlash mumkin.",
            ],
            "tip": "Kategoriyalar ixtiyoriy. 3-5 ta koloda bo'lsa, ularsiz ham bo'ladi. Lekin 20+ koloda bo'lsa — navigatsiyani sezilarli darajada osonlashtiradi.",
            "actionText": "Birinchi kategoriyani yarating:",
            "actions": [
                {"url": "/categories", "label": "Kategoriyalarni ochish"},
            ],
        },
        {
            "emoji": "🎯",
            "color": "linear-gradient(135deg, #14b8a6, #0d9488)",
            "title": "Maqsadlar va seriya",
            "sub": "Kunlik maqsad qo'ying va kunlarni o'tkazib yubormang",
            "intro": "Doimiylik intensivlikdan muhim. Kichik kunlik maqsad qo'ying — bir oydan keyin taraqqiyotdan hayron bo'lasiz.",
            "steps": [
                "Menyudan <strong>Maqsadlar</strong> ni oching.",
                "<strong>«+ Yangi maqsad»</strong> ni bosing: masalan «Kuniga 20 ta karta yechish» yoki «Kuniga 1 ta test o'tish».",
                "Maqsadlar turli xil: kartalar soni, testlar, o'qish daqiqalari.",
                "Maqsadni bajargan har bir kun — seriya o'sadi. Kun o'tkazsangiz — seriya nolga tushadi.",
                "Seriya ismingiz yonida ko'rsatiladi. Uzun seriyalar uchun yutuqlar — <strong>Yutuqlar</strong> bo'limida.",
            ],
            "tip": "Bir hafta ichida tashlab qo'yiladigan katta (100) maqsaddan ko'ra, har kuni qiladigan kichik bajariladigan (10 ta karta) maqsad yaxshiroq.",
            "actionText": "Birinchi maqsadingizni qo'ying:",
            "actions": [
                {"url": "/goals", "label": "Maqsadlar"},
                {"url": "/achievements", "label": "Yutuqlar"},
            ],
        },
        {
            "emoji": "🏆",
            "color": "linear-gradient(135deg, #ef4444, #dc2626)",
            "title": "Yutuqlar va XP",
            "sub": "Tajriba va belgilarni qo'lga kiriting",
            "intro": "Saytdagi har bir harakat uchun — karta, test, bajarilgan maqsad — siz <strong>XP</strong> (tajriba ballari) olasiz. XP to'plash <strong>yutuqlarni</strong> ochadi.",
            "steps": [
                "XP avtomatik beriladi — koloda yaratish, testdan o'tish, to'g'ri javob uchun.",
                "Daraja ism yonida ko'rinadi (yulduzcha ⭐ + XP raqami).",
                "Yutuqlar shartlar bajarilganda ochiladi: 10 testdan o'tish, bitta testda 100% olish, 7 kun seriya saqlash.",
                "<strong>Yutuqlar</strong> bo'limida ochilgan va yopiq yutuqlar maslahatlar bilan ko'rinadi.",
            ],
            "tip": "XP ortidan quvib yurmang. Bu shunchaki faollik ko'rsatkichi. Muhimi — siz haqiqatan nima o'rganganingiz, qancha XP to'plaganingiz emas.",
            "actions": [
                {"url": "/achievements", "label": "Yutuqlarim"},
            ],
        },
        {
            "emoji": "🎮",
            "color": "linear-gradient(135deg, #06b6d4, #0891b2)",
            "title": "Live-o'yinlar",
            "sub": "Real vaqtda kurashing",
            "intro": "Live-o'yin — bu ko'p o'yinchili viktorina rejimi. Bittasi o'yin yaratadi, qolganlari kod orqali qo'shiladi — Kahoot kabi.",
            "steps": [
                "O'yin yaratish uchun: kolodani oching va <strong>«Live»</strong> ni bosing. 6-raqamli kod oling.",
                "Kodni do'stlar/sinfdoshlarga bering — ular <strong>Live → Qo'shilish</strong> bo'limidan kiradilar.",
                "Hamma yig'ilganda — o'yinni boshlang. Har savolda — taymer.",
                "To'g'ri javob uchun + tezlik bonusi uchun ballar.",
                "Oxirida — yetakchilar jadvali. Barcha Live-o'yinlar <strong>Live → Tarix</strong> da saqlanadi.",
            ],
            "tip": "Live darslar va guruh viktoralari uchun ideal. Yaratuvchi har ishtirokchining javoblarini real vaqtda ko'radi.",
            "actionText": "Live-o'yinni boshlang:",
            "actions": [
                {"url": "/live/join", "label": "Qo'shilish"},
                {"url": "/dashboard", "label": "Yaratish (kolodadan)"},
            ],
        },
        {
            "emoji": "📊",
            "color": "linear-gradient(135deg, #a855f7, #9333ea)",
            "title": "Statistika va taraqqiyot",
            "sub": "Zaif joylarni va o'sishni kuzating",
            "intro": "<strong>Statistika</strong> bo'limi qilgan hamma narsangizni ko'rsatadi: qaysi kolodalar, qaysi testlar, qaysi kartalarni yaxshi bilasiz.",
            "steps": [
                "Menyudan <strong>Statistika</strong> ni oching.",
                "Grafiklar: kuniga kartalar, o'rtacha javob vaqti, kolodalar bo'yicha to'g'rilik foizi.",
                "<strong>«Eng qiyin kartalar»</strong> ro'yxati — eng ko'p adashadiganlaringiz. Takrorlashga arziydi.",
                "<strong>Test tarixi</strong> da har qanday o'tkan testni ochib, batafsil ko'rishingiz mumkin: qanday savollar, javoblaringiz, qayerda adashganingiz.",
            ],
            "tip": "Statistikani haftada bir marta tekshiring. Qayerda «to'xtab qolayotganingizni» tushunasiz va rejani sozlaysiz.",
            "actions": [
                {"url": "/stats", "label": "Statistikani ochish"},
                {"url": "/test/history", "label": "Test tarixi"},
            ],
        },
        {
            "emoji": "🌍",
            "color": "linear-gradient(135deg, #84cc16, #65a30d)",
            "title": "Ommaviy kolodalar",
            "sub": "Boshqalar bilan ulashing va o'zgalarnikidan foydalaning",
            "intro": "Har qanday kolodangizni <strong>ommaviy</strong> qilish mumkin — uni QuizAIPro dagi barcha foydalanuvchilar ko'radi. Va boshqalarning kolodalarini mavzular bo'yicha qidirish mumkin.",
            "steps": [
                "O'z kolodangizni nashr qilish uchun — uni oching va <strong>«Nashr qilish»</strong> ni bosing.",
                "Kolodani <strong>klonlash</strong> tugmasi bilan o'zingizga ko'chirish mumkin — sizdagi o'zgarishlar asl nusxaga ta'sir qilmaydi.",
                "Ommaviy kolodalarni qidirish — bosh sahifa, «Hamma kolodalar» o'tkazgichi.",
                "Koloda muallifining profilini ochib, uning boshqa materiallarini ko'rishingiz mumkin.",
            ],
            "tip": "Yaxshi kolodalar ko'p marta klonlashtiriladi. Bu statistikada ko'rinadi — sifatli kontent yaratish uchun motivatsiya.",
            "actions": [],
        },
        {
            "emoji": "⚙️",
            "color": "linear-gradient(135deg, #64748b, #475569)",
            "title": "Sozlamalar va profil",
            "sub": "Til, mavzu, maxfiylik",
            "intro": "Barcha sozlamalar — yuqori o'ng burchakda: avatar → Sozlamalar.",
            "steps": [
                "<strong>Til:</strong> rus, ingliz, o'zbek. Istalgan vaqt o'zgartiriladi, kontent ham tarjima qilinadi.",
                "<strong>Qora/Yorug' mavzu:</strong> sarlavhadagi o'tkazgich (☀️/🌙).",
                "<strong>Profil maxfiyligi:</strong> profilingizni boshqalardan yashirishingiz mumkin — hech kim sizning ommaviy kolodalaringiz va statistikangizni ko'rmaydi.",
                "<strong>Parolni/email ni o'zgartirish</strong> — o'sha sozlamalarda.",
            ],
            "tip": "Qora mavzu o'qish uchun yoqmasa — yorug'iga o'ting. Sayt ikkalasiga ham to'liq moslashgan.",
            "actions": [
                {"url": "/settings", "label": "Sozlamalarni ochish"},
            ],
        },
    ],
    "faq": [
        {
            "q": "QuizAIPro qancha turadi?",
            "a": "QuizAIPro yakka foydalanuvchilar uchun <strong>bepul</strong>. Barcha asosiy funksiyalar — kolodalar, testlar, import, AI-generatsiya — to'lovsiz mavjud.",
        },
        {
            "q": "Chiqib ketganda ma'lumotlarim saqlanadimi?",
            "a": "Ha, hammasi serverlarda saqlanadi. Telefon, planshet, kompyuterdan kirsangiz — bir xil kolodalar va taraqqiyotni ko'rasiz.",
        },
        {
            "q": "Kolodani eksport qilish mumkinmi?",
            "a": "Ha. Koloda sahifasida <strong>Excel</strong>, <strong>PDF</strong> va <strong>JSON</strong> ga eksport tugmalari bor. JSON boshqa ilovalarga o'tkazish uchun qulay.",
        },
        {
            "q": "AI-generatsiya ishlamasa nima qilish kerak?",
            "a": "Ehtimol AI uchun kunlik kvotangiz tugagan. AI bo'limida limitni tekshiring. Vaqtincha ishlamaslik ham bo'lishi mumkin — bir necha daqiqadan keyin urinib ko'ring.",
        },
        {
            "q": "Akkauntni qanday o'chirish?",
            "a": "Qo'llab-quvvatlashga yozing — biz akkaunt va ma'lumotlarning hammasini 24 soat ichida o'chiramiz.",
        },
        {
            "q": "Ro'yxatdagi karta rangi nimani anglatadi?",
            "a": "🌱 Yangi — hali javob bermagan; 📖 O'rganilayotgan — ba'zan to'g'ri; 💪 Qiyin — tez-tez adashasiz; ✨ Yengil — deyarli har doim to'g'ri; 🎓 O'zlashtirilgan — barqaror bilim.",
        },
        {
            "q": "Internetsiz testdan o'tish mumkinmi?",
            "a": "Hozir yo'q. Barcha testlar natijani statistikaga yozish uchun server bilan ulanishni talab qiladi. Oflayn rejim kelajakda rejalashtirilgan.",
        },
        {
            "q": "Test va Flashcards bir-biridan qanday farq qiladi?",
            "a": "<strong>Test</strong> — avtomatik baholash va tarix bilan tekshiruv. <strong>Flashcards</strong> — baholashisiz takrorlash rejimi, mustaqil eslab qolish uchun.",
        },
    ],
}


# ============================================================================
# Public API
# ============================================================================

def get(lang: str) -> dict:
    """Возвращает help-данные на нужном языке (fallback на RU)."""
    if lang == "en":
        return HELP_EN
    if lang == "uz":
        return HELP_UZ
    return HELP_RU
