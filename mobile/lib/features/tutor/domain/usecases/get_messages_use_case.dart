import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/tutor_message.dart';
import 'package:quizaipro_mobile/features/tutor/domain/repositories/tutor_repository.dart';

class GetMessagesUseCase implements UseCase<List<TutorMessage>, String> {
  const GetMessagesUseCase(this._repository);

  final TutorRepository _repository;

  @override
  Future<Either<Failure, List<TutorMessage>>> call(
    String conversationId,
  ) =>
      _repository.getMessages(conversationId);
}
