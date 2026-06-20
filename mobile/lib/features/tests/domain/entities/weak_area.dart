import 'package:freezed_annotation/freezed_annotation.dart';

part 'weak_area.freezed.dart';

@freezed
class WeakArea with _$WeakArea {
  const factory WeakArea({
    required String topic,
    required int totalQuestions,
    required int correctAnswers,
  }) = _WeakArea;

  const WeakArea._();

  double get accuracy =>
      totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;
  int get accuracyPct => (accuracy * 100).round();
}
