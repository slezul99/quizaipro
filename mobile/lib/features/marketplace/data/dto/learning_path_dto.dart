import 'package:json_annotation/json_annotation.dart';

part 'learning_path_dto.g.dart';

@JsonSerializable()
class LearningPathDto {
  const LearningPathDto({
    required this.id,
    required this.title,
    required this.description,
    this.coverUrl,
    required this.coverColorHex,
    required this.deckCount,
    required this.estimatedHours,
    required this.difficulty,
    required this.enrolledCount,
  });

  final String id;
  final String title;
  final String description;

  @JsonKey(name: 'cover_url')
  final String? coverUrl;

  @JsonKey(name: 'cover_color_hex')
  final String coverColorHex;

  @JsonKey(name: 'deck_count')
  final int deckCount;

  @JsonKey(name: 'estimated_hours')
  final int estimatedHours;

  final String difficulty;

  @JsonKey(name: 'enrolled_count')
  final int enrolledCount;

  factory LearningPathDto.fromJson(Map<String, dynamic> json) =>
      _$LearningPathDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LearningPathDtoToJson(this);
}
