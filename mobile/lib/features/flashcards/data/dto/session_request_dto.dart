import 'package:json_annotation/json_annotation.dart';

part 'session_request_dto.g.dart';

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
  final DateTime completedAt;

  factory SessionRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SessionRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SessionRequestDtoToJson(this);
}
