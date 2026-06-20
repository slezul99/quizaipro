import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/repositories/flashcard_repository.dart';

class SaveSessionParams {
  const SaveSessionParams({
    required this.deckId,
    required this.totalCards,
    required this.newCards,
    required this.reviewCards,
    required this.againCount,
    required this.hardCount,
    required this.goodCount,
    required this.easyCount,
    required this.durationSeconds,
  });

  final String deckId;
  final int totalCards;
  final int newCards;
  final int reviewCards;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;
  final int durationSeconds;
}

class SaveSessionUseCase implements UseCase<Unit, SaveSessionParams> {
  const SaveSessionUseCase(this._repository);

  final FlashcardRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SaveSessionParams params) =>
      _repository.saveSession(
        deckId: params.deckId,
        totalCards: params.totalCards,
        newCards: params.newCards,
        reviewCards: params.reviewCards,
        againCount: params.againCount,
        hardCount: params.hardCount,
        goodCount: params.goodCount,
        easyCount: params.easyCount,
        durationSeconds: params.durationSeconds,
      );
}
