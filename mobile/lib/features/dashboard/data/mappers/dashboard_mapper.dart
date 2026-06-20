import 'package:quizaipro_mobile/features/dashboard/data/dto/activity_item_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/daily_goal_progress_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/dashboard_summary_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/due_reviews_summary_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/retention_summary_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/streak_summary_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/data/dto/xp_summary_dto.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/activity_item.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/daily_goal_progress.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/due_reviews_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/retention_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/xp_summary.dart';

abstract final class DashboardMapper {
  static DashboardSummary summaryFromDto(DashboardSummaryDto dto) =>
      DashboardSummary(
        xp: _xpFromDto(dto.xp),
        streak: _streakFromDto(dto.streak),
        dailyGoal: _dailyGoalFromDto(dto.dailyGoal),
        dueReviews: _dueReviewsFromDto(dto.dueReviews),
        userDisplayName: dto.userDisplayName,
        unreadNotifications: dto.unreadNotifications,
        retention: dto.retention != null ? _retentionFromDto(dto.retention!) : null,
      );

  static DashboardSummaryDto summaryToDto(DashboardSummary entity) =>
      DashboardSummaryDto(
        xp: _xpToDto(entity.xp),
        streak: _streakToDto(entity.streak),
        dailyGoal: _dailyGoalToDto(entity.dailyGoal),
        dueReviews: _dueReviewsToDto(entity.dueReviews),
        userDisplayName: entity.userDisplayName,
        unreadNotifications: entity.unreadNotifications,
        retention: entity.retention != null ? _retentionToDto(entity.retention!) : null,
      );

  static ActivityItem activityFromDto(ActivityItemDto dto) {
    final timestamp = DateTime.tryParse(dto.createdAt) ?? DateTime.now();
    final decodedDetails = dto.details ?? const [];
    
    if (dto.type == 'test_session') {
      final detailsList = decodedDetails.map((e) {
        final map = e as Map<String, dynamic>;
        return TestQuestionAttemptDetail(
          front: map['front'] as String,
          isCorrect: map['is_correct'] == 1 || map['is_correct'] == true,
          correctAnswer: map['correct_answer'] as String,
          selectedAnswer: map['selected_answer'] as String?,
          xpEarned: map['xp_earned'] as int? ?? 0,
        );
      }).toList();
      
      return ActivityItem.test(
        id: dto.id,
        title: dto.title,
        totalQuestions: dto.cardsReviewed,
        correctCount: detailsList.where((e) => e.isCorrect).length,
        xpEarned: dto.xpEarned,
        timestamp: timestamp,
        details: detailsList,
      );
    } else {
      final detailsList = decodedDetails.map((e) {
        final map = e as Map<String, dynamic>;
        return StudyCardReviewDetail(
          cardId: map['card_id'] as String,
          front: map['front'] as String,
          back: map['back'] as String,
          explanation: map['explanation'] as String?,
          grade: map['grade'] as int,
          xpEarned: map['xp_earned'] as int,
        );
      }).toList();
      
      return ActivityItem.study(
        id: dto.id,
        title: dto.title,
        cardsReviewed: dto.cardsReviewed,
        xpEarned: dto.xpEarned,
        timestamp: timestamp,
        details: detailsList,
      );
    }
  }

