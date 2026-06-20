import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/sse_chunk.dart';
import 'package:quizaipro_mobile/features/tutor/domain/repositories/tutor_repository.dart';

class SendMessageParams {
  const SendMessageParams({
    required this.conversationId,
    required this.content,
    this.deckId,
  });

  final String conversationId;
  final String content;
  final String? deckId;
}

class SendMessageUseCase
    implements StreamUseCase<SseChunk, SendMessageParams> {
  const SendMessageUseCase(this._repository);

  final TutorRepository _repository;

  @override
  Stream<Either<Failure, SseChunk>> call(SendMessageParams params) =>
      _repository.sendMessage(
        conversationId: params.conversationId,
        content: params.content,
        deckId: params.deckId,
      );
}
