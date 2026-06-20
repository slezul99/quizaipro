import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tests/domain/repositories/test_repository.dart';

class SyncPendingTestsUseCase implements UseCase<int, NoParams> {
  const SyncPendingTestsUseCase(this._repository);

  final TestRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams params) =>
      _repository.syncPendingResults();
}
