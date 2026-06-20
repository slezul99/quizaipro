import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/paginated_result.dart';
import 'package:quizaipro_mobile/features/library/domain/repositories/library_repository.dart';

class SearchLibraryParams {
  const SearchLibraryParams({
    required this.query,
    this.page = 1,
    this.pageSize = 20,
  });

  final String query;
  final int page;
  final int pageSize;
}

class SearchLibraryUseCase
    implements UseCase<PaginatedResult<LibraryDeck>, SearchLibraryParams> {
  const SearchLibraryUseCase(this._repository);

  final LibraryRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<LibraryDeck>>> call(
    SearchLibraryParams params,
  ) =>
      _repository.searchLibrary(
        query: params.query,
        page: params.page,
        pageSize: params.pageSize,
      );
}
