// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyCardReviewDetailDto _$StudyCardReviewDetailDtoFromJson(
        Map<String, dynamic> json) =>
    StudyCardReviewDetailDto(
      cardId: json['card_id'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      explanation: json['explanation'] as String?,
      grade: (json['grade'] as num).toInt(),
      xpEarned: (json['xp_earned'] as num).toInt(),
    );

Map<String, dynamic> _$StudyCardReviewDetailDtoToJson(
        StudyCardReviewDetailDto instance) =>
    <String, dynamic>{
      'card_id': instance.cardId,
      'front': instance.front,
      'back': instance.back,
      'explanation': instance.explanation,
      'grade': instance.grade,
      'xp_earned': instance.xpEarned,
    };

TestQuestionAttemptDetailDto _$TestQuestionAttemptDetailDtoFromJson(
        Map<String, dynamic> json) =>
    TestQuestionAttemptDetailDto(
      front: json['front'] as String,
      isCorrect: json['is_correct'] as bool,
      correctAnswer: json['correct_answer'] as String,
      selectedAnswer: json['selected_answer'] as String?,
      xpEarned: (json['xp_earned'] as num).toInt(),
    );

Map<String, dynamic> _$TestQuestionAttemptDetailDtoToJson(
        TestQuestionAttemptDetailDto instance) =>
    <String, dynamic>{
      'front': instance.front,
      'is_correct': instance.isCorrect,
      'correct_answer': instance.correctAnswer,
      'selected_answer': instance.selectedAnswer,
      'xp_earned': instance.xpEarned,
    };

ActivityItemDto _$ActivityItemDtoFromJson(Map<String, dynamic> json) =>
    ActivityItemDto(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      cardsReviewed: (json['cards_reviewed'] as num).toInt(),
      xpEarned: (json['xp_earned'] as num).toInt(),
      createdAt: json['created_at'] as String,
      details: json['details'] as List<dynamic>?,
    );

Map<String, dynamic> _$ActivityItemDtoToJson(ActivityItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'cards_reviewed': instance.cardsReviewed,
      'xp_earned': instance.xpEarned,
      'created_at': instance.createdAt,
      'details': instance.details,
    };
