import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_summary.freezed.dart';
part 'streak_summary.g.dart';

@freezed
class StreakSummary with _$StreakSummary {
  const StreakSummary._();

  const factory StreakSummary({
    required int currentStreak,
    required int maxStreak,
    required bool todayCompleted,
    DateTime? lastActivityDate,
    required StreakStageInfo? currentStage,
    required StreakStageInfo? nextStage,
    required double? progressRatio,
    required int? daysRemaining,
  }) = _StreakSummary;

  bool get isActive => currentStreak > 0;

  factory StreakSummary.fromJson(Map<String, dynamic> json) =>
      _$StreakSummaryFromJson(json);
}

@freezed
class StreakStageInfo with _$StreakStageInfo {
  const factory StreakStageInfo({
    required String key,
    required int startDays,
    int? nextStageDays,
  }) = _StreakStageInfo;

  factory StreakStageInfo.fromJson(Map<String, dynamic> json) =>
      _$StreakStageInfoFromJson(json);
}
