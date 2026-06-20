import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/tests/domain/entities/test_option.dart';

part 'test_question.freezed.dart';

@freezed
class TestQuestion with _$TestQuestion {
  const factory TestQuestion({
    required String id,
    required String deckId,
    required String question,
    required String correctAnswer,
    required List<TestOption> options,
    String? topic,
  }) = _TestQuestion;

  const TestQuestion._();

  TestOption? get correctOption =>
      options.where((o) => o.isCorrect).firstOrNull;
}
