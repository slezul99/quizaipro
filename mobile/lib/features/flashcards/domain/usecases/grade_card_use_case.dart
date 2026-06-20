import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/algorithms/sm2_algorithm.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/card_grade.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/repositories/flashcard_repository.dart';

class GradeCardParams {
  const GradeCardParams({
    required this.cardId,
    required this.deckId,
    required this.grade,
    required this.sm2Result,
    required this.stability,
    required this.difficulty,
    required this.newAgainCount,
  });

  final String cardId;
  final String deckId;
  final CardGrade grade;
  final Sm2Result sm2Result;
  final double stability;
  final double difficulty;
  final int newAgainCount;
}

class GradeCardUseCase implements UseCase<Unit, GradeCardParams> {
  const GradeCardUseCase(this._repository);

  final FlashcardRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(GradeCardParams params) =>
      _repository.gradeCard(
        cardId: params.cardId,
        deckId: params.deckId,
        grade: params.grade,
        sm2Result: params.sm2Result,
        stability: params.stability,
        difficulty: params.difficulty,
        newAgainCount: params.newAgainCount,
      );
}
