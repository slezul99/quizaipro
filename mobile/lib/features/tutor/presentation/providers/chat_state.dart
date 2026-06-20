import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/tutor/domain/entities/tutor_message.dart';

part 'chat_state.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required String conversationId,
    required String conversationTitle,
    String? deckId,
    @Default([]) List<TutorMessage> messages,
    @Default(false) bool isLoadingHistory,
    @Default(false) bool isStreaming,
    @Default('') String streamingBuffer,
    String? errorMessage,
  }) = _ChatState;

  const ChatState._();

  bool get hasError => errorMessage != null;
}
