import 'package:json_annotation/json_annotation.dart';

part 'session_request_dto.g.dart';

/// Serialize timestamps as UTC so the backend doesn't reject them as "in the
/// future" for users east of UTC (DateTime.now() is local wall-clock).
String _dtoUtcIso(DateTime d) => d.toUtc().toIso8601String();

@JsonSerializable(fieldRename: FieldRename.snake)
class SessionRequestDto {
  const SessionRequestDto({
    required this.id,
    required this.deckId,
    required this.totalCards,
    required this.newCards,
    required this.reviewCards,
    required this.againCount,
    required this.hardCount,
    required this.goodCount,
    required this.easyCount,
    required this.durationSeconds,
    required this.completedAt,
  });

  final String id;
  final String deckId;
  final int totalCards;
  final int newCards;
  final int reviewCards;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;
  final int durationSeconds;
  @JsonKey(toJson: _dtoUtcIso)
  final DateTime completedAt;

  factory SessionRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SessionRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SessionRequestDtoToJson(this);
}
