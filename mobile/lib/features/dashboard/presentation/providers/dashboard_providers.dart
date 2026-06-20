import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/di/providers.dart';
import 'package:quizaipro_mobile/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:quizaipro_mobile/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:quizaipro_mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/usecases/get_dashboard_summary_use_case.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/usecases/get_recent_activity_use_case.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/usecases/refresh_dashboard_use_case.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/usecases/get_streak_journey_use_case.dart';

import 'package:quizaipro_mobile/features/dashboard/domain/usecases/get_level_journey_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'dashboard_providers.g.dart';


// ── L1: Data Sources ─────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
DashboardRemoteDataSource dashboardRemoteDataSource(
  DashboardRemoteDataSourceRef ref,
) {
  final dio = ref.watch(dioProvider);
  return DashboardRemoteDataSourceImpl(dio);
}

@Riverpod(keepAlive: true)
DashboardLocalDataSource dashboardLocalDataSource(
  DashboardLocalDataSourceRef ref,
) {
  final hive = ref.watch(hiveServiceProvider);
  return DashboardLocalDataSourceImpl(hive);
}

// ── L1: Repository ────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) =>
    DashboardRepositoryImpl(
      remoteDataSource: ref.watch(dashboardRemoteDataSourceProvider),
      localDataSource: ref.watch(dashboardLocalDataSourceProvider),
    );

// ── L2: Use Cases ─────────────────────────────────────────────────────────────

@riverpod
GetDashboardSummaryUseCase getDashboardSummaryUseCase(
  GetDashboardSummaryUseCaseRef ref,
) =>
    GetDashboardSummaryUseCase(ref.watch(dashboardRepositoryProvider));

@riverpod
RefreshDashboardUseCase refreshDashboardUseCase(
  RefreshDashboardUseCaseRef ref,
) =>
    RefreshDashboardUseCase(ref.watch(dashboardRepositoryProvider));

@riverpod
GetRecentActivityUseCase getRecentActivityUseCase(
  GetRecentActivityUseCaseRef ref,
) =>
    GetRecentActivityUseCase(ref.watch(dashboardRepositoryProvider));

@riverpod
GetStreakJourneyUseCase getStreakJourneyUseCase(
  GetStreakJourneyUseCaseRef ref,
) =>
    GetStreakJourneyUseCase(ref.watch(dashboardRepositoryProvider));

final getLevelJourneyUseCaseProvider = Provider.autoDispose<GetLevelJourneyUseCase>((ref) {
  return GetLevelJourneyUseCase(ref.watch(dashboardRepositoryProvider));
});

