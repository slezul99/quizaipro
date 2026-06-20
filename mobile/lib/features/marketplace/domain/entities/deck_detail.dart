import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck_detail.freezed.dart';

@freezed
class DeckDetail with _$DeckDetail {
  const factory DeckDetail({
    required String id,
    required String title,
    required String description,
    required String fullDescription,
    required String authorName,
    required String authorUsername,
    String? authorAvatarUrl,
    required String coverColorHex,
    required int cardCount,
    required double rating,
    required int ratingCount,
    required int cloneCount,
    @Default(0) int likeCount,
    required List<String> tags,
    required String language,
    String? subjectId,
    @Default(false) bool isPro,
    required int previewCardsCount,
    @Default(false) bool isClonedByUser,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DeckDetail;
}