  static ActivityItemDto activityToDto(ActivityItem entity) {
    return entity.map(
      study: (s) => ActivityItemDto(
        id: s.id,
        type: 'study_session',
        title: s.title,
        cardsReviewed: s.cardsReviewed,
        xpEarned: s.xpEarned,
        createdAt: s.timestamp.toIso8601String(),
        details: s.details.map((d) => {
          'card_id': d.cardId,
          'front': d.front,
          'back': d.back,
          'explanation': d.explanation,
          'grade': d.grade,
          'xp_earned': d.xpEarned,
        }).toList(),
      ),
      test: (t) => ActivityItemDto(
        id: t.id,
        type: 'test_session',
        title: t.title,
        cardsReviewed: t.totalQuestions,
        xpEarned: t.xpEarned,
        createdAt: t.timestamp.toIso8601String(),
        details: t.details.map((d) => {
          'front': d.front,
          'is_correct': d.isCorrect,
          'correct_answer': d.correctAnswer,
          'selected_answer': d.selectedAnswer,
          'xp_earned': d.xpEarned,
        }).toList(),
      ),
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static XpSummary _xpFromDto(XpSummaryDto dto) => XpSummary(
        currentXp: dto.currentXp,
        level: dto.level,
        xpInCurrentLevel: dto.xpInCurrentLevel,
        xpForNextLevel: dto.xpForNextLevel,
      );

  static XpSummaryDto _xpToDto(XpSummary e) => XpSummaryDto(
        currentXp: e.currentXp,
        level: e.level,
        xpInCurrentLevel: e.xpInCurrentLevel,
        xpForNextLevel: e.xpForNextLevel,
      );

  static StreakSummary _streakFromDto(StreakSummaryDto dto) => StreakSummary(
        currentStreak: dto.currentStreak,
        maxStreak: dto.maxStreak,
        todayCompleted: dto.todayCompleted,
        lastActivityDate: dto.lastActivityDate != null
            ? DateTime.tryParse(dto.lastActivityDate!)
            : null,
        currentStage: dto.currentStage != null ? _stageFromDto(dto.currentStage!) : null,
        nextStage: dto.nextStage != null ? _stageFromDto(dto.nextStage!) : null,
        progressRatio: dto.progressRatio,
        daysRemaining: dto.daysRemaining,
      );

  static StreakSummaryDto _streakToDto(StreakSummary e) => StreakSummaryDto(
        currentStreak: e.currentStreak,
        maxStreak: e.maxStreak,
        todayCompleted: e.todayCompleted,
        lastActivityDate: e.lastActivityDate?.toIso8601String(),
        currentStage: e.currentStage != null ? _stageToDto(e.currentStage!) : null,
        nextStage: e.nextStage != null ? _stageToDto(e.nextStage!) : null,
        progressRatio: e.progressRatio,
        daysRemaining: e.daysRemaining,
      );

  static StreakStageInfo _stageFromDto(StreakStageInfoDto dto) => StreakStageInfo(
        key: dto.key,
        startDays: dto.startDays,
        nextStageDays: dto.nextStageDays,
      );

  static StreakStageInfoDto _stageToDto(StreakStageInfo e) => StreakStageInfoDto(
        key: e.key,
        startDays: e.startDays,
        nextStageDays: e.nextStageDays,
      );

  static DailyGoalProgress _dailyGoalFromDto(DailyGoalProgressDto dto) =>
      DailyGoalProgress(
        targetCards: dto.targetCards,
        completedCards: dto.completedCards,
      );

  static DailyGoalProgressDto _dailyGoalToDto(DailyGoalProgress e) =>
      DailyGoalProgressDto(
        targetCards: e.targetCards,
        completedCards: e.completedCards,
      );

  static DueReviewsSummary _dueReviewsFromDto(DueReviewsSummaryDto dto) =>
      DueReviewsSummary(
        totalDue: dto.totalDue,
        overdue: dto.overdue,
        dueToday: dto.dueToday,
      );

  static DueReviewsSummaryDto _dueReviewsToDto(DueReviewsSummary e) =>
      DueReviewsSummaryDto(
        totalDue: e.totalDue,
        overdue: e.overdue,
        dueToday: e.dueToday,
      );

  static RetentionSummary _retentionFromDto(RetentionSummaryDto dto) =>
      RetentionSummary(
        now: dto.now,
        forecast: dto.forecast,
        fading: dto.fading ?? 0,
        studied: dto.studied ?? 0,
      );

  static RetentionSummaryDto _retentionToDto(RetentionSummary e) =>
      RetentionSummaryDto(
        now: e.now,
        forecast: e.forecast,
        fading: e.fading,
        studied: e.studied,
      );
}
