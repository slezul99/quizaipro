import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/paginated_result.dart';
import 'package:quizaipro_mobile/features/library/domain/repositories/library_repository.dart';

class GetFavoritesParams {
  const GetFavoritesParams({this.page = 1, this.pageSize = 20});

  final int page;
  final int pageSize;
}

class GetFavoritesUseCase
    implements UseCase<PaginatedResult<LibraryDeck>, GetFavoritesParams> {
  const GetFavoritesUseCase(this._repository);

  final LibraryRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<LibraryDeck>>> call(
    GetFavoritesParams params,
  ) =>
      _repository.getFavorites(page: params.page, pageSize: params.pageSize);
}
