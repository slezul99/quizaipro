import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck_summary.freezed.dart';

@freezed
class DeckSummary with _$DeckSummary {
  const factory DeckSummary({
    required String id,
    required String title,
    required String description,
    required String authorName,
    required String coverColorHex,
    required int cardCount,
    required double rating,
    required int ratingCount,
    required int cloneCount,
    required List<String> tags,
    required String language,
    String? subjectId,
    @Default(false) bool isPro,
  }) = _DeckSummary;
}
