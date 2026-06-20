import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/paginated_result.dart';
import 'package:quizaipro_mobile/features/library/domain/repositories/library_repository.dart';

class GetMyDecksParams {
  const GetMyDecksParams({
    required this.filter,
    this.page = 1,
    this.pageSize = 20,
  });

  final LibraryFilter filter;
  final int page;
  final int pageSize;
}

class GetMyDecksUseCase
    implements UseCase<PaginatedResult<LibraryDeck>, GetMyDecksParams> {
  const GetMyDecksUseCase(this._repository);

  final LibraryRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<LibraryDeck>>> call(
    GetMyDecksParams params,
  ) =>
      _repository.getMyDecks(
        filter: params.filter,
        page: params.page,
        pageSize: params.pageSize,
      );
}
