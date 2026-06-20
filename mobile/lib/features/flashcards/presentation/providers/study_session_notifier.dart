import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/algorithms/fsrs_algorithm.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/algorithms/sm2_algorithm.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/card_grade.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/session_stats.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_card.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_mode.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/usecases/grade_card_use_case.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/usecases/load_study_queue_use_case.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/usecases/save_session_use_case.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/providers/flashcard_providers.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/providers/dashboard_notifier.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/providers/study_session_state.dart';

part 'study_session_notifier.g.dart';

@riverpod
class StudySessionNotifier extends _$StudySessionNotifier {
  @override
  Future<StudySessionState> build({
    required String deckId,
    required StudyMode mode,
    required String deckTitle,
  }) async {
    final result = await ref.read(loadStudyQueueUseCaseProvider).call(
          LoadStudyQueueParams(
            deckId: deckId,
            mode: mode,
            sessionSize: AppConstants.studySessionBatchSize,
          ),
        );

    return result.fold(
      (failure) => throw failure,
      (queue) {
        return StudySessionState(
          queue: queue,
          currentIndex: 0,
          isCardFlipped: false,
          stats: SessionStats(total: queue.length, startedAt: DateTime.now()),
          mode: mode,
          deckId: deckId,
          deckTitle: deckTitle,
          isComplete: queue.isEmpty,
        );
      },
    );
  }

  void flipCard() {
    final current = state.valueOrNull;
    if (current == null ||
        current.isCardFlipped ||
        current.currentCard == null) return;
    state = AsyncData(current.copyWith(isCardFlipped: true));
  }

  Future<void> gradeCard(CardGrade grade) async {
    final current = state.valueOrNull;
    if (current == null ||
        !current.isCardFlipped ||
        current.currentCard == null) return;

    final card = current.currentCard!;

    // FSRS scheduling (offline-equivalent to the backend fsrs.py).
    final rating = switch (grade) {
      CardGrade.again => 1,
      CardGrade.hard => 2,
      CardGrade.good => 3,
      CardGrade.easy => 4,
    };
    final elapsedDays = card.lastStudiedAt == null
        ? 0.0
        : DateTime.now().difference(card.lastStudiedAt!).inHours / 24.0;
    final fsrs = FsrsAlgorithm.calculate(
      stability: card.stability,
      difficulty: card.difficulty,
      repetitions: card.repetitions,
      easeFactor: card.easeFactor,
      interval: card.interval,
      elapsedDays: elapsedDays,
      rating: rating,
    );
    // Repackage into the existing Sm2Result shape for the persistence pipeline;
    // easeFactor is kept unchanged (FSRS doesn't use it).
    final sm2Result = Sm2Result(
      easeFactor: card.easeFactor,
      interval: fsrs.interval,
      repetitions: fsrs.repetitions,
      nextReviewAt: fsrs.nextReviewAt,
    );

    final result = await ref.read(gradeCardUseCaseProvider).call(
          GradeCardParams(
            cardId: card.id,
            deckId: card.deckId,
            grade: grade,
            sm2Result: sm2Result,
            stability: fsrs.stability,
            difficulty: fsrs.difficulty,
            newAgainCount: card.againCount +
                (grade == CardGrade.again ? 1 : 0),
          ),
        );

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null)!;
      state = AsyncError(failure, StackTrace.current);
      return;
    }

    final isNew = card.isNew;
    final newStats = current.stats.copyWith(
      reviewed: current.stats.reviewed + 1,
      againCount: grade == CardGrade.again
          ? current.stats.againCount + 1
          : current.stats.againCount,
      hardCount: grade == CardGrade.hard
          ? current.stats.hardCount + 1
          : current.stats.hardCount,
      goodCount: grade == CardGrade.good
          ? current.stats.goodCount + 1
          : current.stats.goodCount,
      easyCount: grade == CardGrade.easy
          ? current.stats.easyCount + 1
          : current.stats.easyCount,
      newCount:
          isNew ? current.stats.newCount + 1 : current.stats.newCount,
      reviewCount: !isNew
          ? current.stats.reviewCount + 1
          : current.stats.reviewCount,
    );

    var newQueue = [...current.queue];
    if (grade == CardGrade.again && !card.wasRescheduled) {
      newQueue.add(card.copyWith(
        wasRescheduled: true,
        sessionGrade: grade,
        againCount: card.againCount + 1,
      ));
    }

    final nextIndex = current.currentIndex + 1;
    final isComplete = nextIndex >= newQueue.length;

    state = AsyncData(current.copyWith(
      queue: newQueue,
      currentIndex: nextIndex,
      isCardFlipped: false,
      stats: newStats,
      isComplete: isComplete,
    ));

    if (isComplete) {
      await _saveSession(newStats, current.deckId);
    }
  }

  Future<void> toggleFavorite(StudyCard card) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final newFav = !card.isFavorite;

    final newQueue = current.queue
        .map((c) => c.id == card.id ? c.copyWith(isFavorite: newFav) : c)
        .toList();
    state = AsyncData(current.copyWith(queue: newQueue));

    // Fire-and-forget: update local DB
    await ref
        .read(flashcardRepositoryProvider)
        .toggleFavorite(card.id, isFavorite: newFav);
  }

  Future<void> _saveSession(SessionStats stats, String deckId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(isSavingSession: true));

    final result = await ref.read(saveSessionUseCaseProvider).call(
          SaveSessionParams(
            deckId: deckId,
            totalCards: stats.reviewed,
            newCards: stats.newCount,
            reviewCards: stats.reviewCount,
            againCount: stats.againCount,
            hardCount: stats.hardCount,
            goodCount: stats.goodCount,
            easyCount: stats.easyCount,
            durationSeconds: stats.elapsed.inSeconds,
          ),
        );

    final updated = state.valueOrNull;
    if (updated == null) return;

    result.fold(
      (failure) => state = AsyncData(updated.copyWith(
        isSavingSession: false,
        saveError: failure.userMessage,
      )),
      (_) {
        state = AsyncData(updated.copyWith(isSavingSession: false));
        ref.invalidate(dashboardNotifierProvider);
      },
    );

    // Flush any grades that failed to reach the backend during the session
    // (e.g. a transient network drop, or grading while the server was
    // unreachable). Each gradeCard() already attempts an immediate POST and
    // silently queues on failure; nothing else ever drains that queue, so
    // without this a single failed POST means the review is stored locally
    // but never counts on the server/dashboard. Best-effort: still offline →
    // the queue simply survives for the next session/refresh.
    await ref.read(syncPendingGradesUseCaseProvider).call(const NoParams());
  }
}
