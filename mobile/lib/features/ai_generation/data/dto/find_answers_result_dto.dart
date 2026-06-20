import 'package:json_annotation/json_annotation.dart';

part 'find_answers_result_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FindAnswersResultDto {
  const FindAnswersResultDto({
    required this.question,
    required this.explanation,
    required this.keyPoints,
  });

  final String question;
  final String explanation;
  final List<String> keyPoints;

  factory FindAnswersResultDto.fromJson(Map<String, dynamic> json) =>
      _$FindAnswersResultDtoFromJson(json);
}
