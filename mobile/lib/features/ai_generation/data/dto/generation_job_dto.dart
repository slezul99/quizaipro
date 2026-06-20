import 'package:json_annotation/json_annotation.dart';

part 'generation_job_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class GenerationJobDto {
  const GenerationJobDto({
    required this.id,
    required this.source,
    required this.status,
    required this.progress,
    this.topic,
    this.inputText,
    this.pdfFileName,
    required this.qualityMode,
    required this.requestedCardCount,
    required this.cards,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String source;
  final String status;
  final int progress;
  final String? topic;
  final String? inputText;
  final String? pdfFileName;
  final String qualityMode;
  final int requestedCardCount;
  final List<GeneratedCardDto> cards;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  factory GenerationJobDto.fromJson(Map<String, dynamic> json) =>
      _$GenerationJobDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeneratedCardDto {
  const GeneratedCardDto({
    required this.question,
    required this.answer,
    required this.topic,
    required this.difficulty,
  });

  final String question;
  final String answer;
  final String topic;
  final String difficulty;

  factory GeneratedCardDto.fromJson(Map<String, dynamic> json) =>
      _$GeneratedCardDtoFromJson(json);
}
