import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/features/tests/domain/entities/followup_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/mistake_diagnosis.dart';

abstract interface class DiagnosisRemoteDataSource {
  Future<MistakeDiagnosis> diagnose({
    required String question,
    required String chosen,
    required String correct,
  });

  Future<FollowupQuestion> followup({
    required String question,
    required String correct,
    String? misconception,
  });
}

class DiagnosisRemoteDataSourceImpl implements DiagnosisRemoteDataSource {
  DiagnosisRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<MistakeDiagnosis> diagnose({
    required String question,
    required String chosen,
    required String correct,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/tutor/diagnose',
      data: {'question': question, 'chosen': chosen, 'correct': correct},
    );
    return MistakeDiagnosis.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<FollowupQuestion> followup({
    required String question,
    required String correct,
    String? misconception,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/tutor/followup',
      data: {
        'question': question,
        'correct': correct,
        if (misconception != null && misconception.isNotEmpty)
          'misconception': misconception,
      },
    );
    return FollowupQuestion.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }
}
