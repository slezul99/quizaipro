import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_collection.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/paginated_result.dart';

abstract interface class LibraryRepository {
  Future<Either<Failure, PaginatedResult<LibraryDeck>>> getMyDecks({
    required LibraryFilter filter,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, List<LibraryDeck>>> getRecentDecks({int limit = 10});

  Future<Either<Failure, PaginatedResult<LibraryCollection>>> getMyCollections({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, PaginatedResult<LibraryDeck>>> getFavorites({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, bool>> toggleFavorite(String deckId);

  Future<Either<Failure, LibraryDeck>> createDeck({
    required String title,
    required String description,
  });

  Future<Either<Failure, LibraryDeck>> updateDeck({
    required String deckId,
    required String title,
    required String description,
  });

  Future<Either<Failure, Unit>> deleteDeck(String deckId);

  Future<Either<Failure, Unit>> archiveDeck(String deckId);

  Future<Either<Failure, Unit>> unarchiveDeck(String deckId);

  Future<Either<Failure, PaginatedResult<LibraryDeck>>> searchLibrary({
    required String query,
    required int page,
    required int pageSize,
  });
}
