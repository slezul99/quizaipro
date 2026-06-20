import 'package:json_annotation/json_annotation.dart';

part 'streak_summary_dto.g.dart';

@JsonSerializable()
class StreakSummaryDto {
  const StreakSummaryDto({
    required this.currentStreak,
    required this.maxStreak,
    required this.todayCompleted,
    this.lastActivityDate,
    required this.currentStage,
    required this.nextStage,
    required this.progressRatio,
    required this.daysRemaining,
  });

  @JsonKey(name: 'current_streak')
  final int currentStreak;

  @JsonKey(name: 'max_streak')
  final int maxStreak;

  @JsonKey(name: 'today_completed')
  final bool todayCompleted;

  @JsonKey(name: 'last_activity_date')
  final String? lastActivityDate;

  @JsonKey(name: 'current_stage')
  final StreakStageInfoDto? currentStage;

  @JsonKey(name: 'next_stage')
  final StreakStageInfoDto? nextStage;

  @JsonKey(name: 'progress_ratio')
  final double? progressRatio;

  @JsonKey(name: 'days_remaining')
  final int? daysRemaining;

  factory StreakSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$StreakSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StreakSummaryDtoToJson(this);
}

@JsonSerializable()
class StreakStageInfoDto {
  const StreakStageInfoDto({
    required this.key,
    required this.startDays,
    this.nextStageDays,
  });

  final String key;

  @JsonKey(name: 'start_days')
  final int startDays;

  @JsonKey(name: 'next_stage_days')
  final int? nextStageDays;

  factory StreakStageInfoDto.fromJson(Map<String, dynamic> json) =>
      _$StreakStageInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StreakStageInfoDtoToJson(this);
}
