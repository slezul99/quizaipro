import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/library/data/datasources/library_local_data_source.dart';
import 'package:quizaipro_mobile/features/library/data/datasources/library_remote_data_source.dart';
import 'package:quizaipro_mobile/features/library/data/mappers/library_mapper.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_collection.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/paginated_result.dart';
import 'package:quizaipro_mobile/features/library/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  const LibraryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final LibraryRemoteDataSource remoteDataSource;
  final LibraryLocalDataSource localDataSource;

  @override
  Future<Either<Failure, PaginatedResult<LibraryDeck>>> getMyDecks({
    required LibraryFilter filter,
    required int page,
    required int pageSize,
  }) async {
    final cacheKey = '${filter.cacheKey}_$page';
    try {
      final dto = await remoteDataSource.getMyDecks(
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
      await localDataSource.cacheDecks(cacheKey, dto);
      return Right(PaginatedResult<LibraryDeck>(
        items: dto.items.map(LibraryMapper.deckFromDto).toList(),
        page: dto.page,
        totalPages: dto.totalPages,
        totalCount: dto.totalCount,
      ));
    } on DioException catch (e) {
      final failure = _fromDio(e);
      if (failure is NetworkFailure) {
        final cached = localDataSource.getCachedDecks(cacheKey);
        if (cached != null) {
          return Right(PaginatedResult<LibraryDeck>(
            items: cached.items.map(LibraryMapper.deckFromDto).toList(),
            page: cached.page,
            totalPages: cached.totalPages,
            totalCount: cached.totalCount,
          ));
        }
      }
      return Left(failure);
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LibraryDeck>>> getRecentDecks({
    int limit = 10,
  }) async {
    try {
      final dtos = await remoteDataSource.getRecentDecks(limit: limit);
      await localDataSource.cacheRecentDecks(dtos);
      return Right(dtos.map(LibraryMapper.deckFromDto).toList());
    } on DioException catch (e) {
      final failure = _fromDio(e);
      if (failure is NetworkFailure) {
        final cached = localDataSource.getCachedRecentDecks();
        if (cached != null) {
          return Right(cached.map(LibraryMapper.deckFromDto).toList());
        }
      }
      return Left(failure);
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<LibraryCollection>>> getMyCollections({
    required int page,
    required int pageSize,
  }) async {
    try {
      final dto = await remoteDataSource.getMyCollections(
        page: page,
        pageSize: pageSize,
      );
      await localDataSource.cacheCollections(page, dto);
      return Right(PaginatedResult<LibraryCollection>(
        items: dto.items.map(LibraryMapper.collectionFromDto).toList(),
        page: dto.page,
        totalPages: dto.totalPages,
        totalCount: dto.totalCount,
      ));
    } on DioException catch (e) {
      final failure = _fromDio(e);
      if (failure is NetworkFailure) {
        final cached = localDataSource.getCachedCollections(page);
        if (cached != null) {
          return Right(PaginatedResult<LibraryCollection>(
            items: cached.items.map(LibraryMapper.collectionFromDto).toList(),
            page: cached.page,
            totalPages: cached.totalPages,
            totalCount: cached.totalCount,
          ));
        }
      }
      return Left(failure);
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<LibraryDeck>>> getFavorites({
    required int page,
    required int pageSize,
  }) async {
    try {
      final dto = await remoteDataSource.getFavorites(
        page: page,
        pageSize: pageSize,
      );
      await localDataSource.cacheFavorites(page, dto);
      return Right(PaginatedResult<LibraryDeck>(
        items: dto.items.map(LibraryMapper.deckFromDto).toList(),
        page: dto.page,
        totalPages: dto.totalPages,
        totalCount: dto.totalCount,
      ));
    } on DioException catch (e) {
      final failure = _fromDio(e);
      if (failure is NetworkFailure) {
        final cached = localDataSource.getCachedFavorites(page);
        if (cached != null) {
          return Right(PaginatedResult<LibraryDeck>(
            items: cached.items.map(LibraryMapper.deckFromDto).toList(),
            page: cached.page,
            totalPages: cached.totalPages,
            totalCount: cached.totalCount,
          ));
        }
      }
      return Left(failure);
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(String deckId) async {
    try {
      final result = await remoteDataSource.toggleFavorite(deckId);
      return Right(result);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LibraryDeck>> createDeck({
    required String title,
    required String description,
  }) async {
    try {
      final dto = await remoteDataSource.createDeck(
        title: title,
        description: description,
      );
      return Right(LibraryMapper.deckFromDto(dto));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LibraryDeck>> updateDeck({
    required String deckId,
    required String title,
    required String description,
  }) async {
    try {
      final dto = await remoteDataSource.updateDeck(
        deckId: deckId,
        title: title,
        description: description,
      );
      return Right(LibraryMapper.deckFromDto(dto));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDeck(String deckId) async {
    try {
      await remoteDataSource.deleteDeck(deckId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> archiveDeck(String deckId) async {
    try {
      await remoteDataSource.archiveDeck(deckId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> unarchiveDeck(String deckId) async {
    try {
      await remoteDataSource.unarchiveDeck(deckId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<LibraryDeck>>> searchLibrary({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    try {
      final dto = await remoteDataSource.searchLibrary(
        query: query,
        page: page,
        pageSize: pageSize,
      );
      return Right(PaginatedResult<LibraryDeck>(
        items: dto.items.map(LibraryMapper.deckFromDto).toList(),
        page: dto.page,
        totalPages: dto.totalPages,
        totalCount: dto.totalCount,
      ));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  Failure _fromDio(DioException e) {
    if (e.error is Failure) return e.error as Failure;
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        Failure.network(message: e.message ?? 'Connection error'),
      _ => Failure.unknown(message: e.message ?? 'Unexpected error'),
    };
  }
}
