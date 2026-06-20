import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/card_grade.dart';

class Sm2Result {
  const Sm2Result({
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.nextReviewAt,
  });

  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime nextReviewAt;
}

abstract final class Sm2Algorithm {
  /// Standard SM-2 algorithm with 4-grade mapping:
  ///   again=1, hard=3, good=4, easy=5
  ///
  /// Grades < 3 reset repetitions and set interval=1.
  /// Grades >= 3 follow standard SM-2 interval progression.
  static Sm2Result calculate({
    required double easeFactor,
    required int interval,
    required int repetitions,
    required CardGrade grade,
  }) {
    final q = grade.sm2Value;

    double newEF =
        easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    newEF = newEF.clamp(
      AppConstants.srsMinEaseFactor,
      AppConstants.srsMaxEaseFactor,
    );

    int newInterval;
    int newRepetitions;

    if (q < 3) {
      newRepetitions = 0;
      newInterval = 1;
    } else {
      newRepetitions = repetitions + 1;
      if (repetitions == 0) {
        newInterval = 1;
      } else if (repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (interval * newEF).round();
      }
      newInterval =
          newInterval.clamp(1, AppConstants.srsMaxIntervalDays);
    }

    return Sm2Result(
      easeFactor: newEF,
      interval: newInterval,
      repetitions: newRepetitions,
      nextReviewAt: DateTime.now().add(Duration(days: newInterval)),
    );
  }
}
