import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/features/flashcards/data/dto/flashcard_dto.dart';
import 'package:quizaipro_mobile/features/flashcards/data/dto/grade_request_dto.dart';
import 'package:quizaipro_mobile/features/flashcards/data/dto/session_request_dto.dart';

abstract interface class FlashcardRemoteDataSource {
  Future<List<FlashcardDto>> getCardsForDeck(String deckId);
  Future<void> gradeCard(GradeRequestDto dto);
  Future<void> saveSession(SessionRequestDto dto);
  Future<FlashcardDto> createCard(
      String deckId, String front, String back, String note);
  Future<FlashcardDto> updateCard(
      String deckId, String cardId, String front, String back, String note);
  Future<void> deleteCard(String deckId, String cardId);
}

class FlashcardRemoteDataSourceImpl implements FlashcardRemoteDataSource {
  FlashcardRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<FlashcardDto>> getCardsForDeck(String deckId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/decks/$deckId/cards',
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(FlashcardDto.fromJson)
        .toList();
  }

  @override
  Future<void> gradeCard(GradeRequestDto dto) async {
    print('DEBUG: gradeCard payload = ${dto.toJson()}');
    try {
      final response = await _dio.post<void>(
        '/study/grade',
        data: dto.toJson(),
      );
      print('DEBUG: gradeCard success, status = ${response.statusCode}');
    } catch (e) {
      print('DEBUG: gradeCard error = $e');
      rethrow;
    }
  }

  @override
  Future<void> saveSession(SessionRequestDto dto) async {
    await _dio.post<void>(
      '/study/sessions',
      data: dto.toJson(),
    );
  }

  @override
  Future<FlashcardDto> createCard(
      String deckId, String front, String back, String note) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/decks/$deckId/cards',
      data: {'front': front, 'back': back, 'note': note},
    );
    return FlashcardDto.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<FlashcardDto> updateCard(
      String deckId, String cardId, String front, String back, String note) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/decks/$deckId/cards/$cardId',
      data: {'front': front, 'back': back, 'note': note},
    );
    return FlashcardDto.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCard(String deckId, String cardId) async {
    await _dio.delete<void>('/decks/$deckId/cards/$cardId');
  }
}
