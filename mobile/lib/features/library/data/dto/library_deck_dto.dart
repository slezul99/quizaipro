import 'package:json_annotation/json_annotation.dart';

part 'library_deck_dto.g.dart';

@JsonSerializable()
class LibraryDeckDto {
  const LibraryDeckDto({
    required this.id,
    required this.title,
    this.icon = '📚',
    required this.description,
    required this.cardCount,
    required this.dueCount,
    this.hasTests = false,
    this.hasFlashcards = false,
    required this.coverColorHex,
    this.coverUrl,
    required this.isPro,
    required this.isPublic,
    required this.isFavorite,
    required this.isArchived,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.difficulty,
    this.lastStudiedAt,
    this.subjectName,
  });

  final String id;
  final String title;
  @JsonKey(defaultValue: '📚') final String icon;
  final String description;
  @JsonKey(name: 'card_count') final int cardCount;
  @JsonKey(name: 'due_count') final int dueCount;
  @JsonKey(name: 'has_tests', defaultValue: false) final bool hasTests;
  @JsonKey(name: 'has_flashcards', defaultValue: false) final bool hasFlashcards;
  @JsonKey(name: 'cover_color_hex') final String coverColorHex;
  @JsonKey(name: 'cover_url') final String? coverUrl;
  @JsonKey(name: 'is_pro') final bool isPro;
  @JsonKey(name: 'is_public') final bool isPublic;
  @JsonKey(name: 'is_favorite') final bool isFavorite;
  @JsonKey(name: 'is_archived') final bool isArchived;
  final List<String> tags;
  @JsonKey(name: 'created_at') final String createdAt;
  @JsonKey(name: 'updated_at') final String updatedAt;
  final String? difficulty;
  @JsonKey(name: 'last_studied_at') final String? lastStudiedAt;
  @JsonKey(name: 'subject_name') final String? subjectName;

  factory LibraryDeckDto.fromJson(Map<String, dynamic> json) =>
      _$LibraryDeckDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LibraryDeckDtoToJson(this);
}
