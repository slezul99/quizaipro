import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_filter.freezed.dart';

enum MarketplaceSortBy { popular, newest, rating, alphabetical }

enum DeckDifficulty { beginner, intermediate, advanced }

@freezed
class MarketplaceFilter with _$MarketplaceFilter {
  const factory MarketplaceFilter({
    String? subjectId,
    String? collectionId,
    @Default(MarketplaceSortBy.popular) MarketplaceSortBy sortBy,
    DeckDifficulty? difficulty,
    @Default(false) bool proOnly,
  }) = _MarketplaceFilter;

  const MarketplaceFilter._();

  String get cacheKey =>
      '${subjectId ?? ''}_${collectionId ?? ''}_${sortBy.name}_${difficulty?.name ?? ''}_$proOnly';

  bool get isDefault =>
      subjectId == null &&
      collectionId == null &&
      sortBy == MarketplaceSortBy.popular &&
      difficulty == null &&
      !proOnly;
}
