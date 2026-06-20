import 'dart:convert';

import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/core/storage/hive_service.dart';
import 'package:quizaipro_mobile/features/library/data/dto/library_collection_dto.dart';
import 'package:quizaipro_mobile/features/library/data/dto/library_deck_dto.dart';
import 'package:quizaipro_mobile/features/library/data/dto/library_paginated_dto.dart';

abstract interface class LibraryLocalDataSource {
  Future<void> cacheDecks(
    String key,
    LibraryPaginatedDto<LibraryDeckDto> data,
  );
  LibraryPaginatedDto<LibraryDeckDto>? getCachedDecks(String key);

  Future<void> cacheRecentDecks(List<LibraryDeckDto> data);
  List<LibraryDeckDto>? getCachedRecentDecks();

  Future<void> cacheCollections(
    int page,
    LibraryPaginatedDto<LibraryCollectionDto> data,
  );
  LibraryPaginatedDto<LibraryCollectionDto>? getCachedCollections(int page);

  Future<void> cacheFavorites(
    int page,
    LibraryPaginatedDto<LibraryDeckDto> data,
  );
  LibraryPaginatedDto<LibraryDeckDto>? getCachedFavorites(int page);

  Future<void> clearAll();
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  const LibraryLocalDataSourceImpl(this._hive);

  final HiveService _hive;

  static const _decksTtlMinutes = AppConstants.libraryDecksCacheTtlMinutes;
  static const _recentTtlMinutes = AppConstants.libraryRecentCacheTtlMinutes;
  static const _collectionsTtlMinutes =
      AppConstants.libraryCollectionsCacheTtlMinutes;

  @override
  Future<void> cacheDecks(
    String key,
    LibraryPaginatedDto<LibraryDeckDto> data,
  ) {
    final json = {
      'items': data.items.map((e) => e.toJson()).toList(),
      'page': data.page,
      'total_pages': data.totalPages,
      'total_count': data.totalCount,
    };
    return _hive.putLibraryCache(
      '${AppConstants.libraryDecksKey}_$key',
      jsonEncode(json),
      DateTime.now().add(Duration(minutes: _decksTtlMinutes)),
    );
  }

  @override
  LibraryPaginatedDto<LibraryDeckDto>? getCachedDecks(String key) {
    final entry = _hive.getLibraryCache('${AppConstants.libraryDecksKey}_$key');
    if (entry.data == null || entry.expired) return null;
    final decoded = jsonDecode(entry.data as String) as Map<String, dynamic>;
    return LibraryPaginatedDto.fromJson(decoded, LibraryDeckDto.fromJson);
  }

  @override
  Future<void> cacheRecentDecks(List<LibraryDeckDto> data) {
    final json = data.map((e) => e.toJson()).toList();
    return _hive.putLibraryCache(
      AppConstants.libraryRecentKey,
      jsonEncode(json),
      DateTime.now().add(Duration(minutes: _recentTtlMinutes)),
    );
  }

  @override
  List<LibraryDeckDto>? getCachedRecentDecks() {
    final entry = _hive.getLibraryCache(AppConstants.libraryRecentKey);
    if (entry.data == null || entry.expired) return null;
    final decoded = jsonDecode(entry.data as String) as List<dynamic>;
    return decoded
        .map((e) => LibraryDeckDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheCollections(
    int page,
    LibraryPaginatedDto<LibraryCollectionDto> data,
  ) {
    final json = {
      'items': data.items.map((e) => e.toJson()).toList(),
      'page': data.page,
      'total_pages': data.totalPages,
      'total_count': data.totalCount,
    };
    return _hive.putLibraryCache(
      '${AppConstants.libraryCollectionsKey}_$page',
      jsonEncode(json),
      DateTime.now().add(Duration(minutes: _collectionsTtlMinutes)),
    );
  }

  @override
  LibraryPaginatedDto<LibraryCollectionDto>? getCachedCollections(int page) {
    final entry = _hive.getLibraryCache(
      '${AppConstants.libraryCollectionsKey}_$page',
    );
    if (entry.data == null || entry.expired) return null;
    final decoded = jsonDecode(entry.data as String) as Map<String, dynamic>;
    return LibraryPaginatedDto.fromJson(
      decoded,
      LibraryCollectionDto.fromJson,
    );
  }

  @override
  Future<void> cacheFavorites(
    int page,
    LibraryPaginatedDto<LibraryDeckDto> data,
  ) {
    final json = {
      'items': data.items.map((e) => e.toJson()).toList(),
      'page': data.page,
      'total_pages': data.totalPages,
      'total_count': data.totalCount,
    };
    return _hive.putLibraryCache(
      '${AppConstants.libraryFavoritesKey}_$page',
      jsonEncode(json),
      DateTime.now().add(Duration(minutes: _decksTtlMinutes)),
    );
  }

  @override
  LibraryPaginatedDto<LibraryDeckDto>? getCachedFavorites(int page) {
    final entry = _hive.getLibraryCache(
      '${AppConstants.libraryFavoritesKey}_$page',
    );
    if (entry.data == null || entry.expired) return null;
    final decoded = jsonDecode(entry.data as String) as Map<String, dynamic>;
    return LibraryPaginatedDto.fromJson(decoded, LibraryDeckDto.fromJson);
  }

  @override
  Future<void> clearAll() => _hive.clearLibraryCache();
}
