import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:quizaipro_mobile/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:quizaipro_mobile/features/dashboard/data/mappers/dashboard_mapper.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/activity_item.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/level_journey.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_journey.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {


  DashboardRepositoryImpl({
    required DashboardRemoteDataSource remoteDataSource,
    required DashboardLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final DashboardRemoteDataSource _remote;
  final DashboardLocalDataSource _local;

  DashboardSummary? _cachedSummary;
  List<ActivityItem> _cachedActivity = const [];

  @override
  DashboardSummary? get cachedSummary => _cachedSummary;

  @override
  List<ActivityItem> get cachedActivity => _cachedActivity;

  // ── Summary ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary() async {
    if (_local.isSummaryCacheValid()) {
      final cached = _local.getCachedSummary();
      if (cached != null) {
        _cachedSummary = DashboardMapper.summaryFromDto(cached);
        return Right(_cachedSummary!);
      }
    }
    return _fetchAndCacheSummary();
  }

  @override
  Future<Either<Failure, DashboardSummary>> refreshDashboardSummary() =>
      _fetchAndCacheSummary();

  Future<Either<Failure, DashboardSummary>> _fetchAndCacheSummary() async {
    try {
      final dto = await _remote.getDashboardSummary();
      await _local.cacheSummary(dto);
      _cachedSummary = DashboardMapper.summaryFromDto(dto);
      return Right(_cachedSummary!);
    } on DioException catch (e) {
      final failure = _fromDio(e);
      // On connectivity error, return stale cache rather than failing.
      if (failure is NetworkFailure) {
        final stale = _local.getCachedSummary();
        if (stale != null) {
          _cachedSummary = DashboardMapper.summaryFromDto(stale);
          return Right(_cachedSummary!);
        }
      }
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Activity ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ActivityItem>>> getRecentActivity({
    int limit = 10,
  }) async {
    try {
      final dtos = await _remote.getRecentActivity(limit: limit);
      await _local.cacheActivity(dtos);
      _cachedActivity = dtos.map(DashboardMapper.activityFromDto).toList();
      return Right(_cachedActivity);
    } on DioException catch (e) {
      final failure = _fromDio(e);
      if (failure is NetworkFailure) {
        final cached = _local.getCachedActivity();
        _cachedActivity = cached.map(DashboardMapper.activityFromDto).toList();
        return Right(_cachedActivity);
      }
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StreakJourney>> getStreakJourney() async {
    try {
      final json = await _remote.getStreakJourney();
      return Right(StreakJourney.fromJson(json));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LevelJourney>> getLevelJourney() async {
    try {
      final json = await _remote.getLevelJourney();
      return Right(LevelJourney.fromJson(json));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Failure _fromDio(DioException e) {
    if (e.error is Failure) return e.error as Failure;
    return NetworkFailure(message: e.message ?? 'Network error.');
  }
}

