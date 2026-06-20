import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/subject.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';

class GetSubjectsUseCase implements UseCase<List<Subject>, NoParams> {
  const GetSubjectsUseCase(this._repository);

  final MarketplaceRepository _repository;

  @override
  Future<Either<Failure, List<Subject>>> call(NoParams params) =>
      _repository.getSubjects();
}
