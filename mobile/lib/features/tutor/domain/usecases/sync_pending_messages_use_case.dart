import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tutor/domain/repositories/tutor_repository.dart';

class SyncPendingMessagesUseCase implements UseCase<int, NoParams> {
  const SyncPendingMessagesUseCase(this._repository);

  final TutorRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams _) => _repository.syncPending();
}
