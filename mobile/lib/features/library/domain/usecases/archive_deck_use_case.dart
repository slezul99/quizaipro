import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/library/domain/repositories/library_repository.dart';

class ArchiveDeckParams {
  const ArchiveDeckParams({required this.deckId, required this.archive});

  final String deckId;
  final bool archive;
}

class ArchiveDeckUseCase implements UseCase<Unit, ArchiveDeckParams> {
  const ArchiveDeckUseCase(this._repository);

  final LibraryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ArchiveDeckParams params) => params.archive
      ? _repository.archiveDeck(params.deckId)
      : _repository.unarchiveDeck(params.deckId);
}
