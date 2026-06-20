import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/di/providers.dart';
import 'package:quizaipro_mobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:quizaipro_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:quizaipro_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quizaipro_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:quizaipro_mobile/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:quizaipro_mobile/features/auth/domain/usecases/login_use_case.dart';
import 'package:quizaipro_mobile/features/auth/domain/usecases/logout_use_case.dart';
import 'package:quizaipro_mobile/features/auth/domain/usecases/register_use_case.dart';
import 'package:quizaipro_mobile/features/auth/domain/usecases/sign_in_with_apple_use_case.dart';
import 'package:quizaipro_mobile/features/auth/domain/usecases/sign_in_with_google_use_case.dart';

part 'auth_providers.g.dart';

// ── L1 — Data sources ─────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) =>
    AuthRemoteDataSourceImpl(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
AuthLocalDataSource authLocalDataSource(AuthLocalDataSourceRef ref) =>
    AuthLocalDataSourceImpl(ref.watch(hiveServiceProvider));

// ── L1 — Repository ───────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepositoryImpl(
      remoteDataSource: ref.watch(authRemoteDataSourceProvider),
      localDataSource: ref.watch(authLocalDataSourceProvider),
      secureStorage: ref.watch(secureStorageProvider),
    );

// ── L2 — Use cases ────────────────────────────────────────────────────────────

@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) =>
    LoginUseCase(ref.watch(authRepositoryProvider));

@riverpod
RegisterUseCase registerUseCase(RegisterUseCaseRef ref) =>
    RegisterUseCase(ref.watch(authRepositoryProvider));

@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) =>
    LogoutUseCase(ref.watch(authRepositoryProvider));

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(GetCurrentUserUseCaseRef ref) =>
    GetCurrentUserUseCase(ref.watch(authRepositoryProvider));

@riverpod
SignInWithGoogleUseCase signInWithGoogleUseCase(
  SignInWithGoogleUseCaseRef ref,
) =>
    SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));

@riverpod
SignInWithAppleUseCase signInWithAppleUseCase(
  SignInWithAppleUseCaseRef ref,
) =>
    SignInWithAppleUseCase(ref.watch(authRepositoryProvider));
