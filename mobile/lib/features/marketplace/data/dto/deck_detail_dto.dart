import 'package:json_annotation/json_annotation.dart';

part 'deck_detail_dto.g.dart';

@JsonSerializable()
class DeckDetailDto {
  const DeckDetailDto({
    required this.id,
    required this.title,
    required this.description,
    required this.fullDescription,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.coverColorHex,
    required this.cardCount,
    required this.rating,
    required this.ratingCount,
    required this.cloneCount,
    this.likeCount = 0,
    required this.tags,
    required this.language,
    this.subjectId,
    this.isPro = false,
    required this.previewCardsCount,
    this.isClonedByUser = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;

  @JsonKey(name: 'full_description')
  final String fullDescription;

  @JsonKey(name: 'author_name')
  final String authorName;

  @JsonKey(name: 'author_username')
  final String authorUsername;

  @JsonKey(name: 'author_avatar_url')
  final String? authorAvatarUrl;

  @JsonKey(name: 'cover_color_hex')
  final String coverColorHex;

  @JsonKey(name: 'card_count')
  final int cardCount;

  final double rating;

  @JsonKey(name: 'rating_count')
  final int ratingCount;

  @JsonKey(name: 'clone_count')
  final int cloneCount;

  @JsonKey(name: 'like_count', defaultValue: 0)
  final int likeCount;

  final List<String> tags;
  final String language;

  @JsonKey(name: 'subject_id')
  final String? subjectId;

  @JsonKey(name: 'is_pro')
  final bool isPro;

  @JsonKey(name: 'preview_cards_count')
  final int previewCardsCount;

  @JsonKey(name: 'is_cloned_by_user')
  final bool isClonedByUser;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  factory DeckDetailDto.fromJson(Map<String, dynamic> json) =>
      _$DeckDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeckDetailDtoToJson(this);
}
