import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/deck_summary.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';

class CreateDeckUseCase implements UseCase<DeckSummary, String> {
  CreateDeckUseCase(this._repository);

  final AiGenerationRepository _repository;

  @override
  Future<Either<Failure, DeckSummary>> call(String title) =>
      _repository.createDeck(title);
}
