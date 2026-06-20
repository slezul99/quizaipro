import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';

part 'library_filter_notifier.g.dart';

@Riverpod(keepAlive: true)
class LibraryFilterNotifier extends _$LibraryFilterNotifier {
  @override
  LibraryFilter build() => const LibraryFilter();

  void setSort(LibrarySortBy sortBy) =>
      state = state.copyWith(sortBy: sortBy);

  void setDifficulty(LibraryDifficulty? difficulty) =>
      state = state.copyWith(difficulty: difficulty);

  void setShowArchived(bool value) =>
      state = state.copyWith(showArchived: value);

  void setHasDueOnly(bool value) =>
      state = state.copyWith(hasDueOnly: value);

  void applyFilter(LibraryFilter filter) => state = filter;

  void reset() => state = const LibraryFilter();
}
