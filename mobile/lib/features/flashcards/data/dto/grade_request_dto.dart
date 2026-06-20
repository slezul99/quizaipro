import 'package:json_annotation/json_annotation.dart';

part 'grade_request_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class GradeRequestDto {
  const GradeRequestDto({
    required this.cardId,
    required this.deckId,
    required this.grade,
    required this.newEaseFactor,
    this.newStability,
    this.newDifficulty,
    required this.newInterval,
    required this.newRepetitions,
    required this.nextReviewAt,
    required this.gradedAt,
  });

  final String cardId;
  final String deckId;
  final int grade;
  final double newEaseFactor;
  final double? newStability;
  final double? newDifficulty;
  final int newInterval;
  final int newRepetitions;
  final DateTime nextReviewAt;
  final DateTime gradedAt;

  factory GradeRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GradeRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GradeRequestDtoToJson(this);
}
