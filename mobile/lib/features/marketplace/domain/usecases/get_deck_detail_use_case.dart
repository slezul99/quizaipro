import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_detail.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';

class GetDeckDetailParams {
  const GetDeckDetailParams({required this.deckId});

  final String deckId;
}

class GetDeckDetailUseCase
    implements UseCase<DeckDetail, GetDeckDetailParams> {
  const GetDeckDetailUseCase(this._repository);

  final MarketplaceRepository _repository;

  @override
  Future<Either<Failure, DeckDetail>> call(GetDeckDetailParams params) =>
      _repository.getDeckDetail(params.deckId);
}
