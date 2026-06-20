// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_path_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningPathDto _$LearningPathDtoFromJson(Map<String, dynamic> json) =>
    LearningPathDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      coverUrl: json['cover_url'] as String?,
      coverColorHex: json['cover_color_hex'] as String,
      deckCount: (json['deck_count'] as num).toInt(),
      estimatedHours: (json['estimated_hours'] as num).toInt(),
      difficulty: json['difficulty'] as String,
      enrolledCount: (json['enrolled_count'] as num).toInt(),
    );

Map<String, dynamic> _$LearningPathDtoToJson(LearningPathDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'cover_url': instance.coverUrl,
      'cover_color_hex': instance.coverColorHex,
      'deck_count': instance.deckCount,
      'estimated_hours': instance.estimatedHours,
      'difficulty': instance.difficulty,
      'enrolled_count': instance.enrolledCount,
    };
