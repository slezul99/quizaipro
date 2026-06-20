import 'package:json_annotation/json_annotation.dart';

part 'daily_goal_progress_dto.g.dart';

@JsonSerializable()
class DailyGoalProgressDto {
  const DailyGoalProgressDto({
    required this.targetCards,
    required this.completedCards,
  });

  @JsonKey(name: 'target_cards')
  final int targetCards;

  @JsonKey(name: 'completed_cards')
  final int completedCards;

  factory DailyGoalProgressDto.fromJson(Map<String, dynamic> json) =>
      _$DailyGoalProgressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyGoalProgressDtoToJson(this);
}
