import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/storage/drift/app_database.dart';
import 'package:quizaipro_mobile/features/tests/data/dto/test_result_request_dto.dart';
import 'package:quizaipro_mobile/features/tests/data/local/test_local_data_source.dart';
import 'package:quizaipro_mobile/features/tests/data/remote/test_remote_data_source.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_answer.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_history_item.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_option.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_result.dart';
import 'package:quizaipro_mobile/features/tests/domain/repositories/test_repository.dart';

class TestRepositoryImpl implements TestRepository {
  TestRepositoryImpl({
    required TestRemoteDataSource remoteDataSource,
    required TestLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final TestRemoteDataSource _remote;
  final TestLocalDataSource _local;

  static String _generateId() {
    final rand = Random.secure();
    return List.generate(32, (_) => rand.nextInt(16).toRadixString(16))
        .join();
  }

  @override
  Future<Either<Failure, List<TestQuestion>>> getQuestionsForDeck(
    String deckId,
  ) async {
    final hasLocal = await _local.hasQuestionsForDeck(deckId);

    if (hasLocal) {
      try {
        final rows = await _local.getQuestionsForDeck(deckId);
        return Right(rows.map(_rowToQuestion).toList());
      } catch (_) {}
    }

    try {
      final dtos = await _remote.getQuestionsForDeck(deckId);
      final companions = dtos
          .map(
            (d) => TestQuestionsLocalTableCompanion(
              id: Value(d.id),
              deckId: Value(d.deckId),
              question: Value(d.question),
              correctAnswer: Value(d.correctAnswer),
              optionsJson: Value(jsonEncode(
                d.options.map((o) => o.toJson()).toList(),
              )),
              topic: Value(d.topic),
              cachedAt: Value(DateTime.now()),
            ),
          )
          .toList();
      await _local.cacheQuestions(companions);
      return Right(dtos
          .map(
            (d) => TestQuestion(
              id: d.id,
              deckId: d.deckId,
              question: d.question,
              correctAnswer: d.correctAnswer,
              options: d.options
                  .map((o) => TestOption(
                        id: o.id,
                        text: o.text,
                        isCorrect: o.isCorrect,
                      ))
                  .toList(),
              topic: d.topic,
            ),
          )
          .toList());
    } on DioException catch (e) {
      if (hasLocal) {
        final rows = await _local.getQuestionsForDeck(deckId);
        return Right(rows.map(_rowToQuestion).toList());
      }
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveResult(TestResult result) async {
    final resultId = result.id.isEmpty ? _generateId() : result.id;

    try {
      await _local.saveResult(TestResultsLocalTableCompanion(
        id: Value(resultId),
        deckId: Value(result.deckId),
        deckTitle: Value(result.deckTitle),
        totalQuestions: Value(result.totalQuestions),
        correctCount: Value(result.correctCount),
        durationSeconds: Value(result.durationSeconds),
        answersJson: Value(jsonEncode(
          result.answers.map(_answerToJson).toList(),
        )),
        questionsJson: Value(jsonEncode(
          result.questions.map(_questionToJson).toList(),
        )),
        completedAt: Value(result.completedAt),
      ));

      try {
        await _remote.submitResult(TestResultRequestDto(
          id: resultId,
          deckId: result.deckId,
          totalQuestions: result.totalQuestions,
          correctCount: result.correctCount,
          durationSeconds: result.durationSeconds,
          completedAt: result.completedAt,
          answers: _buildAnswerDtos(result.answers, result.questions),
        ));
        await _local.markResultSynced(resultId);
      } catch (_) {
        // Queued locally; will sync later.
      }

      return const Right(unit);
    } catch (e) {
      return Left(Failure.cache(message: 'Failed to save test result.'));
    }
  }

  @override
  Future<Either<Failure, List<TestHistoryItem>>> getTestHistory(
    String deckId,
  ) async {
    try {
      final rows = await _local.getTestHistory(deckId);
      if (rows.isNotEmpty) {
        return Right(rows.map(_rowToHistoryItem).toList());
      }
    } catch (_) {}

    try {
      final dtos = await _remote.getTestHistory(deckId);
      return Right(dtos
          .map(
            (d) => TestHistoryItem(
              id: d.id,
              deckId: d.deckId,
              deckTitle: d.deckTitle,
              totalQuestions: d.totalQuestions,
              correctCount: d.correctCount,
              durationSeconds: d.durationSeconds,
              completedAt: d.completedAt,
            ),
          )
          .toList());
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> syncPendingResults() async {
    try {
      int synced = 0;
      final pending = await _local.getUnsyncedResults();
      for (final r in pending) {
        try {
          await _remote.submitResult(TestResultRequestDto(
            id: r.id,
            deckId: r.deckId,
            totalQuestions: r.totalQuestions,
            correctCount: r.correctCount,
            durationSeconds: r.durationSeconds,
            completedAt: r.completedAt,
            answers: _buildAnswerDtos(
              _parseAnswers(r.answersJson),
              _parseQuestions(r.questionsJson),
            ),
          ));
          await _local.markResultSynced(r.id);
          synced++;
        } catch (_) {
          continue;
        }
      }
      return Right(synced);
    } catch (e) {
      return Left(const Failure.unknown());
    }
  }

  TestQuestion _rowToQuestion(TestQuestionsLocalTableData row) {
    final optList =
        (jsonDecode(row.optionsJson) as List<dynamic>).cast<Map<String, dynamic>>();
    return TestQuestion(
      id: row.id,
      deckId: row.deckId,
      question: row.question,
      correctAnswer: row.correctAnswer,
      options: optList
          .map(
            (o) => TestOption(
              id: o['id'] as String,
              text: o['text'] as String,
              isCorrect: o['is_correct'] as bool,
            ),
          )
          .toList(),
      topic: row.topic,
    );
  }

  TestHistoryItem _rowToHistoryItem(TestResultsLocalTableData row) =>
      TestHistoryItem(
        id: row.id,
        deckId: row.deckId,
        deckTitle: row.deckTitle,
        totalQuestions: row.totalQuestions,
        correctCount: row.correctCount,
        durationSeconds: row.durationSeconds,
        completedAt: row.completedAt,
      );

  /// Builds the per-question payload persisted into `test_attempt_answers`.
  /// `chosen`/`correct` are option letters (the backend stores option ids as
  /// letters); `note` re-serialises the options so the dashboard can map a
  /// letter back to its text when rendering recent activity.
  List<TestAnswerRequestDto> _buildAnswerDtos(
    List<TestAnswer> answers,
    List<TestQuestion> questions,
  ) {
    final qById = {for (final q in questions) q.id: q};
    final dtos = <TestAnswerRequestDto>[];
    var pos = 1;
    for (final a in answers) {
      final q = qById[a.questionId];
      if (q == null) continue;
      final correctLetter =
          q.options.where((o) => o.isCorrect).firstOrNull?.id ?? '';
      final note = q.options.map((o) => '${o.id}) ${o.text}').join('\n');
      dtos.add(TestAnswerRequestDto(
        position: pos++,
        cardId: int.tryParse(q.id),
        front: q.question,
        back: q.correctAnswer,
        note: note,
        chosen: a.selectedOptionId ?? '',
        correct: correctLetter,
        isCorrect: a.isCorrect,
      ));
    }
    return dtos;
  }

  List<TestAnswer> _parseAnswers(String json) {
    final list = (jsonDecode(json) as List<dynamic>).cast<Map<String, dynamic>>();
    return list
        .map(
          (a) => TestAnswer(
            questionId: a['questionId'] as String,
            selectedOptionId: a['selectedOptionId'] as String?,
            isCorrect: a['isCorrect'] as bool,
            answeredAt: DateTime.parse(a['answeredAt'] as String),
          ),
        )
        .toList();
  }

  List<TestQuestion> _parseQuestions(String json) {
    final list = (jsonDecode(json) as List<dynamic>).cast<Map<String, dynamic>>();
    return list
        .map(
          (q) => TestQuestion(
            id: q['id'] as String,
            deckId: q['deckId'] as String,
            question: q['question'] as String,
            correctAnswer: q['correctAnswer'] as String,
            options: (q['options'] as List<dynamic>)
                .cast<Map<String, dynamic>>()
                .map(
                  (o) => TestOption(
                    id: o['id'] as String,
                    text: o['text'] as String,
                    isCorrect: o['isCorrect'] as bool,
                  ),
                )
                .toList(),
            topic: q['topic'] as String?,
          ),
        )
        .toList();
  }

  Map<String, dynamic> _questionToJson(TestQuestion q) => {
        'id': q.id,
        'deckId': q.deckId,
        'question': q.question,
        'correctAnswer': q.correctAnswer,
        'options': q.options
            .map((o) => {
                  'id': o.id,
                  'text': o.text,
                  'isCorrect': o.isCorrect,
                })
            .toList(),
        'topic': q.topic,
      };

  Map<String, dynamic> _answerToJson(TestAnswer a) => {
        'questionId': a.questionId,
        'selectedOptionId': a.selectedOptionId,
        'isCorrect': a.isCorrect,
        'answeredAt': a.answeredAt.toIso8601String(),
      };

  Failure _fromDio(DioException e) {
    if (e.error is Failure) return e.error as Failure;
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      return Failure.network(
        message: e.message ?? 'No internet connection.',
      );
    }
    if (e.response?.statusCode == 401) return const Failure.unauthorized();
    if (e.response?.statusCode == 429) {
      return Failure.rateLimited(message: e.message ?? 'Too many requests.');
    }
    return Failure.server(
      code: e.response?.statusCode?.toString() ?? 'unknown',
      message: e.message ?? 'Server error.',
    );
  }
}
