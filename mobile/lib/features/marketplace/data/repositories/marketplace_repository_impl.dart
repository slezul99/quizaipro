import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/marketplace/data/datasources/marketplace_local_data_source.dart';
import 'package:quizaipro_mobile/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:quizaipro_mobile/features/marketplace/data/mappers/marketplace_mapper.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/collection.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_card_preview.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_detail.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_summary.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/learning_path.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/marketplace_filter.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/paginated_result.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/subject.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  const MarketplaceRepositoryImpl({
    required MarketplaceRemoteDataSource remoteDataSource,
    required MarketplaceLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final MarketplaceRemoteDataSource _remote;
  final MarketplaceLocalDataSource _local;

  // ── Subjects ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Subject>>> getSubjects() async {
    final cached = _local.getCachedSubjects();
    if (cached != null) {
      return Right(cached.map(MarketplaceMapper.subjectFromDto).toList());
    }
    try {
      final dtos = await _remote.getSubjects();
      await _local.cacheSubjects(dtos);
      return Right(dtos.map(MarketplaceMapper.subjectFromDto).toList());
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(const Failure.unknown());
    }
  }

  // ── Collections ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<Collection>>> getCollections({
    String? subjectId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final cacheKey = 'collections_${subjectId ?? 'all'}_$page';
    final cached = _local.getCachedCollections(cacheKey);
    if (cached != null) {
      return Right(MarketplaceMapper.paginatedCollectionsFromDto(cached));
    }
    try {
      final dto = await _remote.getCollections(
        subjectId: subjectId,
        page: page,
        pageSize: pageSize,
      );
      await _local.cacheCollections(cacheKey, dto);
      return Right(MarketplaceMapper.paginatedCollectionsFromDto(dto));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(const Failure.unknown());
    }
  }

  // ── Learning paths ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<LearningPath>>> getLearningPaths({
    int page = 1,
    int pageSize = 20,
  }) async {
    final cached = _local.getCachedLearningPaths(page);
    if (cached != null) {
      return Right(MarketplaceMapper.paginatedLearningPathsFromDto(cached));
    }
    try {
      final dto = await _remote.getLearningPaths(page: page, pageSize: pageSize);
      await _local.cacheLearningPaths(page, dto);
      return Right(MarketplaceMapper.paginatedLearningPathsFromDto(dto));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(const Failure.unknown());
    }
  }

  // ── Decks ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<DeckSummary>>> getDecks({
    required MarketplaceFilter filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    final cached = _local.getCachedDecks(filter, page);
    if (cached != null) {
      return Right(MarketplaceMapper.paginatedDecksFromDto(cached));
    }
    try {
      final dto = await _remote.getDecks(
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
      await _local.cacheDecks(filter, page, dto);
      return Right(MarketplaceMapper.paginatedDecksFromDto(dto));
    } on DioException catch (e) {
      final failure = _fromDio(e);
      if (failure is NetworkFailure) {
        final stale = _local.getCachedDecks(filter, page);
        if (stale != null) {
          return Right(MarketplaceMapper.paginatedDecksFromDto(stale));
        }
      }
      return Left(failure);
    } catch (e) {
      return Left(const Failure.unknown());
    }
  }

  // ── Deck detail ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, DeckDetail>> getDeckDetail(String deckId) async {
    final cached = _local.getCachedDeckDetail(deckId);
    if (cached != null) {
      return Right(MarketplaceMapper.deckDetailFromDto(cached));
    }
    try {
      final dto = await _remote.getDeckDetail(deckId);
      await _local.cacheDeckDetail(deckId, dto);
      return Right(MarketplaceMapper.deckDetailFromDto(dto));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(const Failure.unknown());
    }
  }

  // ── Cards preview ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<DeckCardPreview>>> getDeckCardsPreview(
    String deckId, {
    int limit = 5,
  }) async {
    try {
      final dtos = await _remote.getDeckCardsPreview(deckId, limit: limit);
      return Right(dtos.map(MarketplaceMapper.cardPreviewFromDto).toList());
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(const Failure.unknown());
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<DeckSummary>>> searchDecks({
    required String query,
    required MarketplaceFilter filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final dto = await _remote.searchDecks(
        query: query,
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
      return Right(MarketplaceMapper.paginatedDecksFromDto(dto));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(const Failure.unknown());
    }
  }

  // ── Clone ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> cloneDeck(String deckId) async {
    try {
      final clonedId = await _remote.cloneDeck(deckId);
      // Invalidate deck detail cache so isClonedByUser updates.
      await _local.cacheDeckDetail(deckId,
          (await _remote.getDeckDetail(deckId)));
      return Right(clonedId);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(const Failure.unknown());
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Failure _fromDio(DioException e) {
    if (e.error is Failure) return e.error as Failure;
    return Failure.network(message: e.message ?? 'Network error.');
  }
}
