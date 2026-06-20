import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_answer.freezed.dart';

@freezed
class TestAnswer with _$TestAnswer {
  const factory TestAnswer({
    required String questionId,
    required String? selectedOptionId,
    required bool isCorrect,
    required DateTime answeredAt,
  }) = _TestAnswer;
}
