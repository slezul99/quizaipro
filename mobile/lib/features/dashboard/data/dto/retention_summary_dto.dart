import 'package:json_annotation/json_annotation.dart';

part 'retention_summary_dto.g.dart';

@JsonSerializable()
class RetentionSummaryDto {
  const RetentionSummaryDto({
    this.now,
    this.forecast,
    this.fading,
    this.studied,
  });

  /// Average recall probability across studied cards now (%, null until any
  /// card has been studied).
  final int? now;

  /// Forecast recall probability in a week with no review (%).
  final int? forecast;

  /// Number of studied cards already fading below the target retention.
  final int? fading;

  /// How many cards have been studied at least once.
  final int? studied;

  factory RetentionSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$RetentionSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RetentionSummaryDtoToJson(this);
}
