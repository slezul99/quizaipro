import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/conversation.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/create_conversation_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/delete_conversation_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/get_conversations_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/pin_conversation_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/rename_conversation_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/search_conversations_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/providers/tutor_providers.dart';

part 'conversations_notifier.freezed.dart';
part 'conversations_notifier.g.dart';

@freezed
class ConversationsState with _$ConversationsState {
  const factory ConversationsState({
    @Default([]) List<Conversation> conversations,
    @Default([]) List<Conversation> searchResults,
    @Default('') String searchQuery,
    @Default(false) bool isSearching,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ConversationsState;

  const ConversationsState._();

  bool get isEmpty => conversations.isEmpty && !isLoading;
  List<Conversation> get pinned =>
      conversations.where((c) => c.isPinned).toList();
  List<Conversation> get unpinned =>
      conversations.where((c) => !c.isPinned).toList();
}

@Riverpod(keepAlive: true)
class ConversationsNotifier extends _$ConversationsNotifier {
  @override
  ConversationsState build() => const ConversationsState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(getConversationsUseCaseProvider);
    final result = await useCase(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.userMessage,
      ),
      (conversations) => state = state.copyWith(
        isLoading: false,
        conversations: conversations,
      ),
    );
  }

  Future<Conversation?> createConversation({
    required String title,
    String? deckId,
    String? deckTitle,
  }) async {
    final useCase = ref.read(createConversationUseCaseProvider);
    final result = await useCase(CreateConversationParams(
      title: title,
      deckId: deckId,
      deckTitle: deckTitle,
    ));

    return result.fold(
      (_) => null,
      (conversation) {
        state = state.copyWith(
          conversations: [conversation, ...state.conversations],
        );
        return conversation;
      },
    );
  }

  Future<void> rename(String conversationId, String title) async {
    final useCase = ref.read(renameConversationUseCaseProvider);
    await useCase(RenameConversationParams(
      conversationId: conversationId,
      title: title,
    ));
    state = state.copyWith(
      conversations: state.conversations
          .map(
            (c) => c.id == conversationId ? c.copyWith(title: title) : c,
          )
          .toList(),
    );
  }

  Future<void> togglePin(String conversationId) async {
    final conversation =
        state.conversations.where((c) => c.id == conversationId).firstOrNull;
    if (conversation == null) return;

    final newPinned = !conversation.isPinned;
    final useCase = ref.read(pinConversationUseCaseProvider);
    await useCase(PinConversationParams(
      conversationId: conversationId,
      isPinned: newPinned,
    ));

    final updated = state.conversations
        .map(
          (c) => c.id == conversationId ? c.copyWith(isPinned: newPinned) : c,
        )
        .toList()
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });

    state = state.copyWith(conversations: updated);
  }

  Future<void> delete(String conversationId) async {
    final useCase = ref.read(deleteConversationUseCaseProvider);
    await useCase(conversationId);
    state = state.copyWith(
      conversations:
          state.conversations.where((c) => c.id != conversationId).toList(),
    );
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, isSearching: query.isNotEmpty);
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: [], isSearching: false);
      return;
    }

    final useCase = ref.read(searchConversationsUseCaseProvider);
    final result = await useCase(query);
    result.fold(
      (_) {},
      (results) => state = state.copyWith(searchResults: results),
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      searchResults: [],
      isSearching: false,
    );
  }

  void updateLastMessage(String conversationId, String preview) {
    state = state.copyWith(
      conversations: state.conversations
          .map(
            (c) => c.id == conversationId
                ? c.copyWith(
                    lastMessagePreview: preview,
                    updatedAt: DateTime.now(),
                    messageCount: c.messageCount + 1,
                  )
                : c,
          )
          .toList()
        ..sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        }),
    );
  }
}
