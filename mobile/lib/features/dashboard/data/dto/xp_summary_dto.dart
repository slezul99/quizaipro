import 'package:json_annotation/json_annotation.dart';

part 'xp_summary_dto.g.dart';

@JsonSerializable()
class XpSummaryDto {
  const XpSummaryDto({
    required this.currentXp,
    required this.level,
    required this.xpInCurrentLevel,
    required this.xpForNextLevel,
  });

  @JsonKey(name: 'current_xp')
  final int currentXp;

  final int level;

  @JsonKey(name: 'xp_in_current_level')
  final int xpInCurrentLevel;

  @JsonKey(name: 'xp_for_next_level')
  final int xpForNextLevel;

  factory XpSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$XpSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$XpSummaryDtoToJson(this);
}
