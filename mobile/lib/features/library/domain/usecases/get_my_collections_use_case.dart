import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_collection.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/paginated_result.dart';
import 'package:quizaipro_mobile/features/library/domain/repositories/library_repository.dart';

class GetMyCollectionsParams {
  const GetMyCollectionsParams({this.page = 1, this.pageSize = 20});

  final int page;
  final int pageSize;
}

class GetMyCollectionsUseCase
    implements
        UseCase<PaginatedResult<LibraryCollection>, GetMyCollectionsParams> {
  const GetMyCollectionsUseCase(this._repository);

  final LibraryRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<LibraryCollection>>> call(
    GetMyCollectionsParams params,
  ) =>
      _repository.getMyCollections(
        page: params.page,
        pageSize: params.pageSize,
      );
}
