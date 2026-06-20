// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XpSummaryDto _$XpSummaryDtoFromJson(Map<String, dynamic> json) => XpSummaryDto(
      currentXp: (json['current_xp'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      xpInCurrentLevel: (json['xp_in_current_level'] as num).toInt(),
      xpForNextLevel: (json['xp_for_next_level'] as num).toInt(),
    );

Map<String, dynamic> _$XpSummaryDtoToJson(XpSummaryDto instance) =>
    <String, dynamic>{
      'current_xp': instance.currentXp,
      'level': instance.level,
      'xp_in_current_level': instance.xpInCurrentLevel,
      'xp_for_next_level': instance.xpForNextLevel,
    };
