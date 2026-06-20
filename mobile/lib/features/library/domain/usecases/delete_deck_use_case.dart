import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/library/domain/repositories/library_repository.dart';

class DeleteDeckParams {
  const DeleteDeckParams({required this.deckId});

  final String deckId;
}

class DeleteDeckUseCase implements UseCase<Unit, DeleteDeckParams> {
  const DeleteDeckUseCase(this._repository);

  final LibraryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteDeckParams params) =>
      _repository.deleteDeck(params.deckId);
}
