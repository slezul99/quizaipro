import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';

class CloneDeckParams {
  const CloneDeckParams({required this.deckId});

  final String deckId;
}

class CloneDeckUseCase implements UseCase<String, CloneDeckParams> {
  const CloneDeckUseCase(this._repository);

  final MarketplaceRepository _repository;

  @override
  Future<Either<Failure, String>> call(CloneDeckParams params) =>
      _repository.cloneDeck(params.deckId);
}
