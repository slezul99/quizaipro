import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';

abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract interface class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

final class NoParams {
  const NoParams();
}
