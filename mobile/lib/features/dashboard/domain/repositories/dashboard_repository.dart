import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/activity_item.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_journey.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/level_journey.dart';

abstract interface class DashboardRepository {
  /// Returns cached summary if TTL is valid, otherwise fetches from network.
  Future<Either<Failure, DashboardSummary>> getDashboardSummary();

  /// Always fetches from network. Falls back to cache on network error.
  Future<Either<Failure, DashboardSummary>> refreshDashboardSummary();

  Future<Either<Failure, List<ActivityItem>>> getRecentActivity({int limit = 10});
  
  Future<Either<Failure, StreakJourney>> getStreakJourney();

  Future<Either<Failure, LevelJourney>> getLevelJourney();

  DashboardSummary? get cachedSummary;
  List<ActivityItem> get cachedActivity;
}

