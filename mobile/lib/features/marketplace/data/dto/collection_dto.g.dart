// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionDto _$CollectionDtoFromJson(Map<String, dynamic> json) =>
    CollectionDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      coverUrl: json['cover_url'] as String?,
      coverColorHex: json['cover_color_hex'] as String,
      deckCount: (json['deck_count'] as num).toInt(),
      subjectId: json['subject_id'] as String?,
      curatorName: json['curator_name'] as String,
    );

Map<String, dynamic> _$CollectionDtoToJson(CollectionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'cover_url': instance.coverUrl,
      'cover_color_hex': instance.coverColorHex,
      'deck_count': instance.deckCount,
      'subject_id': instance.subjectId,
      'curator_name': instance.curatorName,
    };
