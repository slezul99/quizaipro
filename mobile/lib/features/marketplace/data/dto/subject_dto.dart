import 'package:json_annotation/json_annotation.dart';

part 'subject_dto.g.dart';

@JsonSerializable()
class SubjectDto {
  const SubjectDto({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.deckCount,
    required this.colorHex,
  });

  final String id;
  final String name;

  @JsonKey(name: 'icon_code')
  final String iconCode;

  @JsonKey(name: 'deck_count')
  final int deckCount;

  @JsonKey(name: 'color_hex')
  final String colorHex;

  factory SubjectDto.fromJson(Map<String, dynamic> json) =>
      _$SubjectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectDtoToJson(this);
}
