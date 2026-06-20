import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/dashboard/domain/entities/daily_goal_progress.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/due_reviews_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/retention_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/xp_summary.dart';

part 'dashboard_summary.freezed.dart';

@freezed
class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required XpSummary xp,
    required StreakSummary streak,
    required DailyGoalProgress dailyGoal,
    required DueReviewsSummary dueReviews,
    required String userDisplayName,
    @Default(0) int unreadNotifications,
    RetentionSummary? retention,
  }) = _DashboardSummary;
}
