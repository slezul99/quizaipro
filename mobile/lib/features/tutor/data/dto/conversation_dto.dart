import 'package:json_annotation/json_annotation.dart';

part 'conversation_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ConversationDto {
  const ConversationDto({
    required this.id,
    required this.title,
    this.deckId,
    this.deckTitle,
    required this.isPinned,
    required this.messageCount,
    this.lastMessagePreview,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? deckId;
  final String? deckTitle;
  final bool isPinned;
  final int messageCount;
  final String? lastMessagePreview;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationDtoToJson(this);
}
