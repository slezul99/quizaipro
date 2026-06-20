import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_job.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/quality_mode.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';

final class GenerateFromTopicParams {
  const GenerateFromTopicParams({
    required this.topic,
    required this.cardCount,
    required this.qualityMode,
  });

  final String topic;
  final int cardCount;
  final QualityMode qualityMode;
}

class GenerateFromTopicUseCase
    implements UseCase<GenerationJob, GenerateFromTopicParams> {
  GenerateFromTopicUseCase(this._repository);

  final AiGenerationRepository _repository;

  @override
  Future<Either<Failure, GenerationJob>> call(
          GenerateFromTopicParams params) =>
      _repository.generateFromTopic(
        topic: params.topic,
        cardCount: params.cardCount,
        qualityMode: params.qualityMode,
      );
}
