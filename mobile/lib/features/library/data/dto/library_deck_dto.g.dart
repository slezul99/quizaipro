// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_deck_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibraryDeckDto _$LibraryDeckDtoFromJson(Map<String, dynamic> json) =>
    LibraryDeckDto(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? '📚',
      description: json['description'] as String,
      cardCount: (json['card_count'] as num).toInt(),
      dueCount: (json['due_count'] as num).toInt(),
      hasTests: json['has_tests'] as bool? ?? false,
      hasFlashcards: json['has_flashcards'] as bool? ?? false,
      coverColorHex: json['cover_color_hex'] as String,
      coverUrl: json['cover_url'] as String?,
      isPro: json['is_pro'] as bool,
      isPublic: json['is_public'] as bool,
      isFavorite: json['is_favorite'] as bool,
      isArchived: json['is_archived'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      difficulty: json['difficulty'] as String?,
      lastStudiedAt: json['last_studied_at'] as String?,
      subjectName: json['subject_name'] as String?,
    );

Map<String, dynamic> _$LibraryDeckDtoToJson(LibraryDeckDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'icon': instance.icon,
      'description': instance.description,
      'card_count': instance.cardCount,
      'due_count': instance.dueCount,
      'has_tests': instance.hasTests,
      'has_flashcards': instance.hasFlashcards,
      'cover_color_hex': instance.coverColorHex,
      'cover_url': instance.coverUrl,
      'is_pro': instance.isPro,
      'is_public': instance.isPublic,
      'is_favorite': instance.isFavorite,
      'is_archived': instance.isArchived,
      'tags': instance.tags,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'difficulty': instance.difficulty,
      'last_studied_at': instance.lastStudiedAt,
      'subject_name': instance.subjectName,
    };
