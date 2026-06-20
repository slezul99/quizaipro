import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/features/ai_generation/data/dto/deck_summary_dto.dart';
import 'package:quizaipro_mobile/features/ai_generation/data/dto/find_answers_result_dto.dart';
import 'package:quizaipro_mobile/features/ai_generation/data/dto/generation_job_dto.dart';

abstract interface class AiGenerationRemoteDataSource {
  Future<GenerationJobDto> generateFromTopic({
    required String topic,
    required int cardCount,
    required String qualityMode,
  });

  Future<GenerationJobDto> generateFromText({
    required String text,
    required int cardCount,
    required String qualityMode,
  });

  Future<GenerationJobDto> generateFromPdf({
    required String filePath,
    required String fileName,
    required int cardCount,
    required String qualityMode,
  });

  Future<GenerationJobDto> getJobStatus(String jobId);

  Future<List<GenerationJobDto>> getHistory();

  Future<void> saveGeneratedCards({
    required String deckId,
    required List<Map<String, dynamic>> cards,
  });

  Future<DeckSummaryDto> createDeck(String title);

  Future<FindAnswersResultDto> findAnswers({
    required String question,
    String? deckId,
  });

  Future<String> explainCard({
    required String question,
    required String answer,
    String? deckId,
  });

  Future<List<DeckSummaryDto>> getUserDecks();
}

class AiGenerationRemoteDataSourceImpl
    implements AiGenerationRemoteDataSource {
  AiGenerationRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<GenerationJobDto> generateFromTopic({
    required String topic,
    required int cardCount,
    required String qualityMode,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/ai/generate/topic',
      data: {
        'topic': topic,
        'card_count': cardCount,
        'quality_mode': qualityMode,
      },
    );
    return GenerationJobDto.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<GenerationJobDto> generateFromText({
    required String text,
    required int cardCount,
    required String qualityMode,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/ai/generate/text',
      data: {
        'text': text,
        'card_count': cardCount,
        'quality_mode': qualityMode,
      },
    );
    return GenerationJobDto.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<GenerationJobDto> generateFromPdf({
    required String filePath,
    required String fileName,
    required int cardCount,
    required String qualityMode,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'card_count': cardCount,
      'quality_mode': qualityMode,
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/ai/generate/pdf',
      data: formData,
    );
    return GenerationJobDto.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<GenerationJobDto> getJobStatus(String jobId) async {
    final response = await _dio
        .get<Map<String, dynamic>>('/ai/jobs/$jobId');
    return GenerationJobDto.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<GenerationJobDto>> getHistory() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/ai/jobs');
    final list = response.data!['data'] as List<dynamic>;
    return list
        .map((e) => GenerationJobDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveGeneratedCards({
    required String deckId,
    required List<Map<String, dynamic>> cards,
  }) =>
      _dio.post<void>(
        '/decks/$deckId/cards/bulk',
        data: {'cards': cards},
      );

  @override
  Future<DeckSummaryDto> createDeck(String title) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/decks',
      data: {'title': title},
    );
    return DeckSummaryDto.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<FindAnswersResultDto> findAnswers({
    required String question,
    String? deckId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/ai/find-answers',
      data: {
        'question': question,
        if (deckId != null) 'deck_id': deckId,
      },
    );
    return FindAnswersResultDto.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<String> explainCard({
    required String question,
    required String answer,
    String? deckId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/ai/explain',
      data: {
        'question': question,
        'answer': answer,
        if (deckId != null) 'deck_id': deckId,
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return data['explanation'] as String;
  }

  @override
  Future<List<DeckSummaryDto>> getUserDecks() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/decks');
    final list = response.data!['data'] as List<dynamic>;
    return list
        .map((e) => DeckSummaryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
