import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/library/domain/usecases/search_library_use_case.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_providers.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_state.dart';

part 'search_library_notifier.g.dart';

@riverpod
class SearchLibraryNotifier extends _$SearchLibraryNotifier {
  @override
  Future<SearchLibraryState> build() async =>
      const SearchLibraryState(isIdle: true);

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData(SearchLibraryState(isIdle: true));
      return;
    }
    state = const AsyncLoading();
    final useCase = ref.read(searchLibraryUseCaseProvider);
    final result = await useCase(
      SearchLibraryParams(query: query.trim()),
    );
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (page) => state = AsyncData(SearchLibraryState(
        items: page.items,
        currentPage: page.page,
        totalPages: page.totalPages,
        isIdle: false,
        query: query.trim(),
      )),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null ||
        current.isIdle ||
        !current.hasMore ||
        current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final useCase = ref.read(searchLibraryUseCaseProvider);
    final result = await useCase(
      SearchLibraryParams(
        query: current.query,
        page: current.currentPage + 1,
      ),
    );
    result.fold(
      (f) => state = AsyncData(current.copyWith(isLoadingMore: false)),
      (page) => state = AsyncData(current.copyWith(
        items: [...current.items, ...page.items],
        currentPage: page.page,
        totalPages: page.totalPages,
        isLoadingMore: false,
      )),
    );
  }

  void clear() {
    state = const AsyncData(SearchLibraryState(isIdle: true));
  }
}
