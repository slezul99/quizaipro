// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeckSummaryDto _$DeckSummaryDtoFromJson(Map<String, dynamic> json) =>
    DeckSummaryDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      authorName: json['author_name'] as String,
      coverColorHex: json['cover_color_hex'] as String,
      cardCount: (json['card_count'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      ratingCount: (json['rating_count'] as num).toInt(),
      cloneCount: (json['clone_count'] as num).toInt(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      language: json['language'] as String,
      subjectId: json['subject_id'] as String?,
      isPro: json['is_pro'] as bool? ?? false,
    );

Map<String, dynamic> _$DeckSummaryDtoToJson(DeckSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'author_name': instance.authorName,
      'cover_color_hex': instance.coverColorHex,
      'card_count': instance.cardCount,
      'rating': instance.rating,
      'rating_count': instance.ratingCount,
      'clone_count': instance.cloneCount,
      'tags': instance.tags,
      'language': instance.language,
      'subject_id': instance.subjectId,
      'is_pro': instance.isPro,
    };
