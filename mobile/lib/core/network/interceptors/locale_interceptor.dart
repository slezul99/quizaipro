import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/core/storage/hive_service.dart';

/// Tags every request with the app's UI language so localized backend
/// responses (marketplace subjects, AI tutor, AI generation) match what the
/// user sees on screen, instead of falling back to the account's stored
/// `users.lang` (which can drift out of sync with the device language).
class LocaleInterceptor extends Interceptor {
  LocaleInterceptor(this._hiveService);

  final HiveService _hiveService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.queryParameters.putIfAbsent(
      'lang',
      () => _hiveService.languageCode,
    );
    handler.next(options);
  }
}
