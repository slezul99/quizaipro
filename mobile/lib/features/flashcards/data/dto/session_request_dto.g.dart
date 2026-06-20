// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionRequestDto _$SessionRequestDtoFromJson(Map<String, dynamic> json) =>
    SessionRequestDto(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      totalCards: (json['total_cards'] as num).toInt(),
      newCards: (json['new_cards'] as num).toInt(),
      reviewCards: (json['review_cards'] as num).toInt(),
      againCount: (json['again_count'] as num).toInt(),
      hardCount: (json['hard_count'] as num).toInt(),
      goodCount: (json['good_count'] as num).toInt(),
      easyCount: (json['easy_count'] as num).toInt(),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      completedAt: DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$SessionRequestDtoToJson(SessionRequestDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deck_id': instance.deckId,
      'total_cards': instance.totalCards,
      'new_cards': instance.newCards,
      'review_cards': instance.reviewCards,
      'again_count': instance.againCount,
      'hard_count': instance.hardCount,
      'good_count': instance.goodCount,
      'easy_count': instance.easyCount,
      'duration_seconds': instance.durationSeconds,
      'completed_at': instance.completedAt.toIso8601String(),
    };
