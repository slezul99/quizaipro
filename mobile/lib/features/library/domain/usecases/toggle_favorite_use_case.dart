import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/library/domain/repositories/library_repository.dart';

class ToggleFavoriteParams {
  const ToggleFavoriteParams({required this.deckId});

  final String deckId;
}

class ToggleFavoriteUseCase implements UseCase<bool, ToggleFavoriteParams> {
  const ToggleFavoriteUseCase(this._repository);

  final LibraryRepository _repository;

  @override
  Future<Either<Failure, bool>> call(ToggleFavoriteParams params) =>
      _repository.toggleFavorite(params.deckId);
}
