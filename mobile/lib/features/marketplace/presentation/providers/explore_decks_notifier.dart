import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/marketplace/domain/usecases/get_decks_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_filter_notifier.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_list_state.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';

part 'explore_decks_notifier.g.dart';

@Riverpod(keepAlive: true)
class ExploreDecksNotifier extends _$ExploreDecksNotifier {
  static const _pageSize = 20;

  @override
  Future<DecksListState> build() async {
    // Rebuilds automatically when filter changes.
    final filter = ref.watch(marketplaceFilterNotifierProvider);
    final useCase = ref.read(getDecksUseCaseProvider);

    final result = await useCase(
      GetDecksParams(filter: filter, page: 1, pageSize: _pageSize),
    );

    return result.fold(
      (f) => throw f,
      (paginated) => DecksListState(
        items: paginated.items,
        currentPage: paginated.page,
        totalPages: paginated.totalPages,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true, loadMoreFailure: null));

    final filter = ref.read(marketplaceFilterNotifierProvider);
    final useCase = ref.read(getDecksUseCaseProvider);
    final nextPage = current.currentPage + 1;

    final result = await useCase(
      GetDecksParams(filter: filter, page: nextPage, pageSize: _pageSize),
    );

    result.fold(
      (f) {
        state = AsyncData(current.copyWith(
          isLoadingMore: false,
          loadMoreFailure: f,
        ));
      },
      (paginated) {
        state = AsyncData(DecksListState(
          items: [...current.items, ...paginated.items],
          currentPage: paginated.page,
          totalPages: paginated.totalPages,
        ));
      },
    );
  }

  Future<void> refresh() async {
    state = state.whenData((s) => s.copyWith(isRefreshing: true));

    final filter = ref.read(marketplaceFilterNotifierProvider);
    final useCase = ref.read(getDecksUseCaseProvider);

    final result = await useCase(
      GetDecksParams(filter: filter, page: 1, pageSize: _pageSize),
    );

    result.fold(
      (f) {
        state = state.whenData((s) => s.copyWith(isRefreshing: false));
      },
      (paginated) {
        state = AsyncData(DecksListState(
          items: paginated.items,
          currentPage: paginated.page,
          totalPages: paginated.totalPages,
        ));
      },
    );
  }
}
