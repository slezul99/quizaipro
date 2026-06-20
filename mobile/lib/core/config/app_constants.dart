abstract final class AppConstants {
  // ── Network ───────────────────────────────────────────────────────────────
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;
  static const int maxRetries = 3;
  static const int retryBaseDelayMs = 500;

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String authCachedUserKey = 'auth_cached_user';

  // ── Hive boxes ────────────────────────────────────────────────────────────
  static const String settingsBox = 'settings_box';
  static const String featureFlagsBox = 'feature_flags_box';
  static const String marketplaceListingsBox = 'marketplace_listings_box';
  static const String draftsBox = 'drafts_box';

  // ── Settings keys (stored in settingsBox) ─────────────────────────────────
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String dailyGoalKey = 'daily_goal';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Study / SRS ───────────────────────────────────────────────────────────
  static const int studySessionBatchSize = 20;
  static const int srsMaxIntervalDays = 36500;
  static const double srsDefaultEaseFactor = 2.5;
  static const double srsMinEaseFactor = 1.3;
  static const double srsMaxEaseFactor = 5.0;
  static const double srsDifficultEFThreshold = 2.0;
  // FSRS difficulty is 1..10 (higher = harder); >= this flags a "difficult" card.
  static const double srsDifficultFsrsThreshold = 7.0;
  static const int srsDifficultAgainThreshold = 3;

  // ── WebSocket ─────────────────────────────────────────────────────────────
  static const int wsPingIntervalMs = 25000;
  static const int wsPongTimeoutMs = 10000;
  static const int wsMaxReconnectDelayMs = 30000;
  static const int wsInitialReconnectDelayMs = 500;

  // ── Cache TTL ─────────────────────────────────────────────────────────────
  static const int marketplaceListingsTtlMinutes = 30;
  static const int userProfileTtlMinutes = 10;
  static const int dashboardCacheTtlMinutes = 5;

  // ── Dashboard cache keys (stored in settingsBox) ───────────────────────────
  static const String dashboardCacheSummaryKey = 'dashboard_cache_summary';
  static const String dashboardCacheActivityKey = 'dashboard_cache_activity';

  // ── Marketplace cache keys (stored in marketplaceListingsBox) ─────────────
  static const String marketplaceSubjectsKey = 'mp_subjects';
  static const String marketplaceLearningPathsKey = 'mp_learning_paths';
  static const String marketplaceDecksKey = 'mp_decks';
  static const String marketplaceDeckDetailKey = 'mp_deck_detail';

  // ── Library Hive box ──────────────────────────────────────────────────────
  static const String libraryBox = 'library_box';

  // ── Library cache TTL ─────────────────────────────────────────────────────
  static const int libraryDecksCacheTtlMinutes = 5;
  static const int libraryRecentCacheTtlMinutes = 2;
  static const int libraryCollectionsCacheTtlMinutes = 10;

  // ── Library cache keys (stored in libraryBox) ─────────────────────────────
  static const String libraryDecksKey = 'lib_decks';
  static const String libraryRecentKey = 'lib_recent';
  static const String libraryCollectionsKey = 'lib_collections';
  static const String libraryFavoritesKey = 'lib_favorites';

  // ── Tests ─────────────────────────────────────────────────────────────────
  static const int testDefaultQuestionCount = 10;
  static const int testDefaultSecondsPerQuestion = 30;
  static const int testWeakAreaThresholdPct = 60;

  // ── AI Tutor ──────────────────────────────────────────────────────────────
  static const int tutorMaxConversations = 100;
  static const int tutorMessagePreviewLength = 80;

  // ── AI Generation ─────────────────────────────────────────────────────────
  static const int aiGenerationDefaultCards = 10;
  static const int aiGenerationMinCards = 5;
  static const int aiGenerationMaxCards = 50;
  static const int aiGenerationPollIntervalMs = 2000;

  // ── Drift ─────────────────────────────────────────────────────────────────
  static const String driftDbFileName = 'quizaipro.db';
  static const int driftDbVersion = 6;
}
