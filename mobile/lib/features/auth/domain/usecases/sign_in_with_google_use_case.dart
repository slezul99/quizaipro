import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/auth/domain/entities/user.dart';
import 'package:quizaipro_mobile/features/auth/domain/repositories/auth_repository.dart';

class GoogleSignInParams {
  const GoogleSignInParams({required this.idToken});

  final String idToken;
}

class SignInWithGoogleUseCase implements UseCase<User, GoogleSignInParams> {
  const SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(GoogleSignInParams params) =>
      _repository.signInWithGoogle(idToken: params.idToken);
}
