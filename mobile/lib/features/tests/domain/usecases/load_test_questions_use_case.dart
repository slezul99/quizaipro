import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/repositories/test_repository.dart';

class LoadTestQuestionsParams {
  const LoadTestQuestionsParams({required this.deckId});
  final String deckId;
}

class LoadTestQuestionsUseCase
    implements UseCase<List<TestQuestion>, LoadTestQuestionsParams> {
  const LoadTestQuestionsUseCase(this._repository);

  final TestRepository _repository;

  @override
  Future<Either<Failure, List<TestQuestion>>> call(
    LoadTestQuestionsParams params,
  ) =>
      _repository.getQuestionsForDeck(params.deckId);
}
