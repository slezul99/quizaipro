// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_collection_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibraryCollectionDto _$LibraryCollectionDtoFromJson(
        Map<String, dynamic> json) =>
    LibraryCollectionDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      coverColorHex: json['cover_color_hex'] as String,
      deckCount: (json['deck_count'] as num).toInt(),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$LibraryCollectionDtoToJson(
        LibraryCollectionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'cover_color_hex': instance.coverColorHex,
      'deck_count': instance.deckCount,
      'created_at': instance.createdAt,
    };
