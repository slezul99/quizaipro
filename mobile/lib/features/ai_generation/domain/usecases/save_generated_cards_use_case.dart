import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generated_card.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';

final class SaveGeneratedCardsParams {
  const SaveGeneratedCardsParams({
    required this.deckId,
    required this.cards,
  });

  final String deckId;
  final List<GeneratedCard> cards;
}

class SaveGeneratedCardsUseCase
    implements UseCase<Unit, SaveGeneratedCardsParams> {
  SaveGeneratedCardsUseCase(this._repository);

  final AiGenerationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SaveGeneratedCardsParams params) =>
      _repository.saveGeneratedCards(
        deckId: params.deckId,
        cards: params.cards,
      );
}
