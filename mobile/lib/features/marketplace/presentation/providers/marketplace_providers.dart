import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/di/providers.dart';
import 'package:quizaipro_mobile/features/marketplace/data/datasources/marketplace_local_data_source.dart';
import 'package:quizaipro_mobile/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:quizaipro_mobile/features/marketplace/data/repositories/marketplace_repository_impl.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/clone_deck_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/get_collections_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/get_deck_cards_preview_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/get_deck_detail_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/get_decks_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/get_learning_paths_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/get_subjects_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/search_decks_use_case.dart';

part 'marketplace_providers.g.dart';

// ── L1: Data Sources ─────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
MarketplaceRemoteDataSource marketplaceRemoteDataSource(
  MarketplaceRemoteDataSourceRef ref,
) =>
    MarketplaceRemoteDataSourceImpl(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
MarketplaceLocalDataSource marketplaceLocalDataSource(
  MarketplaceLocalDataSourceRef ref,
) =>
    MarketplaceLocalDataSourceImpl(ref.watch(hiveServiceProvider));

// ── L1: Repository ────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
MarketplaceRepository marketplaceRepository(MarketplaceRepositoryRef ref) =>
    MarketplaceRepositoryImpl(
      remoteDataSource: ref.watch(marketplaceRemoteDataSourceProvider),
      localDataSource: ref.watch(marketplaceLocalDataSourceProvider),
    );

// ── L2: Use Cases ─────────────────────────────────────────────────────────────

@riverpod
GetSubjectsUseCase getSubjectsUseCase(GetSubjectsUseCaseRef ref) =>
    GetSubjectsUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
GetCollectionsUseCase getCollectionsUseCase(GetCollectionsUseCaseRef ref) =>
    GetCollectionsUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
GetLearningPathsUseCase getLearningPathsUseCase(
  GetLearningPathsUseCaseRef ref,
) =>
    GetLearningPathsUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
GetDecksUseCase getDecksUseCase(GetDecksUseCaseRef ref) =>
    GetDecksUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
GetDeckDetailUseCase getDeckDetailUseCase(GetDeckDetailUseCaseRef ref) =>
    GetDeckDetailUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
GetDeckCardsPreviewUseCase getDeckCardsPreviewUseCase(
  GetDeckCardsPreviewUseCaseRef ref,
) =>
    GetDeckCardsPreviewUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
SearchDecksUseCase searchDecksUseCase(SearchDecksUseCaseRef ref) =>
    SearchDecksUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
CloneDeckUseCase cloneDeckUseCase(CloneDeckUseCaseRef ref) =>
    CloneDeckUseCase(ref.watch(marketplaceRepositoryProvider));
