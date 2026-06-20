import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/storage/drift/app_database.dart';
import 'package:quizaipro_mobile/features/ai_generation/data/dto/generation_job_dto.dart';
import 'package:quizaipro_mobile/features/ai_generation/data/local/generation_local_data_source.dart';
import 'package:quizaipro_mobile/features/ai_generation/data/remote/ai_generation_remote_data_source.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/deck_summary.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/find_answers_result.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generated_card.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_job.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_source.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_status.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/quality_mode.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';

class AiGenerationRepositoryImpl implements AiGenerationRepository {
  AiGenerationRepositoryImpl({
    required AiGenerationRemoteDataSource remoteDataSource,
    required GenerationLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final AiGenerationRemoteDataSource _remote;
  final GenerationLocalDataSource _local;

  // ── Generate ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, GenerationJob>> generateFromTopic({
    required String topic,
    required int cardCount,
    required QualityMode qualityMode,
  }) =>
      _runJobRequest(() => _remote.generateFromTopic(
            topic: topic,
            cardCount: cardCount,
            qualityMode: qualityMode.name,
          ));

  @override
  Future<Either<Failure, GenerationJob>> generateFromText({
    required String text,
    required int cardCount,
    required QualityMode qualityMode,
  }) =>
      _runJobRequest(() => _remote.generateFromText(
            text: text,
            cardCount: cardCount,
            qualityMode: qualityMode.name,
          ));

  @override
  Future<Either<Failure, GenerationJob>> generateFromPdf({
    required String filePath,
    required String fileName,
    required int cardCount,
    required QualityMode qualityMode,
  }) =>
      _runJobRequest(() => _remote.generateFromPdf(
            filePath: filePath,
            fileName: fileName,
            cardCount: cardCount,
            qualityMode: qualityMode.name,
          ));

