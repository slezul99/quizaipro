import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_history_item.freezed.dart';

@freezed
class TestHistoryItem with _$TestHistoryItem {
  const factory TestHistoryItem({
    required String id,
    required String deckId,
    required String deckTitle,
    required int totalQuestions,
    required int correctCount,
    required int durationSeconds,
    required DateTime completedAt,
  }) = _TestHistoryItem;

  const TestHistoryItem._();

  double get score =>
      totalQuestions == 0 ? 0 : correctCount / totalQuestions;
  int get scorePct => (score * 100).round();
  int get wrongCount => totalQuestions - correctCount;
}
