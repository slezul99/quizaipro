// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeckDetailDto _$DeckDetailDtoFromJson(Map<String, dynamic> json) =>
    DeckDetailDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      fullDescription: json['full_description'] as String,
      authorName: json['author_name'] as String,
      authorUsername: json['author_username'] as String,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      coverColorHex: json['cover_color_hex'] as String,
      cardCount: (json['card_count'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      ratingCount: (json['rating_count'] as num).toInt(),
      cloneCount: (json['clone_count'] as num).toInt(),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      language: json['language'] as String,
      subjectId: json['subject_id'] as String?,
      isPro: json['is_pro'] as bool? ?? false,
      previewCardsCount: (json['preview_cards_count'] as num).toInt(),
      isClonedByUser: json['is_cloned_by_user'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$DeckDetailDtoToJson(DeckDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'full_description': instance.fullDescription,
      'author_name': instance.authorName,
      'author_username': instance.authorUsername,
      'author_avatar_url': instance.authorAvatarUrl,
      'cover_color_hex': instance.coverColorHex,
      'card_count': instance.cardCount,
      'rating': instance.rating,
      'rating_count': instance.ratingCount,
      'clone_count': instance.cloneCount,
      'like_count': instance.likeCount,
      'tags': instance.tags,
      'language': instance.language,
      'subject_id': instance.subjectId,
      'is_pro': instance.isPro,
      'preview_cards_count': instance.previewCardsCount,
      'is_cloned_by_user': instance.isClonedByUser,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
