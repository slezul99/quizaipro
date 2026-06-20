import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_item.freezed.dart';

enum ActivityType { study, test, duel, aiTutor }

@freezed
class StudyCardReviewDetail with _$StudyCardReviewDetail {
  const factory StudyCardReviewDetail({
    required String cardId,
    required String front,
    required String back,
    String? explanation,
    required int grade,
    required int xpEarned,
  }) = _StudyCardReviewDetail;
}

@freezed
class TestQuestionAttemptDetail with _$TestQuestionAttemptDetail {
  const factory TestQuestionAttemptDetail({
    required String front,
    required bool isCorrect,
    required String correctAnswer,
    String? selectedAnswer,
    required int xpEarned,
  }) = _TestQuestionAttemptDetail;
}

@freezed
sealed class ActivityItem with _$ActivityItem {
  const factory ActivityItem.study({
    required String id,
    required String title,
    required int cardsReviewed,
    required int xpEarned,
    required DateTime timestamp,
    required List<StudyCardReviewDetail> details,
  }) = StudySessionActivity;

  const factory ActivityItem.test({
    required String id,
    required String title,
    required int totalQuestions,
    required int correctCount,
    required int xpEarned,
    required DateTime timestamp,
    required List<TestQuestionAttemptDetail> details,
  }) = TestSessionActivity;
}

extension ActivityItemCompatX on ActivityItem {
  ActivityType get type => map(
        study: (_) => ActivityType.study,
        test: (_) => ActivityType.test,
      );

  int get cardsReviewed => map(
        study: (s) => s.cardsReviewed,
        test: (t) => t.totalQuestions,
      );
}
