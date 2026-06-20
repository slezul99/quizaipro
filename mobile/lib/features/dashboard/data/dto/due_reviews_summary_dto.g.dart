// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'due_reviews_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DueReviewsSummaryDto _$DueReviewsSummaryDtoFromJson(
        Map<String, dynamic> json) =>
    DueReviewsSummaryDto(
      totalDue: (json['total_due'] as num).toInt(),
      overdue: (json['overdue'] as num).toInt(),
      dueToday: (json['due_today'] as num).toInt(),
    );

Map<String, dynamic> _$DueReviewsSummaryDtoToJson(
        DueReviewsSummaryDto instance) =>
    <String, dynamic>{
      'total_due': instance.totalDue,
      'overdue': instance.overdue,
      'due_today': instance.dueToday,
    };
