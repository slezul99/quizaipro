import 'package:freezed_annotation/freezed_annotation.dart';

part 'find_answers_result.freezed.dart';
part 'find_answers_result.g.dart';

@freezed
class FindAnswersResult with _$FindAnswersResult {
  const factory FindAnswersResult({
    required String question,
    required String explanation,
    @Default([]) List<String> keyPoints,
  }) = _FindAnswersResult;

  factory FindAnswersResult.fromJson(Map<String, dynamic> json) =>
      _$FindAnswersResultFromJson(json);
}
