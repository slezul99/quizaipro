import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_job.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/quality_mode.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';

final class GenerateFromPdfParams {
  const GenerateFromPdfParams({
    required this.filePath,
    required this.fileName,
    required this.cardCount,
    required this.qualityMode,
  });

  final String filePath;
  final String fileName;
  final int cardCount;
  final QualityMode qualityMode;
}

class GenerateFromPdfUseCase
    implements UseCase<GenerationJob, GenerateFromPdfParams> {
  GenerateFromPdfUseCase(this._repository);

  final AiGenerationRepository _repository;

  @override
  Future<Either<Failure, GenerationJob>> call(
          GenerateFromPdfParams params) =>
      _repository.generateFromPdf(
        filePath: params.filePath,
        fileName: params.fileName,
        cardCount: params.cardCount,
        qualityMode: params.qualityMode,
      );
}
