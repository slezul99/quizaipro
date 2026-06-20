import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/message_role.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/sse_chunk.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/tutor_message.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/send_message_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/providers/chat_state.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/providers/tutor_providers.dart';

part 'chat_notifier.g.dart';

@Riverpod(keepAlive: true)
class ChatNotifier extends _$ChatNotifier {
  StreamSubscription<dynamic>? _sseSubscription;

  @override
  ChatState build({
    required String conversationId,
    required String conversationTitle,
    String? deckId,
  }) {
    ref.onDispose(() {
      _sseSubscription?.cancel();
      _sseSubscription = null;
    });
    return ChatState(
      conversationId: conversationId,
      conversationTitle: conversationTitle,
      deckId: deckId,
    );
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoadingHistory: true, errorMessage: null);

    final useCase = ref.read(getMessagesUseCaseProvider);
    final result = await useCase(conversationId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: failure.userMessage,
      ),
      (messages) => state = state.copyWith(
        isLoadingHistory: false,
        messages: messages,
      ),
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || state.isStreaming) return;

    final trimmed = content.trim();

    // Add the user message to local state immediately.
    final userMsg = TutorMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: MessageRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isStreaming: true,
      streamingBuffer: '',
      errorMessage: null,
    );

    final useCase = ref.read(sendMessageUseCaseProvider);
    final stream = useCase(SendMessageParams(
      conversationId: conversationId,
      content: trimmed,
      deckId: deckId,
    ));

    await _sseSubscription?.cancel();
    _sseSubscription = stream.listen(
      (either) {
        either.fold(
          (failure) {
            state = state.copyWith(
              isStreaming: false,
              errorMessage: failure.userMessage,
            );
          },
          (chunk) {
            switch (chunk) {
              case SseChunkDelta(:final text):
                state = state.copyWith(
                  streamingBuffer: state.streamingBuffer + text,
                );

              case SseChunkDone():
                _finaliseStreamingMessage();

              case SseChunkError(:final message):
                state = state.copyWith(
                  isStreaming: false,
                  errorMessage: message,
                  streamingBuffer: '',
                );
            }
          },
        );
      },
      onError: (_) {
        state = state.copyWith(
          isStreaming: false,
          errorMessage: 'Connection lost. Please try again.',
          streamingBuffer: '',
        );
      },
      onDone: () {
        if (state.isStreaming) _finaliseStreamingMessage();
      },
    );
  }

  void _finaliseStreamingMessage() {
    final content = state.streamingBuffer;
    if (content.isEmpty) {
      state = state.copyWith(isStreaming: false, streamingBuffer: '');
      return;
    }

    final assistantMsg = TutorMessage(
      id: 'local_ai_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: MessageRole.assistant,
      content: content,
      createdAt: DateTime.now(),
      synced: true,
    );

    state = state.copyWith(
      messages: [...state.messages, assistantMsg],
      isStreaming: false,
      streamingBuffer: '',
    );
  }

  void clearError() => state = state.copyWith(errorMessage: null);

  void cancelStream() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
    if (state.isStreaming) {
      state = state.copyWith(isStreaming: false, streamingBuffer: '');
    }
  }
}
