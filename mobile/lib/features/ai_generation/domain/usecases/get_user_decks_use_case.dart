import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/deck_summary.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';

class GetUserDecksUseCase implements UseCase<List<DeckSummary>, NoParams> {
  GetUserDecksUseCase(this._repository);

  final AiGenerationRepository _repository;

  @override
  Future<Either<Failure, List<DeckSummary>>> call(NoParams params) =>
      _repository.getUserDecks();
}
