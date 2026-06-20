import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_goal_progress.freezed.dart';

@freezed
class DailyGoalProgress with _$DailyGoalProgress {
  const DailyGoalProgress._();

  const factory DailyGoalProgress({
    required int targetCards,
    required int completedCards,
  }) = _DailyGoalProgress;

  double get progress =>
      targetCards > 0 ? (completedCards / targetCards).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => completedCards >= targetCards;

  int get remainingCards => (targetCards - completedCards).clamp(0, targetCards);
}
