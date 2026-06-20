import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_result.dart';
import 'package:quizaipro_mobile/features/tests/domain/repositories/test_repository.dart';

class SubmitTestUseCase implements UseCase<Unit, TestResult> {
  const SubmitTestUseCase(this._repository);

  final TestRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(TestResult params) =>
      _repository.saveResult(params);
}
