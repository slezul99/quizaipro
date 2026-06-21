import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_summary.freezed.dart';
part 'streak_summary.g.dart';

@freezed
class StreakSummary with _$StreakSummary {
  const StreakSummary._();

  const factory StreakSummary({
    @JsonKey(name: 'current_streak') required int currentStreak,
    @JsonKey(name: 'max_streak') required int maxStreak,
    @JsonKey(name: 'today_completed') required bool todayCompleted,
    @JsonKey(name: 'last_activity_date') DateTime? lastActivityDate,
    @JsonKey(name: 'current_stage') required StreakStageInfo? currentStage,
    @JsonKey(name: 'next_stage') required StreakStageInfo? nextStage,
    @JsonKey(name: 'progress_ratio') required double? progressRatio,
    @JsonKey(name: 'days_remaining') required int? daysRemaining,
  }) = _StreakSummary;

  bool get isActive => currentStreak > 0;

  factory StreakSummary.fromJson(Map<String, dynamic> json) =>
      _$StreakSummaryFromJson(json);
}

@freezed
class StreakStageInfo with _$StreakStageInfo {
  const factory StreakStageInfo({
    required String key,
    @JsonKey(name: 'start_days') required int startDays,
    @JsonKey(name: 'next_stage_days') int? nextStageDays,
  }) = _StreakStageInfo;

  factory StreakStageInfo.fromJson(Map<String, dynamic> json) =>
      _$StreakStageInfoFromJson(json);
}
