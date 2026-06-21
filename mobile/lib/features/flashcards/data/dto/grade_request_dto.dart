import 'package:json_annotation/json_annotation.dart';

part 'grade_request_dto.g.dart';

/// Serialize timestamps as UTC so the backend (which compares against UTC)
/// doesn't reject them as "in the future" for users east of UTC. DateTime.now()
/// is local wall-clock; .toUtc() pins it to the correct instant.
String dtoUtcIso(DateTime d) => d.toUtc().toIso8601String();

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
  @JsonKey(toJson: dtoUtcIso)
  final DateTime nextReviewAt;
  @JsonKey(toJson: dtoUtcIso)
  final DateTime gradedAt;

  factory GradeRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GradeRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GradeRequestDtoToJson(this);
}
