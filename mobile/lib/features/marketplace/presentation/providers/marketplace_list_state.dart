import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/collection.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_summary.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/learning_path.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/marketplace_filter.dart';

part 'marketplace_list_state.freezed.dart';

@freezed
class DecksListState with _$DecksListState {
  const factory DecksListState({
    required List<DeckSummary> items,
    @Default(1) int currentPage,
    @Default(1) int totalPages,
    @Default(false) bool isLoadingMore,
    @Default(false) bool isRefreshing,
    Failure? loadMoreFailure,
  }) = _DecksListState;

  const DecksListState._();

  bool get hasMore => currentPage < totalPages;
}

@freezed
class CollectionsListState with _$CollectionsListState {
  const factory CollectionsListState({
    required List<Collection> items,
    @Default(1) int currentPage,
    @Default(1) int totalPages,
    @Default(false) bool isLoadingMore,
    Failure? loadMoreFailure,
  }) = _CollectionsListState;

  const CollectionsListState._();

  bool get hasMore => currentPage < totalPages;
}

@freezed
class LearningPathsListState with _$LearningPathsListState {
  const factory LearningPathsListState({
    required List<LearningPath> items,
    @Default(1) int currentPage,
    @Default(1) int totalPages,
    @Default(false) bool isLoadingMore,
    Failure? loadMoreFailure,
  }) = _LearningPathsListState;

  const LearningPathsListState._();

  bool get hasMore => currentPage < totalPages;
}

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    @Default(MarketplaceFilter()) MarketplaceFilter filter,
    @Default([]) List<DeckSummary> items,
    @Default(1) int currentPage,
    @Default(1) int totalPages,
    @Default(false) bool isSearching,
    @Default(false) bool isLoadingMore,
    Failure? searchFailure,
  }) = _SearchState;

  const SearchState._();

  bool get hasMore => currentPage < totalPages && query.isNotEmpty;
  bool get isEmpty => items.isEmpty && !isSearching && query.isNotEmpty;
  bool get isIdle => query.isEmpty;
}
