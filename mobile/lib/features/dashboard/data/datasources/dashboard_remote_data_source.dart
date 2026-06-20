import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/features/dashboard/data/dto/activity_item_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/dashboard_summary_dto.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardSummaryDto> getDashboardSummary();
  Future<List<ActivityItemDto>> getRecentActivity({int limit = 10});
  Future<Map<String, dynamic>> getStreakJourney();
  Future<Map<String, dynamic>> getLevelJourney();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DashboardSummaryDto> getDashboardSummary() async {
    final response = await _dio.get<Map<String, dynamic>>('/dashboard');
    return DashboardSummaryDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ActivityItemDto>> getRecentActivity({int limit = 10}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/dashboard/activity',
      queryParameters: {'limit': limit},
    );
    final list = response.data!['data'] as List<dynamic>;
    return list
        .map((e) => ActivityItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getStreakJourney() async {
    final response = await _dio.get<Map<String, dynamic>>('/dashboard/streak-journey');
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> getLevelJourney() async {
    final response = await _dio.get<Map<String, dynamic>>('/dashboard/level-journey');
    return response.data!;
  }
}

