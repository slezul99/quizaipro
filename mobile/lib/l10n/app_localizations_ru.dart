// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'QuizAIPro';

  @override
  String get loading => 'Загрузка...';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get back => 'Назад';

  @override
  String get done => 'Готово';

  @override
  String get next => 'Далее';

  @override
  String get skip => 'Пропустить';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errorNetwork => 'Нет подключения к интернету.';

  @override
  String get errorUnauthorized => 'Сессия истекла. Войдите снова.';

  @override
  String get errorRateLimited => 'Слишком много запросов. Подождите немного.';

  @override
  String get authWelcomeTitle => 'Учись умнее с AI';

  @override
  String get authWelcomeSubtitle =>
      'AI-карточки, которые адаптируются под тебя.';

  @override
  String get authLogin => 'Войти';

  @override
  String get authRegister => 'Создать аккаунт';

  @override
  String get authContinueWithGoogle => 'Войти через Google';

  @override
  String get authContinueWithApple => 'Войти через Apple';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authLogout => 'Выйти';

  @override
  String get authLoginTitle => 'С возвращением';

  @override
  String get authLoginSubtitle => 'Войдите, чтобы продолжить обучение';

  @override
  String get authRegisterTitle => 'Создать аккаунт';

  @override
  String get authRegisterSubtitle => 'Начните путь с AI-обучением';

  @override
  String get authUsername => 'Имя пользователя';

  @override
  String get authUsernamePlaceholder => 'ваш_ник';

  @override
  String get authEmailPlaceholder => 'ваш@email.com';

  @override
  String get authIdentifier => 'Email или логин';

  @override
  String get authIdentifierPlaceholder => 'email или имя пользователя';

  @override
  String get authPasswordPlaceholder => 'Не менее 8 символов';

  @override
  String get authConfirmPassword => 'Подтвердите пароль';

  @override
  String get authConfirmPasswordPlaceholder => 'Повторите пароль';

  @override
  String get authPasswordHintLogin => 'Ваш пароль';

  @override
  String get authConfirmPasswordRequired => 'Пожалуйста, подтвердите пароль';

  @override
  String get authGetStarted => 'Начать';

  @override
  String get authAlreadyHaveAccount => 'У меня уже есть аккаунт';

  @override
  String get authOrContinueWith => 'или продолжить через';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authNoAccount => 'Нет аккаунта? ';

  @override
  String get authSignUp => 'Зарегистрироваться';

  @override
  String get authHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get authSignInLink => 'Войти';

  @override
  String get authTermsNotice =>
      'Создавая аккаунт, вы соглашаетесь с\nПользовательским соглашением и Политикой конфиденциальности.';

  @override
  String get authPasswordStrengthWeak => 'Слабый';

  @override
  String get authPasswordStrengthFair => 'Средний';

  @override
  String get authPasswordStrengthStrong => 'Надёжный';

  @override
  String get authPasswordStrengthVeryStrong => 'Очень надёжный';

  @override
  String validationRequired(String field) {
    return 'Поле «$field» обязательно';
  }

  @override
  String get validationEmail => 'Введите корректный email';

  @override
  String get validationPasswordMin =>
      'Пароль должен содержать не менее 8 символов';

  @override
  String get validationPasswordsNoMatch => 'Пароли не совпадают';

  @override
  String get validationUsernameMin =>
      'Имя пользователя должно содержать не менее 3 символов';

  @override
  String get validationUsernameMax =>
      'Имя пользователя должно содержать не более 20 символов';

  @override
  String get validationUsernameChars =>
      'Только буквы, цифры и нижнее подчёркивание';

  @override
  String get errorUnexpected => 'Произошла непредвиденная ошибка.';

  @override
  String get navHome => 'Главная';

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navDiscover => 'Маркет';

  @override
  String get navArena => 'Арена';

  @override
  String get navProfile => 'Профиль';

  @override
  String get arenaComingSoon => 'Арена — скоро появится';

  @override
  String get profileComingSoon => 'Профиль — скоро появится';

  @override
  String get homeComingSoon => 'Главная — скоро появится';

  @override
  String get discoverTitle => 'Обзор';

  @override
  String get discoverComingSoon => 'Обзор — скоро появится';

  @override
  String get duelComingSoon => 'Дуэль — скоро появится';

  @override
  String get liveTestComingSoon => 'Живой тест — скоро появится';

  @override
  String get notificationsComingSoon => 'Уведомления — скоро появятся';

  @override
  String homeStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Серия $countString дн.';
  }

  @override
  String get dashboardStreakDay => 'дн. серия';

  @override
  String dashboardStreakBest(int count) {
    return 'Рекорд: $count дн.';
  }

  @override
  String get dashboardStreakToday => 'Сегодня';

  @override
  String get dashboardStreakDone => 'Готово!';

  @override
  String dashboardCardsLeft(int count) {
    return 'осталось $count шт.';
  }

  @override
  String homeDueCards(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString карточек к повторению';
  }

  @override
  String get studyStart => 'Начать учёбу';

  @override
  String studyCardOf(int current, int total) {
    return '$current из $total';
  }

  @override
  String get tutorAskPlaceholder => 'Спроси что угодно по теме колоды...';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsDailyGoal => 'Дневная цель';

  @override
  String settingsDailyGoalCards(int count) {
    return '$count карточек / день';
  }

  @override
  String get dashboardGreetingMorning => 'Доброе утро,';

  @override
  String get dashboardGreetingAfternoon => 'Добрый день,';

  @override
  String get dashboardGreetingEvening => 'Добрый вечер,';

  @override
  String get dashboardDailyGoal => 'Дневная цель';

  @override
  String get dashboardDailyGoalCompleted => 'Цель достигнута!';

  @override
  String get dashboardRetention => 'Удержание';

  @override
  String get dashboardRetentionForecast => 'через неделю';

  @override
  String get dashboardRetentionFading => 'остывают';

  @override
  String get dashboardReadyToStudy => 'Готово к изучению';

  @override
  String get dashboardAllCaughtUp => 'Все карточки изучены! 🎉';

  @override
  String dashboardXpLabel(int xp) {
    return '$xp XP';
  }

  @override
  String dashboardXpToNextLevel(int xp, int nextLevel) {
    return '$xp XP до уровня $nextLevel';
  }

  @override
  String dashboardLevelBadge(int level) {
    return 'Ур$level';
  }

  @override
  String get dashboardOverdue => 'просрочено';

  @override
  String get dashboardStartStudying => 'Начать';

  @override
  String get dashboardQuickActions => 'Быстрые действия';

  @override
  String get dashboardActionStudy => 'Учить';

  @override
  String get dashboardActionDiscover => 'Маркет';

  @override
  String get dashboardActionAiTutor => 'Тьютор';

  @override
  String get dashboardActionAiStudio => 'Студия';

  @override
  String get dashboardRecentActivity => 'Недавняя активность';

  @override
  String get dashboardActivityEmpty =>
      'Активности пока нет. Начните учиться, чтобы видеть прогресс!';

  @override
  String dashboardActivitySummary(int count, String time) {
    return '$count шт. · $time';
  }

  @override
  String dashboardTimeAgoMinutes(int minutes) {
    return '$minutes мин назад';
  }

  @override
  String dashboardTimeAgoHours(int hours) {
    return '$hours ч назад';
  }

  @override
  String dashboardTimeAgoDays(int days) {
    return '$days дн назад';
  }

  @override
  String dashboardXpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get dashboardActivityTypeStudy => 'Изучение карточек';

  @override
  String get dashboardActivityTypeTest => 'Тест пройден';

  @override
  String get dashboardActivityTypeDuel => 'Дуэль';

  @override
  String get dashboardActivityTypeAiTutor => 'Сессия с AI-репетитором';

  @override
  String get marketplaceTitle => 'Маркетплейс';

  @override
  String get marketplaceTabExplore => 'Обзор';

  @override
  String get marketplaceTabCollections => 'Коллекции';

  @override
  String get marketplaceTabPaths => 'Пути';

  @override
  String get marketplaceSearchHint => 'Поиск колод...';

  @override
  String get marketplaceFilterSort => 'Сортировка';

  @override
  String get marketplaceFilterDifficulty => 'Уровень';

  @override
  String get marketplaceFilterProOnly => 'Только Pro-колоды';

  @override
  String get marketplaceFilterApply => 'Применить';

  @override
  String get marketplaceFilterReset => 'Сбросить';

  @override
  String get marketplaceFilterAllSubjects => 'Все темы';

  @override
  String get marketplaceNoDecks =>
      'Колоды не найдены. Попробуйте изменить фильтры.';

  @override
  String get marketplaceNoCollections => 'Коллекций пока нет.';

  @override
  String get marketplaceNoPaths => 'Учебных путей пока нет.';

  @override
  String get marketplaceEnroll => 'Записались';

  @override
  String get marketplaceDeckAbout => 'О колоде';

  @override
  String get marketplaceDeckPreview => 'Предпросмотр карточек';

  @override
  String get marketplaceDeckClone => 'Добавить в библиотеку';

  @override
  String get marketplaceDeckAlreadyCloned => 'Уже в вашей библиотеке';

  @override
  String get marketplaceCards => 'Карточки';

  @override
  String get marketplaceRating => 'Рейтинг';

  @override
  String get marketplaceReviews => 'Отзывы';

  @override
  String get marketplaceRateThis => 'Оцените колоду';

  @override
  String get marketplaceReviewHint => 'Поделитесь впечатлением (необязательно)';

  @override
  String get marketplaceSubmitReview => 'Отправить';

  @override
  String get marketplaceUpdateReview => 'Обновить';

  @override
  String get marketplaceReportReview => 'Пожаловаться';

  @override
  String get marketplaceNoReviews => 'Пока нет отзывов — будьте первым!';

  @override
  String get marketplaceNoRatings => 'Нет оценок';

  @override
  String get marketplaceYou => 'Вы';

  @override
  String get marketplaceClones => 'Копии';

  @override
  String get marketplaceLikes => 'Лайки';

  @override
  String get marketplaceCardFront => 'Лицо';

  @override
  String get marketplaceCardBack => 'Оборот';

  @override
  String get marketplaceSearchIdle =>
      'Введите запрос для поиска колод, тем или авторов.';

  @override
  String get marketplaceSearchEmpty =>
      'Ничего не найдено. Попробуйте другой запрос.';

  @override
  String get marketplaceSortPopular => 'Популярные';

  @override
  String get marketplaceSortNewest => 'Новинки';

  @override
  String get marketplaceSortRating => 'С высоким рейтингом';

  @override
  String get marketplaceSortAlphabetical => 'А–Я';

  @override
  String marketplaceCardCount(int count) {
    return '$count карт.';
  }

  @override
  String marketplaceDeckCount(int count) {
    return '$count колод';
  }

  @override
  String marketplaceHours(int hours) {
    return '$hoursч';
  }

  @override
  String get marketplaceProBadge => 'PRO';

  @override
  String get libraryTitle => 'Моя библиотека';

  @override
  String get libraryTabDecks => 'Колоды';

  @override
  String get libraryTabCollections => 'Коллекции';

  @override
  String get libraryTabFavorites => 'Избранное';

  @override
  String get librarySearchHint => 'Поиск в библиотеке...';

  @override
  String get libraryRecentDecks => 'Недавно изученные';

  @override
  String get librarySortTitle => 'Сортировка';

  @override
  String get librarySortDateAdded => 'Дата добавления';

  @override
  String get librarySortName => 'Название (А–Я)';

  @override
  String get librarySortRecent => 'Недавно изученные';

  @override
  String get librarySortCardCount => 'Количество карточек';

  @override
  String get librarySortDueCards => 'Карточки к повторению';

  @override
  String get libraryFilter => 'Фильтр';

  @override
  String get libraryFilterApply => 'Применить';

  @override
  String get libraryFilterReset => 'Сбросить';

  @override
  String get libraryFilterDifficulty => 'Уровень';

  @override
  String get libraryFilterArchived => 'Показать архивные';

  @override
  String get libraryFilterDueOnly => 'Только к повторению';

  @override
  String get libraryFilterDifficultyAny => 'Любой';

  @override
  String get libraryFilterDifficultyBeginner => 'Начинающий';

  @override
  String get libraryFilterDifficultyIntermediate => 'Средний';

  @override
  String get libraryFilterDifficultyAdvanced => 'Продвинутый';

  @override
  String get libraryNoDecks => 'Колод пока нет. Клонируйте из Маркетплейса.';

  @override
  String get libraryNoCollections => 'Коллекций пока нет.';

  @override
  String get libraryNoFavorites =>
      'Нет избранного. Добавьте колоду в избранное.';

  @override
  String get libraryActionStudy => 'Учить';

  @override
  String get libraryActionFavorite => 'В избранное';

  @override
  String get libraryActionUnfavorite => 'Убрать из избранного';

  @override
  String get libraryActionArchive => 'Архивировать';

  @override
  String get libraryActionUnarchive => 'Разархивировать';

  @override
  String get libraryActionDelete => 'Удалить';

  @override
  String get libraryFavoriteAdded => 'Добавлено в избранное';

  @override
  String get libraryFavoriteRemoved => 'Убрано из избранного';

  @override
  String get libraryArchived => 'Колода архивирована';

  @override
  String get libraryUnarchived => 'Колода разархивирована';

  @override
  String get libraryDeleted => 'Колода удалена';

  @override
  String get libraryDeleteTitle => 'Удалить колоду';

  @override
  String libraryDeleteConfirm(String title) {
    return 'Удалить \"$title\"? Это действие нельзя отменить.';
  }

  @override
  String get librarySearchIdle => 'Введите запрос для поиска в библиотеке.';

  @override
  String get librarySearchEmpty => 'Колоды не найдены в вашей библиотеке.';

  @override
  String libraryDueCount(int count) {
    return '$count к повторению';
  }

  @override
  String get libraryDeckDetailDue => 'К повторению';

  @override
  String get libraryDeckDetailTest => 'Тест';

  @override
  String get libraryDeckDetailNotFound => 'Колода не найдена';

  @override
  String get libraryDeckDetailNoCards => 'В этой колоде пока нет карточек.';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get commonGotIt => 'Понятно';

  @override
  String get libraryDeckEditTooltip => 'Редактировать колоду';

  @override
  String get libraryDeckDeleteTooltip => 'Удалить колоду';

  @override
  String get libraryDeckAddCard => 'Добавить';

  @override
  String get cardTileQuizChip => 'Тест';

  @override
  String get cardTileFlashcardChip => 'Флешкарта';

  @override
  String get cardTileShowOptions => 'Варианты';

  @override
  String get cardTileHideOptions => 'Скрыть варианты';

  @override
  String get cardTileShowAnswer => 'Показать ответ';

  @override
  String get cardTileHideAnswer => 'Скрыть ответ';

  @override
  String get cardTileExplanation => 'ОБЪЯСНЕНИЕ';

  @override
  String get deckNoTestsTitle => 'В этой колоде нет тестов';

  @override
  String get deckNoTestsBody =>
      'Добавьте карточки с вариантами ответов (A, B, C…), чтобы пройти тест.';

  @override
  String get deckNoFlashcardsTitle => 'В этой колоде нет флешкарт';

  @override
  String get deckNoFlashcardsBody =>
      'Добавьте флешкарты, чтобы начать изучение этой колоды.';

  @override
  String get deckDeleteTitle => 'Удалить колоду?';

  @override
  String get deckDeleteBody =>
      'Колода и все её карточки будут удалены безвозвратно.';

  @override
  String get deckDeleteFailed => 'Не удалось удалить колоду';

  @override
  String get cardDeleteTitle => 'Удалить карточку?';

  @override
  String get cardDeleteBody => 'Это действие нельзя отменить.';

  @override
  String get cardDeleteFailed => 'Не удалось удалить карточку';

  @override
  String get libraryNewDeckFab => 'Колода';

  @override
  String get cardEditorTitleNew => 'Новый вопрос';

  @override
  String get cardEditorTitleEdit => 'Редактировать вопрос';

  @override
  String get cardEditorQuestionLabel => 'Вопрос';

  @override
  String get cardEditorQuestionHint => 'Введите вопрос…';

  @override
  String get cardEditorOptionsLabel => 'Варианты ответа';

  @override
  String get cardEditorMarkCorrect => 'Отметьте кружком правильный вариант';

  @override
  String get cardEditorAddOption => 'Добавить вариант';

  @override
  String cardEditorMaxOptions(int count) {
    return 'Максимум $count';
  }

  @override
  String cardEditorOptionHint(String letter) {
    return 'Вариант $letter';
  }

  @override
  String get cardEditorExplanationLabel => 'Объяснение (необязательно)';

  @override
  String get cardEditorExplanationHint => 'Почему этот ответ верный…';

  @override
  String get cardEditorErrorQuestion => 'Введите вопрос';

  @override
  String cardEditorErrorMinOptions(int count) {
    return 'Добавьте минимум $count варианта';
  }

  @override
  String get cardEditorErrorMarkCorrect =>
      'Отметьте правильный вариант (он не должен быть пустым)';

  @override
  String get cardEditorErrorSave =>
      'Не удалось сохранить. Проверьте соединение.';

  @override
  String get deckEditorTitleNew => 'Новая колода';

  @override
  String get deckEditorErrorName => 'Введите название колоды';

  @override
  String get deckEditorNameLabel => 'Название';

  @override
  String get deckEditorNameHint => 'Например: История Узбекистана';

  @override
  String get deckEditorDescLabel => 'Описание (необязательно)';

  @override
  String get deckEditorCreate => 'Создать';

  @override
  String levelXpToNext(int xp, int level) {
    return '$xp XP до уровня $level';
  }

  @override
  String get levelUpNewLevel => 'НОВЫЙ УРОВЕНЬ!';

  @override
  String get levelUpEncouragement =>
      'Вы отлично справляетесь! Продолжайте в том же духе, чтобы разблокировать следующую милю.';

  @override
  String get levelUpGreat => 'ОТЛИЧНО';

  @override
  String get levelJourneyLoadError => 'Не удалось загрузить шкалу уровней.';

  @override
  String get levelJourneyRewardsRoad => 'ДОРОГА НАГРАД';

  @override
  String levelJourneyMilestone(int level) {
    return 'Миля уровня $level';
  }

  @override
  String get levelJourneyXpHistory => 'ИСТОРИЯ XP';

  @override
  String get levelJourneyXpHistoryEmpty => 'История XP пуста.';

  @override
  String levelJourneyLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String levelJourneyXpRemaining(int xp) {
    return 'осталось $xp XP';
  }

  @override
  String get flashcardsAgain => 'Снова';

  @override
  String get flashcardsHard => 'Трудно';

  @override
  String get flashcardsGood => 'Хорошо';

  @override
  String get flashcardsEasy => 'Легко';

  @override
  String get flashcardsCardFlip => 'Показать ответ';

  @override
  String get flashcardsCardFront => 'Лицевая';

  @override
  String get flashcardsCardBack => 'Обратная';

  @override
  String get flashcardsModeSmart => 'Умный микс';

  @override
  String get flashcardsModeNew => 'Новые';

  @override
  String get flashcardsModeReview => 'Повторение';

  @override
  String get flashcardsModeDifficult => 'Трудные';

  @override
  String get flashcardsModeFavorite => 'Избранное';

  @override
  String get flashcardsModeFading => 'Остывают';

  @override
  String get flashcardsLoadError => 'Не удалось загрузить карточки';

  @override
  String get flashcardsQuit => 'Завершить сессию';

  @override
  String get flashcardsQuitConfirm => 'Завершить эту учебную сессию?';

  @override
  String get flashcardsQuitYes => 'Завершить';

  @override
  String get flashcardsQuitNo => 'Продолжить';

  @override
  String get flashcardsSessionComplete => 'Сессия завершена!';

  @override
  String get flashcardsSessionStats => 'Ваши результаты';

  @override
  String get flashcardsCardsStudied => 'Карточек изучено';

  @override
  String get flashcardsNewCards => 'Новых';

  @override
  String get flashcardsReviewCards => 'Повторений';

  @override
  String get flashcardsRetention => 'Запоминание';

  @override
  String get flashcardsTimeSpent => 'Потрачено времени';

  @override
  String get flashcardsStudyAgain => 'Учить снова';

  @override
  String get flashcardsBackToLibrary => 'Вернуться в библиотеку';

  @override
  String get testsSetupTitle => 'Настройка теста';

  @override
  String get testsSetupSubtitle => 'Настройте параметры теста';

  @override
  String get testsQuestionCount => 'Количество вопросов';

  @override
  String get testsCountAll => 'Все';

  @override
  String get testsShuffle => 'Перемешать вопросы';

  @override
  String get testsTimedMode => 'Режим таймера';

  @override
  String get testsSecondsPerQuestion => 'Секунд на вопрос';

  @override
  String get testsStart => 'Начать тест';

  @override
  String get testsSubmit => 'Сдать тест';

  @override
  String get testsNext => 'Далее';

  @override
  String get testsPrevious => 'Назад';

  @override
  String get testsQuitTitle => 'Выйти из теста?';

  @override
  String get testsQuitMessage => 'Прогресс будет потерян. Вы уверены?';

  @override
  String get testsQuitCancel => 'Отмена';

  @override
  String get testsQuitConfirm => 'Выйти';

  @override
  String get testsResultsTitle => 'Результаты теста';

  @override
  String get testsScoreExcellent => 'Отлично!';

  @override
  String get testsScoreGreat => 'Молодец!';

  @override
  String get testsScoreGood => 'Хорошая попытка';

  @override
  String get testsScorePractice => 'Продолжайте практиковаться';

  @override
  String get testsScoreStudy => 'Нужно больше изучения';

  @override
  String get testsCorrect => 'Верно';

  @override
  String get testsWrong => 'Неверно';

  @override
  String get testsDuration => 'Время';

  @override
  String get testsWeakAreas => 'Слабые места';

  @override
  String get testsReviewAnswers => 'Просмотр ответов';

  @override
  String get testsTryAgain => 'Попробовать снова';

  @override
  String get testsViewHistory => 'История тестов';

  @override
  String get testsReviewTitle => 'Просмотр ответов';

  @override
  String get testsDiagnoseButton => 'Почему я ошибся?';

  @override
  String get testsDiagnoseLoading => 'Анализирую…';

  @override
  String get testsDiagnoseWhyWrong => 'Почему твой ответ неверен';

  @override
  String get testsDiagnoseWhyCorrect => 'Почему верный ответ правильный';

  @override
  String get testsDiagnoseMisconception => 'Вероятное заблуждение';

  @override
  String get testsDiagnoseTip => 'Как запомнить';

  @override
  String get testsDiagnoseError =>
      'Не удалось разобрать ошибку. Попробуйте позже.';

  @override
  String get testsFollowupButton => 'Закрепить: похожий вопрос';

  @override
  String get testsFollowupCorrect => 'Верно!';

  @override
  String get testsFollowupWrong => 'Неверно';

  @override
  String get testsFollowupError =>
      'Не удалось создать вопрос. Попробуйте позже.';

  @override
  String get testsHistoryTitle => 'История тестов';

  @override
  String get testsHistoryEmpty => 'Тестов ещё нет';

  @override
  String get testsHistoryEmptySubtitle =>
      'Пройдите тест, чтобы увидеть результаты';

  @override
  String get testsLoadError => 'Не удалось загрузить вопросы';

  @override
  String get testsNoQuestions => 'В этой колоде нет вопросов для теста.';

  @override
  String get testsHistoryLoadError => 'Не удалось загрузить историю';

  @override
  String get testsRetry => 'Повторить';

  @override
  String testsCorrectOfTotal(int correct, int total) {
    return '$correct правильных из $total вопросов';
  }

  @override
  String testsReviewQuestionOf(int current, int total) {
    return 'Вопрос $current из $total';
  }

  @override
  String testsSecondsShort(int seconds) {
    return '$secondsс';
  }

  @override
  String testsMinutesSecondsShort(int minutes, int seconds) {
    return '$minutesмин $secondsс';
  }

  @override
  String testsScoreFraction(int correct, int total) {
    return '$correct / $total правильно';
  }

  @override
  String get tutorTitle => 'ИИ-наставник';

  @override
  String get tutorNewConversation => 'Новый диалог';

  @override
  String get tutorConversationTitle => 'Название диалога';

  @override
  String get tutorCreate => 'Создать';

  @override
  String get tutorRenameTitle => 'Переименовать диалог';

  @override
  String get tutorRename => 'Переименовать';

  @override
  String get tutorNewTitle => 'Новое название';

  @override
  String get tutorDeleteTitle => 'Удалить диалог?';

  @override
  String get tutorDeleteMessage =>
      'Этот диалог и все сообщения будут удалены навсегда.';

  @override
  String get tutorPin => 'Закрепить';

  @override
  String get tutorUnpin => 'Открепить';

  @override
  String get tutorDelete => 'Удалить';

  @override
  String get tutorPinnedSection => 'Закреплённые';

  @override
  String get tutorConversationsSection => 'Диалоги';

  @override
  String get tutorEmpty => 'Диалогов пока нет';

  @override
  String get tutorEmptySubtitle => 'Начните разговор с ИИ-наставником';

  @override
  String get tutorSearch => 'Поиск диалогов…';

  @override
  String tutorNoResults(String query) {
    return 'Ничего не найдено для \"$query\"';
  }

  @override
  String get tutorWithDeckContext => 'С контекстом колоды';

  @override
  String get tutorAskAnything => 'Спроси меня что угодно!';

  @override
  String get tutorWelcomeSubtitle =>
      'Я могу объяснить концепции, задать вопросы или помочь разобраться с карточками.';

  @override
  String get tutorInputHint => 'Спросите ИИ-наставника…';

  @override
  String get tutorCopied => 'Скопировано в буфер';

  @override
  String get tutorConnectionLost => 'Соединение потеряно. Попробуйте снова.';

  @override
  String get tutorLoadError => 'Не удалось загрузить диалоги';

  @override
  String get tutorRetry => 'Повторить';

  @override
  String get aiStudioTitle => 'AI Студия';

  @override
  String get aiStudioTabGenerate => 'Генерация';

  @override
  String get aiStudioTabFindAnswers => 'Найти ответы';

  @override
  String get aiStudioHistory => 'История';

  @override
  String get aiStudioSourceTopic => 'Тема';

  @override
  String get aiStudioSourceText => 'Текст';

  @override
  String get aiStudioSourcePdf => 'PDF';

  @override
  String get aiStudioTopicLabel => 'Тема';

  @override
  String get aiStudioTopicHint =>
      'Например: Французская революция, Математика, Тело человека…';

  @override
  String get aiStudioTextLabel => 'Вставьте текст (минимум 50 символов)';

  @override
  String get aiStudioTextHint =>
      'Вставьте статью, отрывок из учебника или любой текст…';

  @override
  String get aiStudioPdfLabel => 'Загрузить PDF';

  @override
  String get aiStudioPdfChoose => 'Выбрать PDF-файл';

  @override
  String get aiStudioPdfReady => 'PDF готов';

  @override
  String get aiStudioCardCountLabel => 'Количество карточек';

  @override
  String get aiStudioQualityLabel => 'Качество';

  @override
  String get aiStudioQualityFast => 'Быстро';

  @override
  String get aiStudioQualityBalanced => 'Сбалансированно';

  @override
  String get aiStudioQualityPremium => 'Премиум';

  @override
  String get aiStudioQualityFastDescription => '~15 сек';

  @override
  String get aiStudioQualityBalancedDescription => '~30 сек';

  @override
  String get aiStudioQualityPremiumDescription => '~60 сек · лучшее качество';

  @override
  String get aiStudioGenerate => 'Генерировать';

  @override
  String get aiStudioGenerating => 'Генерируется…';

  @override
  String get aiStudioFindAnswersHint =>
      'Например: Что стало причиной Первой мировой войны?';

  @override
  String get aiStudioFindAnswersLabel => 'Задайте любой вопрос';

  @override
  String get aiStudioAiAnswer => 'Ответ ИИ';

  @override
  String get aiStudioKeyPoints => 'Ключевые моменты';

  @override
  String get aiProgressTitle => 'Генерируется…';

  @override
  String aiProgressFrom(String source) {
    return 'Генерация из $source';
  }

  @override
  String aiProgressQuality(int count, String quality) {
    return '$count карточек · качество $quality';
  }

  @override
  String get aiProgressFailed => 'Генерация не удалась. Попробуйте ещё раз.';

  @override
  String get aiProgressGoBack => 'Назад';

  @override
  String get aiResultsTitle => 'сгенерировано карточек';

  @override
  String get aiResultsTitleDefault => 'Результаты';

  @override
  String aiResultsSelected(int selected, int total) {
    return 'Выбрано $selected из $total';
  }

  @override
  String get aiResultsSelectAll => 'Выбрать все';

  @override
  String get aiResultsDeselectAll => 'Снять выбор';

  @override
  String get aiResultsNew => 'Новая';

  @override
  String get aiResultsSaveToDeck => 'Сохранить в колоду';

  @override
  String get aiResultsCardsSaved => 'карточек сохранено!';

  @override
  String get aiResultsEmpty => 'Карточки не были сгенерированы.';

  @override
  String get aiResultsEmptySubtitle =>
      'Попробуйте другую тему или добавьте больше текста.';

  @override
  String get aiResultsTryAgain => 'Попробовать снова';

  @override
  String get aiHistoryTitle => 'История генерации';

  @override
  String get aiHistoryEmpty => 'Генераций пока нет';

  @override
  String get aiHistoryEmptySubtitle =>
      'История создания карточек появится здесь.';

  @override
  String aiSaveToDeck(int count) {
    return 'Сохранить $count карточек в…';
  }

  @override
  String get aiSaveCreateNew => 'Создать новую колоду';

  @override
  String get aiSaveDeckName => 'Название колоды';

  @override
  String get aiSaveSaveCards => 'Сохранить карточки';

  @override
  String get aiExplainTitle => 'Объяснение ИИ';

  @override
  String get aiExplainQuestion => 'Вопрос';

  @override
  String get aiExplainAnswer => 'Ответ';

  @override
  String get aiExplainExplanation => 'Объяснение';

  @override
  String get aiExplainLoading => 'ИИ объясняет эту концепцию…';

  @override
  String get aiExplainRetry => 'Попробовать снова';

  @override
  String aiStudioCharCount(int count) {
    return '$count симв.';
  }

  @override
  String aiStudioCharCountNeedMore(int count, int more) {
    return '$count симв. (нужно еще $more)';
  }

  @override
  String get aiStudioStatusFailed => 'Ошибка';

  @override
  String get aiStudioStatusCancelled => 'Отменено';

  @override
  String get aiStudioStatusPending => 'Ожидание';

  @override
  String get aiStudioStatusProcessing => 'В процессе';

  @override
  String aiStudioCardsCount(int count) {
    return '$count карточек';
  }

  @override
  String get aiSaveErrorNoName => 'Введите название колоды.';

  @override
  String get aiSaveErrorNoDeck => 'Сначала выберите колоду.';

  @override
  String get streakEvolutionRoadmap => 'Карта эволюции';

  @override
  String get streakMilestoneAchievements => 'Достижения серий';

  @override
  String get streakConsistencyHistory => 'История активности (30 дней)';

  @override
  String get streakClaimedRewardsHistory => 'История наград';

  @override
  String get streakActiveBadge => 'АКТИВНО';

  @override
  String get streakMaximized => 'Легендарное дерево выращено! 👑';

  @override
  String get streakNoRewards => 'Награды за серии еще не получены.';

  @override
  String streakDaysRemaining(int count, String stage) {
    return '$count дн. до стадии $stage';
  }

  @override
  String streakGrowthStage(String stage) {
    return 'Стадия роста: $stage';
  }

  @override
  String streakCurrentDays(int count) {
    return 'Активная серия: $count дн.';
  }

  @override
  String streakDayCount(int count) {
    return 'Серия: $count дн.';
  }

  @override
  String get streakStageSeed => 'Семечко';

  @override
  String get streakStageSprout => 'Росток';

  @override
  String get streakStageYoungTree => 'Молодое дерево';

  @override
  String get streakStageBloomingTree => 'Цветущее дерево';

  @override
  String get streakStageAncientTree => 'Древнее дерево';

  @override
  String get streakStageLegendaryTree => 'Легендарное дерево';

  @override
  String streakLastReward(String reward) {
    return 'Последняя награда: $reward';
  }

  @override
  String streakNextReward(String reward) {
    return 'Следующая награда: $reward';
  }

  @override
  String get streakNoLastReward => 'Последняя награда: Нет';

  @override
  String get streakMaxReward => 'Следующая награда: Нет (Макс. уровень)';

  @override
  String streakProgressDays(Object current, Object pct, Object target) {
    return '$current / $target дн. ($pct%)';
  }
}
