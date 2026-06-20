import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_job.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';

class GetGenerationHistoryUseCase
    implements UseCase<List<GenerationJob>, NoParams> {
  GetGenerationHistoryUseCase(this._repository);

  final AiGenerationRepository _repository;

  @override
  Future<Either<Failure, List<GenerationJob>>> call(NoParams params) =>
      _repository.getHistory();
}
