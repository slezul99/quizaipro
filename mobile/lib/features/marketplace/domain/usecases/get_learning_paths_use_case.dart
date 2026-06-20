import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/learning_path.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/paginated_result.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';

class GetLearningPathsParams {
  const GetLearningPathsParams({this.page = 1, this.pageSize = 20});

  final int page;
  final int pageSize;
}

class GetLearningPathsUseCase
    implements UseCase<PaginatedResult<LearningPath>, GetLearningPathsParams> {
  const GetLearningPathsUseCase(this._repository);

  final MarketplaceRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<LearningPath>>> call(
    GetLearningPathsParams params,
  ) =>
      _repository.getLearningPaths(page: params.page, pageSize: params.pageSize);
}
