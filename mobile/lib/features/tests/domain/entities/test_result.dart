import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/tests/domain/entities/test_answer.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_config.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/weak_area.dart';

part 'test_result.freezed.dart';

@freezed
class TestResult with _$TestResult {
  const factory TestResult({
    required String id,
    required String deckId,
    required String deckTitle,
    required TestConfig config,
    required int totalQuestions,
    required int correctCount,
    required int durationSeconds,
    required List<TestAnswer> answers,
    required List<TestQuestion> questions,
    @Default([]) List<WeakArea> weakAreas,
    required DateTime completedAt,
  }) = _TestResult;

  const TestResult._();

  double get score =>
      totalQuestions == 0 ? 0 : correctCount / totalQuestions;
  int get scorePct => (score * 100).round();
  int get wrongCount => totalQuestions - correctCount;

  String get formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return m == 0 ? '${s}s' : '${m}m ${s}s';
  }
}
