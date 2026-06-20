// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_history_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestHistoryDto _$TestHistoryDtoFromJson(Map<String, dynamic> json) =>
    TestHistoryDto(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      deckTitle: json['deck_title'] as String,
      totalQuestions: (json['total_questions'] as num).toInt(),
      correctCount: (json['correct_count'] as num).toInt(),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      completedAt: DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$TestHistoryDtoToJson(TestHistoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deck_id': instance.deckId,
      'deck_title': instance.deckTitle,
      'total_questions': instance.totalQuestions,
      'correct_count': instance.correctCount,
      'duration_seconds': instance.durationSeconds,
      'completed_at': instance.completedAt.toIso8601String(),
    };
