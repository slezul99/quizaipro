import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/followup_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/mistake_diagnosis.dart';

abstract interface class DiagnosisRepository {
  Future<Either<Failure, MistakeDiagnosis>> diagnose({
    required String question,
    required String chosen,
    required String correct,
  });

  Future<Either<Failure, FollowupQuestion>> followup({
    required String question,
    required String correct,
    String? misconception,
  });
}
