import 'package:json_annotation/json_annotation.dart';

part 'test_history_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TestHistoryDto {
  const TestHistoryDto({
    required this.id,
    required this.deckId,
    required this.deckTitle,
    required this.totalQuestions,
    required this.correctCount,
    required this.durationSeconds,
    required this.completedAt,
  });

  final String id;
  final String deckId;
  final String deckTitle;
  final int totalQuestions;
  final int correctCount;
  final int durationSeconds;
  final DateTime completedAt;

  factory TestHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$TestHistoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TestHistoryDtoToJson(this);
}
