import 'package:json_annotation/json_annotation.dart';

part 'test_result_request_dto.g.dart';

/// Serialize timestamps as UTC so the backend doesn't reject them as "in the
/// future" for users east of UTC (DateTime.now() is local wall-clock).
String _dtoUtcIso(DateTime d) => d.toUtc().toIso8601String();

/// One answered question, persisted server-side into `test_attempt_answers`
/// so the dashboard activity feed can show the full Q&A (mirrors the web flow).
@JsonSerializable(fieldRename: FieldRename.snake)
class TestAnswerRequestDto {
  const TestAnswerRequestDto({
    required this.position,
    required this.cardId,
    required this.front,
    required this.back,
    required this.note,
    required this.chosen,
    required this.correct,
    required this.isCorrect,
  });

  final int position;
  final int? cardId;
  final String front;
  final String back;
  final String note;
  final String chosen;
  final String correct;
  final bool isCorrect;

  factory TestAnswerRequestDto.fromJson(Map<String, dynamic> json) =>
      _$TestAnswerRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TestAnswerRequestDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TestResultRequestDto {
  const TestResultRequestDto({
    required this.id,
    required this.deckId,
    required this.totalQuestions,
    required this.correctCount,
    required this.durationSeconds,
    required this.completedAt,
    this.answers = const [],
  });

  final String id;
  final String deckId;
  final int totalQuestions;
  final int correctCount;
  final int durationSeconds;
  @JsonKey(toJson: _dtoUtcIso)
  final DateTime completedAt;
  final List<TestAnswerRequestDto> answers;

  factory TestResultRequestDto.fromJson(Map<String, dynamic> json) =>
      _$TestResultRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TestResultRequestDtoToJson(this);
}
