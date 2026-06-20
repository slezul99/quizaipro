import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String title,
    String? deckId,
    String? deckTitle,
    @Default(false) bool isPinned,
    @Default(0) int messageCount,
    String? lastMessagePreview,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool synced,
  }) = _Conversation;
}
