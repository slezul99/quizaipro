import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/auth/domain/entities/user.dart';
import 'package:quizaipro_mobile/features/auth/domain/repositories/auth_repository.dart';

class AppleSignInParams {
  const AppleSignInParams({
    required this.identityToken,
    required this.authorizationCode,
    this.fullName,
  });

  final String identityToken;
  final String authorizationCode;
  final String? fullName;
}

class SignInWithAppleUseCase implements UseCase<User, AppleSignInParams> {
  const SignInWithAppleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(AppleSignInParams params) =>
      _repository.signInWithApple(
        identityToken: params.identityToken,
        authorizationCode: params.authorizationCode,
        fullName: params.fullName,
      );
}
