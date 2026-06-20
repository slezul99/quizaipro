import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String username,
    String? displayName,
  });

  Future<Either<Failure, User>> signInWithGoogle({
    required String idToken,
  });

  Future<Either<Failure, User>> signInWithApple({
    required String identityToken,
    required String authorizationCode,
    String? fullName,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  User? get cachedUser;

  Future<void> cacheUser(User user);

  Future<void> clearCache();
}
