import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'QuizAIPro'**
  String get appName;

  /// Generic loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Back navigation label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Skip button label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network.'**
  String get errorNetwork;

  /// Unauthorized error message
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get errorUnauthorized;

  /// Rate limit error message
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment.'**
  String get errorRateLimited;

  /// Welcome screen headline
  ///
  /// In en, this message translates to:
  /// **'Learn Smarter with AI'**
  String get authWelcomeTitle;

  /// Welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'AI-powered flashcards that adapt to how you learn.'**
  String get authWelcomeSubtitle;

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLogin;

  /// Register button label
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authRegister;

  /// Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// Apple sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Logout action label
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get authLogout;

  /// Login screen headline
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue learning'**
  String get authLoginSubtitle;

  /// Register screen headline
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterTitle;

  /// Register screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Start your AI learning journey'**
  String get authRegisterSubtitle;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// Username field placeholder
  ///
  /// In en, this message translates to:
  /// **'your_username'**
  String get authUsernamePlaceholder;

  /// Email field placeholder
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get authEmailPlaceholder;

  /// Login identifier field label (email or username)
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get authIdentifier;

  /// Login identifier field placeholder
  ///
  /// In en, this message translates to:
  /// **'email or username'**
  String get authIdentifierPlaceholder;

  /// Password field placeholder
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authPasswordPlaceholder;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// Confirm password field placeholder
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get authConfirmPasswordPlaceholder;

  /// Password field placeholder on the login screen
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get authPasswordHintLogin;

  /// Confirm password required validation message
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get authConfirmPasswordRequired;

  /// Get started button label on welcome screen
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get authGetStarted;

  /// Login button label on welcome screen
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get authAlreadyHaveAccount;

  /// Divider label between email auth and social auth
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get authOrContinueWith;

  /// Sign in button label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// Create account button label
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// Prompt for users without an account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authNoAccount;

  /// Sign up link label
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// Prompt for users with an existing account
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authHaveAccount;

  /// Sign in link label on register screen
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInLink;

  /// Terms notice on register screen
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to our\nTerms of Service and Privacy Policy.'**
  String get authTermsNotice;

  /// Weak password strength label
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get authPasswordStrengthWeak;

  /// Fair password strength label
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get authPasswordStrengthFair;

  /// Strong password strength label
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get authPasswordStrengthStrong;

  /// Very strong password strength label
  ///
  /// In en, this message translates to:
  /// **'Very strong'**
  String get authPasswordStrengthVeryStrong;

  /// Field required validation message
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String validationRequired(String field);

  /// Invalid email validation message
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmail;

  /// Password too short validation message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordMin;

  /// Passwords mismatch validation message
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsNoMatch;

  /// Username too short validation message
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get validationUsernameMin;

  /// Username too long validation message
  ///
  /// In en, this message translates to:
  /// **'Username must be at most 20 characters'**
  String get validationUsernameMax;

  /// Username invalid chars validation message
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers and underscores'**
  String get validationUsernameChars;

  /// Fallback error message for unhandled exceptions
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorUnexpected;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Library tab label
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Discover tab label
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// Arena tab label
  ///
  /// In en, this message translates to:
  /// **'Arena'**
  String get navArena;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Placeholder text on the Arena screen
  ///
  /// In en, this message translates to:
  /// **'Arena — Coming soon'**
  String get arenaComingSoon;

  /// Placeholder text on the Profile screen
  ///
  /// In en, this message translates to:
  /// **'Profile — Coming soon'**
  String get profileComingSoon;

  /// Placeholder text on the Home screen
  ///
  /// In en, this message translates to:
  /// **'Home — Coming soon'**
  String get homeComingSoon;

  /// Discover screen app bar title
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// Placeholder text on the Discover screen
  ///
  /// In en, this message translates to:
  /// **'Discover — Coming soon'**
  String get discoverComingSoon;

  /// Placeholder text on the Duel screen
  ///
  /// In en, this message translates to:
  /// **'Duel — Coming soon'**
  String get duelComingSoon;

  /// Placeholder text on the Live Test screen
  ///
  /// In en, this message translates to:
  /// **'Live Test — Coming soon'**
  String get liveTestComingSoon;

  /// Placeholder text on the Notifications screen
  ///
  /// In en, this message translates to:
  /// **'Notifications — Coming soon'**
  String get notificationsComingSoon;

  /// Streak counter on home screen
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String homeStreak(int count);

  /// Day streak label
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get dashboardStreakDay;

  /// Best streak label
  ///
  /// In en, this message translates to:
  /// **'Best: {count} days'**
  String dashboardStreakBest(int count);

  /// Today status label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardStreakToday;

  /// Streak done status label
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get dashboardStreakDone;

  /// Remaining cards label
  ///
  /// In en, this message translates to:
  /// **'{count} cards left'**
  String dashboardCardsLeft(int count);

  /// Due cards count on home screen
  ///
  /// In en, this message translates to:
  /// **'{count} cards due'**
  String homeDueCards(int count);

  /// Start study session button
  ///
  /// In en, this message translates to:
  /// **'Start Studying'**
  String get studyStart;

  /// Card progress in study session
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String studyCardOf(int current, int total);

  /// AI Tutor input placeholder
  ///
  /// In en, this message translates to:
  /// **'Ask anything about your deck...'**
  String get tutorAskPlaceholder;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Daily goal setting label
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get settingsDailyGoal;

  /// Daily goal value display
  ///
  /// In en, this message translates to:
  /// **'{count} cards / day'**
  String settingsDailyGoalCards(int count);

  /// Morning greeting on dashboard
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get dashboardGreetingMorning;

  /// Afternoon greeting on dashboard
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get dashboardGreetingAfternoon;

  /// Evening greeting on dashboard
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get dashboardGreetingEvening;

  /// Daily goal card title
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dashboardDailyGoal;

  /// Daily goal completed label
  ///
  /// In en, this message translates to:
  /// **'Goal achieved!'**
  String get dashboardDailyGoalCompleted;

  /// Dashboard retention card title
  ///
  /// In en, this message translates to:
  /// **'Retention'**
  String get dashboardRetention;

  /// Prefix for the one-week retention forecast
  ///
  /// In en, this message translates to:
  /// **'in a week'**
  String get dashboardRetentionForecast;

  /// Label after the count of cards fading below target retention
  ///
  /// In en, this message translates to:
  /// **'fading'**
  String get dashboardRetentionFading;

  /// Explanation shown when tapping the retention card's help icon
  ///
  /// In en, this message translates to:
  /// **'Retention shows how much of what you\'ve studied you remember right now — computed by the FSRS algorithm from each card\'s memory stability and the time since your last review. \"In a week\" is the forecast if you don\'t review. \"Fading\" are cards you\'ve likely started to forget; tap the card to review those first.'**
  String get dashboardRetentionInfo;

  /// Ready-to-study card title
  ///
  /// In en, this message translates to:
  /// **'Ready to study'**
  String get dashboardReadyToStudy;

  /// Empty state message when nothing is due
  ///
  /// In en, this message translates to:
  /// **'All caught up! 🎉'**
  String get dashboardAllCaughtUp;

  /// XP value with suffix
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String dashboardXpLabel(int xp);

  /// XP required to reach next level
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to level {nextLevel}'**
  String dashboardXpToNextLevel(int xp, int nextLevel);

  /// Level badge text
  ///
  /// In en, this message translates to:
  /// **'L{level}'**
  String dashboardLevelBadge(int level);

  /// Overdue pill label
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get dashboardOverdue;

  /// Start studying CTA button
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dashboardStartStudying;

  /// Quick actions section header
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashboardQuickActions;

  /// Study quick action button
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get dashboardActionStudy;

  /// Discover quick action button
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get dashboardActionDiscover;

  /// AI Tutor quick action button
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get dashboardActionAiTutor;

  /// AI Studio quick action button label
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get dashboardActionAiStudio;

  /// Recent activity section header
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get dashboardRecentActivity;

  /// Empty activity list message
  ///
  /// In en, this message translates to:
  /// **'No activity yet. Start studying to see your progress!'**
  String get dashboardActivityEmpty;

  /// Activity item summary: cards reviewed and relative time
  ///
  /// In en, this message translates to:
  /// **'{count} cards · {time}'**
  String dashboardActivitySummary(int count, String time);

  /// Relative time in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String dashboardTimeAgoMinutes(int minutes);

  /// Relative time in hours
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String dashboardTimeAgoHours(int hours);

  /// Relative time in days
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String dashboardTimeAgoDays(int days);

  /// XP earned badge with plus sign
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String dashboardXpEarned(int xp);

  /// Activity detail label for a flashcard study session
  ///
  /// In en, this message translates to:
  /// **'Study session'**
  String get dashboardActivityTypeStudy;

  /// Activity detail label for a completed test
  ///
  /// In en, this message translates to:
  /// **'Test completed'**
  String get dashboardActivityTypeTest;

  /// Activity detail label for a duel
  ///
  /// In en, this message translates to:
  /// **'Duel'**
  String get dashboardActivityTypeDuel;

  /// Activity detail label for an AI tutor session
  ///
  /// In en, this message translates to:
  /// **'AI Tutor session'**
  String get dashboardActivityTypeAiTutor;

  /// Marketplace screen title
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get marketplaceTitle;

  /// Explore tab label
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get marketplaceTabExplore;

  /// Collections tab label
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get marketplaceTabCollections;

  /// Learning paths tab label
  ///
  /// In en, this message translates to:
  /// **'Paths'**
  String get marketplaceTabPaths;

  /// Search bar hint text
  ///
  /// In en, this message translates to:
  /// **'Search decks...'**
  String get marketplaceSearchHint;

  /// Sort filter section label
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get marketplaceFilterSort;

  /// Difficulty filter section label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get marketplaceFilterDifficulty;

  /// Pro only filter toggle label
  ///
  /// In en, this message translates to:
  /// **'Pro decks only'**
  String get marketplaceFilterProOnly;

  /// Apply filter button label
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get marketplaceFilterApply;

  /// Reset filter button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get marketplaceFilterReset;

  /// All subjects chip label
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get marketplaceFilterAllSubjects;

  /// Empty decks list message
  ///
  /// In en, this message translates to:
  /// **'No decks found. Try changing your filters.'**
  String get marketplaceNoDecks;

  /// Empty collections list message
  ///
  /// In en, this message translates to:
  /// **'No collections available yet.'**
  String get marketplaceNoCollections;

  /// Empty paths list message
  ///
  /// In en, this message translates to:
  /// **'No learning paths available yet.'**
  String get marketplaceNoPaths;

  /// Enrolled count label on learning path card
  ///
  /// In en, this message translates to:
  /// **'Enrolled'**
  String get marketplaceEnroll;

  /// About section header on deck detail
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get marketplaceDeckAbout;

  /// Preview cards button label
  ///
  /// In en, this message translates to:
  /// **'Preview cards'**
  String get marketplaceDeckPreview;

  /// Clone deck button label
  ///
  /// In en, this message translates to:
  /// **'Clone to my library'**
  String get marketplaceDeckClone;

  /// Already cloned status label
  ///
  /// In en, this message translates to:
  /// **'Already in your library'**
  String get marketplaceDeckAlreadyCloned;

  /// Cards stat label on deck detail
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get marketplaceCards;

  /// Rating stat label on deck detail
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get marketplaceRating;

  /// Reviews section title
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get marketplaceReviews;

  /// Rate-this-deck prompt
  ///
  /// In en, this message translates to:
  /// **'Rate this deck'**
  String get marketplaceRateThis;

  /// Review text field hint
  ///
  /// In en, this message translates to:
  /// **'Share your impression (optional)'**
  String get marketplaceReviewHint;

  /// Submit-review button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get marketplaceSubmitReview;

  /// Update-review button
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get marketplaceUpdateReview;

  /// Report-review button
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get marketplaceReportReview;

  /// Empty reviews state
  ///
  /// In en, this message translates to:
  /// **'No reviews yet — be the first!'**
  String get marketplaceNoReviews;

  /// No ratings yet label
  ///
  /// In en, this message translates to:
  /// **'No ratings'**
  String get marketplaceNoRatings;

  /// Label for the current user's own review
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get marketplaceYou;

  /// Clones stat label on deck detail
  ///
  /// In en, this message translates to:
  /// **'Clones'**
  String get marketplaceClones;

  /// Likes stat label on deck detail
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get marketplaceLikes;

  /// Card front face label in preview
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get marketplaceCardFront;

  /// Card back face label in preview
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get marketplaceCardBack;

  /// Search idle state message
  ///
  /// In en, this message translates to:
  /// **'Search for decks, subjects, or creators to get started.'**
  String get marketplaceSearchIdle;

  /// Search empty state message
  ///
  /// In en, this message translates to:
  /// **'No results found. Try adjusting your search terms.'**
  String get marketplaceSearchEmpty;

  /// Sort by popular
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get marketplaceSortPopular;

  /// Sort by newest
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get marketplaceSortNewest;

  /// Sort by rating
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get marketplaceSortRating;

  /// Sort alphabetical
  ///
  /// In en, this message translates to:
  /// **'A–Z'**
  String get marketplaceSortAlphabetical;

  /// Number of cards in a deck
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String marketplaceCardCount(int count);

  /// Number of decks in a collection/path
  ///
  /// In en, this message translates to:
  /// **'{count} decks'**
  String marketplaceDeckCount(int count);

  /// Estimated hours
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String marketplaceHours(int hours);

  /// Pro badge text
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get marketplaceProBadge;

  /// Library screen title
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get libraryTitle;

  /// Decks tab label
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get libraryTabDecks;

  /// Collections tab label in library
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get libraryTabCollections;

  /// Favorites tab label
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get libraryTabFavorites;

  /// Library search bar hint
  ///
  /// In en, this message translates to:
  /// **'Search my library...'**
  String get librarySearchHint;

  /// Recent decks section label
  ///
  /// In en, this message translates to:
  /// **'Recently Studied'**
  String get libraryRecentDecks;

  /// Sort sheet title
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get librarySortTitle;

  /// Sort by date added label
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get librarySortDateAdded;

  /// Sort by name label
  ///
  /// In en, this message translates to:
  /// **'Name (A–Z)'**
  String get librarySortName;

  /// Sort by recently studied label
  ///
  /// In en, this message translates to:
  /// **'Recently Studied'**
  String get librarySortRecent;

  /// Sort by card count label
  ///
  /// In en, this message translates to:
  /// **'Card Count'**
  String get librarySortCardCount;

  /// Sort by due cards label
  ///
  /// In en, this message translates to:
  /// **'Due Cards'**
  String get librarySortDueCards;

  /// Filter button label
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get libraryFilter;

  /// Apply filter button
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get libraryFilterApply;

  /// Reset filter button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get libraryFilterReset;

  /// Difficulty filter label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get libraryFilterDifficulty;

  /// Show archived filter label
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get libraryFilterArchived;

  /// Due only filter label
  ///
  /// In en, this message translates to:
  /// **'Due cards only'**
  String get libraryFilterDueOnly;

  /// Filter difficulty any
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get libraryFilterDifficultyAny;

  /// Filter difficulty beginner
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get libraryFilterDifficultyBeginner;

  /// Filter difficulty intermediate
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get libraryFilterDifficultyIntermediate;

  /// Filter difficulty advanced
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get libraryFilterDifficultyAdvanced;

  /// Empty decks message
  ///
  /// In en, this message translates to:
  /// **'No decks yet. Clone from the Marketplace to get started.'**
  String get libraryNoDecks;

  /// Empty collections message
  ///
  /// In en, this message translates to:
  /// **'No collections yet.'**
  String get libraryNoCollections;

  /// Empty favorites message
  ///
  /// In en, this message translates to:
  /// **'No favorites yet. Star a deck to save it here.'**
  String get libraryNoFavorites;

  /// Study action label
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get libraryActionStudy;

  /// Favorite action label
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get libraryActionFavorite;

  /// Unfavorite action label
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get libraryActionUnfavorite;

  /// Archive action label
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get libraryActionArchive;

  /// Unarchive action label
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get libraryActionUnarchive;

  /// Delete action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get libraryActionDelete;

  /// Favorite added snackbar
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get libraryFavoriteAdded;

  /// Favorite removed snackbar
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get libraryFavoriteRemoved;

  /// Archived snackbar
  ///
  /// In en, this message translates to:
  /// **'Deck archived'**
  String get libraryArchived;

  /// Unarchived snackbar
  ///
  /// In en, this message translates to:
  /// **'Deck unarchived'**
  String get libraryUnarchived;

  /// Deleted snackbar
  ///
  /// In en, this message translates to:
  /// **'Deck deleted'**
  String get libraryDeleted;

  /// Delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Deck'**
  String get libraryDeleteTitle;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This cannot be undone.'**
  String libraryDeleteConfirm(String title);

  /// Search idle hint
  ///
  /// In en, this message translates to:
  /// **'Type to search your library.'**
  String get librarySearchIdle;

  /// Search empty in library
  ///
  /// In en, this message translates to:
  /// **'No decks found in your library.'**
  String get librarySearchEmpty;

  /// Due cards count badge on library deck list tile
  ///
  /// In en, this message translates to:
  /// **'{count} due'**
  String libraryDueCount(int count);

  /// Due cards stat label on library deck detail
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get libraryDeckDetailDue;

  /// Test action button label on library deck detail
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get libraryDeckDetailTest;

  /// Shown when a library deck id can't be resolved
  ///
  /// In en, this message translates to:
  /// **'Deck not found'**
  String get libraryDeckDetailNotFound;

  /// Empty state for the cards section on library deck detail
  ///
  /// In en, this message translates to:
  /// **'No cards in this deck yet.'**
  String get libraryDeckDetailNoCards;

  /// Generic edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Acknowledge / dismiss button
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonGotIt;

  /// Tooltip for the edit-deck button
  ///
  /// In en, this message translates to:
  /// **'Edit deck'**
  String get libraryDeckEditTooltip;

  /// Tooltip for the delete-deck button
  ///
  /// In en, this message translates to:
  /// **'Delete deck'**
  String get libraryDeckDeleteTooltip;

  /// Add-card button on the deck detail screen
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get libraryDeckAddCard;

  /// Chip marking an MCQ card
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get cardTileQuizChip;

  /// Chip marking a plain flashcard
  ///
  /// In en, this message translates to:
  /// **'Flashcard'**
  String get cardTileFlashcardChip;

  /// Reveal MCQ options
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get cardTileShowOptions;

  /// Hide MCQ options
  ///
  /// In en, this message translates to:
  /// **'Hide options'**
  String get cardTileHideOptions;

  /// Reveal the answer
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get cardTileShowAnswer;

  /// Hide the answer
  ///
  /// In en, this message translates to:
  /// **'Hide answer'**
  String get cardTileHideAnswer;

  /// Explanation section label on a card
  ///
  /// In en, this message translates to:
  /// **'EXPLANATION'**
  String get cardTileExplanation;

  /// Title when a deck has no MCQ cards
  ///
  /// In en, this message translates to:
  /// **'This deck has no quizzes'**
  String get deckNoTestsTitle;

  /// Body when a deck has no MCQ cards
  ///
  /// In en, this message translates to:
  /// **'Add cards with answer options (A, B, C…) to take a quiz.'**
  String get deckNoTestsBody;

  /// Title when a deck has no flashcards
  ///
  /// In en, this message translates to:
  /// **'This deck has no flashcards'**
  String get deckNoFlashcardsTitle;

  /// Body when a deck has no flashcards
  ///
  /// In en, this message translates to:
  /// **'Add flashcards to start studying this deck.'**
  String get deckNoFlashcardsBody;

  /// Delete-deck confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete deck?'**
  String get deckDeleteTitle;

  /// Delete-deck confirmation body
  ///
  /// In en, this message translates to:
  /// **'The deck and all its cards will be permanently deleted.'**
  String get deckDeleteBody;

  /// Delete-deck failure snackbar
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the deck'**
  String get deckDeleteFailed;

  /// Delete-card confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete card?'**
  String get cardDeleteTitle;

  /// Delete-card confirmation body
  ///
  /// In en, this message translates to:
  /// **'This action can\'t be undone.'**
  String get cardDeleteBody;

  /// Delete-card failure snackbar
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the card'**
  String get cardDeleteFailed;

  /// Label of the new-deck floating action button
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get libraryNewDeckFab;

  /// Card editor title when creating
  ///
  /// In en, this message translates to:
  /// **'New question'**
  String get cardEditorTitleNew;

  /// Card editor title when editing
  ///
  /// In en, this message translates to:
  /// **'Edit question'**
  String get cardEditorTitleEdit;

  /// Question field label
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get cardEditorQuestionLabel;

  /// Question field hint
  ///
  /// In en, this message translates to:
  /// **'Enter a question…'**
  String get cardEditorQuestionHint;

  /// Options section label
  ///
  /// In en, this message translates to:
  /// **'Answer options'**
  String get cardEditorOptionsLabel;

  /// Hint to mark the correct option
  ///
  /// In en, this message translates to:
  /// **'Mark the correct option'**
  String get cardEditorMarkCorrect;

  /// Add-option button
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get cardEditorAddOption;

  /// Shown when the max option count is reached
  ///
  /// In en, this message translates to:
  /// **'Max {count}'**
  String cardEditorMaxOptions(int count);

  /// Hint for an option input
  ///
  /// In en, this message translates to:
  /// **'Option {letter}'**
  String cardEditorOptionHint(String letter);

  /// Explanation field label
  ///
  /// In en, this message translates to:
  /// **'Explanation (optional)'**
  String get cardEditorExplanationLabel;

  /// Explanation field hint
  ///
  /// In en, this message translates to:
  /// **'Why this answer is correct…'**
  String get cardEditorExplanationHint;

  /// Validation: empty question
  ///
  /// In en, this message translates to:
  /// **'Enter a question'**
  String get cardEditorErrorQuestion;

  /// Validation: too few options
  ///
  /// In en, this message translates to:
  /// **'Add at least {count} options'**
  String cardEditorErrorMinOptions(int count);

  /// Validation: no correct option marked
  ///
  /// In en, this message translates to:
  /// **'Mark the correct option (it must not be empty)'**
  String get cardEditorErrorMarkCorrect;

  /// Save failure message
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Check your connection.'**
  String get cardEditorErrorSave;

  /// Deck editor title when creating
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get deckEditorTitleNew;

  /// Validation: empty deck name
  ///
  /// In en, this message translates to:
  /// **'Enter a deck name'**
  String get deckEditorErrorName;

  /// Deck name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get deckEditorNameLabel;

  /// Deck name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. History of Uzbekistan'**
  String get deckEditorNameHint;

  /// Deck description field label
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get deckEditorDescLabel;

  /// Create-deck button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get deckEditorCreate;

  /// XP remaining until the next level
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to level {level}'**
  String levelXpToNext(int xp, int level);

  /// Level-up celebration title
  ///
  /// In en, this message translates to:
  /// **'NEW LEVEL!'**
  String get levelUpNewLevel;

  /// Level-up celebration subtext
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great! Keep it up to unlock the next milestone.'**
  String get levelUpEncouragement;

  /// Level-up celebration dismiss button
  ///
  /// In en, this message translates to:
  /// **'GREAT'**
  String get levelUpGreat;

  /// Level journey load error
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the level track.'**
  String get levelJourneyLoadError;

  /// Milestones section header
  ///
  /// In en, this message translates to:
  /// **'REWARDS ROAD'**
  String get levelJourneyRewardsRoad;

  /// Milestone fallback name
  ///
  /// In en, this message translates to:
  /// **'Level {level} milestone'**
  String levelJourneyMilestone(int level);

  /// XP history section header
  ///
  /// In en, this message translates to:
  /// **'XP HISTORY'**
  String get levelJourneyXpHistory;

  /// Empty XP history
  ///
  /// In en, this message translates to:
  /// **'XP history is empty.'**
  String get levelJourneyXpHistoryEmpty;

  /// Level label
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelJourneyLevel(int level);

  /// XP remaining label
  ///
  /// In en, this message translates to:
  /// **'{xp} XP left'**
  String levelJourneyXpRemaining(int xp);

  /// Again grade button
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get flashcardsAgain;

  /// Hard grade button
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get flashcardsHard;

  /// Good grade button
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get flashcardsGood;

  /// Easy grade button
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get flashcardsEasy;

  /// Tap to flip card hint
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get flashcardsCardFlip;

  /// Label shown on the front face of a flashcard
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get flashcardsCardFront;

  /// Label shown on the back face of a flashcard
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get flashcardsCardBack;

  /// Smart mix mode label
  ///
  /// In en, this message translates to:
  /// **'Smart Mix'**
  String get flashcardsModeSmart;

  /// New cards mode label
  ///
  /// In en, this message translates to:
  /// **'New Cards'**
  String get flashcardsModeNew;

  /// Review mode label
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get flashcardsModeReview;

  /// Difficult mode label
  ///
  /// In en, this message translates to:
  /// **'Difficult'**
  String get flashcardsModeDifficult;

  /// Favorites mode label
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get flashcardsModeFavorite;

  /// Study mode reviewing cards slipping below target retention
  ///
  /// In en, this message translates to:
  /// **'Fading'**
  String get flashcardsModeFading;

  /// Error loading cards
  ///
  /// In en, this message translates to:
  /// **'Failed to load cards'**
  String get flashcardsLoadError;

  /// Quit study session button tooltip
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get flashcardsQuit;

  /// Quit confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'End this study session?'**
  String get flashcardsQuitConfirm;

  /// Confirm quit
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get flashcardsQuitYes;

  /// Cancel quit
  ///
  /// In en, this message translates to:
  /// **'Keep Studying'**
  String get flashcardsQuitNo;

  /// Completion screen title
  ///
  /// In en, this message translates to:
  /// **'Session Complete!'**
  String get flashcardsSessionComplete;

  /// Session stats heading
  ///
  /// In en, this message translates to:
  /// **'Your Results'**
  String get flashcardsSessionStats;

  /// Cards studied stat label
  ///
  /// In en, this message translates to:
  /// **'Cards studied'**
  String get flashcardsCardsStudied;

  /// New cards count label
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get flashcardsNewCards;

  /// Review cards count label
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get flashcardsReviewCards;

  /// Retention rate label
  ///
  /// In en, this message translates to:
  /// **'Retention'**
  String get flashcardsRetention;

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get flashcardsTimeSpent;

  /// Study again CTA
  ///
  /// In en, this message translates to:
  /// **'Study Again'**
  String get flashcardsStudyAgain;

  /// Return to library CTA
  ///
  /// In en, this message translates to:
  /// **'Back to Library'**
  String get flashcardsBackToLibrary;

  /// Test setup screen title
  ///
  /// In en, this message translates to:
  /// **'Test Setup'**
  String get testsSetupTitle;

  /// Test setup subtitle
  ///
  /// In en, this message translates to:
  /// **'Configure your test session'**
  String get testsSetupSubtitle;

  /// Question count selector label
  ///
  /// In en, this message translates to:
  /// **'Number of Questions'**
  String get testsQuestionCount;

  /// All questions option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get testsCountAll;

  /// Shuffle toggle label
  ///
  /// In en, this message translates to:
  /// **'Shuffle Questions'**
  String get testsShuffle;

  /// Timed mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Timed Mode'**
  String get testsTimedMode;

  /// Seconds per question label
  ///
  /// In en, this message translates to:
  /// **'Seconds per Question'**
  String get testsSecondsPerQuestion;

  /// Start test CTA
  ///
  /// In en, this message translates to:
  /// **'Start Test'**
  String get testsStart;

  /// Submit test CTA
  ///
  /// In en, this message translates to:
  /// **'Submit Test'**
  String get testsSubmit;

  /// Next question button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get testsNext;

  /// Previous question button
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get testsPrevious;

  /// Quit dialog title
  ///
  /// In en, this message translates to:
  /// **'Quit Test?'**
  String get testsQuitTitle;

  /// Quit dialog message
  ///
  /// In en, this message translates to:
  /// **'Your progress will be lost. Are you sure?'**
  String get testsQuitMessage;

  /// Cancel quit
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get testsQuitCancel;

  /// Confirm quit
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get testsQuitConfirm;

  /// Results screen title
  ///
  /// In en, this message translates to:
  /// **'Test Results'**
  String get testsResultsTitle;

  /// Score label 90%+
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get testsScoreExcellent;

  /// Score label 80-89%
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get testsScoreGreat;

  /// Score label 60-79%
  ///
  /// In en, this message translates to:
  /// **'Good Effort'**
  String get testsScoreGood;

  /// Score label 40-59%
  ///
  /// In en, this message translates to:
  /// **'Keep Practicing'**
  String get testsScorePractice;

  /// Score label below 40%
  ///
  /// In en, this message translates to:
  /// **'Need More Study'**
  String get testsScoreStudy;

  /// Correct answers stat
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get testsCorrect;

  /// Wrong answers stat
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get testsWrong;

  /// Duration stat label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get testsDuration;

  /// Weak areas section title
  ///
  /// In en, this message translates to:
  /// **'Weak Areas'**
  String get testsWeakAreas;

  /// Review answers CTA
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get testsReviewAnswers;

  /// Try again CTA
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get testsTryAgain;

  /// History CTA
  ///
  /// In en, this message translates to:
  /// **'View Test History'**
  String get testsViewHistory;

  /// Review screen title
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get testsReviewTitle;

  /// Button to ask AI to diagnose a wrong answer
  ///
  /// In en, this message translates to:
  /// **'Why did I get this wrong?'**
  String get testsDiagnoseButton;

  /// Loading label while AI analyzes the mistake
  ///
  /// In en, this message translates to:
  /// **'Analyzing…'**
  String get testsDiagnoseLoading;

  /// Diagnosis section heading
  ///
  /// In en, this message translates to:
  /// **'Why your answer is wrong'**
  String get testsDiagnoseWhyWrong;

  /// Diagnosis section heading
  ///
  /// In en, this message translates to:
  /// **'Why the correct answer is right'**
  String get testsDiagnoseWhyCorrect;

  /// Diagnosis section heading
  ///
  /// In en, this message translates to:
  /// **'Likely misconception'**
  String get testsDiagnoseMisconception;

  /// Diagnosis section heading
  ///
  /// In en, this message translates to:
  /// **'How to remember'**
  String get testsDiagnoseTip;

  /// Diagnosis failure message
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t analyze the mistake. Try again later.'**
  String get testsDiagnoseError;

  /// Button to generate a reinforcing follow-up question
  ///
  /// In en, this message translates to:
  /// **'Practice: similar question'**
  String get testsFollowupButton;

  /// Shown when the follow-up answer is right
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get testsFollowupCorrect;

  /// Shown when the follow-up answer is wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get testsFollowupWrong;

  /// Follow-up generation failure message
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create a question. Try again later.'**
  String get testsFollowupError;

  /// History screen title
  ///
  /// In en, this message translates to:
  /// **'Test History'**
  String get testsHistoryTitle;

  /// Empty history message
  ///
  /// In en, this message translates to:
  /// **'No tests taken yet'**
  String get testsHistoryEmpty;

  /// Empty history subtitle
  ///
  /// In en, this message translates to:
  /// **'Complete a test to see your results here'**
  String get testsHistoryEmptySubtitle;

  /// Load error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load questions'**
  String get testsLoadError;

  /// Shown when a deck has no MCQ cards to build a test from
  ///
  /// In en, this message translates to:
  /// **'This deck has no quiz questions to test.'**
  String get testsNoQuestions;

  /// History load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get testsHistoryLoadError;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get testsRetry;

  /// Score detail line
  ///
  /// In en, this message translates to:
  /// **'{correct} correct out of {total} questions'**
  String testsCorrectOfTotal(int correct, int total);

  /// Review answers question position label
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String testsReviewQuestionOf(int current, int total);

  /// Short seconds value, e.g. 30s
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String testsSecondsShort(int seconds);

  /// Short minutes and seconds duration, e.g. 1m 30s
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String testsMinutesSecondsShort(int minutes, int seconds);

  /// Score fraction, e.g. 7 / 10 correct
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total} correct'**
  String testsScoreFraction(int correct, int total);

  /// AI Tutor screen title
  ///
  /// In en, this message translates to:
  /// **'AI Tutor'**
  String get tutorTitle;

  /// New conversation CTA
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get tutorNewConversation;

  /// Title input hint
  ///
  /// In en, this message translates to:
  /// **'Conversation title'**
  String get tutorConversationTitle;

  /// Create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get tutorCreate;

  /// Rename dialog title
  ///
  /// In en, this message translates to:
  /// **'Rename Conversation'**
  String get tutorRenameTitle;

  /// Rename button
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get tutorRename;

  /// New title hint
  ///
  /// In en, this message translates to:
  /// **'New title'**
  String get tutorNewTitle;

  /// Delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Conversation?'**
  String get tutorDeleteTitle;

  /// Delete dialog message
  ///
  /// In en, this message translates to:
  /// **'This conversation and all its messages will be permanently deleted.'**
  String get tutorDeleteMessage;

  /// Pin action
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get tutorPin;

  /// Unpin action
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get tutorUnpin;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tutorDelete;

  /// Pinned section header
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get tutorPinnedSection;

  /// Conversations section header
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get tutorConversationsSection;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get tutorEmpty;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with your AI tutor'**
  String get tutorEmptySubtitle;

  /// Search hint
  ///
  /// In en, this message translates to:
  /// **'Search conversations…'**
  String get tutorSearch;

  /// No search results
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String tutorNoResults(String query);

  /// Deck context badge
  ///
  /// In en, this message translates to:
  /// **'With deck context'**
  String get tutorWithDeckContext;

  /// Chat welcome title
  ///
  /// In en, this message translates to:
  /// **'Ask me anything!'**
  String get tutorAskAnything;

  /// Chat welcome subtitle
  ///
  /// In en, this message translates to:
  /// **'I can explain concepts, quiz you on topics, or help you understand your flashcards.'**
  String get tutorWelcomeSubtitle;

  /// Chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Ask your AI tutor…'**
  String get tutorInputHint;

  /// Copy snackbar
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get tutorCopied;

  /// SSE connection lost error
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Please try again.'**
  String get tutorConnectionLost;

  /// Load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load conversations'**
  String get tutorLoadError;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get tutorRetry;

  /// No description provided for @aiStudioTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Studio'**
  String get aiStudioTitle;

  /// No description provided for @aiStudioTabGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get aiStudioTabGenerate;

  /// No description provided for @aiStudioTabFindAnswers.
  ///
  /// In en, this message translates to:
  /// **'Find Answers'**
  String get aiStudioTabFindAnswers;

  /// No description provided for @aiStudioHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get aiStudioHistory;

  /// No description provided for @aiStudioSourceTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get aiStudioSourceTopic;

  /// No description provided for @aiStudioSourceText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get aiStudioSourceText;

  /// No description provided for @aiStudioSourcePdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get aiStudioSourcePdf;

  /// No description provided for @aiStudioTopicLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get aiStudioTopicLabel;

  /// No description provided for @aiStudioTopicHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. The French Revolution, Calculus, Human Body…'**
  String get aiStudioTopicHint;

  /// No description provided for @aiStudioTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Paste your text (min 50 characters)'**
  String get aiStudioTextLabel;

  /// No description provided for @aiStudioTextHint.
  ///
  /// In en, this message translates to:
  /// **'Paste an article, textbook excerpt, or any text…'**
  String get aiStudioTextHint;

  /// No description provided for @aiStudioPdfLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get aiStudioPdfLabel;

  /// No description provided for @aiStudioPdfChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose PDF file'**
  String get aiStudioPdfChoose;

  /// No description provided for @aiStudioPdfReady.
  ///
  /// In en, this message translates to:
  /// **'PDF ready'**
  String get aiStudioPdfReady;

  /// No description provided for @aiStudioCardCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of cards'**
  String get aiStudioCardCountLabel;

  /// No description provided for @aiStudioQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get aiStudioQualityLabel;

  /// No description provided for @aiStudioQualityFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get aiStudioQualityFast;

  /// No description provided for @aiStudioQualityBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get aiStudioQualityBalanced;

  /// No description provided for @aiStudioQualityPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get aiStudioQualityPremium;

  /// No description provided for @aiStudioQualityFastDescription.
  ///
  /// In en, this message translates to:
  /// **'~15 sec'**
  String get aiStudioQualityFastDescription;

  /// No description provided for @aiStudioQualityBalancedDescription.
  ///
  /// In en, this message translates to:
  /// **'~30 sec'**
  String get aiStudioQualityBalancedDescription;

  /// No description provided for @aiStudioQualityPremiumDescription.
  ///
  /// In en, this message translates to:
  /// **'~60 sec · best quality'**
  String get aiStudioQualityPremiumDescription;

  /// No description provided for @aiStudioGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get aiStudioGenerate;

  /// No description provided for @aiStudioGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get aiStudioGenerating;

  /// No description provided for @aiStudioFindAnswersHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. What caused World War I?'**
  String get aiStudioFindAnswersHint;

  /// No description provided for @aiStudioFindAnswersLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask any question'**
  String get aiStudioFindAnswersLabel;

  /// No description provided for @aiStudioAiAnswer.
  ///
  /// In en, this message translates to:
  /// **'AI Answer'**
  String get aiStudioAiAnswer;

  /// No description provided for @aiStudioKeyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get aiStudioKeyPoints;

  /// No description provided for @aiProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get aiProgressTitle;

  /// No description provided for @aiProgressFrom.
  ///
  /// In en, this message translates to:
  /// **'Generating from {source}'**
  String aiProgressFrom(String source);

  /// No description provided for @aiProgressQuality.
  ///
  /// In en, this message translates to:
  /// **'{count} cards · {quality} quality'**
  String aiProgressQuality(int count, String quality);

  /// No description provided for @aiProgressFailed.
  ///
  /// In en, this message translates to:
  /// **'Generation failed. Please try again.'**
  String get aiProgressFailed;

  /// No description provided for @aiProgressGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get aiProgressGoBack;

  /// No description provided for @aiResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'cards generated'**
  String get aiResultsTitle;

  /// No description provided for @aiResultsTitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get aiResultsTitleDefault;

  /// No description provided for @aiResultsSelected.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String aiResultsSelected(int selected, int total);

  /// No description provided for @aiResultsSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get aiResultsSelectAll;

  /// No description provided for @aiResultsDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get aiResultsDeselectAll;

  /// No description provided for @aiResultsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get aiResultsNew;

  /// No description provided for @aiResultsSaveToDeck.
  ///
  /// In en, this message translates to:
  /// **'Save to Deck'**
  String get aiResultsSaveToDeck;

  /// No description provided for @aiResultsCardsSaved.
  ///
  /// In en, this message translates to:
  /// **'cards saved!'**
  String get aiResultsCardsSaved;

  /// No description provided for @aiResultsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cards were generated.'**
  String get aiResultsEmpty;

  /// No description provided for @aiResultsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different topic or use more text.'**
  String get aiResultsEmptySubtitle;

  /// No description provided for @aiResultsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get aiResultsTryAgain;

  /// No description provided for @aiHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Generation History'**
  String get aiHistoryTitle;

  /// No description provided for @aiHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No generations yet'**
  String get aiHistoryEmpty;

  /// No description provided for @aiHistoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your card generation history will appear here.'**
  String get aiHistoryEmptySubtitle;

  /// No description provided for @aiSaveToDeck.
  ///
  /// In en, this message translates to:
  /// **'Save {count} cards to…'**
  String aiSaveToDeck(int count);

  /// No description provided for @aiSaveCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new deck'**
  String get aiSaveCreateNew;

  /// No description provided for @aiSaveDeckName.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get aiSaveDeckName;

  /// No description provided for @aiSaveSaveCards.
  ///
  /// In en, this message translates to:
  /// **'Save Cards'**
  String get aiSaveSaveCards;

  /// No description provided for @aiExplainTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Explanation'**
  String get aiExplainTitle;

  /// No description provided for @aiExplainQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get aiExplainQuestion;

  /// No description provided for @aiExplainAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get aiExplainAnswer;

  /// No description provided for @aiExplainExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get aiExplainExplanation;

  /// No description provided for @aiExplainLoading.
  ///
  /// In en, this message translates to:
  /// **'AI is explaining this concept…'**
  String get aiExplainLoading;

  /// No description provided for @aiExplainRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get aiExplainRetry;

  /// No description provided for @aiStudioCharCount.
  ///
  /// In en, this message translates to:
  /// **'{count} chars'**
  String aiStudioCharCount(int count);

  /// No description provided for @aiStudioCharCountNeedMore.
  ///
  /// In en, this message translates to:
  /// **'{count} chars (need {more} more)'**
  String aiStudioCharCountNeedMore(int count, int more);

  /// No description provided for @aiStudioStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get aiStudioStatusFailed;

  /// No description provided for @aiStudioStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get aiStudioStatusCancelled;

  /// No description provided for @aiStudioStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get aiStudioStatusPending;

  /// No description provided for @aiStudioStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get aiStudioStatusProcessing;

  /// No description provided for @aiStudioCardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String aiStudioCardsCount(int count);

  /// No description provided for @aiSaveErrorNoName.
  ///
  /// In en, this message translates to:
  /// **'Enter a deck name.'**
  String get aiSaveErrorNoName;

  /// No description provided for @aiSaveErrorNoDeck.
  ///
  /// In en, this message translates to:
  /// **'Select a deck first.'**
  String get aiSaveErrorNoDeck;

  /// No description provided for @streakEvolutionRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Evolution Roadmap'**
  String get streakEvolutionRoadmap;

  /// No description provided for @streakMilestoneAchievements.
  ///
  /// In en, this message translates to:
  /// **'Milestone Achievements'**
  String get streakMilestoneAchievements;

  /// No description provided for @streakConsistencyHistory.
  ///
  /// In en, this message translates to:
  /// **'Consistency History (Last 30 Days)'**
  String get streakConsistencyHistory;

  /// No description provided for @streakClaimedRewardsHistory.
  ///
  /// In en, this message translates to:
  /// **'Claimed Rewards History'**
  String get streakClaimedRewardsHistory;

  /// No description provided for @streakActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get streakActiveBadge;

  /// No description provided for @streakMaximized.
  ///
  /// In en, this message translates to:
  /// **'Legendary Tree Maximized! 👑'**
  String get streakMaximized;

  /// No description provided for @streakNoRewards.
  ///
  /// In en, this message translates to:
  /// **'No milestone rewards claimed yet.'**
  String get streakNoRewards;

  /// Days remaining to next evolution stage
  ///
  /// In en, this message translates to:
  /// **'{count} days until {stage}'**
  String streakDaysRemaining(int count, String stage);

  /// Growth Stage title
  ///
  /// In en, this message translates to:
  /// **'Growth Stage: {stage}'**
  String streakGrowthStage(String stage);

  /// Current active day count
  ///
  /// In en, this message translates to:
  /// **'{count} Day Active Streak'**
  String streakCurrentDays(int count);

  /// General day count label
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak'**
  String streakDayCount(int count);

  /// No description provided for @streakStageSeed.
  ///
  /// In en, this message translates to:
  /// **'Seed'**
  String get streakStageSeed;

  /// No description provided for @streakStageSprout.
  ///
  /// In en, this message translates to:
  /// **'Sprout'**
  String get streakStageSprout;

  /// No description provided for @streakStageYoungTree.
  ///
  /// In en, this message translates to:
  /// **'Young Tree'**
  String get streakStageYoungTree;

  /// No description provided for @streakStageBloomingTree.
  ///
  /// In en, this message translates to:
  /// **'Blooming Tree'**
  String get streakStageBloomingTree;

  /// No description provided for @streakStageAncientTree.
  ///
  /// In en, this message translates to:
  /// **'Ancient Tree'**
  String get streakStageAncientTree;

  /// Legendary evolution stage
  ///
  /// In en, this message translates to:
  /// **'Legendary Tree'**
  String get streakStageLegendaryTree;

  /// 365+ day evolution stage
  ///
  /// In en, this message translates to:
  /// **'Eternal Tree'**
  String get streakStageEternalTree;

  /// Last milestone reward claimed
  ///
  /// In en, this message translates to:
  /// **'Last Reward: {reward}'**
  String streakLastReward(String reward);

  /// Next milestone reward
  ///
  /// In en, this message translates to:
  /// **'Next Reward: {reward}'**
  String streakNextReward(String reward);

  /// No description provided for @streakNoLastReward.
  ///
  /// In en, this message translates to:
  /// **'Last Reward: None'**
  String get streakNoLastReward;

  /// No description provided for @streakMaxReward.
  ///
  /// In en, this message translates to:
  /// **'Next Reward: None (Max Level)'**
  String get streakMaxReward;

  /// No description provided for @streakProgressDays.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target} Days ({pct}%)'**
  String streakProgressDays(Object current, Object pct, Object target);

  /// No description provided for @streakTreeGrewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your tree grew!'**
  String get streakTreeGrewTitle;

  /// No description provided for @streakTreeGrewBody.
  ///
  /// In en, this message translates to:
  /// **'New stage: {stage}. Keep it up — come back every day!'**
  String streakTreeGrewBody(String stage);

  /// No description provided for @streakTreeIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your tree is growing'**
  String get streakTreeIntroTitle;

  /// No description provided for @streakTreeIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Come back daily and hit your goal — your tree grows from a seed all the way to the Eternal Tree.'**
  String get streakTreeIntroBody;

  /// No description provided for @streakTreeIntroCta.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get streakTreeIntroCta;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
