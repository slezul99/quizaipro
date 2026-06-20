import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_job.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/quality_mode.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';

final class GenerateFromTextParams {
  const GenerateFromTextParams({
    required this.text,
    required this.cardCount,
    required this.qualityMode,
  });

  final String text;
  final int cardCount;
  final QualityMode qualityMode;
}

class GenerateFromTextUseCase
    implements UseCase<GenerationJob, GenerateFromTextParams> {
  GenerateFromTextUseCase(this._repository);

  final AiGenerationRepository _repository;

  @override
  Future<Either<Failure, GenerationJob>> call(
          GenerateFromTextParams params) =>
      _repository.generateFromText(
        text: params.text,
        cardCount: params.cardCount,
        qualityMode: params.qualityMode,
      );
}
