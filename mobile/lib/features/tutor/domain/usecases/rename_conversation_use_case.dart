import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tutor/domain/repositories/tutor_repository.dart';

class RenameConversationParams {
  const RenameConversationParams({
    required this.conversationId,
    required this.title,
  });

  final String conversationId;
  final String title;
}

class RenameConversationUseCase
    implements UseCase<Unit, RenameConversationParams> {
  const RenameConversationUseCase(this._repository);

  final TutorRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(RenameConversationParams params) =>
      _repository.renameConversation(
        conversationId: params.conversationId,
        title: params.title,
      );
}
