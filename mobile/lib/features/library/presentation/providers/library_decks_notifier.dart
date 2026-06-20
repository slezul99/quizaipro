import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/get_my_decks_use_case.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_filter_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_providers.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_state.dart';

part 'library_decks_notifier.g.dart';

@Riverpod(keepAlive: true)
class LibraryDecksNotifier extends _$LibraryDecksNotifier {
  @override
  Future<DecksListState> build() async {
    final filter = ref.watch(libraryFilterNotifierProvider);
    return _loadPage(filter, 1);
  }

  Future<DecksListState> _loadPage(LibraryFilter filter, int page) async {
    final useCase = ref.read(getMyDecksUseCaseProvider);
    final result = await useCase(
      GetMyDecksParams(filter: filter, page: page),
    );
    return result.fold(
      (f) => throw f,
      (page) => DecksListState(
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
    final filter = ref.read(libraryFilterNotifierProvider);
    final useCase = ref.read(getMyDecksUseCaseProvider);
    final result = await useCase(
      GetMyDecksParams(filter: filter, page: current.currentPage + 1),
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

  void optimisticToggleFavorite(String deckId, bool newValue) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      items: current.items
          .map((d) => d.id == deckId ? d.copyWith(isFavorite: newValue) : d)
          .toList(),
    ));
  }

  void revertFavorite(String deckId, bool originalValue) {
    optimisticToggleFavorite(deckId, originalValue);
  }

  void removeDeck(String deckId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      items: current.items.where((d) => d.id != deckId).toList(),
    ));
  }

  void updateArchiveStatus(String deckId, bool isArchived) {
    final current = state.valueOrNull;
    if (current == null) return;
    final filter = ref.read(libraryFilterNotifierProvider);
    if (!filter.showArchived) {
      removeDeck(deckId);
    } else {
      state = AsyncData(current.copyWith(
        items: current.items
            .map((d) =>
                d.id == deckId ? d.copyWith(isArchived: isArchived) : d)
            .toList(),
      ));
    }
  }
}
