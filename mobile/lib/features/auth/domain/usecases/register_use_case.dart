import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/auth/domain/entities/user.dart';
import 'package:quizaipro_mobile/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.username,
    this.displayName,
  });

  final String email;
  final String password;
  final String username;
  final String? displayName;
}

class RegisterUseCase implements UseCase<User, RegisterParams> {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(RegisterParams params) =>
      _repository.register(
        email: params.email,
        password: params.password,
        username: params.username,
        displayName: params.displayName,
      );
}
