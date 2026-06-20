// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardSummaryDto _$DashboardSummaryDtoFromJson(Map<String, dynamic> json) =>
    DashboardSummaryDto(
      xp: XpSummaryDto.fromJson(json['xp'] as Map<String, dynamic>),
      streak: StreakSummaryDto.fromJson(json['streak'] as Map<String, dynamic>),
      dailyGoal: DailyGoalProgressDto.fromJson(
          json['daily_goal'] as Map<String, dynamic>),
      dueReviews: DueReviewsSummaryDto.fromJson(
          json['due_reviews'] as Map<String, dynamic>),
      userDisplayName: json['user_display_name'] as String,
      unreadNotifications: (json['unread_notifications'] as num?)?.toInt() ?? 0,
      retention: json['retention'] == null
          ? null
          : RetentionSummaryDto.fromJson(
              json['retention'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardSummaryDtoToJson(
        DashboardSummaryDto instance) =>
    <String, dynamic>{
      'xp': instance.xp.toJson(),
      'streak': instance.streak.toJson(),
      'daily_goal': instance.dailyGoal.toJson(),
      'due_reviews': instance.dueReviews.toJson(),
      'retention': instance.retention?.toJson(),
      'user_display_name': instance.userDisplayName,
      'unread_notifications': instance.unreadNotifications,
    };
