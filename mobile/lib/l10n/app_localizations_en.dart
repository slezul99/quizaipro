// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'QuizAIPro';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection. Check your network.';

  @override
  String get errorUnauthorized => 'Session expired. Please log in again.';

  @override
  String get errorRateLimited => 'Too many requests. Please wait a moment.';

  @override
  String get authWelcomeTitle => 'Learn Smarter with AI';

  @override
  String get authWelcomeSubtitle =>
      'AI-powered flashcards that adapt to how you learn.';

  @override
  String get authLogin => 'Log In';

  @override
  String get authRegister => 'Create Account';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authLogout => 'Log Out';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle => 'Sign in to continue learning';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get authRegisterSubtitle => 'Start your AI learning journey';

  @override
  String get authUsername => 'Username';

  @override
  String get authUsernamePlaceholder => 'your_username';

  @override
  String get authEmailPlaceholder => 'your@email.com';

  @override
  String get authIdentifier => 'Email or username';

  @override
  String get authIdentifierPlaceholder => 'email or username';

  @override
  String get authPasswordPlaceholder => 'At least 8 characters';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authConfirmPasswordPlaceholder => 'Repeat your password';

  @override
  String get authPasswordHintLogin => 'Your password';

  @override
  String get authConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get authGetStarted => 'Get Started';

  @override
  String get authAlreadyHaveAccount => 'I already have an account';

  @override
  String get authOrContinueWith => 'or continue with';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authHaveAccount => 'Already have an account? ';

  @override
  String get authSignInLink => 'Sign in';

  @override
  String get authTermsNotice =>
      'By creating an account you agree to our\nTerms of Service and Privacy Policy.';

  @override
  String get authPasswordStrengthWeak => 'Weak';

  @override
  String get authPasswordStrengthFair => 'Fair';

  @override
  String get authPasswordStrengthStrong => 'Strong';

  @override
  String get authPasswordStrengthVeryStrong => 'Very strong';

  @override
  String validationRequired(String field) {
    return '$field is required';
  }

  @override
  String get validationEmail => 'Enter a valid email address';

  @override
  String get validationPasswordMin => 'Password must be at least 8 characters';

  @override
  String get validationPasswordsNoMatch => 'Passwords do not match';

  @override
  String get validationUsernameMin => 'Username must be at least 3 characters';

  @override
  String get validationUsernameMax => 'Username must be at most 20 characters';

  @override
  String get validationUsernameChars => 'Only letters, numbers and underscores';

  @override
  String get errorUnexpected => 'An unexpected error occurred.';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navArena => 'Arena';

  @override
  String get navProfile => 'Profile';

  @override
  String get arenaComingSoon => 'Arena — Coming soon';

  @override
  String get profileComingSoon => 'Profile — Coming soon';

  @override
  String get homeComingSoon => 'Home — Coming soon';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get discoverComingSoon => 'Discover — Coming soon';

  @override
  String get duelComingSoon => 'Duel — Coming soon';

  @override
  String get liveTestComingSoon => 'Live Test — Coming soon';

  @override
  String get notificationsComingSoon => 'Notifications — Coming soon';

  @override
  String homeStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString day streak';
  }

  @override
  String get dashboardStreakDay => 'day streak';

  @override
  String dashboardStreakBest(int count) {
    return 'Best: $count days';
  }

  @override
  String get dashboardStreakToday => 'Today';

  @override
  String get dashboardStreakDone => 'Done!';

  @override
  String dashboardCardsLeft(int count) {
    return '$count cards left';
  }

  @override
  String homeDueCards(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString cards due';
  }

  @override
  String get studyStart => 'Start Studying';

  @override
  String studyCardOf(int current, int total) {
    return '$current of $total';
  }

  @override
  String get tutorAskPlaceholder => 'Ask anything about your deck...';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDailyGoal => 'Daily Goal';

  @override
  String settingsDailyGoalCards(int count) {
    return '$count cards / day';
  }

  @override
  String get dashboardGreetingMorning => 'Good morning,';

  @override
  String get dashboardGreetingAfternoon => 'Good afternoon,';

  @override
  String get dashboardGreetingEvening => 'Good evening,';

  @override
  String get dashboardDailyGoal => 'Daily Goal';

  @override
  String get dashboardDailyGoalCompleted => 'Goal achieved!';

  @override
  String get dashboardReadyToStudy => 'Ready to study';

  @override
  String get dashboardAllCaughtUp => 'All caught up! 🎉';

  @override
  String dashboardXpLabel(int xp) {
    return '$xp XP';
  }

  @override
  String dashboardXpToNextLevel(int xp, int nextLevel) {
    return '$xp XP to level $nextLevel';
  }

  @override
  String dashboardLevelBadge(int level) {
    return 'L$level';
  }

  @override
  String get dashboardOverdue => 'Overdue';

  @override
  String get dashboardStartStudying => 'Start';

  @override
  String get dashboardQuickActions => 'Quick Actions';

  @override
  String get dashboardActionStudy => 'Study';

  @override
  String get dashboardActionDiscover => 'Discover';

  @override
  String get dashboardActionAiTutor => 'Tutor';

  @override
  String get dashboardActionAiStudio => 'Studio';

  @override
  String get dashboardRecentActivity => 'Recent Activity';

  @override
  String get dashboardActivityEmpty =>
      'No activity yet. Start studying to see your progress!';

  @override
  String dashboardActivitySummary(int count, String time) {
    return '$count cards · $time';
  }

  @override
  String dashboardTimeAgoMinutes(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String dashboardTimeAgoHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String dashboardTimeAgoDays(int days) {
    return '${days}d ago';
  }

  @override
  String dashboardXpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get dashboardActivityTypeStudy => 'Study session';

  @override
  String get dashboardActivityTypeTest => 'Test completed';

  @override
  String get dashboardActivityTypeDuel => 'Duel';

  @override
  String get dashboardActivityTypeAiTutor => 'AI Tutor session';

  @override
  String get marketplaceTitle => 'Discover';

  @override
  String get marketplaceTabExplore => 'Explore';

  @override
  String get marketplaceTabCollections => 'Collections';

  @override
  String get marketplaceTabPaths => 'Paths';

  @override
  String get marketplaceSearchHint => 'Search decks...';

  @override
  String get marketplaceFilterSort => 'Sort by';

  @override
  String get marketplaceFilterDifficulty => 'Difficulty';

  @override
  String get marketplaceFilterProOnly => 'Pro decks only';

  @override
  String get marketplaceFilterApply => 'Apply';

  @override
  String get marketplaceFilterReset => 'Reset';

  @override
  String get marketplaceFilterAllSubjects => 'All subjects';

  @override
  String get marketplaceNoDecks => 'No decks found. Try changing your filters.';

  @override
  String get marketplaceNoCollections => 'No collections available yet.';

  @override
  String get marketplaceNoPaths => 'No learning paths available yet.';

  @override
  String get marketplaceEnroll => 'Enrolled';

  @override
  String get marketplaceDeckAbout => 'About';

  @override
  String get marketplaceDeckPreview => 'Preview cards';

  @override
  String get marketplaceDeckClone => 'Clone to my library';

  @override
  String get marketplaceDeckAlreadyCloned => 'Already in your library';

  @override
  String get marketplaceCards => 'Cards';

  @override
  String get marketplaceRating => 'Rating';

  @override
  String get marketplaceClones => 'Clones';

  @override
  String get marketplaceLikes => 'Likes';

  @override
  String get marketplaceCardFront => 'Front';

  @override
  String get marketplaceCardBack => 'Back';

  @override
  String get marketplaceSearchIdle =>
      'Search for decks, subjects, or creators to get started.';

  @override
  String get marketplaceSearchEmpty =>
      'No results found. Try adjusting your search terms.';

  @override
  String get marketplaceSortPopular => 'Popular';

  @override
  String get marketplaceSortNewest => 'Newest';

  @override
  String get marketplaceSortRating => 'Top Rated';

  @override
  String get marketplaceSortAlphabetical => 'A–Z';

  @override
  String marketplaceCardCount(int count) {
    return '$count cards';
  }

  @override
  String marketplaceDeckCount(int count) {
    return '$count decks';
  }

  @override
  String marketplaceHours(int hours) {
    return '${hours}h';
  }

  @override
  String get marketplaceProBadge => 'PRO';

  @override
  String get libraryTitle => 'My Library';

  @override
  String get libraryTabDecks => 'Decks';

  @override
  String get libraryTabCollections => 'Collections';

  @override
  String get libraryTabFavorites => 'Favorites';

  @override
  String get librarySearchHint => 'Search my library...';

  @override
  String get libraryRecentDecks => 'Recently Studied';

  @override
  String get librarySortTitle => 'Sort by';

  @override
  String get librarySortDateAdded => 'Date Added';

  @override
  String get librarySortName => 'Name (A–Z)';

  @override
  String get librarySortRecent => 'Recently Studied';

  @override
  String get librarySortCardCount => 'Card Count';

  @override
  String get librarySortDueCards => 'Due Cards';

  @override
  String get libraryFilter => 'Filter';

  @override
  String get libraryFilterApply => 'Apply';

  @override
  String get libraryFilterReset => 'Reset';

  @override
  String get libraryFilterDifficulty => 'Difficulty';

  @override
  String get libraryFilterArchived => 'Show archived';

  @override
  String get libraryFilterDueOnly => 'Due cards only';

  @override
  String get libraryFilterDifficultyAny => 'Any';

  @override
  String get libraryFilterDifficultyBeginner => 'Beginner';

  @override
  String get libraryFilterDifficultyIntermediate => 'Intermediate';

  @override
  String get libraryFilterDifficultyAdvanced => 'Advanced';

  @override
  String get libraryNoDecks =>
      'No decks yet. Clone from the Marketplace to get started.';

  @override
  String get libraryNoCollections => 'No collections yet.';

  @override
  String get libraryNoFavorites =>
      'No favorites yet. Star a deck to save it here.';

  @override
  String get libraryActionStudy => 'Study';

  @override
  String get libraryActionFavorite => 'Add to Favorites';

  @override
  String get libraryActionUnfavorite => 'Remove from Favorites';

  @override
  String get libraryActionArchive => 'Archive';

  @override
  String get libraryActionUnarchive => 'Unarchive';

  @override
  String get libraryActionDelete => 'Delete';

  @override
  String get libraryFavoriteAdded => 'Added to favorites';

  @override
  String get libraryFavoriteRemoved => 'Removed from favorites';

  @override
  String get libraryArchived => 'Deck archived';

  @override
  String get libraryUnarchived => 'Deck unarchived';

  @override
  String get libraryDeleted => 'Deck deleted';

  @override
  String get libraryDeleteTitle => 'Delete Deck';

  @override
  String libraryDeleteConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? This cannot be undone.';
  }

  @override
  String get librarySearchIdle => 'Type to search your library.';

  @override
  String get librarySearchEmpty => 'No decks found in your library.';

  @override
  String libraryDueCount(int count) {
    return '$count due';
  }

  @override
  String get libraryDeckDetailDue => 'Due';

  @override
  String get libraryDeckDetailTest => 'Test';

  @override
  String get libraryDeckDetailNotFound => 'Deck not found';

  @override
  String get libraryDeckDetailNoCards => 'No cards in this deck yet.';

  @override
  String get flashcardsAgain => 'Again';

  @override
  String get flashcardsHard => 'Hard';

  @override
  String get flashcardsGood => 'Good';

  @override
  String get flashcardsEasy => 'Easy';

  @override
  String get flashcardsCardFlip => 'Tap to reveal';

  @override
  String get flashcardsCardFront => 'Front';

  @override
  String get flashcardsCardBack => 'Back';

  @override
  String get flashcardsModeSmart => 'Smart Mix';

  @override
  String get flashcardsModeNew => 'New Cards';

  @override
  String get flashcardsModeReview => 'Review';

  @override
  String get flashcardsModeDifficult => 'Difficult';

  @override
  String get flashcardsModeFavorite => 'Favorites';

  @override
  String get flashcardsLoadError => 'Failed to load cards';

  @override
  String get flashcardsQuit => 'End Session';

  @override
  String get flashcardsQuitConfirm => 'End this study session?';

  @override
  String get flashcardsQuitYes => 'End Session';

  @override
  String get flashcardsQuitNo => 'Keep Studying';

  @override
  String get flashcardsSessionComplete => 'Session Complete!';

  @override
  String get flashcardsSessionStats => 'Your Results';

  @override
  String get flashcardsCardsStudied => 'Cards studied';

  @override
  String get flashcardsNewCards => 'New';

  @override
  String get flashcardsReviewCards => 'Review';

  @override
  String get flashcardsRetention => 'Retention';

  @override
  String get flashcardsTimeSpent => 'Time spent';

  @override
  String get flashcardsStudyAgain => 'Study Again';

  @override
  String get flashcardsBackToLibrary => 'Back to Library';

  @override
  String get testsSetupTitle => 'Test Setup';

  @override
  String get testsSetupSubtitle => 'Configure your test session';

  @override
  String get testsQuestionCount => 'Number of Questions';

  @override
  String get testsCountAll => 'All';

  @override
  String get testsShuffle => 'Shuffle Questions';

  @override
  String get testsTimedMode => 'Timed Mode';

  @override
  String get testsSecondsPerQuestion => 'Seconds per Question';

  @override
  String get testsStart => 'Start Test';

  @override
  String get testsSubmit => 'Submit Test';

  @override
  String get testsNext => 'Next';

  @override
  String get testsPrevious => 'Previous';

  @override
  String get testsQuitTitle => 'Quit Test?';

  @override
  String get testsQuitMessage => 'Your progress will be lost. Are you sure?';

  @override
  String get testsQuitCancel => 'Cancel';

  @override
  String get testsQuitConfirm => 'Quit';

  @override
  String get testsResultsTitle => 'Test Results';

  @override
  String get testsScoreExcellent => 'Excellent!';

  @override
  String get testsScoreGreat => 'Great Job!';

  @override
  String get testsScoreGood => 'Good Effort';

  @override
  String get testsScorePractice => 'Keep Practicing';

  @override
  String get testsScoreStudy => 'Need More Study';

  @override
  String get testsCorrect => 'Correct';

  @override
  String get testsWrong => 'Wrong';

  @override
  String get testsDuration => 'Duration';

  @override
  String get testsWeakAreas => 'Weak Areas';

  @override
  String get testsReviewAnswers => 'Review Answers';

  @override
  String get testsTryAgain => 'Try Again';

  @override
  String get testsViewHistory => 'View Test History';

  @override
  String get testsReviewTitle => 'Review Answers';

  @override
  String get testsDiagnoseButton => 'Why did I get this wrong?';

  @override
  String get testsDiagnoseLoading => 'Analyzing…';

  @override
  String get testsDiagnoseWhyWrong => 'Why your answer is wrong';

  @override
  String get testsDiagnoseWhyCorrect => 'Why the correct answer is right';

  @override
  String get testsDiagnoseMisconception => 'Likely misconception';

  @override
  String get testsDiagnoseTip => 'How to remember';

  @override
  String get testsDiagnoseError =>
      'Couldn\'t analyze the mistake. Try again later.';

  @override
  String get testsFollowupButton => 'Practice: similar question';

  @override
  String get testsFollowupCorrect => 'Correct!';

  @override
  String get testsFollowupWrong => 'Incorrect';

  @override
  String get testsFollowupError =>
      'Couldn\'t create a question. Try again later.';

  @override
  String get testsHistoryTitle => 'Test History';

  @override
  String get testsHistoryEmpty => 'No tests taken yet';

  @override
  String get testsHistoryEmptySubtitle =>
      'Complete a test to see your results here';

  @override
  String get testsLoadError => 'Failed to load questions';

  @override
  String get testsNoQuestions => 'This deck has no quiz questions to test.';

  @override
  String get testsHistoryLoadError => 'Failed to load history';

  @override
  String get testsRetry => 'Retry';

  @override
  String testsCorrectOfTotal(int correct, int total) {
    return '$correct correct out of $total questions';
  }

  @override
  String testsReviewQuestionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String testsSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String testsMinutesSecondsShort(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String testsScoreFraction(int correct, int total) {
    return '$correct / $total correct';
  }

  @override
  String get tutorTitle => 'AI Tutor';

  @override
  String get tutorNewConversation => 'New Conversation';

  @override
  String get tutorConversationTitle => 'Conversation title';

  @override
  String get tutorCreate => 'Create';

  @override
  String get tutorRenameTitle => 'Rename Conversation';

  @override
  String get tutorRename => 'Rename';

  @override
  String get tutorNewTitle => 'New title';

  @override
  String get tutorDeleteTitle => 'Delete Conversation?';

  @override
  String get tutorDeleteMessage =>
      'This conversation and all its messages will be permanently deleted.';

  @override
  String get tutorPin => 'Pin';

  @override
  String get tutorUnpin => 'Unpin';

  @override
  String get tutorDelete => 'Delete';

  @override
  String get tutorPinnedSection => 'Pinned';

  @override
  String get tutorConversationsSection => 'Conversations';

  @override
  String get tutorEmpty => 'No conversations yet';

  @override
  String get tutorEmptySubtitle => 'Start a conversation with your AI tutor';

  @override
  String get tutorSearch => 'Search conversations…';

  @override
  String tutorNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get tutorWithDeckContext => 'With deck context';

  @override
  String get tutorAskAnything => 'Ask me anything!';

  @override
  String get tutorWelcomeSubtitle =>
      'I can explain concepts, quiz you on topics, or help you understand your flashcards.';

  @override
  String get tutorInputHint => 'Ask your AI tutor…';

  @override
  String get tutorCopied => 'Copied to clipboard';

  @override
  String get tutorConnectionLost => 'Connection lost. Please try again.';

  @override
  String get tutorLoadError => 'Failed to load conversations';

  @override
  String get tutorRetry => 'Retry';

  @override
  String get aiStudioTitle => 'AI Studio';

  @override
  String get aiStudioTabGenerate => 'Generate';

  @override
  String get aiStudioTabFindAnswers => 'Find Answers';

  @override
  String get aiStudioHistory => 'History';

  @override
  String get aiStudioSourceTopic => 'Topic';

  @override
  String get aiStudioSourceText => 'Text';

  @override
  String get aiStudioSourcePdf => 'PDF';

  @override
  String get aiStudioTopicLabel => 'Topic';

  @override
  String get aiStudioTopicHint =>
      'e.g. The French Revolution, Calculus, Human Body…';

  @override
  String get aiStudioTextLabel => 'Paste your text (min 50 characters)';

  @override
  String get aiStudioTextHint =>
      'Paste an article, textbook excerpt, or any text…';

  @override
  String get aiStudioPdfLabel => 'Upload PDF';

  @override
  String get aiStudioPdfChoose => 'Choose PDF file';

  @override
  String get aiStudioPdfReady => 'PDF ready';

  @override
  String get aiStudioCardCountLabel => 'Number of cards';

  @override
  String get aiStudioQualityLabel => 'Quality';

  @override
  String get aiStudioQualityFast => 'Fast';

  @override
  String get aiStudioQualityBalanced => 'Balanced';

  @override
  String get aiStudioQualityPremium => 'Premium';

  @override
  String get aiStudioQualityFastDescription => '~15 sec';

  @override
  String get aiStudioQualityBalancedDescription => '~30 sec';

  @override
  String get aiStudioQualityPremiumDescription => '~60 sec · best quality';

  @override
  String get aiStudioGenerate => 'Generate';

  @override
  String get aiStudioGenerating => 'Generating…';

  @override
  String get aiStudioFindAnswersHint => 'e.g. What caused World War I?';

  @override
  String get aiStudioFindAnswersLabel => 'Ask any question';

  @override
  String get aiStudioAiAnswer => 'AI Answer';

  @override
  String get aiStudioKeyPoints => 'Key Points';

  @override
  String get aiProgressTitle => 'Generating…';

  @override
  String aiProgressFrom(String source) {
    return 'Generating from $source';
  }

  @override
  String aiProgressQuality(int count, String quality) {
    return '$count cards · $quality quality';
  }

  @override
  String get aiProgressFailed => 'Generation failed. Please try again.';

  @override
  String get aiProgressGoBack => 'Go back';

  @override
  String get aiResultsTitle => 'cards generated';

  @override
  String get aiResultsTitleDefault => 'Results';

  @override
  String aiResultsSelected(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String get aiResultsSelectAll => 'Select All';

  @override
  String get aiResultsDeselectAll => 'Deselect All';

  @override
  String get aiResultsNew => 'New';

  @override
  String get aiResultsSaveToDeck => 'Save to Deck';

  @override
  String get aiResultsCardsSaved => 'cards saved!';

  @override
  String get aiResultsEmpty => 'No cards were generated.';

  @override
  String get aiResultsEmptySubtitle =>
      'Try a different topic or use more text.';

  @override
  String get aiResultsTryAgain => 'Try Again';

  @override
  String get aiHistoryTitle => 'Generation History';

  @override
  String get aiHistoryEmpty => 'No generations yet';

  @override
  String get aiHistoryEmptySubtitle =>
      'Your card generation history will appear here.';

  @override
  String aiSaveToDeck(int count) {
    return 'Save $count cards to…';
  }

  @override
  String get aiSaveCreateNew => 'Create new deck';

  @override
  String get aiSaveDeckName => 'Deck name';

  @override
  String get aiSaveSaveCards => 'Save Cards';

  @override
  String get aiExplainTitle => 'AI Explanation';

  @override
  String get aiExplainQuestion => 'Question';

  @override
  String get aiExplainAnswer => 'Answer';

  @override
  String get aiExplainExplanation => 'Explanation';

  @override
  String get aiExplainLoading => 'AI is explaining this concept…';

  @override
  String get aiExplainRetry => 'Try again';

  @override
  String aiStudioCharCount(int count) {
    return '$count chars';
  }

  @override
  String aiStudioCharCountNeedMore(int count, int more) {
    return '$count chars (need $more more)';
  }

  @override
  String get aiStudioStatusFailed => 'Failed';

  @override
  String get aiStudioStatusCancelled => 'Cancelled';

  @override
  String get aiStudioStatusPending => 'Pending';

  @override
  String get aiStudioStatusProcessing => 'Processing';

  @override
  String aiStudioCardsCount(int count) {
    return '$count cards';
  }

  @override
  String get aiSaveErrorNoName => 'Enter a deck name.';

  @override
  String get aiSaveErrorNoDeck => 'Select a deck first.';

  @override
  String get streakEvolutionRoadmap => 'Evolution Roadmap';

  @override
  String get streakMilestoneAchievements => 'Milestone Achievements';

  @override
  String get streakConsistencyHistory => 'Consistency History (Last 30 Days)';

  @override
  String get streakClaimedRewardsHistory => 'Claimed Rewards History';

  @override
  String get streakActiveBadge => 'ACTIVE';

  @override
  String get streakMaximized => 'Legendary Tree Maximized! 👑';

  @override
  String get streakNoRewards => 'No milestone rewards claimed yet.';

  @override
  String streakDaysRemaining(int count, String stage) {
    return '$count days until $stage';
  }

  @override
  String streakGrowthStage(String stage) {
    return 'Growth Stage: $stage';
  }

  @override
  String streakCurrentDays(int count) {
    return '$count Day Active Streak';
  }

  @override
  String streakDayCount(int count) {
    return '$count Day Streak';
  }

  @override
  String get streakStageSeed => 'Seed';

  @override
  String get streakStageSprout => 'Sprout';

  @override
  String get streakStageYoungTree => 'Young Tree';

  @override
  String get streakStageBloomingTree => 'Blooming Tree';

  @override
  String get streakStageAncientTree => 'Ancient Tree';

  @override
  String get streakStageLegendaryTree => 'Legendary Tree';

  @override
  String streakLastReward(String reward) {
    return 'Last Reward: $reward';
  }

  @override
  String streakNextReward(String reward) {
    return 'Next Reward: $reward';
  }

  @override
  String get streakNoLastReward => 'Last Reward: None';

  @override
  String get streakMaxReward => 'Next Reward: None (Max Level)';

  @override
  String streakProgressDays(Object current, Object pct, Object target) {
    return '$current / $target Days ($pct%)';
  }
}
