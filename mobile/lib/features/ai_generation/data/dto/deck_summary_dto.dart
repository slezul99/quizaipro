import 'package:json_annotation/json_annotation.dart';

part 'deck_summary_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DeckSummaryDto {
  const DeckSummaryDto({
    required this.id,
    required this.title,
    required this.cardCount,
  });

  final String id;
  final String title;
  final int cardCount;

  factory DeckSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$DeckSummaryDtoFromJson(json);
}