  Future<Either<Failure, GenerationJob>> _runJobRequest(
      Future<GenerationJobDto> Function() call) async {
    try {
      final dto = await call();
      final job = _dtoToJob(dto);
      await _saveJobLocally(dto);
      return Right(job);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  // ── Job Status ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, GenerationJob>> getJobStatus(String jobId) async {
    try {
      final dto = await _remote.getJobStatus(jobId);
      final job = _dtoToJob(dto);
      await _local.updateJobStatus(
        jobId: jobId,
        status: dto.status,
        progress: dto.progress,
        generatedCardsJson: dto.cards.isEmpty
            ? null
            : jsonEncode(dto.cards.map((c) => _cardDtoToJson(c)).toList()),
        errorMessage: dto.errorMessage,
        completedAt: dto.completedAt,
      );
      return Right(job);
    } on DioException catch (e) {
      // Serve local cache on network failure
      try {
        final row = await _local.getJob(jobId);
        if (row != null) return Right(_rowToJob(row));
      } catch (_) {}
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  // ── History ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<GenerationJob>>> getHistory() async {
    try {
      final dtos = await _remote.getHistory();
      for (final d in dtos) {
        await _saveJobLocally(d);
      }
      return Right(dtos.map(_dtoToJob).toList());
    } on DioException catch (_) {
      try {
        final rows = await _local.getHistory();
        return Right(rows.map(_rowToJob).toList());
      } catch (e) {
        return Left(Failure.cache(message: e.toString()));
      }
    } catch (e) {
      try {
        final rows = await _local.getHistory();
        return Right(rows.map(_rowToJob).toList());
      } catch (_) {
        return Left(Failure.unknown(message: e.toString()));
      }
    }
  }

  // ── Save Cards ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> saveGeneratedCards({
    required String deckId,
    required List<GeneratedCard> cards,
  }) async {
    try {
      await _remote.saveGeneratedCards(
        deckId: deckId,
        cards: cards.map(_cardToJson).toList(),
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  // ── Deck Management ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, DeckSummary>> createDeck(String title) async {
    try {
      final dto = await _remote.createDeck(title);
      return Right(DeckSummary(
          id: dto.id, title: dto.title, cardCount: dto.cardCount));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DeckSummary>>> getUserDecks() async {
    try {
      final dtos = await _remote.getUserDecks();
      return Right(dtos
          .map((d) =>
              DeckSummary(id: d.id, title: d.title, cardCount: d.cardCount))
          .toList());
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  // ── AI Features ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, FindAnswersResult>> findAnswers({
    required String question,
    String? deckId,
  }) async {
    try {
      final dto = await _remote.findAnswers(question: question, deckId: deckId);
      return Right(FindAnswersResult(
        question: dto.question,
        explanation: dto.explanation,
        keyPoints: dto.keyPoints,
      ));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> explainCard({
    required String question,
    required String answer,
    String? deckId,
  }) async {
    try {
      final explanation = await _remote.explainCard(
          question: question, answer: answer, deckId: deckId);
      return Right(explanation);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _saveJobLocally(GenerationJobDto dto) =>
      _local.saveJob(GenerationJobsLocalTableCompanion(
        id: Value(dto.id),
        source: Value(dto.source),
        status: Value(dto.status),
        progress: Value(dto.progress),
        topic: Value(dto.topic),
        inputText: Value(dto.inputText),
        pdfFileName: Value(dto.pdfFileName),
        qualityMode: Value(dto.qualityMode),
        requestedCardCount: Value(dto.requestedCardCount),
        generatedCardsJson: Value(dto.cards.isEmpty
            ? null
            : jsonEncode(dto.cards.map((c) => _cardDtoToJson(c)).toList())),
        errorMessage: Value(dto.errorMessage),
        createdAt: Value(dto.createdAt),
        completedAt: Value(dto.completedAt),
      ));

  GenerationJob _dtoToJob(GenerationJobDto dto) => GenerationJob(
        id: dto.id,
        source: _parseSource(dto.source),
        status: _parseStatus(dto.status),
        progress: dto.progress,
        topic: dto.topic,
        inputText: dto.inputText,
        pdfFileName: dto.pdfFileName,
        qualityMode: _parseQualityMode(dto.qualityMode),
        requestedCardCount: dto.requestedCardCount,
        cards: dto.cards
            .map((c) => GeneratedCard(
                  question: c.question,
                  answer: c.answer,
                  topic: c.topic,
                  difficulty: c.difficulty,
                ))
            .toList(),
        errorMessage: dto.errorMessage,
        createdAt: dto.createdAt,
        completedAt: dto.completedAt,
      );

  GenerationJob _rowToJob(GenerationJobsLocalTableData row) {
    final List<GeneratedCard> cards = [];
    if (row.generatedCardsJson != null) {
      try {
        final list = jsonDecode(row.generatedCardsJson!) as List<dynamic>;
        for (final e in list) {
          final m = e as Map<String, dynamic>;
          cards.add(GeneratedCard(
            question: m['question'] as String,
            answer: m['answer'] as String,
            topic: (m['topic'] as String?) ?? '',
            difficulty: (m['difficulty'] as String?) ?? 'medium',
          ));
        }
      } catch (_) {}
    }
    return GenerationJob(
      id: row.id,
      source: _parseSource(row.source),
      status: _parseStatus(row.status),
      progress: row.progress,
      topic: row.topic,
      inputText: row.inputText,
      pdfFileName: row.pdfFileName,
      qualityMode: _parseQualityMode(row.qualityMode),
      requestedCardCount: row.requestedCardCount,
      cards: cards,
      errorMessage: row.errorMessage,
      createdAt: row.createdAt,
      completedAt: row.completedAt,
    );
  }

  Map<String, dynamic> _cardDtoToJson(GeneratedCardDto c) => {
        'question': c.question,
        'answer': c.answer,
        'topic': c.topic,
        'difficulty': c.difficulty,
      };

  Map<String, dynamic> _cardToJson(GeneratedCard c) => {
        'question': c.question,
        'answer': c.answer,
        'topic': c.topic,
        'difficulty': c.difficulty,
      };

  GenerationSource _parseSource(String s) =>
      GenerationSource.values.firstWhere((e) => e.name == s,
          orElse: () => GenerationSource.topic);

  GenerationStatus _parseStatus(String s) =>
      GenerationStatus.values.firstWhere((e) => e.name == s,
          orElse: () => GenerationStatus.pending);

  QualityMode _parseQualityMode(String s) =>
      QualityMode.values.firstWhere((e) => e.name == s,
          orElse: () => QualityMode.balanced);

  Failure _fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Failure.network(message: 'No internet connection.');
    }
    final status = e.response?.statusCode;
    if (status == 401) return const Failure.unauthorized();
    if (status == 429) {
      return const Failure.rateLimited(message: 'Too many requests. Wait a moment.');
    }
    if (status == 503) {
      return const Failure.aiUnavailable();
    }
    return Failure.server(
      code: status?.toString() ?? 'unknown',
      message: e.response?.data?['message']?.toString() ??
          'Server error. Please try again.',
    );
  }
}
