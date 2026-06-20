import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_summary.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/marketplace_filter.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/paginated_result.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';

class SearchDecksParams {
  const SearchDecksParams({
    required this.query,
    required this.filter,
    this.page = 1,
    this.pageSize = 20,
  });

  final String query;
  final MarketplaceFilter filter;
  final int page;
  final int pageSize;
}

class SearchDecksUseCase
    implements UseCase<PaginatedResult<DeckSummary>, SearchDecksParams> {
  const SearchDecksUseCase(this._repository);

  final MarketplaceRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<DeckSummary>>> call(
    SearchDecksParams params,
  ) =>
      _repository.searchDecks(
        query: params.query,
        filter: params.filter,
        page: params.page,
        pageSize: params.pageSize,
      );
}
