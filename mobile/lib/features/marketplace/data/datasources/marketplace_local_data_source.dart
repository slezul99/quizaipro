import 'dart:convert';

import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/core/storage/hive_service.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/collection_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/deck_detail_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/deck_summary_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/learning_path_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/paginated_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/subject_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/marketplace_filter.dart';

abstract interface class MarketplaceLocalDataSource {
  List<SubjectDto>? getCachedSubjects();
  Future<void> cacheSubjects(List<SubjectDto> dtos);

  PaginatedDto<CollectionDto>? getCachedCollections(String key);
  Future<void> cacheCollections(String key, PaginatedDto<CollectionDto> dto);

  PaginatedDto<LearningPathDto>? getCachedLearningPaths(int page);
  Future<void> cacheLearningPaths(int page, PaginatedDto<LearningPathDto> dto);

  PaginatedDto<DeckSummaryDto>? getCachedDecks(
    MarketplaceFilter filter,
    int page,
  );
  Future<void> cacheDecks(
    MarketplaceFilter filter,
    int page,
    PaginatedDto<DeckSummaryDto> dto,
  );

  DeckDetailDto? getCachedDeckDetail(String deckId);
  Future<void> cacheDeckDetail(String deckId, DeckDetailDto dto);

  Future<void> clearAll();
}

class MarketplaceLocalDataSourceImpl implements MarketplaceLocalDataSource {
  const MarketplaceLocalDataSourceImpl(this._hive);

  final HiveService _hive;

  static final _ttl = Duration(
    minutes: AppConstants.marketplaceListingsTtlMinutes,
  );

  // ── Subjects ──────────────────────────────────────────────────────────────

  @override
  List<SubjectDto>? getCachedSubjects() {
    final cached = _hive.getListingsCache(AppConstants.marketplaceSubjectsKey);
    if (cached.expired || cached.data == null) return null;
    try {
      final list = jsonDecode(cached.data as String) as List<dynamic>;
      return list
          .map((e) => SubjectDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheSubjects(List<SubjectDto> dtos) =>
      _hive.putListingsCache(
        AppConstants.marketplaceSubjectsKey,
        jsonEncode(dtos.map((e) => e.toJson()).toList()),
        DateTime.now().add(_ttl),
      );

  // ── Collections ───────────────────────────────────────────────────────────

  @override
  PaginatedDto<CollectionDto>? getCachedCollections(String key) {
    final cached = _hive.getListingsCache(key);
    if (cached.expired || cached.data == null) return null;
    try {
      return PaginatedDto.fromJson(
        jsonDecode(cached.data as String) as Map<String, dynamic>,
        CollectionDto.fromJson,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheCollections(
    String key,
    PaginatedDto<CollectionDto> dto,
  ) =>
      _hive.putListingsCache(
        key,
        jsonEncode({
          'items': dto.items.map((e) => e.toJson()).toList(),
          'page': dto.page,
          'total_pages': dto.totalPages,
          'total_count': dto.totalCount,
        }),
        DateTime.now().add(_ttl),
      );

  // ── Learning paths ────────────────────────────────────────────────────────

  @override
  PaginatedDto<LearningPathDto>? getCachedLearningPaths(int page) {
    final key = '${AppConstants.marketplaceLearningPathsKey}_$page';
    final cached = _hive.getListingsCache(key);
    if (cached.expired || cached.data == null) return null;
    try {
      return PaginatedDto.fromJson(
        jsonDecode(cached.data as String) as Map<String, dynamic>,
        LearningPathDto.fromJson,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheLearningPaths(
    int page,
    PaginatedDto<LearningPathDto> dto,
  ) {
    final key = '${AppConstants.marketplaceLearningPathsKey}_$page';
    return _hive.putListingsCache(
      key,
      jsonEncode({
        'items': dto.items.map((e) => e.toJson()).toList(),
        'page': dto.page,
        'total_pages': dto.totalPages,
        'total_count': dto.totalCount,
      }),
      DateTime.now().add(_ttl),
    );
  }

  // ── Decks ─────────────────────────────────────────────────────────────────

  @override
  PaginatedDto<DeckSummaryDto>? getCachedDecks(
    MarketplaceFilter filter,
    int page,
  ) {
    final key = '${AppConstants.marketplaceDecksKey}_${filter.cacheKey}_$page';
    final cached = _hive.getListingsCache(key);
    if (cached.expired || cached.data == null) return null;
    try {
      return PaginatedDto.fromJson(
        jsonDecode(cached.data as String) as Map<String, dynamic>,
        DeckSummaryDto.fromJson,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheDecks(
    MarketplaceFilter filter,
    int page,
    PaginatedDto<DeckSummaryDto> dto,
  ) {
    final key = '${AppConstants.marketplaceDecksKey}_${filter.cacheKey}_$page';
    return _hive.putListingsCache(
      key,
      jsonEncode({
        'items': dto.items.map((e) => e.toJson()).toList(),
        'page': dto.page,
        'total_pages': dto.totalPages,
        'total_count': dto.totalCount,
      }),
      DateTime.now().add(_ttl),
    );
  }

  // ── Deck detail ───────────────────────────────────────────────────────────

  @override
  DeckDetailDto? getCachedDeckDetail(String deckId) {
    final key = '${AppConstants.marketplaceDeckDetailKey}_$deckId';
    final cached = _hive.getListingsCache(key);
    if (cached.expired || cached.data == null) return null;
    try {
      return DeckDetailDto.fromJson(
        jsonDecode(cached.data as String) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheDeckDetail(String deckId, DeckDetailDto dto) {
    final key = '${AppConstants.marketplaceDeckDetailKey}_$deckId';
    return _hive.putListingsCache(
      key,
      jsonEncode(dto.toJson()),
      DateTime.now().add(_ttl),
    );
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  @override
  Future<void> clearAll() => _hive.marketplaceListings.clear();
}
