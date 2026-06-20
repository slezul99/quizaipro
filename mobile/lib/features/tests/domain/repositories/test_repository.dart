import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_history_item.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_result.dart';

abstract interface class TestRepository {
  Future<Either<Failure, List<TestQuestion>>> getQuestionsForDeck(
    String deckId,
  );

  Future<Either<Failure, Unit>> saveResult(TestResult result);

  Future<Either<Failure, List<TestHistoryItem>>> getTestHistory(
    String deckId,
  );

  Future<Either<Failure, int>> syncPendingResults();
}
