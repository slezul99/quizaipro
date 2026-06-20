import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/conversation.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/sse_chunk.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/tutor_message.dart';

abstract interface class TutorRepository {
  Future<Either<Failure, List<Conversation>>> getConversations();

  Future<Either<Failure, Conversation>> createConversation({
    required String title,
    String? deckId,
    String? deckTitle,
  });

  Future<Either<Failure, Unit>> renameConversation({
    required String conversationId,
    required String title,
  });

  Future<Either<Failure, Unit>> pinConversation({
    required String conversationId,
    required bool isPinned,
  });

  Future<Either<Failure, Unit>> deleteConversation(String conversationId);

  Future<Either<Failure, List<TutorMessage>>> getMessages(
    String conversationId,
  );

  Stream<Either<Failure, SseChunk>> sendMessage({
    required String conversationId,
    required String content,
    String? deckId,
  });

  Future<Either<Failure, List<Conversation>>> searchConversations(
    String query,
  );

  Future<Either<Failure, int>> syncPending();
}
