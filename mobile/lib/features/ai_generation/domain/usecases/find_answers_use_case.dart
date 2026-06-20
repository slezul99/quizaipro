import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/find_answers_result.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';

final class FindAnswersParams {
  const FindAnswersParams({required this.question, this.deckId});

  final String question;
  final String? deckId;
}

class FindAnswersUseCase
    implements UseCase<FindAnswersResult, FindAnswersParams> {
  FindAnswersUseCase(this._repository);

  final AiGenerationRepository _repository;

  @override
  Future<Either<Failure, FindAnswersResult>> call(FindAnswersParams params) =>
      _repository.findAnswers(
        question: params.question,
        deckId: params.deckId,
      );
}
