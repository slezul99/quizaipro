// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generation_job_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerationJobDto _$GenerationJobDtoFromJson(Map<String, dynamic> json) =>
    GenerationJobDto(
      id: json['id'] as String,
      source: json['source'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num).toInt(),
      topic: json['topic'] as String?,
      inputText: json['input_text'] as String?,
      pdfFileName: json['pdf_file_name'] as String?,
      qualityMode: json['quality_mode'] as String,
      requestedCardCount: (json['requested_card_count'] as num).toInt(),
      cards: (json['cards'] as List<dynamic>)
          .map((e) => GeneratedCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$GenerationJobDtoToJson(GenerationJobDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source': instance.source,
      'status': instance.status,
      'progress': instance.progress,
      'topic': instance.topic,
      'input_text': instance.inputText,
      'pdf_file_name': instance.pdfFileName,
      'quality_mode': instance.qualityMode,
      'requested_card_count': instance.requestedCardCount,
      'cards': instance.cards,
      'error_message': instance.errorMessage,
      'created_at': instance.createdAt.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };

GeneratedCardDto _$GeneratedCardDtoFromJson(Map<String, dynamic> json) =>
    GeneratedCardDto(
      question: json['question'] as String,
      answer: json['answer'] as String,
      topic: json['topic'] as String,
      difficulty: json['difficulty'] as String,
    );

Map<String, dynamic> _$GeneratedCardDtoToJson(GeneratedCardDto instance) =>
    <String, dynamic>{
      'question': instance.question,
      'answer': instance.answer,
      'topic': instance.topic,
      'difficulty': instance.difficulty,
    };
