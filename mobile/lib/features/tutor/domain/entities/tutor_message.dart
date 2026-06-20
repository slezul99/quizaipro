import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/tutor/domain/entities/message_role.dart';

part 'tutor_message.freezed.dart';

@freezed
class TutorMessage with _$TutorMessage {
  const factory TutorMessage({
    required String id,
    required String conversationId,
    required MessageRole role,
    required String content,
    required DateTime createdAt,
    @Default(false) bool isStreaming,
    @Default(false) bool synced,
  }) = _TutorMessage;

  const TutorMessage._();

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}
