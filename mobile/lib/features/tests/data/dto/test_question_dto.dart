import 'package:json_annotation/json_annotation.dart';

part 'test_question_dto.g.dart';

@JsonSerializable()
class TestOptionDto {
  const TestOptionDto({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  final String id;
  final String text;
  @JsonKey(name: 'is_correct')
  final bool isCorrect;

  factory TestOptionDto.fromJson(Map<String, dynamic> json) =>
      _$TestOptionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TestOptionDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TestQuestionDto {
  const TestQuestionDto({
    required this.id,
    required this.deckId,
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.topic,
  });

  final String id;
  final String deckId;
  final String question;
  final String correctAnswer;
  final List<TestOptionDto> options;
  final String? topic;

  factory TestQuestionDto.fromJson(Map<String, dynamic> json) =>
      _$TestQuestionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TestQuestionDtoToJson(this);
}
