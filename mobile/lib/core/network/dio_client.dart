import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/core/config/app_config.dart';
import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:quizaipro_mobile/core/network/interceptors/connectivity_interceptor.dart';
import 'package:quizaipro_mobile/core/network/interceptors/error_interceptor.dart';
import 'package:quizaipro_mobile/core/network/interceptors/locale_interceptor.dart';
import 'package:quizaipro_mobile/core/network/interceptors/logging_interceptor.dart';
import 'package:quizaipro_mobile/core/network/interceptors/retry_interceptor.dart';
import 'package:quizaipro_mobile/core/network/network_info.dart';
import 'package:quizaipro_mobile/core/storage/hive_service.dart';
import 'package:quizaipro_mobile/core/storage/secure_storage.dart';

abstract final class DioClient {
  static Dio create({
    required AppConfig config,
    required SecureStorage secureStorage,
    required NetworkInfo networkInfo,
    required HiveService hiveService,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        sendTimeout: const Duration(milliseconds: AppConstants.sendTimeoutMs),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    // Interceptor chain: Connectivity → Auth → Locale → Logging → Retry → Error
    dio.interceptors.addAll([
      ConnectivityInterceptor(networkInfo),
      AuthInterceptor(secureStorage: secureStorage, dio: dio),
      LocaleInterceptor(hiveService),
      if (config.enableLogging) LoggingInterceptor(),
      RetryInterceptor(dio),
      ErrorInterceptor(),
    ]);

    return dio;
  }

  /// Creates a Dio instance for SSE (AI Tutor streaming).
  /// No retry, no error conversion — streams handle their own error events.
  static Dio createSse({
    required AppConfig config,
    required SecureStorage secureStorage,
    required NetworkInfo networkInfo,
    required HiveService hiveService,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(minutes: 5),
        headers: {
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
        },
        responseType: ResponseType.stream,
      ),
    );

    dio.interceptors.addAll([
      ConnectivityInterceptor(networkInfo),
      AuthInterceptor(secureStorage: secureStorage, dio: dio),
      LocaleInterceptor(hiveService),
      if (config.enableLogging) LoggingInterceptor(),
    ]);

    return dio;
  }
}
