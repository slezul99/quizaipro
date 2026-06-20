import 'package:json_annotation/json_annotation.dart';

part 'deck_summary_dto.g.dart';

@JsonSerializable()
class DeckSummaryDto {
  const DeckSummaryDto({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.coverColorHex,
    required this.cardCount,
    required this.rating,
    required this.ratingCount,
    required this.cloneCount,
    required this.tags,
    required this.language,
    this.subjectId,
    this.isPro = false,
  });

  final String id;
  final String title;
  final String description;

  @JsonKey(name: 'author_name')
  final String authorName;

  @JsonKey(name: 'cover_color_hex')
  final String coverColorHex;

  @JsonKey(name: 'card_count')
  final int cardCount;

  final double rating;

  @JsonKey(name: 'rating_count')
  final int ratingCount;

  @JsonKey(name: 'clone_count')
  final int cloneCount;

  final List<String> tags;
  final String language;

  @JsonKey(name: 'subject_id')
  final String? subjectId;

  @JsonKey(name: 'is_pro')
  final bool isPro;

  factory DeckSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$DeckSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeckSummaryDtoToJson(this);
}
