import 'package:hive_flutter/hive_flutter.dart';

import 'package:quizaipro_mobile/core/config/app_constants.dart';

class HiveService {
  Box<dynamic> get settings => Hive.box<dynamic>(AppConstants.settingsBox);

  Box<dynamic> get featureFlags =>
      Hive.box<dynamic>(AppConstants.featureFlagsBox);

  Box<dynamic> get marketplaceListings =>
      Hive.box<dynamic>(AppConstants.marketplaceListingsBox);

  Box<dynamic> get drafts => Hive.box<dynamic>(AppConstants.draftsBox);

  Box<dynamic> get library => Hive.box<dynamic>(AppConstants.libraryBox);

  // ── Typed settings helpers ────────────────────────────────────────────────

  String get themeMode =>
      settings.get(AppConstants.themeKey, defaultValue: 'system') as String;

  Future<void> setThemeMode(String mode) =>
      settings.put(AppConstants.themeKey, mode);

  String get languageCode =>
      settings.get(AppConstants.languageKey, defaultValue: 'ru') as String;

  Future<void> setLanguageCode(String code) =>
      settings.put(AppConstants.languageKey, code);

  int get dailyGoal =>
      settings.get(AppConstants.dailyGoalKey, defaultValue: 20) as int;

  Future<void> setDailyGoal(int count) =>
      settings.put(AppConstants.dailyGoalKey, count);

  bool get onboardingCompleted =>
      settings.get(AppConstants.onboardingCompletedKey, defaultValue: false)
          as bool;

  Future<void> setOnboardingCompleted() =>
      settings.put(AppConstants.onboardingCompletedKey, true);

  // ── Feature flags ─────────────────────────────────────────────────────────

  bool flag(String key, {bool defaultValue = false}) =>
      featureFlags.get(key, defaultValue: defaultValue) as bool;

  Future<void> setFlag(String key, {required bool value}) =>
      featureFlags.put(key, value);

  // ── TTL-cached listings ───────────────────────────────────────────────────

  Future<void> putListingsCache(String key, dynamic data, DateTime expiresAt) =>
      marketplaceListings.put(
        key,
        {'data': data, 'expiresAt': expiresAt.millisecondsSinceEpoch},
      );

  ({dynamic data, bool expired}) getListingsCache(String key) {
    final entry = marketplaceListings.get(key) as Map?;
    if (entry == null) return (data: null, expired: true);
    final expiresAt =
        DateTime.fromMillisecondsSinceEpoch(entry['expiresAt'] as int);
    return (
      data: entry['data'],
      expired: DateTime.now().isAfter(expiresAt),
    );
  }

  // ── Drafts ────────────────────────────────────────────────────────────────

  Future<void> saveDraft(String key, dynamic draft) =>
      drafts.put(key, draft);

  dynamic getDraft(String key) => drafts.get(key);

  Future<void> deleteDraft(String key) => drafts.delete(key);

  // ── TTL-cached dashboard ──────────────────────────────────────────────────

  Future<void> putDashboardCache(
    String key,
    dynamic data,
    DateTime expiresAt,
  ) =>
      settings.put(key, {
        'data': data,
        'expiresAt': expiresAt.millisecondsSinceEpoch,
      });

  ({dynamic data, bool expired}) getDashboardCache(String key) {
    final entry = settings.get(key) as Map?;
    if (entry == null) return (data: null, expired: true);
    final expiresAt =
        DateTime.fromMillisecondsSinceEpoch(entry['expiresAt'] as int);
    return (
      data: entry['data'],
      expired: DateTime.now().isAfter(expiresAt),
    );
  }

  Future<void> clearDashboardCache() => Future.wait([
        settings.delete(AppConstants.dashboardCacheSummaryKey),
        settings.delete(AppConstants.dashboardCacheActivityKey),
      ]);

  // ── TTL-cached library ────────────────────────────────────────────────────

  Future<void> putLibraryCache(
    String key,
    dynamic data,
    DateTime expiresAt,
  ) =>
      library.put(key, {
        'data': data,
        'expiresAt': expiresAt.millisecondsSinceEpoch,
      });

  ({dynamic data, bool expired}) getLibraryCache(String key) {
    final entry = library.get(key) as Map?;
    if (entry == null) return (data: null, expired: true);
    final expiresAt =
        DateTime.fromMillisecondsSinceEpoch(entry['expiresAt'] as int);
    return (
      data: entry['data'],
      expired: DateTime.now().isAfter(expiresAt),
    );
  }

  Future<void> clearLibraryCache() => library.clear();

  // ── Flush all boxes ───────────────────────────────────────────────────────

  Future<void> clearAll() => Future.wait([
        settings.clear(),
        featureFlags.clear(),
        marketplaceListings.clear(),
        drafts.clear(),
        library.clear(),
      ]);
}
