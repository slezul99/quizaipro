abstract final class AppRoutes {
  // ── Root ──────────────────────────────────────────────────────────────────
  static const splash = '/';
  static const splashName = 'splash';

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const onboarding = '/onboarding';
  static const onboardingName = 'onboarding';
  static const onboardingGoal = 'goal';
  static const onboardingGoalName = 'onboarding.goal';
  static const onboardingPermissions = 'permissions';
  static const onboardingPermissionsName = 'onboarding.permissions';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const welcome = '/auth/welcome';
  static const welcomeName = 'auth.welcome';
  static const login = '/auth/login';
  static const loginName = 'auth.login';
  static const register = '/auth/register';
  static const registerName = 'auth.register';
  static const forgotPassword = '/auth/forgot-password';
  static const forgotPasswordName = 'auth.forgot-password';

  // ── Shell tabs ────────────────────────────────────────────────────────────
  static const home = '/home';
  static const homeName = 'home';

  static const library = '/library';
  static const libraryName = 'library';
  static const libraryDeck = 'deck/:deckId';
  static const libraryDeckName = 'library.deck';
  static const libraryCards = 'cards';
  static const libraryCardsName = 'library.cards';
  static const librarySearch = 'search';
  static const librarySearchName = 'library.search';

  static const discover = '/discover';
  static const discoverName = 'discover';
  static const discoverDeck = 'deck/:deckId';
  static const discoverDeckName = 'discover.deck';
  static const discoverSearch = 'search';
  static const discoverSearchName = 'discover.search';

  static const arena = '/arena';
  static const arenaName = 'arena';
  static const arenaChat = 'chat';
  static const arenaChatName = 'arena.chat';
  static const arenaDuel = 'duel';
  static const arenaDuelName = 'arena.duel';

  static const profile = '/profile';
  static const profileName = 'profile';
  static const profileSettings = 'settings';
  static const profileSettingsName = 'profile.settings';

  // ── Immersive (root navigator — no shell / bottom bar) ────────────────────
  static const tutor = '/tutor';
  static const tutorName = 'tutor';

  static const tutorChat = '/tutor/chat';
  static const tutorChatName = 'tutor.chat';

  static const studySession = '/study/session';
  static const studySessionName = 'study.session';

  static const testSetup = '/test/setup';
  static const testSetupName = 'test.setup';

  static const testSession = '/test/session';
  static const testSessionName = 'test.session';

  static const testResults = '/test/results';
  static const testResultsName = 'test.results';

  static const testReview = '/test/review';
  static const testReviewName = 'test.review';

  static const testHistory = '/test/history';
  static const testHistoryName = 'test.history';

  static const aiGenerationStudio = '/ai/studio';
  static const aiGenerationStudioName = 'ai.studio';
  static const aiGenerationProgress = '/ai/progress';
  static const aiGenerationProgressName = 'ai.progress';
  static const aiGenerationResults = '/ai/results';
  static const aiGenerationResultsName = 'ai.results';
  static const aiGenerationHistory = '/ai/history';
  static const aiGenerationHistoryName = 'ai.history';
  static const aiGenerationExplain = '/ai/explain';
  static const aiGenerationExplainName = 'ai.explain';

  static const duelSession = '/duel/:duelId';
  static const duelSessionName = 'duel.session';

  static const liveSession = '/live/:code';
  static const liveSessionName = 'live.session';

  static const notifications = '/notifications';
  static const notificationsName = 'notifications';

  static const publicProfile = '/u/:username';
  static const publicProfileName = 'user.profile';

  static const streakJourney = '/streak';
  static const streakJourneyName = 'streak.journey';

  static const levelJourney = '/level';
  static const levelJourneyName = 'level.journey';

  static const activityDetail = '/activity-detail';
  static const activityDetailName = 'activity.detail';
}

