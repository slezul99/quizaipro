import 'dart:convert';

import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/core/storage/hive_service.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/activity_item_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/dashboard_summary_dto.dart';

abstract interface class DashboardLocalDataSource {
  DashboardSummaryDto? getCachedSummary();
  List<ActivityItemDto> getCachedActivity();
  bool isSummaryCacheValid();
  Future<void> cacheSummary(DashboardSummaryDto dto);
  Future<void> cacheActivity(List<ActivityItemDto> dtos);
  Future<void> clearCache();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  const DashboardLocalDataSourceImpl(this._hive);

  final HiveService _hive;

  @override
  bool isSummaryCacheValid() {
    final cached = _hive.getDashboardCache(AppConstants.dashboardCacheSummaryKey);
    return !cached.expired && cached.data != null;
  }

  @override
  DashboardSummaryDto? getCachedSummary() {
    final cached = _hive.getDashboardCache(AppConstants.dashboardCacheSummaryKey);
    if (cached.expired || cached.data == null) return null;
    try {
      return DashboardSummaryDto.fromJson(
        jsonDecode(cached.data as String) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  List<ActivityItemDto> getCachedActivity() {
    final cached = _hive.getDashboardCache(AppConstants.dashboardCacheActivityKey);
    if (cached.expired || cached.data == null) return const [];
    try {
      final list = jsonDecode(cached.data as String) as List<dynamic>;
      return list
          .map((e) => ActivityItemDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> cacheSummary(DashboardSummaryDto dto) async {
    final expiresAt = DateTime.now().add(
      const Duration(minutes: AppConstants.dashboardCacheTtlMinutes),
    );
    await _hive.putDashboardCache(
      AppConstants.dashboardCacheSummaryKey,
      jsonEncode(dto.toJson()),
      expiresAt,
    );
  }

  @override
  Future<void> cacheActivity(List<ActivityItemDto> dtos) async {
    final expiresAt = DateTime.now().add(
      const Duration(minutes: AppConstants.dashboardCacheTtlMinutes),
    );
    await _hive.putDashboardCache(
      AppConstants.dashboardCacheActivityKey,
      jsonEncode(dtos.map((e) => e.toJson()).toList()),
      expiresAt,
    );
  }

  @override
  Future<void> clearCache() => _hive.clearDashboardCache();
}
