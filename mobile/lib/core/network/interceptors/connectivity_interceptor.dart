import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/network/network_info.dart';

class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._networkInfo);

  final NetworkInfo _networkInfo;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const NetworkFailure(
            message: 'No internet connection.',
            retryable: true,
          ),
          message: 'No internet connection.',
        ),
        true,
      );
      return;
    }
    handler.next(options);
  }
}
