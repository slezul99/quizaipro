// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retention_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetentionSummaryDto _$RetentionSummaryDtoFromJson(Map<String, dynamic> json) =>
    RetentionSummaryDto(
      now: (json['now'] as num?)?.toInt(),
      forecast: (json['forecast'] as num?)?.toInt(),
      fading: (json['fading'] as num?)?.toInt(),
      studied: (json['studied'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RetentionSummaryDtoToJson(
        RetentionSummaryDto instance) =>
    <String, dynamic>{
      'now': instance.now,
      'forecast': instance.forecast,
      'fading': instance.fading,
      'studied': instance.studied,
    };
