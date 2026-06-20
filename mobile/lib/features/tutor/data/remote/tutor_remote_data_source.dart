import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/features/tutor/data/dto/conversation_dto.dart';
import 'package:quizaipro_mobile/features/tutor/data/dto/send_message_request_dto.dart';
import 'package:quizaipro_mobile/features/tutor/data/dto/tutor_message_dto.dart';
import 'package:quizaipro_mobile/features/tutor/data/remote/sse_connection_manager.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/sse_chunk.dart';

abstract interface class TutorRemoteDataSource {
  Future<List<ConversationDto>> getConversations();
  Future<ConversationDto> createConversation({
    required String id,
    required String title,
    String? deckId,
    String? deckTitle,
  });
  Future<void> renameConversation({
    required String conversationId,
    required String title,
  });
  Future<void> pinConversation({
    required String conversationId,
    required bool isPinned,
  });
  Future<void> deleteConversation(String conversationId);
  Future<List<TutorMessageDto>> getMessages(String conversationId);
  Stream<SseChunk> streamMessage({
    required String conversationId,
    required String content,
    String? deckId,
  });
  Future<List<ConversationDto>> searchConversations(String query);
}

class TutorRemoteDataSourceImpl implements TutorRemoteDataSource {
  TutorRemoteDataSourceImpl({
    required Dio dio,
    required SseConnectionManager sseManager,
  })  : _dio = dio,
        _sse = sseManager;

  final Dio _dio;
  final SseConnectionManager _sse;

  @override
  Future<List<ConversationDto>> getConversations() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/tutor/conversations');
    final data = response.data!['data'] as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(ConversationDto.fromJson)
        .toList();
  }

  @override
  Future<ConversationDto> createConversation({
    required String id,
    required String title,
    String? deckId,
    String? deckTitle,
  }) async {
    final body = <String, dynamic>{
      'id': id,
      'title': title,
      if (deckId != null) 'deck_id': deckId,
      if (deckTitle != null) 'deck_title': deckTitle,
    };
    final response = await _dio.post<Map<String, dynamic>>(
      '/tutor/conversations',
      data: body,
    );
    return ConversationDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> renameConversation({
    required String conversationId,
    required String title,
  }) =>
      _dio.patch<void>(
        '/tutor/conversations/$conversationId',
        data: {'title': title},
      );

  @override
  Future<void> pinConversation({
    required String conversationId,
    required bool isPinned,
  }) =>
      _dio.patch<void>(
        '/tutor/conversations/$conversationId/pin',
        data: {'is_pinned': isPinned},
      );

  @override
  Future<void> deleteConversation(String conversationId) =>
      _dio.delete<void>('/tutor/conversations/$conversationId');

  @override
  Future<List<TutorMessageDto>> getMessages(String conversationId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tutor/conversations/$conversationId/messages',
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(TutorMessageDto.fromJson)
        .toList();
  }

  @override
  Stream<SseChunk> streamMessage({
    required String conversationId,
    required String content,
    String? deckId,
  }) {
    final body = <String, dynamic>{
      'conversation_id': conversationId,
      'content': content,
      if (deckId != null) 'deck_id': deckId,
    };
    return _sse.connect(
      path: '/tutor/stream',
      body: body,
    );
  }

  @override
  Future<List<ConversationDto>> searchConversations(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tutor/conversations',
      queryParameters: {'q': query},
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(ConversationDto.fromJson)
        .toList();
  }
}
