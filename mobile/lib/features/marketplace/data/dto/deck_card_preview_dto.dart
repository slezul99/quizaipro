import 'package:json_annotation/json_annotation.dart';

part 'deck_card_preview_dto.g.dart';

@JsonSerializable()
class DeckCardPreviewDto {
  const DeckCardPreviewDto({
    required this.id,
    required this.front,
    required this.back,
    this.hint,
  });

  final String id;
  final String front;
  final String back;
  final String? hint;

  factory DeckCardPreviewDto.fromJson(Map<String, dynamic> json) =>
      _$DeckCardPreviewDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeckCardPreviewDtoToJson(this);
}
