import 'package:freezed_annotation/freezed_annotation.dart';

part 'library_filter.freezed.dart';

enum LibrarySortBy { createdAt, name, recentlyStudied, cardCount, dueCards }

enum LibraryDifficulty { beginner, intermediate, advanced }

@freezed
class LibraryFilter with _$LibraryFilter {
  const factory LibraryFilter({
    @Default(LibrarySortBy.createdAt) LibrarySortBy sortBy,
    LibraryDifficulty? difficulty,
    @Default(false) bool showArchived,
    @Default(false) bool hasDueOnly,
  }) = _LibraryFilter;

  const LibraryFilter._();

  bool get isDefault =>
      sortBy == LibrarySortBy.createdAt &&
      difficulty == null &&
      !showArchived &&
      !hasDueOnly;

  String get cacheKey =>
      '${sortBy.name}_${difficulty?.name ?? ''}_${showArchived}_$hasDueOnly';
}
