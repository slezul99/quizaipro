import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('→ ${options.method} ${options.uri}');
      final headers = Map<String, dynamic>.from(options.headers)
        ..remove('Authorization');
      if (headers.isNotEmpty) debugPrint('  headers: $headers');
      if (options.data != null) debugPrint('  body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '← ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '✗ ${err.requestOptions.method} ${err.requestOptions.uri} '
        '— ${err.response?.statusCode} ${err.message}',
      );
    }
    handler.next(err);
  }
}
