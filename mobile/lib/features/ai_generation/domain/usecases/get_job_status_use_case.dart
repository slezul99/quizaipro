import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_job.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';

class GetJobStatusUseCase implements UseCase<GenerationJob, String> {
  GetJobStatusUseCase(this._repository);

  final AiGenerationRepository _repository;

  @override
  Future<Either<Failure, GenerationJob>> call(String jobId) =>
      _repository.getJobStatus(jobId);
}
