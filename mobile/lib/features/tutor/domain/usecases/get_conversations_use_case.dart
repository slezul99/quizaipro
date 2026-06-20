import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/conversation.dart';
import 'package:quizaipro_mobile/features/tutor/domain/repositories/tutor_repository.dart';

class GetConversationsUseCase implements UseCase<List<Conversation>, NoParams> {
  const GetConversationsUseCase(this._repository);

  final TutorRepository _repository;

  @override
  Future<Either<Failure, List<Conversation>>> call(NoParams params) =>
      _repository.getConversations();
}
