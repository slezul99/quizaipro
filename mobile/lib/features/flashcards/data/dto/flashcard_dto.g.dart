// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlashcardDto _$FlashcardDtoFromJson(Map<String, dynamic> json) => FlashcardDto(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      hint: json['hint'] as String?,
      easeFactor: (json['ease_factor'] as num).toDouble(),
      interval: (json['interval'] as num).toInt(),
      repetitions: (json['repetitions'] as num).toInt(),
      nextReviewAt: json['next_review_at'] == null
          ? null
          : DateTime.parse(json['next_review_at'] as String),
      lastStudiedAt: json['last_studied_at'] == null
          ? null
          : DateTime.parse(json['last_studied_at'] as String),
      isFavorite: json['is_favorite'] as bool,
      isDifficult: json['is_difficult'] as bool,
      againCount: (json['again_count'] as num).toInt(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$FlashcardDtoToJson(FlashcardDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deck_id': instance.deckId,
      'front': instance.front,
      'back': instance.back,
      'hint': instance.hint,
      'ease_factor': instance.easeFactor,
      'interval': instance.interval,
      'repetitions': instance.repetitions,
      'next_review_at': instance.nextReviewAt?.toIso8601String(),
      'last_studied_at': instance.lastStudiedAt?.toIso8601String(),
      'is_favorite': instance.isFavorite,
      'is_difficult': instance.isDifficult,
      'again_count': instance.againCount,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
