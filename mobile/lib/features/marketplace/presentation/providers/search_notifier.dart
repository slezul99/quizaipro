import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/marketplace/domain/entities/marketplace_filter.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/search_decks_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_list_state.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';

part 'search_notifier.g.dart';

@riverpod
class SearchNotifier extends _$SearchNotifier {
  static const _pageSize = 20;

  @override
  SearchState build() => const SearchState();

  Future<void> search(String query, {MarketplaceFilter? filter}) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    final effectiveFilter = filter ?? const MarketplaceFilter();

    state = state.copyWith(
      query: query,
      filter: effectiveFilter,
      isSearching: true,
      items: const [],
      searchFailure: null,
    );

    final useCase = ref.read(searchDecksUseCaseProvider);
    final result = await useCase(SearchDecksParams(
      query: query,
      filter: effectiveFilter,
      page: 1,
      pageSize: _pageSize,
    ));

    result.fold(
      (f) => state = state.copyWith(isSearching: false, searchFailure: f),
      (paginated) => state = state.copyWith(
        isSearching: false,
        items: paginated.items,
        currentPage: paginated.page,
        totalPages: paginated.totalPages,
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isSearching) return;

    state = state.copyWith(isLoadingMore: true);

    final useCase = ref.read(searchDecksUseCaseProvider);
    final nextPage = state.currentPage + 1;

    final result = await useCase(SearchDecksParams(
      query: state.query,
      filter: state.filter,
      page: nextPage,
      pageSize: _pageSize,
    ));

    result.fold(
      (f) => state = state.copyWith(isLoadingMore: false),
      (paginated) => state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...paginated.items],
        currentPage: paginated.page,
        totalPages: paginated.totalPages,
      ),
    );
  }

  void applyFilter(MarketplaceFilter filter) {
    if (state.query.isNotEmpty) {
      search(state.query, filter: filter);
    }
  }

  void clear() => state = const SearchState();
}
