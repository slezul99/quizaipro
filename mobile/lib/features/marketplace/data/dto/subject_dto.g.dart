// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectDto _$SubjectDtoFromJson(Map<String, dynamic> json) => SubjectDto(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCode: json['icon_code'] as String,
      deckCount: (json['deck_count'] as num).toInt(),
      colorHex: json['color_hex'] as String,
    );

Map<String, dynamic> _$SubjectDtoToJson(SubjectDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon_code': instance.iconCode,
      'deck_count': instance.deckCount,
      'color_hex': instance.colorHex,
    };
