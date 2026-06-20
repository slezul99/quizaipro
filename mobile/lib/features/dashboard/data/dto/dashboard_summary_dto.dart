import 'package:json_annotation/json_annotation.dart';

import 'package:quizaipro_mobile/features/dashboard/data/dto/daily_goal_progress_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/due_reviews_summary_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/streak_summary_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/xp_summary_dto.dart';

part 'dashboard_summary_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class DashboardSummaryDto {
  const DashboardSummaryDto({
    required this.xp,
    required this.streak,
    required this.dailyGoal,
    required this.dueReviews,
    required this.userDisplayName,
    this.unreadNotifications = 0,
  });

  final XpSummaryDto xp;
  final StreakSummaryDto streak;

  @JsonKey(name: 'daily_goal')
  final DailyGoalProgressDto dailyGoal;

  @JsonKey(name: 'due_reviews')
  final DueReviewsSummaryDto dueReviews;

  @JsonKey(name: 'user_display_name')
  final String userDisplayName;

  @JsonKey(name: 'unread_notifications')
  final int unreadNotifications;

  factory DashboardSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardSummaryDtoToJson(this);
}
