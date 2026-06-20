import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/storage/secure_storage.dart';
import 'package:quizaipro_mobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:quizaipro_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:quizaipro_mobile/features/auth/data/dto/apple_auth_request_dto.dart';
import 'package:quizaipro_mobile/features/auth/data/dto/google_auth_request_dto.dart';
import 'package:quizaipro_mobile/features/auth/data/dto/login_request_dto.dart';
import 'package:quizaipro_mobile/features/auth/data/dto/register_request_dto.dart';
import 'package:quizaipro_mobile/features/auth/data/mappers/user_mapper.dart';
import 'package:quizaipro_mobile/features/auth/domain/entities/user.dart';
import 'package:quizaipro_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required SecureStorage secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _secureStorage = secureStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final SecureStorage _secureStorage;

  User? _cachedUser;

  @override
  User? get cachedUser => _cachedUser;

  // ── Login ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequestDto(email: email, password: password),
      );
      return Right(await _persistSession(response.accessToken, response.refreshToken, response.user));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        RegisterRequestDto(
          email: email,
          password: password,
          username: username,
          displayName: displayName,
        ),
      );
      return Right(await _persistSession(response.accessToken, response.refreshToken, response.user));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Google Sign In ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, User>> signInWithGoogle({
    required String idToken,
  }) async {
    try {
      final response = await _remoteDataSource.signInWithGoogle(
        GoogleAuthRequestDto(idToken: idToken),
      );
      return Right(await _persistSession(response.accessToken, response.refreshToken, response.user));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Apple Sign In ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, User>> signInWithApple({
    required String identityToken,
    required String authorizationCode,
    String? fullName,
  }) async {
    try {
      final response = await _remoteDataSource.signInWithApple(
        AppleAuthRequestDto(
          identityToken: identityToken,
          authorizationCode: authorizationCode,
          fullName: fullName,
        ),
      );
      return Right(await _persistSession(response.accessToken, response.refreshToken, response.user));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await _secureStorage.readRefreshToken();
      if (refreshToken != null) {
        // Best-effort: ignore server errors during logout.
        await _remoteDataSource.logout(refreshToken).catchError((_) {});
      }
      await _clearSession();
      return const Right(null);
    } catch (e) {
      // Always succeed locally even if server logout fails.
      await _clearSession();
      return const Right(null);
    }
  }

  // ── Get Current User ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final dto = await _remoteDataSource.getCurrentUser();
      final user = UserMapper.fromDto(dto);
      _cachedUser = user;
      await _localDataSource.cacheUser(dto);
      return Right(user);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Cache ops ─────────────────────────────────────────────────────────────

  @override
  Future<void> cacheUser(User user) async {
    _cachedUser = user;
    await _localDataSource.cacheUser(UserMapper.toDto(user));
  }

  @override
  Future<void> clearCache() async {
    _cachedUser = null;
    await _localDataSource.clearUser();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<User> _persistSession(
    String accessToken,
    String refreshToken,
    dynamic userDto,
  ) async {
    await Future.wait([
      _secureStorage.writeAccessToken(accessToken),
      _secureStorage.writeRefreshToken(refreshToken),
      _localDataSource.cacheUser(userDto),
    ]);
    final user = UserMapper.fromDto(userDto);
    _cachedUser = user;
    return user;
  }

  Future<void> _clearSession() async {
    _cachedUser = null;
    await Future.wait([
      _secureStorage.clearAuthTokens(),
      _localDataSource.clearUser(),
    ]);
  }

  Failure _fromDio(DioException e) {
    if (e.error is Failure) return e.error as Failure;
    return NetworkFailure(message: e.message ?? 'Network error.');
  }
}
