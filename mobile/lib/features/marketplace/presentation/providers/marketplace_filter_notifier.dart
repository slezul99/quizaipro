import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/marketplace/domain/entities/marketplace_filter.dart';

part 'marketplace_filter_notifier.g.dart';

@Riverpod(keepAlive: true)
class MarketplaceFilterNotifier extends _$MarketplaceFilterNotifier {
  @override
  MarketplaceFilter build() => const MarketplaceFilter();

  void setSubject(String? subjectId) =>
      state = state.copyWith(subjectId: subjectId, collectionId: null);

  void setCollection(String? collectionId) =>
      state = state.copyWith(collectionId: collectionId, subjectId: null);

  void setSort(MarketplaceSortBy sortBy) =>
      state = state.copyWith(sortBy: sortBy);

  void setDifficulty(DeckDifficulty? difficulty) =>
      state = state.copyWith(difficulty: difficulty);

  void setProOnly(bool proOnly) => state = state.copyWith(proOnly: proOnly);

  void reset() => state = const MarketplaceFilter();
}
