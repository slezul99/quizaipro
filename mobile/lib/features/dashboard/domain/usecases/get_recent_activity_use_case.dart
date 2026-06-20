import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/activity_item.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetActivityParams {
  const GetActivityParams({this.limit = 10});
  final int limit;
}

class GetRecentActivityUseCase implements UseCase<List<ActivityItem>, GetActivityParams> {
  const GetRecentActivityUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<ActivityItem>>> call(GetActivityParams params) =>
      _repository.getRecentActivity(limit: params.limit);
}
