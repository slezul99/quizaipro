import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tutor/domain/repositories/tutor_repository.dart';

class PinConversationParams {
  const PinConversationParams({
    required this.conversationId,
    required this.isPinned,
  });

  final String conversationId;
  final bool isPinned;
}

class PinConversationUseCase
    implements UseCase<Unit, PinConversationParams> {
  const PinConversationUseCase(this._repository);

  final TutorRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(PinConversationParams params) =>
      _repository.pinConversation(
        conversationId: params.conversationId,
        isPinned: params.isPinned,
      );
}
