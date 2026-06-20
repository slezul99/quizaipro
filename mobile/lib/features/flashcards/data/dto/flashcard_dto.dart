import 'package:json_annotation/json_annotation.dart';

part 'flashcard_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FlashcardDto {
  const FlashcardDto({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.hint,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    this.nextReviewAt,
    this.lastStudiedAt,
    required this.isFavorite,
    required this.isDifficult,
    required this.againCount,
    required this.updatedAt,
  });

  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? hint;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime? nextReviewAt;
  final DateTime? lastStudiedAt;
  final bool isFavorite;
  final bool isDifficult;
  final int againCount;
  final DateTime updatedAt;

  factory FlashcardDto.fromJson(Map<String, dynamic> json) =>
      _$FlashcardDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FlashcardDtoToJson(this);
}
