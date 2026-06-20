import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/features/tests/data/dto/test_history_dto.dart';
import 'package:quizaipro_mobile/features/tests/data/dto/test_question_dto.dart';
import 'package:quizaipro_mobile/features/tests/data/dto/test_result_request_dto.dart';

abstract interface class TestRemoteDataSource {
  Future<List<TestQuestionDto>> getQuestionsForDeck(String deckId);
  Future<void> submitResult(TestResultRequestDto dto);
  Future<List<TestHistoryDto>> getTestHistory(String deckId);
}

class TestRemoteDataSourceImpl implements TestRemoteDataSource {
  TestRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TestQuestionDto>> getQuestionsForDeck(String deckId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/decks/$deckId/test-questions',
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(TestQuestionDto.fromJson)
        .toList();
  }

  @override
  Future<void> submitResult(TestResultRequestDto dto) async {
    await _dio.post<void>(
      '/test/results',
      data: dto.toJson(),
    );
  }

  @override
  Future<List<TestHistoryDto>> getTestHistory(String deckId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/test/history',
      queryParameters: {'deckId': deckId},
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(TestHistoryDto.fromJson)
        .toList();
  }
}
