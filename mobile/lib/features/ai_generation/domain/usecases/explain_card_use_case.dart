import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';

final class ExplainCardParams {
  const ExplainCardParams({
    required this.question,
    required this.answer,
    this.deckId,
  });

  final String question;
  final String answer;
  final String? deckId;
}

class ExplainCardUseCase implements UseCase<String, ExplainCardParams> {
  ExplainCardUseCase(this._repository);

  final AiGenerationRepository _repository;

  @override
  Future<Either<Failure, String>> call(ExplainCardParams params) =>
      _repository.explainCard(
        question: params.question,
        answer: params.answer,
        deckId: params.deckId,
      );
}
