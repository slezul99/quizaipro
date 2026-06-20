import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/core/config/app_constants.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);

  final Dio _dio;

  static const _retriableTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.connectionTimeout,
  };

  static const _idempotentMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = err.requestOptions.extra['_retryCount'] as int? ?? 0;
    final method = err.requestOptions.method.toUpperCase();
    final isRetriable = _retriableTypes.contains(err.type) ||
        (err.response?.statusCode == 503);
    final isIdempotent = _idempotentMethods.contains(method);

    if (isRetriable && isIdempotent && attempt < AppConstants.maxRetries) {
      final delayMs = AppConstants.retryBaseDelayMs * (1 << attempt);
      await Future<void>.delayed(Duration(milliseconds: delayMs));

      final options = err.requestOptions.copyWith(
        extra: {...err.requestOptions.extra, '_retryCount': attempt + 1},
      );

      try {
        final response = await _dio.fetch<dynamic>(options);
        handler.resolve(response);
      } on DioException catch (retryErr) {
        handler.next(retryErr);
      }
      return;
    }

    handler.next(err);
  }
}
