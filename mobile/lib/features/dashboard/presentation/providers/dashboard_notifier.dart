import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/activity_item.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/usecases/get_dashboard_summary_use_case.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/usecases/get_recent_activity_use_case.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/usecases/refresh_dashboard_use_case.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/providers/dashboard_state.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/providers/flashcard_providers.dart';

part 'dashboard_notifier.g.dart';

@Riverpod(keepAlive: true)
class DashboardNotifier extends _$DashboardNotifier {
  @override
  Future<DashboardState> build() async {
    // Load stats first so the home screen paints immediately (summary is
    // cache-first — instant on a warm cache). The offline-grade queue is then
    // drained in the BACKGROUND rather than awaited up-front, so a flaky/slow
    // network on the sync call never delays first paint. If grades were actually
    // queued (the rare "reopened after offline study" case), we refresh once the
    // drain completes. The in-session flush (StudySessionNotifier) already
    // covers the just-finished session.
    final getSummary = ref.read(getDashboardSummaryUseCaseProvider);
    final getActivity = ref.read(getRecentActivityUseCaseProvider);

    final (summaryResult, activityResult) = await (
      getSummary(NoParams()),
      getActivity(const GetActivityParams(limit: 10)),
    ).wait;

    final summary = summaryResult.fold(
      (failure) => throw failure,
      (s) => s,
    );
    final activity = activityResult.fold(
      (failure) => <ActivityItem>[],
      (a) => a,
    );

    _drainPendingGradesInBackground();

    return DashboardState(summary: summary, recentActivity: activity);
  }

  /// Flushes offline-queued study grades without blocking first paint. Refreshes
  /// the dashboard only if something was actually synced.
  void _drainPendingGradesInBackground() {
    Future<void>(() async {
      final result =
          await ref.read(syncPendingGradesUseCaseProvider).call(const NoParams());
      final syncedCount = result.fold((_) => 0, (count) => count);
      if (syncedCount > 0) {
        await refresh();
      }
    });
  }

  Future<void> refresh() async {
    // Keep existing data visible while refreshing.
    state = state.whenData(
      (current) => current.copyWith(isRefreshing: true),
    );

    final refreshSummary = ref.read(refreshDashboardUseCaseProvider);
    final getActivity = ref.read(getRecentActivityUseCaseProvider);

    try {
      final (summaryResult, activityResult) = await (
        refreshSummary(NoParams()),
        getActivity(const GetActivityParams(limit: 10)),
      ).wait;

      final summary = summaryResult.fold(
        (failure) => throw failure,
        (s) => s,
      );
      final activity = activityResult.fold(
        (failure) => _currentActivity,
        (a) => a,
      );

      state = AsyncData(
        DashboardState(
          summary: summary,
          recentActivity: activity,
          isRefreshing: false,
        ),
      );
    } on Failure catch (failure) {
      state = state.whenData(
        (current) => current.copyWith(isRefreshing: false),
      );
      // Rethrow so pull-to-refresh indicator can react.
      throw failure;
    } catch (e) {
      state = state.whenData(
        (current) => current.copyWith(isRefreshing: false),
      );
      throw UnknownFailure(message: e.toString());
    }
  }

  List<ActivityItem> get _currentActivity =>
      state.valueOrNull?.recentActivity ?? const [];

  DashboardSummary? get cachedSummary => state.valueOrNull?.summary;
}
