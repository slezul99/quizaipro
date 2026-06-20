// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreakSummaryDto _$StreakSummaryDtoFromJson(Map<String, dynamic> json) =>
    StreakSummaryDto(
      currentStreak: (json['current_streak'] as num).toInt(),
      maxStreak: (json['max_streak'] as num).toInt(),
      todayCompleted: json['today_completed'] as bool,
      lastActivityDate: json['last_activity_date'] as String?,
      currentStage: json['current_stage'] == null
          ? null
          : StreakStageInfoDto.fromJson(
              json['current_stage'] as Map<String, dynamic>),
      nextStage: json['next_stage'] == null
          ? null
          : StreakStageInfoDto.fromJson(
              json['next_stage'] as Map<String, dynamic>),
      progressRatio: (json['progress_ratio'] as num?)?.toDouble(),
      daysRemaining: (json['days_remaining'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StreakSummaryDtoToJson(StreakSummaryDto instance) =>
    <String, dynamic>{
      'current_streak': instance.currentStreak,
      'max_streak': instance.maxStreak,
      'today_completed': instance.todayCompleted,
      'last_activity_date': instance.lastActivityDate,
      'current_stage': instance.currentStage,
      'next_stage': instance.nextStage,
      'progress_ratio': instance.progressRatio,
      'days_remaining': instance.daysRemaining,
    };

StreakStageInfoDto _$StreakStageInfoDtoFromJson(Map<String, dynamic> json) =>
    StreakStageInfoDto(
      key: json['key'] as String,
      startDays: (json['start_days'] as num).toInt(),
      nextStageDays: (json['next_stage_days'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StreakStageInfoDtoToJson(StreakStageInfoDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'start_days': instance.startDays,
      'next_stage_days': instance.nextStageDays,
    };
