// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeRequestDto _$GradeRequestDtoFromJson(Map<String, dynamic> json) =>
    GradeRequestDto(
      cardId: json['card_id'] as String,
      deckId: json['deck_id'] as String,
      grade: (json['grade'] as num).toInt(),
      newEaseFactor: (json['new_ease_factor'] as num).toDouble(),
      newStability: (json['new_stability'] as num?)?.toDouble(),
      newDifficulty: (json['new_difficulty'] as num?)?.toDouble(),
      newInterval: (json['new_interval'] as num).toInt(),
      newRepetitions: (json['new_repetitions'] as num).toInt(),
      nextReviewAt: DateTime.parse(json['next_review_at'] as String),
      gradedAt: DateTime.parse(json['graded_at'] as String),
    );

Map<String, dynamic> _$GradeRequestDtoToJson(GradeRequestDto instance) =>
    <String, dynamic>{
      'card_id': instance.cardId,
      'deck_id': instance.deckId,
      'grade': instance.grade,
      'new_ease_factor': instance.newEaseFactor,
      'new_stability': instance.newStability,
      'new_difficulty': instance.newDifficulty,
      'new_interval': instance.newInterval,
      'new_repetitions': instance.newRepetitions,
      'next_review_at': instance.nextReviewAt.toIso8601String(),
      'graded_at': instance.gradedAt.toIso8601String(),
    };
