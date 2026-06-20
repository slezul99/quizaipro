import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/flashcard.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_card.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_mode.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/repositories/flashcard_repository.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';
import 'package:quizaipro_mobile/features/library/domain/repositories/library_repository.dart';

class LoadStudyQueueParams {
  const LoadStudyQueueParams({
    required this.deckId,
    required this.mode,
    required this.sessionSize,
  });

  final String deckId;
  final StudyMode mode;
  final int sessionSize;
}

class LoadStudyQueueUseCase
    implements UseCase<List<StudyCard>, LoadStudyQueueParams> {
  const LoadStudyQueueUseCase(this._repository, this._libraryRepository);

  final FlashcardRepository _repository;
  final LibraryRepository _libraryRepository;

  @override
  Future<Either<Failure, List<StudyCard>>> call(
    LoadStudyQueueParams params,
  ) async {
    if (params.deckId.isEmpty) {
      return _loadAcrossDecks(params);
    }
    final result = await _repository.getCardsForDeck(params.deckId);
    return result.map(
      (cards) => _buildQueue(cards, params.mode, params.sessionSize),
    );
  }

  /// No deck selected — build a session from due cards across every deck
  /// in the user's library (used by the dashboard "study now" actions).
  Future<Either<Failure, List<StudyCard>>> _loadAcrossDecks(
    LoadStudyQueueParams params,
  ) async {
    final decksResult = await _libraryRepository.getMyDecks(
      filter: const LibraryFilter(
        sortBy: LibrarySortBy.dueCards,
        hasDueOnly: true,
      ),
      page: 1,
      pageSize: 50,
    );

    return decksResult.fold(
      (failure) async => Left(failure),
      (decks) async {
        final allCards = <Flashcard>[];
        for (final deck in decks.items) {
          final cardsResult = await _repository.getCardsForDeck(deck.id);
          cardsResult.fold((_) {}, allCards.addAll);
        }
        return Right(_buildQueue(allCards, params.mode, params.sessionSize));
      },
    );
  }

  List<StudyCard> _buildQueue(
    List<Flashcard> all,
    StudyMode mode,
    int size,
  ) {
    final now = DateTime.now();

    final newCards = all
        .where((c) => c.repetitions == 0 && c.nextReviewAt == null)
        .toList();
    final dueCards = all
        .where((c) => c.nextReviewAt != null && c.nextReviewAt!.isBefore(now))
        .toList();
    final difficultCards =
        all.where((c) => c.isDifficult && !c.isNew).toList();
    final favoriteCards = all.where((c) => c.isFavorite).toList();

    final List<Flashcard> selected = switch (mode) {
      StudyMode.newCards => newCards.take(size).toList(),
      StudyMode.review => dueCards.take(size).toList(),
      StudyMode.difficult => difficultCards.take(size).toList(),
      StudyMode.favorite => favoriteCards.take(size).toList(),
      StudyMode.smart =>
        _smartMix(newCards, difficultCards, dueCards, size),
    };

    return selected.map(_toStudyCard).toList();
  }

  List<Flashcard> _smartMix(
    List<Flashcard> newCards,
    List<Flashcard> difficult,
    List<Flashcard> due,
    int size,
  ) {
    final newCount = (size * 0.5).round();
    final difficultCount = (size * 0.3).round();
    final reviewCount = size - newCount - difficultCount;

    final result = <Flashcard>[
      ...newCards.take(newCount),
      ...difficult.take(difficultCount),
      ...due.take(reviewCount),
    ]..shuffle();

    return result.take(size).toList();
  }

  StudyCard _toStudyCard(Flashcard c) => StudyCard(
        id: c.id,
        deckId: c.deckId,
        front: c.front,
        back: c.back,
        hint: c.hint,
        easeFactor: c.easeFactor,
        interval: c.interval,
        repetitions: c.repetitions,
        stability: c.stability,
        difficulty: c.difficulty,
        lastStudiedAt: c.lastStudiedAt,
        nextReviewAt: c.nextReviewAt,
        isFavorite: c.isFavorite,
        isDifficult: c.isDifficult,
        isNew: c.isNew,
        againCount: c.againCount,
      );
}
