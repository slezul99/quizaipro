import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/algorithms/sm2_algorithm.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/card_grade.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/flashcard.dart';

abstract interface class FlashcardRepository {
  Future<Either<Failure, List<Flashcard>>> getCardsForDeck(String deckId);

  Future<Either<Failure, Flashcard>> createCard({
    required String deckId,
    required String front,
    required String back,
    required String note,
  });

  Future<Either<Failure, Flashcard>> updateCard({
    required String deckId,
    required String cardId,
    required String front,
    required String back,
    required String note,
  });

  Future<Either<Failure, Unit>> deleteCard({
    required String deckId,
    required String cardId,
  });

  Future<Either<Failure, Unit>> gradeCard({
    required String cardId,
    required String deckId,
    required CardGrade grade,
    required Sm2Result sm2Result,
    required double stability,
    required double difficulty,
    required int newAgainCount,
  });

  Future<Either<Failure, Unit>> saveSession({
    required String deckId,
    required int totalCards,
    required int newCards,
    required int reviewCards,
    required int againCount,
    required int hardCount,
    required int goodCount,
    required int easyCount,
    required int durationSeconds,
  });

  Future<Either<Failure, int>> syncPendingGrades();

  Future<Either<Failure, Unit>> toggleFavorite(
    String cardId, {
    required bool isFavorite,
  });
}
