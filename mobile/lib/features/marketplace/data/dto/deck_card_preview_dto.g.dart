// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_card_preview_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeckCardPreviewDto _$DeckCardPreviewDtoFromJson(Map<String, dynamic> json) =>
    DeckCardPreviewDto(
      id: json['id'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      hint: json['hint'] as String?,
    );

Map<String, dynamic> _$DeckCardPreviewDtoToJson(DeckCardPreviewDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'front': instance.front,
      'back': instance.back,
      'hint': instance.hint,
    };
