import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/dashboard/domain/entities/activity_item.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/dashboard_summary.dart';

part 'dashboard_state.freezed.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState({
    required DashboardSummary summary,
    required List<ActivityItem> recentActivity,
    @Default(false) bool isRefreshing,
  }) = _DashboardState;
}
