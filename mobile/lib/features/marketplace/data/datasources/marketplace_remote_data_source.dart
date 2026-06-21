import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/features/marketplace/data/dto/collection_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/deck_card_preview_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/deck_detail_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/deck_summary_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/learning_path_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/paginated_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/subject_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_review.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/marketplace_filter.dart';

abstract interface class MarketplaceRemoteDataSource {
  Future<List<SubjectDto>> getSubjects();

  Future<PaginatedDto<CollectionDto>> getCollections({
    String? subjectId,
    int page = 1,
    int pageSize = 20,
  });

  Future<PaginatedDto<LearningPathDto>> getLearningPaths({
    int page = 1,
    int pageSize = 20,
  });

  Future<PaginatedDto<DeckSummaryDto>> getDecks({
    required MarketplaceFilter filter,
    int page = 1,
    int pageSize = 20,
  });

  Future<DeckDetailDto> getDeckDetail(String deckId);

  Future<List<DeckCardPreviewDto>> getDeckCardsPreview(
    String deckId, {
    int limit = 5,
  });

  Future<PaginatedDto<DeckSummaryDto>> searchDecks({
    required String query,
    required MarketplaceFilter filter,
    int page = 1,
    int pageSize = 20,
  });

  Future<String> cloneDeck(String deckId);

  Future<DeckReviewsResult> getDeckReviews(String deckId);
  Future<DeckReview> submitDeckReview(String deckId, int stars, String text);
  Future<void> deleteDeckReview(String deckId);
  Future<void> reportReview(String reviewId);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  const MarketplaceRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<SubjectDto>> getSubjects() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/marketplace/subjects');
    final list = response.data!['data'] as List<dynamic>;
    return list
        .map((e) => SubjectDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PaginatedDto<CollectionDto>> getCollections({
    String? subjectId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/marketplace/collections',
      queryParameters: {
        'page': page,
        'limit': pageSize,
        if (subjectId != null) 'subject_id': subjectId,
      },
    );
    return PaginatedDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
      CollectionDto.fromJson,
    );
  }

  @override
  Future<PaginatedDto<LearningPathDto>> getLearningPaths({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/marketplace/learning-paths',
      queryParameters: {'page': page, 'limit': pageSize},
    );
    return PaginatedDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
      LearningPathDto.fromJson,
    );
  }

  @override
  Future<PaginatedDto<DeckSummaryDto>> getDecks({
    required MarketplaceFilter filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/marketplace/decks',
      queryParameters: {
        'page': page,
        'limit': pageSize,
        'sort': filter.sortBy.name,
        if (filter.subjectId != null) 'subject_id': filter.subjectId,
        if (filter.collectionId != null) 'collection_id': filter.collectionId,
        if (filter.difficulty != null) 'difficulty': filter.difficulty!.name,
        if (filter.proOnly) 'pro_only': true,
      },
    );
    return PaginatedDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
      DeckSummaryDto.fromJson,
    );
  }

  @override
  Future<DeckDetailDto> getDeckDetail(String deckId) async {
    final response = await _dio
        .get<Map<String, dynamic>>('/marketplace/decks/$deckId');
    return DeckDetailDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<DeckCardPreviewDto>> getDeckCardsPreview(
    String deckId, {
    int limit = 5,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/marketplace/decks/$deckId/cards',
      queryParameters: {'limit': limit},
    );
    final list = response.data!['data'] as List<dynamic>;
    return list
        .map((e) => DeckCardPreviewDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PaginatedDto<DeckSummaryDto>> searchDecks({
    required String query,
    required MarketplaceFilter filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/marketplace/search',
      queryParameters: {
        'q': query,
        'page': page,
        'limit': pageSize,
        'sort': filter.sortBy.name,
        if (filter.subjectId != null) 'subject_id': filter.subjectId,
        if (filter.difficulty != null) 'difficulty': filter.difficulty!.name,
        if (filter.proOnly) 'pro_only': true,
      },
    );
    return PaginatedDto.fromJson(
      response.data!['data'] as Map<String, dynamic>,
      DeckSummaryDto.fromJson,
    );
  }

  @override
  Future<String> cloneDeck(String deckId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/marketplace/decks/$deckId/clone',
    );
    return (response.data!['data'] as Map<String, dynamic>)['deck_id'] as String;
  }

  @override
  Future<DeckReviewsResult> getDeckReviews(String deckId) async {
    final r = await _dio.get<Map<String, dynamic>>(
        '/marketplace/decks/$deckId/reviews');
    return DeckReviewsResult.fromJson(r.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<DeckReview> submitDeckReview(
      String deckId, int stars, String text) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/marketplace/decks/$deckId/reviews',
      data: {'stars': stars, 'text': text},
    );
    return DeckReview.fromJson(r.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteDeckReview(String deckId) async {
    await _dio.delete<void>('/marketplace/decks/$deckId/reviews');
  }

  @override
  Future<void> reportReview(String reviewId) async {
    await _dio.post<void>('/marketplace/reviews/$reviewId/report');
  }
}
