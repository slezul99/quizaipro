import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/library/domain/usecases/get_favorites_use_case.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_providers.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_state.dart';

part 'library_favorites_notifier.g.dart';

@Riverpod(keepAlive: true)
class LibraryFavoritesNotifier extends _$LibraryFavoritesNotifier {
  @override
  Future<FavoritesListState> build() async {
    final useCase = ref.read(getFavoritesUseCaseProvider);
    final result = await useCase(const GetFavoritesParams());
    return result.fold(
      (f) => throw f,
      (page) => FavoritesListState(
        items: page.items,
        currentPage: page.page,
        totalPages: page.totalPages,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final useCase = ref.read(getFavoritesUseCaseProvider);
    final result = await useCase(
      GetFavoritesParams(page: current.currentPage + 1),
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

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  void removeDeck(String deckId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      items: current.items.where((d) => d.id != deckId).toList(),
    ));
  }
}
