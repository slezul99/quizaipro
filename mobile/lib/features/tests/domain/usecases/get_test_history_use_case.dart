import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_history_item.dart';
import 'package:quizaipro_mobile/features/tests/domain/repositories/test_repository.dart';

class GetTestHistoryParams {
  const GetTestHistoryParams({required this.deckId});
  final String deckId;
}

class GetTestHistoryUseCase
    implements UseCase<List<TestHistoryItem>, GetTestHistoryParams> {
  const GetTestHistoryUseCase(this._repository);

  final TestRepository _repository;

  @override
  Future<Either<Failure, List<TestHistoryItem>>> call(
    GetTestHistoryParams params,
  ) =>
      _repository.getTestHistory(params.deckId);
}
