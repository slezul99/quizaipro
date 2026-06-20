import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/marketplace/domain/usecases/get_collections_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_list_state.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';

part 'collections_notifier.g.dart';

@Riverpod(keepAlive: true)
class CollectionsNotifier extends _$CollectionsNotifier {
  static const _pageSize = 20;

  @override
  Future<CollectionsListState> build() async {
    final useCase = ref.read(getCollectionsUseCaseProvider);
    final result = await useCase(const GetCollectionsParams());
    return result.fold(
      (f) => throw f,
      (paginated) => CollectionsListState(
        items: paginated.items,
        currentPage: paginated.page,
        totalPages: paginated.totalPages,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final useCase = ref.read(getCollectionsUseCaseProvider);
    final nextPage = current.currentPage + 1;
    final result = await useCase(
      GetCollectionsParams(page: nextPage, pageSize: _pageSize),
    );

    result.fold(
      (f) => state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreFailure: f),
      ),
      (paginated) => state = AsyncData(CollectionsListState(
        items: [...current.items, ...paginated.items],
        currentPage: paginated.page,
        totalPages: paginated.totalPages,
      )),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final useCase = ref.read(getCollectionsUseCaseProvider);
    final result = await useCase(const GetCollectionsParams());
    state = result.fold(
      (f) => AsyncError(f, StackTrace.current),
      (paginated) => AsyncData(CollectionsListState(
        items: paginated.items,
        currentPage: paginated.page,
        totalPages: paginated.totalPages,
      )),
    );
  }
}
