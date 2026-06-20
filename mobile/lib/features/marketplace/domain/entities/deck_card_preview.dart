import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck_card_preview.freezed.dart';

@freezed
class DeckCardPreview with _$DeckCardPreview {
  const factory DeckCardPreview({
    required String id,
    required String front,
    required String back,
    String? hint,
  }) = _DeckCardPreview;
}
