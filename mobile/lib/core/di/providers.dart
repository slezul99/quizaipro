import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/config/app_config.dart';
import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/core/network/dio_client.dart';
import 'package:quizaipro_mobile/core/network/network_info.dart';
import 'package:quizaipro_mobile/core/storage/drift/app_database.dart';
import 'package:quizaipro_mobile/core/storage/hive_service.dart';
import 'package:quizaipro_mobile/core/storage/secure_storage.dart';

part 'providers.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// L0 — Infrastructure (all keepAlive)
// These are singletons for the lifetime of the app.
// ─────────────────────────────────────────────────────────────────────────────

/// Overridden in [ProviderScope] inside bootstrap.dart.
/// The override provides the [AppDatabase] instance created after
/// [getApplicationDocumentsDirectory] resolves.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  throw StateError(
    'appDatabaseProvider must be overridden in ProviderScope. '
    'Call bootstrap() to initialise the app correctly.',
  );
}

@Riverpod(keepAlive: true)
HiveService hiveService(HiveServiceRef ref) => HiveService();

@Riverpod(keepAlive: true)
SecureStorage secureStorage(SecureStorageRef ref) => SecureStorage();

@Riverpod(keepAlive: true)
NetworkInfo networkInfo(NetworkInfoRef ref) => NetworkInfo();

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) => DioClient.create(
      config: AppConfig.instance,
      secureStorage: ref.watch(secureStorageProvider),
      networkInfo: ref.watch(networkInfoProvider),
      hiveService: ref.watch(hiveServiceProvider),
    );

/// Dedicated Dio instance for SSE (AI Tutor streaming).
/// Uses [ResponseType.stream] and a 5-minute receive timeout.
@Riverpod(keepAlive: true)
Dio sseDio(SseDioRef ref) => DioClient.createSse(
      config: AppConfig.instance,
      secureStorage: ref.watch(secureStorageProvider),
      networkInfo: ref.watch(networkInfoProvider),
      hiveService: ref.watch(hiveServiceProvider),
    );

// ─────────────────────────────────────────────────────────────────────────────
// L0 — UI settings (keepAlive, read from Hive)
// ─────────────────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
ThemeMode themeMode(ThemeModeRef ref) {
  final hive = ref.watch(hiveServiceProvider);
  return switch (hive.themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

@Riverpod(keepAlive: true)
String languageCode(LanguageCodeRef ref) =>
    ref.watch(hiveServiceProvider).languageCode;

// ─────────────────────────────────────────────────────────────────────────────
// App info
// ─────────────────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
String appFlavor(AppFlavorRef ref) => AppConfig.instance.name;

@riverpod
bool onboardingCompleted(OnboardingCompletedRef ref) =>
    ref.watch(hiveServiceProvider).onboardingCompleted;

// ─────────────────────────────────────────────────────────────────────────────
// Connectivity stream
// ─────────────────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
Stream<bool> connectivityStream(ConnectivityStreamRef ref) =>
    ref.watch(networkInfoProvider).onConnectivityChanged;

@riverpod
Future<bool> isConnected(IsConnectedRef ref) =>
    ref.watch(networkInfoProvider).isConnected;

// ─────────────────────────────────────────────────────────────────────────────
// Daily goal
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
int dailyGoal(DailyGoalRef ref) =>
    ref.watch(hiveServiceProvider).dailyGoal;
