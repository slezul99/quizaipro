import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_card_preview.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';

class GetDeckCardsPreviewParams {
  const GetDeckCardsPreviewParams({required this.deckId, this.limit = 5});

  final String deckId;
  final int limit;
}

class GetDeckCardsPreviewUseCase
    implements UseCase<List<DeckCardPreview>, GetDeckCardsPreviewParams> {
  const GetDeckCardsPreviewUseCase(this._repository);

  final MarketplaceRepository _repository;

  @override
  Future<Either<Failure, List<DeckCardPreview>>> call(
    GetDeckCardsPreviewParams params,
  ) =>
      _repository.getDeckCardsPreview(params.deckId, limit: params.limit);
}
