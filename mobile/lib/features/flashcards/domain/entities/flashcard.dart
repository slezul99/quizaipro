import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard.freezed.dart';

@freezed
class Flashcard with _$Flashcard {
  const factory Flashcard({
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
    DateTime? nextReviewAt,
    DateTime? lastStudiedAt,
    required bool isFavorite,
    required bool isDifficult,
    required int againCount,
    required DateTime updatedAt,
  }) = _Flashcard;

  const Flashcard._();

  bool get isNew => repetitions == 0 && nextReviewAt == null;

  bool get isDue =>
      nextReviewAt != null && nextReviewAt!.isBefore(DateTime.now());
}
