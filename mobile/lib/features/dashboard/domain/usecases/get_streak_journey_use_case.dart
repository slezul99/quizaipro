import 'package:fpdart/fpdart.dart';
import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_journey.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetStreakJourneyUseCase implements UseCase<StreakJourney, NoParams> {
  const GetStreakJourneyUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, StreakJourney>> call(NoParams params) =>
      _repository.getStreakJourney();
}
