import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/library/domain/entities/library_collection.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';

part 'library_state.freezed.dart';

@freezed
class DecksListState with _$DecksListState {
  const factory DecksListState({
    @Default([]) List<LibraryDeck> items,
    @Default(1) int currentPage,
    @Default(1) int totalPages,
    @Default(false) bool isLoadingMore,
  }) = _DecksListState;

  const DecksListState._();

  bool get hasMore => currentPage < totalPages;
}

@freezed
class CollectionsListState with _$CollectionsListState {
  const factory CollectionsListState({
    @Default([]) List<LibraryCollection> items,
    @Default(1) int currentPage,
    @Default(1) int totalPages,
    @Default(false) bool isLoadingMore,
  }) = _CollectionsListState;

  const CollectionsListState._();

  bool get hasMore => currentPage < totalPages;
}

@freezed
class FavoritesListState with _$FavoritesListState {
  const factory FavoritesListState({
    @Default([]) List<LibraryDeck> items,
    @Default(1) int currentPage,
    @Default(1) int totalPages,
    @Default(false) bool isLoadingMore,
  }) = _FavoritesListState;

  const FavoritesListState._();

  bool get hasMore => currentPage < totalPages;
}

@freezed
class SearchLibraryState with _$SearchLibraryState {
  const factory SearchLibraryState({
    @Default([]) List<LibraryDeck> items,
    @Default(1) int currentPage,
    @Default(1) int totalPages,
    @Default(false) bool isLoadingMore,
    @Default(true) bool isIdle,
    @Default('') String query,
  }) = _SearchLibraryState;

  const SearchLibraryState._();

  bool get hasMore => currentPage < totalPages;
  bool get isEmpty => !isIdle && items.isEmpty;
}
