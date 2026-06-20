import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tutor/domain/repositories/tutor_repository.dart';

class DeleteConversationUseCase implements UseCase<Unit, String> {
  const DeleteConversationUseCase(this._repository);

  final TutorRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String conversationId) =>
      _repository.deleteConversation(conversationId);
}
