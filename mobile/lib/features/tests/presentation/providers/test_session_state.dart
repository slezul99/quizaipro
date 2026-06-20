import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/tests/domain/entities/test_config.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_result.dart';

part 'test_session_state.freezed.dart';

@freezed
sealed class TestSessionState with _$TestSessionState {
  const factory TestSessionState.idle() = TestSessionStateIdle;

  const factory TestSessionState.loading() = TestSessionStateLoading;

  const factory TestSessionState.inProgress({
    required List<TestQuestion> questions,
    required int currentIndex,
    @Default({}) Map<String, String> answers,
    required TestConfig config,
    required DateTime startedAt,
    required String deckId,
    required String deckTitle,
    int? remainingSeconds,
  }) = TestSessionStateInProgress;

  const factory TestSessionState.completed({
    required TestResult result,
  }) = TestSessionStateCompleted;

  const factory TestSessionState.failed({
    required String message,
  }) = TestSessionStateFailed;
}
