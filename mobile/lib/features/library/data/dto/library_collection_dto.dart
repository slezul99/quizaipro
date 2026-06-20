import 'package:json_annotation/json_annotation.dart';

part 'library_collection_dto.g.dart';

@JsonSerializable()
class LibraryCollectionDto {
  const LibraryCollectionDto({
    required this.id,
    required this.name,
    required this.description,
    required this.coverColorHex,
    required this.deckCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  @JsonKey(name: 'cover_color_hex') final String coverColorHex;
  @JsonKey(name: 'deck_count') final int deckCount;
  @JsonKey(name: 'created_at') final String createdAt;

  factory LibraryCollectionDto.fromJson(Map<String, dynamic> json) =>
      _$LibraryCollectionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LibraryCollectionDtoToJson(this);
}
