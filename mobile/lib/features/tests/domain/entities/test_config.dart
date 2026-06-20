import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/core/config/app_constants.dart';

part 'test_config.freezed.dart';

@freezed
class TestConfig with _$TestConfig {
  const factory TestConfig({
    @Default(AppConstants.testDefaultQuestionCount) int questionCount,
    @Default(true) bool shuffle,
    @Default(false) bool timedMode,
    @Default(AppConstants.testDefaultSecondsPerQuestion) int secondsPerQuestion,
  }) = _TestConfig;

  const TestConfig._();

  int get totalSeconds => questionCount * secondsPerQuestion;
}
