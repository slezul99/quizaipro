import 'package:fpdart/fpdart.dart';
import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/level_journey.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetLevelJourneyUseCase implements UseCase<LevelJourney, NoParams> {
  const GetLevelJourneyUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, LevelJourney>> call(NoParams params) =>
      _repository.getLevelJourney();
}
