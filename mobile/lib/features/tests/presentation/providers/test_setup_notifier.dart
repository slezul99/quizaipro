import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_config.dart';

part 'test_setup_notifier.freezed.dart';
part 'test_setup_notifier.g.dart';

@freezed
class TestSetupState with _$TestSetupState {
  const factory TestSetupState({
    required String deckId,
    required String deckTitle,
    @Default(AppConstants.testDefaultQuestionCount) int questionCount,
    @Default(true) bool shuffle,
    @Default(false) bool timedMode,
    @Default(AppConstants.testDefaultSecondsPerQuestion) int secondsPerQuestion,
    @Default(false) bool isStarting,
  }) = _TestSetupState;

  const TestSetupState._();

  TestConfig get config => TestConfig(
        questionCount: questionCount,
        shuffle: shuffle,
        timedMode: timedMode,
        secondsPerQuestion: secondsPerQuestion,
      );
}

@riverpod
class TestSetupNotifier extends _$TestSetupNotifier {
  @override
  TestSetupState build({
    required String deckId,
    required String deckTitle,
  }) =>
      TestSetupState(deckId: deckId, deckTitle: deckTitle);

  void setQuestionCount(int count) =>
      state = state.copyWith(questionCount: count);

  void setShuffle({required bool value}) =>
      state = state.copyWith(shuffle: value);

  void setTimedMode({required bool value}) =>
      state = state.copyWith(timedMode: value);

  void setSecondsPerQuestion(int seconds) =>
      state = state.copyWith(secondsPerQuestion: seconds);

  void setStarting({required bool value}) =>
      state = state.copyWith(isStarting: value);
}
