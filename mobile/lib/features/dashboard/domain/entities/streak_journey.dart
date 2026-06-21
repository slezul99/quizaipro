import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_summary.dart';

part 'streak_journey.freezed.dart';
part 'streak_journey.g.dart';

@freezed
class StreakJourney with _$StreakJourney {
  const factory StreakJourney({
    required StreakSummary streak,
    required List<StreakMilestone> milestones,
    @JsonKey(name: 'rewards_history') required List<ClaimedReward> rewardsHistory,
    required StreakCalendar calendar,
  }) = _StreakJourney;

  factory StreakJourney.fromJson(Map<String, dynamic> json) =>
      _$StreakJourneyFromJson(json);
}

@freezed
class StreakMilestone with _$StreakMilestone {
  const factory StreakMilestone({
    required String key,
    required int days,
    required int xp,
    required String name,
    required String desc,
    required bool unlocked,
    @JsonKey(name: 'unlocked_at') required String? unlockedAt,
  }) = _StreakMilestone;

  factory StreakMilestone.fromJson(Map<String, dynamic> json) =>
      _$StreakMilestoneFromJson(json);
}

@freezed
class ClaimedReward with _$ClaimedReward {
  const factory ClaimedReward({
    required String key,
    required String name,
    required int xp,
    @JsonKey(name: 'unlocked_at') required String unlockedAt,
  }) = _ClaimedReward;

  factory ClaimedReward.fromJson(Map<String, dynamic> json) =>
      _$ClaimedRewardFromJson(json);
}

@freezed
class StreakCalendar with _$StreakCalendar {
  const factory StreakCalendar({
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,
    @JsonKey(name: 'active_dates') required List<String> activeDates,
  }) = _StreakCalendar;

  factory StreakCalendar.fromJson(Map<String, dynamic> json) =>
      _$StreakCalendarFromJson(json);
}
