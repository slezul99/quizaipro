import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/xp_summary.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_mode.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/providers/dashboard_notifier.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/daily_goal_card.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/dashboard_error_view.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/dashboard_header_stats.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/dashboard_shimmer.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/due_reviews_card.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/recent_activity_section.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/retention_card.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/level_up_celebration.dart';
import 'package:go_router/go_router.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.aurora;
    final dashAsync = ref.watch(dashboardNotifierProvider);

    ref.listen(dashboardNotifierProvider, (previous, next) {
      if (previous != null && previous.hasValue && next.hasValue) {
        final prevVal = previous.value!;
        final nextVal = next.value!;
        final prevLvl = prevVal.summary.xp.level;
        final nextLvl = nextVal.summary.xp.level;
        if (nextLvl > prevLvl) {
          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withOpacity(0.85),
            pageBuilder: (context, anim1, anim2) {
              return LevelUpCelebrationDialog(
                oldLevel: prevLvl,
                newLevel: nextLvl,
              );
            },
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: tokens.backgroundCanvas,
      body: dashAsync.when(
        loading: () => DashboardShimmer(tokens: tokens),
        error: (error, _) => DashboardErrorView(
          message: l10n.errorNetwork,
          retryLabel: l10n.retry,
          tokens: tokens,
          onRetry: () => ref.invalidate(dashboardNotifierProvider),
        ),
        data: (state) => RefreshIndicator(
          color: tokens.brandPrimary,
          onRefresh: () async {
            try {
              await ref
                  .read(dashboardNotifierProvider.notifier)
                  .refresh();
            } catch (_) {}
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _DashboardAppBar(
                tokens: tokens,
                displayName: state.summary.userDisplayName,
                unreadCount: state.summary.unreadNotifications,
                streak: state.summary.streak,
                xp: state.summary.xp,
                l10n: l10n,
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  tokens.space20,
                  tokens.space8,
                  tokens.space20,
                  tokens.space20,
                ),
                sliver: SliverList.list(
                  children: [
                    DailyGoalCard(
                      goal: state.summary.dailyGoal,
                      tokens: tokens,
                      label: l10n.dashboardDailyGoal,
                      completedLabel: l10n.dashboardDailyGoalCompleted,
                    ),
                    SizedBox(height: tokens.space16),

                    DueReviewsCard(
                      dueReviews: state.summary.dueReviews,
                      tokens: tokens,
                      titleLabel: l10n.dashboardReadyToStudy,
                      overdueLabel: l10n.dashboardOverdue,
                      startLabel: l10n.dashboardStartStudying,
                      allCaughtUpLabel: l10n.dashboardAllCaughtUp,
                    ),
                    if (state.summary.retention?.hasData ?? false) ...[
                      SizedBox(height: tokens.space16),
                      RetentionCard(
                        retention: state.summary.retention!,
                        tokens: tokens,
                        title: l10n.dashboardRetention,
                        forecastLabel: l10n.dashboardRetentionForecast,
                        fadingLabel: l10n.dashboardRetentionFading,
                        explanation: l10n.dashboardRetentionInfo,
                        onReviewFading: () => context.pushNamed(
                          AppRoutes.studySessionName,
                          queryParameters: {
                            'mode': StudyMode.fading.name,
                            'deckTitle': l10n.dashboardRetention,
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: tokens.space20),
                    Text(
                      l10n.dashboardQuickActions,
                      style: tokens.titleMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: tokens.space12),
                    QuickActionsSection(
                      tokens: tokens,
                      studyLabel: l10n.dashboardActionStudy,
                      discoverLabel: l10n.dashboardActionDiscover,
                      aiTutorLabel: l10n.dashboardActionAiTutor,
                      aiStudioLabel: l10n.dashboardActionAiStudio,
                    ),
                    SizedBox(height: tokens.space24),
                    RecentActivitySection(
                      activity: state.recentActivity,
                      tokens: tokens,
                      titleLabel: l10n.dashboardRecentActivity,
                      emptyLabel: l10n.dashboardActivityEmpty,
                      hasDueReviews: state.summary.dueReviews.hasDue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardAppBar extends StatelessWidget {
  const _DashboardAppBar({
    required this.tokens,
    required this.displayName,
    required this.unreadCount,
    required this.streak,
    required this.xp,
    required this.l10n,
  });

  final AuroraTokens tokens;
  final String displayName;
  final int unreadCount;
  final StreakSummary streak;
  final XpSummary xp;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: tokens.backgroundCanvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 124,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space20,
            MediaQuery.of(context).padding.top + tokens.space12,
            tokens.space20,
            tokens.space8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _greeting(),
                style: tokens.bodyMedium.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
              Text(
                displayName,
                style: tokens.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: tokens.space12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DashboardHeaderStats(streak: streak, xp: xp, tokens: tokens),
              SizedBox(width: tokens.space12),
              _NotificationButton(
                unreadCount: unreadCount,
                tokens: tokens,
                onTap: () => context.goNamed(AppRoutes.notificationsName),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.dashboardGreetingMorning;
    if (hour < 18) return l10n.dashboardGreetingAfternoon;
    return l10n.dashboardGreetingEvening;
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.unreadCount,
    required this.tokens,
    required this.onTap,
  });

  final int unreadCount;
  final AuroraTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tokens.surfaceCard,
              shape: BoxShape.circle,
              boxShadow: tokens.shadowCard,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: tokens.textPrimary,
              size: 22,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFef4444),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
