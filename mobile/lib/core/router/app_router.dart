import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/router/router_notifier.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';
import 'package:quizaipro_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:quizaipro_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:quizaipro_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:quizaipro_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:quizaipro_mobile/features/shell/app_shell.dart';
import 'package:quizaipro_mobile/features/splash/splash_screen.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:quizaipro_mobile/features/library/presentation/screens/library_deck_detail_screen.dart';
import 'package:quizaipro_mobile/features/library/presentation/screens/library_screen.dart';
import 'package:quizaipro_mobile/features/library/presentation/screens/library_search_screen.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/screens/marketplace_screen.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/screens/deck_detail_screen.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/screens/search_screen.dart';
import 'package:quizaipro_mobile/features/arena/presentation/screens/arena_screen.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_mode.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/screens/study_screen.dart';
import 'package:quizaipro_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:quizaipro_mobile/features/tests/presentation/screens/review_answers_screen.dart';
import 'package:quizaipro_mobile/features/tests/presentation/screens/test_history_screen.dart';
import 'package:quizaipro_mobile/features/tests/presentation/screens/test_results_screen.dart';
import 'package:quizaipro_mobile/features/tests/presentation/screens/test_session_screen.dart';
import 'package:quizaipro_mobile/features/tests/presentation/screens/test_setup_screen.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/screens/ai_studio_screen.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/screens/explain_card_screen.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/screens/generation_history_screen.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/screens/generation_progress_screen.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/screens/generation_results_screen.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/screens/conversations_screen.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/screens/tutor_chat_screen.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/screens/streak_journey_screen.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/screens/level_journey_screen.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/screens/activity_detail_screen.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/activity_item.dart';


part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final notifier = ref.watch(routerNotifierProvider.notifier);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      // ── Splash ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.welcome,
        name: AppRoutes.welcomeName,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Immersive (root navigator — rendered above shell) ──────────────────
      GoRoute(
        path: AppRoutes.tutor,
        name: AppRoutes.tutorName,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          const ConversationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.tutorChat,
        name: AppRoutes.tutorChatName,
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          return _fullScreenPage(
            state,
            TutorChatScreen(
              conversationId: q['conversationId'] ?? '',
              conversationTitle: q['conversationTitle'] ?? '',
              deckId: q['deckId'],
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.studySession,
        name: AppRoutes.studySessionName,
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          final deckId = q['deckId'] ?? '';
          final modeStr = q['mode'] ?? 'smart';
          final deckTitle = q['deckTitle'] ?? '';
          final mode = StudyMode.values.firstWhere(
            (m) => m.name == modeStr,
            orElse: () => StudyMode.smart,
          );
          return _fullScreenPage(
            state,
            StudyScreen(
              deckId: deckId,
              mode: mode,
              deckTitle: deckTitle,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.testSetup,
        name: AppRoutes.testSetupName,
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          final deckId = q['deckId'] ?? '';
          final deckTitle = q['deckTitle'] ?? '';
          return _fullScreenPage(
            state,
            TestSetupScreen(deckId: deckId, deckTitle: deckTitle),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.testSession,
        name: AppRoutes.testSessionName,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          const TestSessionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.testResults,
        name: AppRoutes.testResultsName,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          const TestResultsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.testReview,
        name: AppRoutes.testReviewName,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          const ReviewAnswersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.testHistory,
        name: AppRoutes.testHistoryName,
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          return _fullScreenPage(
            state,
            TestHistoryScreen(
              deckId: q['deckId'] ?? '',
              deckTitle: q['deckTitle'] ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.aiGenerationStudio,
        name: AppRoutes.aiGenerationStudioName,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          const AiStudioScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiGenerationProgress,
        name: AppRoutes.aiGenerationProgressName,
        pageBuilder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          return _fullScreenPage(
            state,
            GenerationProgressScreen(jobId: jobId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.aiGenerationResults,
        name: AppRoutes.aiGenerationResultsName,
        pageBuilder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          return _fullScreenPage(
            state,
            GenerationResultsScreen(jobId: jobId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.aiGenerationHistory,
        name: AppRoutes.aiGenerationHistoryName,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          const GenerationHistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiGenerationExplain,
        name: AppRoutes.aiGenerationExplainName,
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          return _fullScreenPage(
            state,
            ExplainCardScreen(
              question: q['question'] ?? '',
              answer: q['answer'] ?? '',
              deckId: q['deckId'],
            ),
          );
        },
      ),
      GoRoute(
        path: '/duel/:duelId',
        name: AppRoutes.duelSessionName,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context).duelComingSoon),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/live/:code',
        name: AppRoutes.liveSessionName,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context).liveTestComingSoon),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: AppRoutes.notificationsName,
        pageBuilder: (context, state) => _modalPage(
          state,
          Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context).notificationsComingSoon),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/u/:username',
        name: AppRoutes.publicProfileName,
        builder: (context, state) =>
            Scaffold(body: Center(child: Text('Profile: ${state.pathParameters['username']}'))),
      ),
      GoRoute(
        path: AppRoutes.streakJourney,
        name: AppRoutes.streakJourneyName,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          const StreakJourneyScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.levelJourney,
        name: AppRoutes.levelJourneyName,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          const LevelJourneyScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.activityDetail,
        name: AppRoutes.activityDetailName,
        pageBuilder: (context, state) => _fullScreenPage(
          state,
          ActivityDetailScreen(item: state.extra as ActivityItem),
        ),
      ),


      // ── App Shell — 5 persistent tabs ─────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.homeName,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.library,
                name: AppRoutes.libraryName,
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.libraryDeck,
                    name: AppRoutes.libraryDeckName,
                    builder: (context, state) => LibraryDeckDetailScreen(
                      deckId: state.pathParameters['deckId']!,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.librarySearch,
                    name: AppRoutes.librarySearchName,
                    builder: (context, state) => const LibrarySearchScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                name: AppRoutes.discoverName,
                builder: (context, state) => const MarketplaceScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.discoverDeck,
                    name: AppRoutes.discoverDeckName,
                    builder: (context, state) => DeckDetailScreen(
                      deckId: state.pathParameters['deckId']!,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.discoverSearch,
                    name: AppRoutes.discoverSearchName,
                    builder: (context, state) => const SearchScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.arena,
                name: AppRoutes.arenaName,
                builder: (context, state) => const ArenaScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRoutes.profileName,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

String? _redirect(AppRouterRef ref, GoRouterState state) {
  final authAsync = ref.read(authNotifierProvider);
  final location = state.matchedLocation;

  // Only unresolved auth should hold the splash route. Startup auth errors are
  // treated as unauthenticated so the app never remains on splash forever.
  if (authAsync.isLoading) {
    return null;
  }

  final isOnSplash = location == AppRoutes.splash;
  final isOnAuth = location.startsWith('/auth');

  if (authAsync.hasError) {
    return isOnAuth ? null : AppRoutes.welcome;
  }

  final isAuthenticated = authAsync.value?.isAuthenticated ?? false;

  if (isOnSplash) {
    return isAuthenticated ? AppRoutes.home : AppRoutes.welcome;
  }

  if (!isAuthenticated && !isOnAuth) {
    return AppRoutes.welcome;
  }

  if (isAuthenticated && isOnAuth) {
    return AppRoutes.home;
  }

  return null;
}

CustomTransitionPage<void> _fullScreenPage(
  GoRouterState state,
  Widget child,
) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      fullscreenDialog: true,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );

CustomTransitionPage<void> _modalPage(
  GoRouterState state,
  Widget child,
) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      fullscreenDialog: true,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(0, 1), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: child,
      ),
    );
