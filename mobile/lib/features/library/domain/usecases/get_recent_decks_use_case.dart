import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/domain/repositories/library_repository.dart';

class GetRecentDecksParams {
  const GetRecentDecksParams({this.limit = 10});

  final int limit;
}

class GetRecentDecksUseCase
    implements UseCase<List<LibraryDeck>, GetRecentDecksParams> {
  const GetRecentDecksUseCase(this._repository);

  final LibraryRepository _repository;

  @override
  Future<Either<Failure, List<LibraryDeck>>> call(GetRecentDecksParams params) =>
      _repository.getRecentDecks(limit: params.limit);
}
