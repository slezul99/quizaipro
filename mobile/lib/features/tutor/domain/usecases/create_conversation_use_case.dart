import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/conversation.dart';
import 'package:quizaipro_mobile/features/tutor/domain/repositories/tutor_repository.dart';

class CreateConversationParams {
  const CreateConversationParams({
    required this.title,
    this.deckId,
    this.deckTitle,
  });

  final String title;
  final String? deckId;
  final String? deckTitle;
}

class CreateConversationUseCase
    implements UseCase<Conversation, CreateConversationParams> {
  const CreateConversationUseCase(this._repository);

  final TutorRepository _repository;

  @override
  Future<Either<Failure, Conversation>> call(
    CreateConversationParams params,
  ) =>
      _repository.createConversation(
        title: params.title,
        deckId: params.deckId,
        deckTitle: params.deckTitle,
      );
}
