import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/repositories/flashcard_repository.dart';

class SyncPendingGradesUseCase implements UseCase<int, NoParams> {
  const SyncPendingGradesUseCase(this._repository);

  final FlashcardRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams params) =>
      _repository.syncPendingGrades();
}
