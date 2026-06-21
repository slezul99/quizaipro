// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_journey.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreakJourneyImpl _$$StreakJourneyImplFromJson(Map<String, dynamic> json) =>
    _$StreakJourneyImpl(
      streak: StreakSummary.fromJson(json['streak'] as Map<String, dynamic>),
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => StreakMilestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      rewardsHistory: (json['rewards_history'] as List<dynamic>)
          .map((e) => ClaimedReward.fromJson(e as Map<String, dynamic>))
          .toList(),
      calendar:
          StreakCalendar.fromJson(json['calendar'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$StreakJourneyImplToJson(_$StreakJourneyImpl instance) =>
    <String, dynamic>{
      'streak': instance.streak,
      'milestones': instance.milestones,
      'rewards_history': instance.rewardsHistory,
      'calendar': instance.calendar,
    };

_$StreakMilestoneImpl _$$StreakMilestoneImplFromJson(
        Map<String, dynamic> json) =>
    _$StreakMilestoneImpl(
      key: json['key'] as String,
      days: (json['days'] as num).toInt(),
      xp: (json['xp'] as num).toInt(),
      name: json['name'] as String,
      desc: json['desc'] as String,
      unlocked: json['unlocked'] as bool,
      unlockedAt: json['unlocked_at'] as String?,
    );

Map<String, dynamic> _$$StreakMilestoneImplToJson(
        _$StreakMilestoneImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'days': instance.days,
      'xp': instance.xp,
      'name': instance.name,
      'desc': instance.desc,
      'unlocked': instance.unlocked,
      'unlocked_at': instance.unlockedAt,
    };

_$ClaimedRewardImpl _$$ClaimedRewardImplFromJson(Map<String, dynamic> json) =>
    _$ClaimedRewardImpl(
      key: json['key'] as String,
      name: json['name'] as String,
      xp: (json['xp'] as num).toInt(),
      unlockedAt: json['unlocked_at'] as String,
    );

Map<String, dynamic> _$$ClaimedRewardImplToJson(_$ClaimedRewardImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'xp': instance.xp,
      'unlocked_at': instance.unlockedAt,
    };

_$StreakCalendarImpl _$$StreakCalendarImplFromJson(Map<String, dynamic> json) =>
    _$StreakCalendarImpl(
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      activeDates: (json['active_dates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$StreakCalendarImplToJson(
        _$StreakCalendarImpl instance) =>
    <String, dynamic>{
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'active_dates': instance.activeDates,
    };
