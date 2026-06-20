import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/auth/domain/entities/user.dart';
import 'package:quizaipro_mobile/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<User, NoParams> {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(NoParams params) =>
      _repository.getCurrentUser();
}
