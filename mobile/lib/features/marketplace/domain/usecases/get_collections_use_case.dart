import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/collection.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/paginated_result.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';

class GetCollectionsParams {
  const GetCollectionsParams({
    this.subjectId,
    this.page = 1,
    this.pageSize = 20,
  });

  final String? subjectId;
  final int page;
  final int pageSize;
}

class GetCollectionsUseCase
    implements UseCase<PaginatedResult<Collection>, GetCollectionsParams> {
  const GetCollectionsUseCase(this._repository);

  final MarketplaceRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<Collection>>> call(
    GetCollectionsParams params,
  ) =>
      _repository.getCollections(
        subjectId: params.subjectId,
        page: params.page,
        pageSize: params.pageSize,
      );
}
