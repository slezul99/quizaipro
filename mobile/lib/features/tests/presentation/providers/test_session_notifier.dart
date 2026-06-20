import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_answer.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_config.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_result.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/weak_area.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_providers.dart';
import 'package:fpdart/fpdart.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/providers/dashboard_notifier.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_session_state.dart';

part 'test_session_notifier.g.dart';

@Riverpod(keepAlive: true)
class TestSessionNotifier extends _$TestSessionNotifier {
  Timer? _timer;

  @override
  TestSessionState build() => const TestSessionState.idle();

  Future<void> startTest({
    required String deckId,
    required String deckTitle,
    required TestConfig config,
    required String emptyMessage,
  }) async {
    state = const TestSessionState.loading();

    final useCase = ref.read(loadTestQuestionsUseCaseProvider);
    final result = await useCase(LoadTestQuestionsParams(deckId: deckId));

    result.fold(
      (failure) => state = TestSessionState.failed(message: failure.userMessage),
      (questions) {
        var q = questions;
        if (q.isEmpty) {
          // No MCQ-parseable cards in this deck — surface a clear message
          // instead of crashing on the clamp below (count.clamp(1, 0)).
          state = TestSessionState.failed(message: emptyMessage);
          return;
        }
        if (config.shuffle) q = _shuffled(q);

        final count = config.questionCount == 0
            ? q.length
            : config.questionCount.clamp(1, q.length);

        final selectedQuestions = q.take(count).toList();

        final now = DateTime.now();
        state = TestSessionState.inProgress(
          questions: selectedQuestions,
          currentIndex: 0,
          answers: {},
          config: config.copyWith(questionCount: count),
          startedAt: now,
          deckId: deckId,
          deckTitle: deckTitle,
          remainingSeconds: config.timedMode ? config.totalSeconds : null,
        );

        if (config.timedMode) {
          _startTimer();
        }
      },
    );
  }

  void selectAnswer(String questionId, String optionId) {
    final s = state;
    if (s is! TestSessionStateInProgress) return;
    state = s.copyWith(
      answers: {...s.answers, questionId: optionId},
    );
  }

  void nextQuestion() {
    final s = state;
    if (s is! TestSessionStateInProgress) return;
    if (s.currentIndex < s.questions.length - 1) {
      state = s.copyWith(currentIndex: s.currentIndex + 1);
    }
  }

  void previousQuestion() {
    final s = state;
    if (s is! TestSessionStateInProgress) return;
    if (s.currentIndex > 0) {
      state = s.copyWith(currentIndex: s.currentIndex - 1);
    }
  }

  void goToQuestion(int index) {
    final s = state;
    if (s is! TestSessionStateInProgress) return;
    if (index < 0 || index >= s.questions.length) return;
    state = s.copyWith(currentIndex: index);
  }

  Future<void> submitTest({
    String deckId = '',
    String deckTitle = '',
  }) async {
    final s = state;
    if (s is! TestSessionStateInProgress) return;

    _cancelTimer();

    final now = DateTime.now();
    final durationSeconds = now.difference(s.startedAt).inSeconds;
    final resolvedDeckId = deckId.isNotEmpty ? deckId : s.deckId;
    final resolvedDeckTitle = deckTitle.isNotEmpty ? deckTitle : s.deckTitle;

    final answers = s.questions.map((q) {
      final selectedId = s.answers[q.id];
      final isCorrect = selectedId != null &&
          q.options.any((o) => o.id == selectedId && o.isCorrect);
      return TestAnswer(
        questionId: q.id,
        selectedOptionId: selectedId,
        isCorrect: isCorrect,
        answeredAt: now,
      );
    }).toList();

    final correctCount = answers.where((a) => a.isCorrect).length;
    final weakAreas = _computeWeakAreas(s.questions, answers);

    final result = TestResult(
      id: '',
      deckId: resolvedDeckId,
      deckTitle: resolvedDeckTitle,
      totalQuestions: s.questions.length,
      correctCount: correctCount,
      durationSeconds: durationSeconds,
      answers: answers,
      questions: s.questions,
      weakAreas: weakAreas,
      completedAt: now,
      config: s.config,
    );

    state = TestSessionState.completed(result: result);

    final submitUseCase = ref.read(submitTestUseCaseProvider);
    final submitResult = await submitUseCase(result);
    submitResult.fold(
      (failure) {
        // keep existing error handling
      },
      (_) {
        ref.invalidate(dashboardNotifierProvider);
      },
    );
  }

  void reset() {
    _cancelTimer();
    state = const TestSessionState.idle();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is! TestSessionStateInProgress) {
        _cancelTimer();
        return;
      }
      final remaining = s.remainingSeconds;
      if (remaining == null) {
        _cancelTimer();
        return;
      }
      if (remaining <= 1) {
        _cancelTimer();
        _timeExpired(s);
      } else {
        state = s.copyWith(remainingSeconds: remaining - 1);
      }
    });
  }

  void _timeExpired(TestSessionStateInProgress s) {
    final now = DateTime.now();
    final durationSeconds = now.difference(s.startedAt).inSeconds;

    final answers = s.questions.map((q) {
      final selectedId = s.answers[q.id];
      final isCorrect = selectedId != null &&
          q.options.any((o) => o.id == selectedId && o.isCorrect);
      return TestAnswer(
        questionId: q.id,
        selectedOptionId: selectedId,
        isCorrect: isCorrect,
        answeredAt: now,
      );
    }).toList();

    final correctCount = answers.where((a) => a.isCorrect).length;
    final weakAreas = _computeWeakAreas(s.questions, answers);

    final result = TestResult(
      id: '',
      deckId: s.deckId,
      deckTitle: s.deckTitle,
      totalQuestions: s.questions.length,
      correctCount: correctCount,
      durationSeconds: durationSeconds,
      answers: answers,
      questions: s.questions,
      weakAreas: weakAreas,
      completedAt: now,
      config: s.config,
    );

    state = TestSessionState.completed(result: result);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  List<TestQuestion> _shuffled(List<TestQuestion> questions) {
    final list = [...questions];
    final rand = Random.secure();
    for (int i = list.length - 1; i > 0; i--) {
      final j = rand.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list;
  }

  List<WeakArea> _computeWeakAreas(
    List<TestQuestion> questions,
    List<TestAnswer> answers,
  ) {
    final byTopic = <String, ({int total, int correct})>{};
    for (final q in questions) {
      final topic = q.topic ?? 'general';
      final answer = answers.where((a) => a.questionId == q.id).firstOrNull;
      final isCorrect = answer?.isCorrect ?? false;
      final current = byTopic[topic] ?? (total: 0, correct: 0);
      byTopic[topic] = (
        total: current.total + 1,
        correct: current.correct + (isCorrect ? 1 : 0),
      );
    }
    return byTopic.entries
        .map((e) => WeakArea(
              topic: e.key,
              totalQuestions: e.value.total,
              correctAnswers: e.value.correct,
            ))
        .where(
          (w) => w.accuracy < AppConstants.testWeakAreaThresholdPct / 100,
        )
        .toList();
  }
}