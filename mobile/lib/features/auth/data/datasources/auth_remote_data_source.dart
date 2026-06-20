import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/features/auth/data/dto/apple_auth_request_dto.dart';
import 'package:quizaipro_mobile/features/auth/data/dto/auth_response_dto.dart';
import 'package:quizaipro_mobile/features/auth/data/dto/google_auth_request_dto.dart';
import 'package:quizaipro_mobile/features/auth/data/dto/login_request_dto.dart';
import 'package:quizaipro_mobile/features/auth/data/dto/register_request_dto.dart';
import 'package:quizaipro_mobile/features/auth/data/dto/user_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponseDto> login(LoginRequestDto request);

  Future<AuthResponseDto> register(RegisterRequestDto request);

  Future<AuthResponseDto> signInWithGoogle(GoogleAuthRequestDto request);

  Future<AuthResponseDto> signInWithApple(AppleAuthRequestDto request);

  Future<void> logout(String refreshToken);

  Future<UserDto> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AuthResponseDto> signInWithGoogle(
    GoogleAuthRequestDto request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/google',
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AuthResponseDto> signInWithApple(
    AppleAuthRequestDto request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/apple',
      data: request.toJson(),
    );
    return AuthResponseDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _dio.post<void>(
      '/auth/logout',
      data: {'refresh_token': refreshToken},
    );
  }

  @override
  Future<UserDto> getCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return UserDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }
}
