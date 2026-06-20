import 'dart:async';

import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/core/config/app_config.dart';
import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.secureStorage,
    required this.dio,
  });

  final SecureStorage secureStorage;

  // Lazy reference to Dio to call the refresh endpoint without circular deps.
  final Dio dio;

  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingQueue = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // The refresh endpoint authenticates via the refresh_token in the body,
    // not a bearer header. Never attach (or overwrite with) the — possibly
    // expired — access token here, otherwise the explicit `Authorization: null`
    // set by the refresh call below would be clobbered. (P0-3)
    if (options.path.contains('/auth/refresh')) {
      handler.next(options);
      return;
    }
    final token = await secureStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Skip refresh loop for the refresh endpoint itself.
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await secureStorage.clearAuthTokens();
      handler.reject(
        err.copyWith(
          error: const UnauthorizedFailure(),
        ),
      );
      return;
    }

    if (_isRefreshing) {
      final completer = Completer<void>();
      _pendingQueue.add(_PendingRequest(err.requestOptions, handler, completer));
      await completer.future;
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await secureStorage.readRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token');

      final response = await dio.post<Map<String, dynamic>>(
        '${AppConfig.instance.apiBaseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
        // Force JSON decoding: this interceptor is shared with the SSE Dio
        // whose BaseOptions.responseType is `stream`. Without this override the
        // refresh response comes back as an undecoded ResponseBody and the
        // `response.data!['data']` access below throws, wiping the tokens and
        // failing every AI-Tutor stream with a 401 right after a 200. (P0-3)
        options: Options(
          responseType: ResponseType.json,
          headers: {'Authorization': null},
        ),
      );

      final data = (response.data!['data'] as Map<String, dynamic>);
      final newAccessToken = data['access_token'] as String;
      final newRefreshToken = data['refresh_token'] as String;

      await Future.wait([
        secureStorage.writeAccessToken(newAccessToken),
        secureStorage.writeRefreshToken(newRefreshToken),
      ]);

      // Replay the original failed request with the new token.
      final retryOptions = err.requestOptions.copyWith(
        headers: {
          ...err.requestOptions.headers,
          'Authorization': 'Bearer $newAccessToken',
        },
      );
      final retryResponse = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);

      // Replay all queued requests.
      for (final pending in _pendingQueue) {
        final pendingOptions = pending.options.copyWith(
          headers: {
            ...pending.options.headers,
            'Authorization': 'Bearer $newAccessToken',
          },
        );
        try {
          final r = await dio.fetch<dynamic>(pendingOptions);
          pending.handler.resolve(r);
        } catch (e) {
          pending.handler.next(
            DioException(requestOptions: pending.options, error: e),
          );
        }
        pending.completer.complete();
      }
    } catch (_) {
      await secureStorage.clearAuthTokens();
      for (final pending in _pendingQueue) {
        pending.handler.reject(
          err.copyWith(
            requestOptions: pending.options,
            error: const UnauthorizedFailure(),
          ),
        );
        pending.completer.complete();
      }
      handler.reject(err.copyWith(error: const UnauthorizedFailure()));
    } finally {
      _pendingQueue.clear();
      _isRefreshing = false;
    }
  }
}

class _PendingRequest {
  const _PendingRequest(this.options, this.handler, this.completer);

  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  final Completer<void> completer;
}
