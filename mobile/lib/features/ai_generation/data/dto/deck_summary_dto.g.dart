// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeckSummaryDto _$DeckSummaryDtoFromJson(Map<String, dynamic> json) =>
    DeckSummaryDto(
      id: json['id'] as String,
      title: json['title'] as String,
      cardCount: (json['card_count'] as num).toInt(),
    );

Map<String, dynamic> _$DeckSummaryDtoToJson(DeckSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'card_count': instance.cardCount,
    };
