import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If the error already carries a typed Failure (set by AuthInterceptor or
    // ConnectivityInterceptor), pass it through unchanged.
    if (err.error is Failure) {
      handler.next(err);
      return;
    }

    final failure = _resolve(err);
    handler.next(err.copyWith(error: failure));
  }

  Failure _resolve(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      return NetworkFailure(
        message: 'Unable to connect to ${err.requestOptions.uri}. Check your internet connection.',
        retryable: true,
      );
    }

    if (err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return NetworkFailure(
        message: 'Request timed out for ${err.requestOptions.uri}. Please try again.',
        retryable: true,
      );
    }

    final statusCode = err.response?.statusCode;
    if (statusCode == null) {
      return NetworkFailure(
        message: err.message ?? 'Network error.',
        retryable: true,
      );
    }

    final body = err.response?.data;
    final apiError = _extractApiError(body);

    return switch (statusCode) {
      400 => ValidationFailure(
          message: apiError?.message ?? 'Invalid request.',
          fields: apiError?.fields,
        ),
      401 => const UnauthorizedFailure(),
      403 => ServerFailure(
          code: apiError?.code ?? 'forbidden',
          message: apiError?.message ?? 'Access denied.',
        ),
      404 => ServerFailure(
          code: apiError?.code ?? 'not_found',
          message: apiError?.message ?? 'Resource not found.',
        ),
      409 => ServerFailure(
          code: apiError?.code ?? 'conflict',
          message: apiError?.message ?? 'Conflict.',
        ),
      422 => ValidationFailure(
          message: apiError?.message ?? 'Validation failed.',
          fields: apiError?.fields,
        ),
      429 => RateLimitedFailure(
          message: apiError?.message ?? 'Too many requests.',
          retryAfterSeconds: _parseRetryAfter(err.response),
        ),
      503 => const AiUnavailableFailure(),
      _ when statusCode >= 500 => ServerFailure(
          code: apiError?.code ?? 'server_error',
          message: apiError?.message ?? 'Server error. Please try again later.',
          retryable: true,
        ),
      _ => ServerFailure(
          code: apiError?.code ?? 'unknown',
          message: apiError?.message ?? 'Unexpected error.',
        ),
    };
  }

  _ApiError? _extractApiError(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final error = body['error'];
    if (error is! Map<String, dynamic>) return null;

    Map<String, List<String>>? fields;
    final rawFields = error['fields'];
    if (rawFields is Map) {
      fields = rawFields.map(
        (k, v) => MapEntry(
          k.toString(),
          (v as List).map((e) => e.toString()).toList(),
        ),
      );
    }

    return _ApiError(
      code: error['code']?.toString() ?? '',
      message: error['message']?.toString() ?? '',
      fields: fields,
    );
  }

  int? _parseRetryAfter(Response<dynamic>? response) {
    final header = response?.headers.value('retry-after');
    return header != null ? int.tryParse(header) : null;
  }
}

class _ApiError {
  const _ApiError({required this.code, required this.message, this.fields});

  final String code;
  final String message;
  final Map<String, List<String>>? fields;
}
