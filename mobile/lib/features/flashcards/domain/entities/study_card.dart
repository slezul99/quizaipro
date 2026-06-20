import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/flashcards/domain/entities/card_grade.dart';

part 'study_card.freezed.dart';

@freezed
class StudyCard with _$StudyCard {
  const factory StudyCard({
    required String id,
    required String deckId,
    required String front,
    required String back,
    String? hint,
    required double easeFactor,
    required int interval,
    required int repetitions,
    double? stability,
    double? difficulty,
    DateTime? lastStudiedAt,
    DateTime? nextReviewAt,
    required bool isFavorite,
    required bool isDifficult,
    required bool isNew,
    required int againCount,
    @Default(false) bool wasRescheduled,
    CardGrade? sessionGrade,
  }) = _StudyCard;
}
