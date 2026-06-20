import 'package:json_annotation/json_annotation.dart';

part 'due_reviews_summary_dto.g.dart';

@JsonSerializable()
class DueReviewsSummaryDto {
  const DueReviewsSummaryDto({
    required this.totalDue,
    required this.overdue,
    required this.dueToday,
  });

  @JsonKey(name: 'total_due')
  final int totalDue;

  final int overdue;

  @JsonKey(name: 'due_today')
  final int dueToday;

  factory DueReviewsSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$DueReviewsSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DueReviewsSummaryDtoToJson(this);
}
