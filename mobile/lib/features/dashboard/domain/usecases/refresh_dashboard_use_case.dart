import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

class RefreshDashboardUseCase implements UseCase<DashboardSummary, NoParams> {
  const RefreshDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, DashboardSummary>> call(NoParams params) =>
      _repository.refreshDashboardSummary();
}
