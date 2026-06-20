import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/di/providers.dart';
import 'package:quizaipro_mobile/features/library/data/datasources/library_local_data_source.dart';
import 'package:quizaipro_mobile/features/library/data/datasources/library_remote_data_source.dart';
import 'package:quizaipro_mobile/features/library/data/repositories/library_repository_impl.dart';
import 'package:quizaipro_mobile/features/library/domain/repositories/library_repository.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/archive_deck_use_case.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/delete_deck_use_case.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/get_favorites_use_case.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/get_my_collections_use_case.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/get_my_decks_use_case.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/get_recent_decks_use_case.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/search_library_use_case.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/toggle_favorite_use_case.dart';

part 'library_providers.g.dart';

// ── L1: Data Sources ─────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
LibraryRemoteDataSource libraryRemoteDataSource(
  LibraryRemoteDataSourceRef ref,
) =>
    LibraryRemoteDataSourceImpl(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
LibraryLocalDataSource libraryLocalDataSource(
  LibraryLocalDataSourceRef ref,
) =>
    LibraryLocalDataSourceImpl(ref.watch(hiveServiceProvider));

// ── L1: Repository ────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
LibraryRepository libraryRepository(LibraryRepositoryRef ref) =>
    LibraryRepositoryImpl(
      remoteDataSource: ref.watch(libraryRemoteDataSourceProvider),
      localDataSource: ref.watch(libraryLocalDataSourceProvider),
    );

// ── L2: Use Cases ─────────────────────────────────────────────────────────────

@riverpod
GetMyDecksUseCase getMyDecksUseCase(GetMyDecksUseCaseRef ref) =>
    GetMyDecksUseCase(ref.watch(libraryRepositoryProvider));

@riverpod
GetRecentDecksUseCase getRecentDecksUseCase(GetRecentDecksUseCaseRef ref) =>
    GetRecentDecksUseCase(ref.watch(libraryRepositoryProvider));

@riverpod
GetMyCollectionsUseCase getMyCollectionsUseCase(
  GetMyCollectionsUseCaseRef ref,
) =>
    GetMyCollectionsUseCase(ref.watch(libraryRepositoryProvider));

@riverpod
GetFavoritesUseCase getFavoritesUseCase(GetFavoritesUseCaseRef ref) =>
    GetFavoritesUseCase(ref.watch(libraryRepositoryProvider));

@riverpod
ToggleFavoriteUseCase toggleFavoriteUseCase(ToggleFavoriteUseCaseRef ref) =>
    ToggleFavoriteUseCase(ref.watch(libraryRepositoryProvider));

@riverpod
DeleteDeckUseCase deleteDeckUseCase(DeleteDeckUseCaseRef ref) =>
    DeleteDeckUseCase(ref.watch(libraryRepositoryProvider));

@riverpod
ArchiveDeckUseCase archiveDeckUseCase(ArchiveDeckUseCaseRef ref) =>
    ArchiveDeckUseCase(ref.watch(libraryRepositoryProvider));

@riverpod
SearchLibraryUseCase searchLibraryUseCase(SearchLibraryUseCaseRef ref) =>
    SearchLibraryUseCase(ref.watch(libraryRepositoryProvider));
