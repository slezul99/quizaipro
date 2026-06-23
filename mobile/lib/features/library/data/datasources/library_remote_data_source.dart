import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/library/data/dto/library_collection_dto.dart';
import 'package:quizaipro_mobile/features/library/data/dto/library_deck_dto.dart';
import 'package:quizaipro_mobile/features/library/data/dto/library_paginated_dto.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';

abstract interface class LibraryRemoteDataSource {
  Future<LibraryPaginatedDto<LibraryDeckDto>> getMyDecks({
    required LibraryFilter filter,
    required int page,
    required int pageSize,
  });

  Future<List<LibraryDeckDto>> getRecentDecks({required int limit});

  Future<LibraryPaginatedDto<LibraryCollectionDto>> getMyCollections({
    required int page,
    required int pageSize,
  });

  Future<LibraryPaginatedDto<LibraryDeckDto>> getFavorites({
    required int page,
    required int pageSize,
  });

  Future<bool> toggleFavorite(String deckId);

  Future<LibraryDeckDto> createDeck({
    required String title,
    required String description,
    String? color,
    String? cover,
  });

  Future<LibraryDeckDto> updateDeck({
    required String deckId,
    required String title,
    required String description,
    String? color,
    String? cover,
  });

  Future<void> deleteDeck(String deckId);

  Future<void> archiveDeck(String deckId);

  Future<void> unarchiveDeck(String deckId);

  Future<LibraryPaginatedDto<LibraryDeckDto>> searchLibrary({
    required String query,
    required int page,
    required int pageSize,
  });
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  const LibraryRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<LibraryPaginatedDto<LibraryDeckDto>> getMyDecks({
    required LibraryFilter filter,
    required int page,
    required int pageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/library/decks',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        'sort': filter.sortBy.name,
        if (filter.difficulty != null) 'difficulty': filter.difficulty!.name,
        'show_archived': filter.showArchived,
        'has_due_only': filter.hasDueOnly,
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return LibraryPaginatedDto.fromJson(data, LibraryDeckDto.fromJson);
  }

  @override
  Future<List<LibraryDeckDto>> getRecentDecks({required int limit}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/library/decks/recent',
      queryParameters: {'limit': limit},
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => LibraryDeckDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LibraryPaginatedDto<LibraryCollectionDto>> getMyCollections({
    required int page,
    required int pageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/library/collections',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return LibraryPaginatedDto.fromJson(data, LibraryCollectionDto.fromJson);
  }

  @override
  Future<LibraryPaginatedDto<LibraryDeckDto>> getFavorites({
    required int page,
    required int pageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/library/favorites',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return LibraryPaginatedDto.fromJson(data, LibraryDeckDto.fromJson);
  }

  @override
  Future<bool> toggleFavorite(String deckId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/decks/$deckId/favorite',
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return data['is_favorite'] as bool;
  }

  @override
  Future<LibraryDeckDto> createDeck({
    required String title,
    required String description,
    String? color,
    String? cover,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/library/decks',
      data: {
        'title': title,
        'description': description,
        if (color != null) 'color': color,
        if (cover != null) 'cover': cover,
      },
    );
    return LibraryDeckDto.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<LibraryDeckDto> updateDeck({
    required String deckId,
    required String title,
    required String description,
    String? color,
    String? cover,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/library/decks/$deckId',
      data: {
        'title': title,
        'description': description,
        if (color != null) 'color': color,
        if (cover != null) 'cover': cover,
      },
    );
    return LibraryDeckDto.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteDeck(String deckId) =>
      _dio.delete<void>('/library/decks/$deckId');

  @override
  Future<void> archiveDeck(String deckId) =>
      _dio.post<void>('/library/decks/$deckId/archive');

  @override
  Future<void> unarchiveDeck(String deckId) =>
      _dio.post<void>('/library/decks/$deckId/unarchive');

  @override
  Future<LibraryPaginatedDto<LibraryDeckDto>> searchLibrary({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/library/search',
      queryParameters: {'q': query, 'page': page, 'page_size': pageSize},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return LibraryPaginatedDto.fromJson(data, LibraryDeckDto.fromJson);
  }
}
