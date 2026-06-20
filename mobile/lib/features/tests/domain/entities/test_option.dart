import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_option.freezed.dart';

@freezed
class TestOption with _$TestOption {
  const factory TestOption({
    required String id,
    required String text,
    required bool isCorrect,
  }) = _TestOption;
}
