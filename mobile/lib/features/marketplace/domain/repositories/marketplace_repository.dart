import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/collection.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_card_preview.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_detail.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_review.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_summary.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/learning_path.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/marketplace_filter.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/paginated_result.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/subject.dart';

abstract interface class MarketplaceRepository {
  Future<Either<Failure, List<Subject>>> getSubjects();

  Future<Either<Failure, PaginatedResult<Collection>>> getCollections({
    String? subjectId,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, PaginatedResult<LearningPath>>> getLearningPaths({
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, PaginatedResult<DeckSummary>>> getDecks({
    required MarketplaceFilter filter,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, DeckDetail>> getDeckDetail(String deckId);

  Future<Either<Failure, List<DeckCardPreview>>> getDeckCardsPreview(
    String deckId, {
    int limit = 5,
  });

  Future<Either<Failure, PaginatedResult<DeckSummary>>> searchDecks({
    required String query,
    required MarketplaceFilter filter,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, String>> cloneDeck(String deckId);

  Future<Either<Failure, DeckReviewsResult>> getDeckReviews(String deckId);

  Future<Either<Failure, DeckReview>> submitDeckReview(
      String deckId, int stars, String text);

  Future<Either<Failure, Unit>> deleteDeckReview(String deckId);

  Future<Either<Failure, Unit>> reportReview(String reviewId);
}
