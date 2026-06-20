import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck_summary.freezed.dart';

@freezed
class DeckSummary with _$DeckSummary {
  const factory DeckSummary({
    required String id,
    required String title,
    @Default(0) int cardCount,
  }) = _DeckSummary;
}
