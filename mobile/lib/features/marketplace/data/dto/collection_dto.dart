import 'package:json_annotation/json_annotation.dart';

part 'collection_dto.g.dart';

@JsonSerializable()
class CollectionDto {
  const CollectionDto({
    required this.id,
    required this.name,
    required this.description,
    this.coverUrl,
    required this.coverColorHex,
    required this.deckCount,
    this.subjectId,
    required this.curatorName,
  });

  final String id;
  final String name;
  final String description;

  @JsonKey(name: 'cover_url')
  final String? coverUrl;

  @JsonKey(name: 'cover_color_hex')
  final String coverColorHex;

  @JsonKey(name: 'deck_count')
  final int deckCount;

  @JsonKey(name: 'subject_id')
  final String? subjectId;

  @JsonKey(name: 'curator_name')
  final String curatorName;

  factory CollectionDto.fromJson(Map<String, dynamic> json) =>
      _$CollectionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionDtoToJson(this);
}
