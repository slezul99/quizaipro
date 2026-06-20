// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_goal_progress_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyGoalProgressDto _$DailyGoalProgressDtoFromJson(
        Map<String, dynamic> json) =>
    DailyGoalProgressDto(
      targetCards: (json['target_cards'] as num).toInt(),
      completedCards: (json['completed_cards'] as num).toInt(),
    );

Map<String, dynamic> _$DailyGoalProgressDtoToJson(
        DailyGoalProgressDto instance) =>
    <String, dynamic>{
      'target_cards': instance.targetCards,
      'completed_cards': instance.completedCards,
    };
