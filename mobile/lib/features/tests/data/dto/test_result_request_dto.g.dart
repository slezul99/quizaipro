// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_result_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestAnswerRequestDto _$TestAnswerRequestDtoFromJson(
        Map<String, dynamic> json) =>
    TestAnswerRequestDto(
      position: (json['position'] as num).toInt(),
      cardId: (json['card_id'] as num?)?.toInt(),
      front: json['front'] as String,
      back: json['back'] as String,
      note: json['note'] as String,
      chosen: json['chosen'] as String,
      correct: json['correct'] as String,
      isCorrect: json['is_correct'] as bool,
    );

Map<String, dynamic> _$TestAnswerRequestDtoToJson(
        TestAnswerRequestDto instance) =>
    <String, dynamic>{
      'position': instance.position,
      'card_id': instance.cardId,
      'front': instance.front,
      'back': instance.back,
      'note': instance.note,
      'chosen': instance.chosen,
      'correct': instance.correct,
      'is_correct': instance.isCorrect,
    };

TestResultRequestDto _$TestResultRequestDtoFromJson(
        Map<String, dynamic> json) =>
    TestResultRequestDto(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      totalQuestions: (json['total_questions'] as num).toInt(),
      correctCount: (json['correct_count'] as num).toInt(),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      completedAt: DateTime.parse(json['completed_at'] as String),
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) =>
                  TestAnswerRequestDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TestResultRequestDtoToJson(
        TestResultRequestDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deck_id': instance.deckId,
      'total_questions': instance.totalQuestions,
      'correct_count': instance.correctCount,
      'duration_seconds': instance.durationSeconds,
      'completed_at': instance.completedAt.toIso8601String(),
      'answers': instance.answers,
    };
