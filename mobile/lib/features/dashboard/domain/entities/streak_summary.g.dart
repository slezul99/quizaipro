// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreakSummaryImpl _$$StreakSummaryImplFromJson(Map<String, dynamic> json) =>
    _$StreakSummaryImpl(
      currentStreak: (json['currentStreak'] as num).toInt(),
      maxStreak: (json['maxStreak'] as num).toInt(),
      todayCompleted: json['todayCompleted'] as bool,
      lastActivityDate: json['lastActivityDate'] == null
          ? null
          : DateTime.parse(json['lastActivityDate'] as String),
      currentStage: json['currentStage'] == null
          ? null
          : StreakStageInfo.fromJson(
              json['currentStage'] as Map<String, dynamic>),
      nextStage: json['nextStage'] == null
          ? null
          : StreakStageInfo.fromJson(json['nextStage'] as Map<String, dynamic>),
      progressRatio: (json['progressRatio'] as num?)?.toDouble(),
      daysRemaining: (json['daysRemaining'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$StreakSummaryImplToJson(_$StreakSummaryImpl instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'maxStreak': instance.maxStreak,
      'todayCompleted': instance.todayCompleted,
      'lastActivityDate': instance.lastActivityDate?.toIso8601String(),
      'currentStage': instance.currentStage,
      'nextStage': instance.nextStage,
      'progressRatio': instance.progressRatio,
      'daysRemaining': instance.daysRemaining,
    };

_$StreakStageInfoImpl _$$StreakStageInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$StreakStageInfoImpl(
      key: json['key'] as String,
      startDays: (json['startDays'] as num).toInt(),
      nextStageDays: (json['nextStageDays'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$StreakStageInfoImplToJson(
        _$StreakStageInfoImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'startDays': instance.startDays,
      'nextStageDays': instance.nextStageDays,
    };
