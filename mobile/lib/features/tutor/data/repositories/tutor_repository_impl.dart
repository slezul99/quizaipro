import 'dart:math';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/storage/drift/app_database.dart';
import 'package:quizaipro_mobile/features/tutor/data/dto/conversation_dto.dart';
import 'package:quizaipro_mobile/features/tutor/data/dto/tutor_message_dto.dart';
import 'package:quizaipro_mobile/features/tutor/data/local/tutor_local_data_source.dart';
import 'package:quizaipro_mobile/features/tutor/data/remote/tutor_remote_data_source.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/conversation.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/message_role.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/sse_chunk.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/tutor_message.dart';
import 'package:quizaipro_mobile/features/tutor/domain/repositories/tutor_repository.dart';

class TutorRepositoryImpl implements TutorRepository {
  TutorRepositoryImpl({
    required TutorRemoteDataSource remoteDataSource,
    required TutorLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final TutorRemoteDataSource _remote;
  final TutorLocalDataSource _local;

  static String _generateId() {
    final rand = Random.secure();
    return List.generate(32, (_) => rand.nextInt(16).toRadixString(16)).join();
  }

  // ── Conversations ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final dtos = await _remote.getConversations();
      for (final d in dtos) {
        await _local.saveConversation(ConversationsLocalTableCompanion(
          id: Value(d.id),
          title: Value(d.title),
          deckId: Value(d.deckId),
          deckTitle: Value(d.deckTitle),
          isPinned: Value(d.isPinned),
          messageCount: Value(d.messageCount),
          lastMessagePreview: Value(d.lastMessagePreview),
          createdAt: Value(d.createdAt),
          updatedAt: Value(d.updatedAt),
          synced: const Value(true),
        ));
      }
      return Right(dtos.map(_dtoToConversation).toList());
    } on DioException catch (e) {
      // Fall back to local cache
      try {
        final rows = await _local.getConversations();
        return Right(rows.map(_rowToConversation).toList());
      } catch (_) {
        return Left(_fromDio(e));
      }
    } catch (e) {
      try {
        final rows = await _local.getConversations();
        return Right(rows.map(_rowToConversation).toList());
      } catch (_) {
        return Left(Failure.unknown(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Conversation>> createConversation({
    required String title,
    String? deckId,
    String? deckTitle,
  }) async {
    final id = _generateId();
    final now = DateTime.now();

    // Save locally first (optimistic)
    await _local.saveConversation(ConversationsLocalTableCompanion(
      id: Value(id),
      title: Value(title),
      deckId: Value(deckId),
      deckTitle: Value(deckTitle),
      isPinned: const Value(false),
      messageCount: const Value(0),
      lastMessagePreview: const Value(null),
      createdAt: Value(now),
      updatedAt: Value(now),
      synced: const Value(false),
    ));

    try {
      final dto = await _remote.createConversation(
        id: id,
        title: title,
        deckId: deckId,
        deckTitle: deckTitle,
      );
      await _local.markConversationSynced(dto.id);
      return Right(_dtoToConversation(dto));
    } on DioException {
      // Returns the local optimistic version — will sync later.
    } catch (_) {}

    return Right(Conversation(
      id: id,
      title: title,
      deckId: deckId,
      deckTitle: deckTitle,
      createdAt: now,
      updatedAt: now,
    ));
  }

  @override
  Future<Either<Failure, Unit>> renameConversation({
    required String conversationId,
    required String title,
  }) async {
    await _local.updateConversationTitle(conversationId, title);
    try {
      await _remote.renameConversation(
        conversationId: conversationId,
        title: title,
      );
      await _local.markConversationSynced(conversationId);
    } catch (_) {}
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> pinConversation({
    required String conversationId,
    required bool isPinned,
  }) async {
    await _local.updateConversationPin(conversationId, isPinned: isPinned);
    try {
      await _remote.pinConversation(
        conversationId: conversationId,
        isPinned: isPinned,
      );
      await _local.markConversationSynced(conversationId);
    } catch (_) {}
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteConversation(
    String conversationId,
  ) async {
    await _local.deleteConversation(conversationId);
    try {
      await _remote.deleteConversation(conversationId);
    } catch (_) {}
    return const Right(unit);
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<TutorMessage>>> getMessages(
    String conversationId,
  ) async {
    try {
      final dtos = await _remote.getMessages(conversationId);
      await _local.saveMessages(dtos
          .map(
            (d) => TutorMessagesLocalTableCompanion(
              id: Value(d.id),
              conversationId: Value(d.conversationId),
              role: Value(d.role),
              content: Value(d.content),
              createdAt: Value(d.createdAt),
              synced: const Value(true),
            ),
          )
          .toList());
      return Right(dtos.map(_dtoToMessage).toList());
    } on DioException catch (e) {
      try {
        final rows = await _local.getMessages(conversationId);
        return Right(rows.map(_rowToMessage).toList());
      } catch (_) {
        return Left(_fromDio(e));
      }
    } catch (e) {
      try {
        final rows = await _local.getMessages(conversationId);
        return Right(rows.map(_rowToMessage).toList());
      } catch (_) {
        return Left(Failure.unknown(message: e.toString()));
      }
    }
  }

  @override
  Stream<Either<Failure, SseChunk>> sendMessage({
    required String conversationId,
    required String content,
    String? deckId,
  }) async* {
    // Persist the user message locally immediately.
    final userMsgId = _generateId();
    final now = DateTime.now();
    await _local.saveMessage(TutorMessagesLocalTableCompanion(
      id: Value(userMsgId),
      conversationId: Value(conversationId),
      role: const Value('user'),
      content: Value(content),
      createdAt: Value(now),
      synced: const Value(false),
    ));

    // Prepare to accumulate the assistant response.
    final assistantMsgId = _generateId();
    final buffer = StringBuffer();

    try {
      final stream = _remote.streamMessage(
        conversationId: conversationId,
        content: content,
        deckId: deckId,
      );

      await for (final chunk in stream) {
        switch (chunk) {
          case SseChunkDelta(:final text):
            buffer.write(text);
            yield Right(chunk);

          case SseChunkDone():
            // Persist the completed assistant message.
            final assistantContent = buffer.toString();
            if (assistantContent.isNotEmpty) {
              await _local.saveMessage(TutorMessagesLocalTableCompanion(
                id: Value(assistantMsgId),
                conversationId: Value(conversationId),
                role: const Value('assistant'),
                content: Value(assistantContent),
                createdAt: Value(DateTime.now()),
                synced: const Value(true),
              ));
            }
            // Update conversation metadata
            final rows = await _local.getMessages(conversationId);
            await _local.updateConversationMeta(
              id: conversationId,
              lastMessagePreview: assistantContent.length > 80
                  ? '${assistantContent.substring(0, 80)}…'
                  : assistantContent,
              messageCount: rows.length,
              updatedAt: DateTime.now(),
            );
            yield Right(chunk);
            return;

          case SseChunkError(:final message):
            yield Left(Failure.aiUnavailable(message: message));
            return;
        }
      }
    } on DioException catch (e) {
      yield Left(_fromDio(e));
    } catch (e) {
      yield Left(Failure.unknown(message: e.toString()));
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Conversation>>> searchConversations(
    String query,
  ) async {
    if (query.trim().isEmpty) return const Right([]);
    try {
      final rows = await _local.searchConversations(query);
      return Right(rows.map(_rowToConversation).toList());
    } catch (e) {
      return Left(Failure.cache(message: e.toString()));
    }
  }

  // ── Sync ──────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, int>> syncPending() async {
    int synced = 0;
    try {
      final conversations = await _local.getUnsyncedConversations();
      for (final c in conversations) {
        try {
          await _remote.createConversation(
            id: c.id,
            title: c.title,
            deckId: c.deckId,
            deckTitle: c.deckTitle,
          );
          await _local.markConversationSynced(c.id);
          synced++;
        } catch (_) {
          continue;
        }
      }
    } catch (_) {}
    return Right(synced);
  }

  // ── Mappers ───────────────────────────────────────────────────────────────

  Conversation _dtoToConversation(ConversationDto d) => Conversation(
        id: d.id,
        title: d.title,
        deckId: d.deckId,
        deckTitle: d.deckTitle,
        isPinned: d.isPinned,
        messageCount: d.messageCount,
        lastMessagePreview: d.lastMessagePreview,
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
        synced: true,
      );

  Conversation _rowToConversation(ConversationsLocalTableData r) =>
      Conversation(
        id: r.id,
        title: r.title,
        deckId: r.deckId,
        deckTitle: r.deckTitle,
        isPinned: r.isPinned,
        messageCount: r.messageCount,
        lastMessagePreview: r.lastMessagePreview,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        synced: r.synced,
      );

  TutorMessage _dtoToMessage(TutorMessageDto d) => TutorMessage(
        id: d.id,
        conversationId: d.conversationId,
        role: _parseRole(d.role),
        content: d.content,
        createdAt: d.createdAt,
        synced: true,
      );

  TutorMessage _rowToMessage(TutorMessagesLocalTableData r) => TutorMessage(
        id: r.id,
        conversationId: r.conversationId,
        role: _parseRole(r.role),
        content: r.content,
        createdAt: r.createdAt,
        synced: r.synced,
      );

  MessageRole _parseRole(String role) => switch (role) {
        'user' => MessageRole.user,
        'assistant' => MessageRole.assistant,
        _ => MessageRole.system,
      };

  Failure _fromDio(DioException e) {
    if (e.error is Failure) return e.error as Failure;
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      return Failure.network(message: e.message ?? 'No internet connection.');
    }
    if (e.response?.statusCode == 401) return const Failure.unauthorized();
    if (e.response?.statusCode == 429) {
      return Failure.rateLimited(message: e.message ?? 'Too many requests.');
    }
    if (e.response?.statusCode == 503) {
      return const Failure.aiUnavailable();
    }
    return Failure.server(
      code: e.response?.statusCode?.toString() ?? 'unknown',
      message: e.message ?? 'Server error.',
    );
  }
}
