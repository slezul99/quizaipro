import 'dart:math';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/storage/drift/app_database.dart';
import 'package:quizaipro_mobile/features/flashcards/data/dto/flashcard_dto.dart';
import 'package:quizaipro_mobile/features/flashcards/data/dto/grade_request_dto.dart';
import 'package:quizaipro_mobile/features/flashcards/data/dto/session_request_dto.dart';
import 'package:quizaipro_mobile/features/flashcards/data/local/flashcard_local_data_source.dart';
import 'package:quizaipro_mobile/features/flashcards/data/remote/flashcard_remote_data_source.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/algorithms/sm2_algorithm.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/card_grade.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/flashcard.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/repositories/flashcard_repository.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  FlashcardRepositoryImpl({
    required FlashcardRemoteDataSource remoteDataSource,
    required FlashcardLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final FlashcardRemoteDataSource _remote;
  final FlashcardLocalDataSource _local;

  static String _generateId() {
    final rand = Random.secure();
    return List.generate(32, (_) => rand.nextInt(16).toRadixString(16)).join();
  }

  @override
  Future<Either<Failure, List<Flashcard>>> getCardsForDeck(
    String deckId,
  ) async {
    final hasLocal = await _local.hasCardsForDeck(deckId);

    if (hasLocal) {
      try {
        final rows = await _local.getCardsForDeck(deckId);
        return Right(rows.map(_rowToFlashcard).toList());
      } catch (_) {}
    }

    try {
      final dtos = await _remote.getCardsForDeck(deckId);
      final companions = dtos
          .map(
            (d) => FlashcardsLocalTableCompanion(
              id: Value(d.id),
              deckId: Value(d.deckId),
              front: Value(d.front),
              back: Value(d.back),
              hint: Value(d.hint),
              easeFactor: Value(d.easeFactor),
              interval: Value(d.interval),
              repetitions: Value(d.repetitions),
              nextReviewAt: Value(d.nextReviewAt),
              lastStudiedAt: Value(d.lastStudiedAt),
              isFavorite: Value(d.isFavorite),
              isDifficult: Value(d.isDifficult),
              againCount: Value(d.againCount),
              updatedAt: Value(d.updatedAt),
            ),
          )
          .toList();
      await _local.upsertCards(companions);
      return Right(dtos
          .map(
            (d) => Flashcard(
              id: d.id,
              deckId: d.deckId,
              front: d.front,
              back: d.back,
              hint: d.hint,
              easeFactor: d.easeFactor,
              interval: d.interval,
              repetitions: d.repetitions,
              stability: d.stability,
              difficulty: d.difficulty,
              nextReviewAt: d.nextReviewAt,
              lastStudiedAt: d.lastStudiedAt,
              isFavorite: d.isFavorite,
              isDifficult: d.isDifficult,
              againCount: d.againCount,
              updatedAt: d.updatedAt,
            ),
          )
          .toList());
    } on DioException catch (e) {
      if (hasLocal) {
        final rows = await _local.getCardsForDeck(deckId);
        return Right(rows.map(_rowToFlashcard).toList());
      }
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> gradeCard({
    required String cardId,
    required String deckId,
    required CardGrade grade,
    required Sm2Result sm2Result,
    required double stability,
    required double difficulty,
    required int newAgainCount,
  }) async {
    try {
      final gradedAt = DateTime.now();
      await _local.updateCardSm2(
        cardId: cardId,
        easeFactor: sm2Result.easeFactor,
        stability: stability,
        difficulty: difficulty,
        interval: sm2Result.interval,
        repetitions: sm2Result.repetitions,
        nextReviewAt: sm2Result.nextReviewAt,
        lastStudiedAt: gradedAt,
        againCount: newAgainCount,
      );

      final pendingId = await _local.insertPendingGrade(
        PendingGradesTableCompanion(
          cardId: Value(cardId),
          deckId: Value(deckId),
          grade: Value(grade.sm2Value),
          newEaseFactor: Value(sm2Result.easeFactor),
          newStability: Value(stability),
          newDifficulty: Value(difficulty),
          newInterval: Value(sm2Result.interval),
          newRepetitions: Value(sm2Result.repetitions),
          nextReviewAt: Value(sm2Result.nextReviewAt),
          gradedAt: Value(gradedAt),
        ),
      );

      try {
        await _remote.gradeCard(GradeRequestDto(
          cardId: cardId,
          deckId: deckId,
          grade: grade.sm2Value,
          newEaseFactor: sm2Result.easeFactor,
          newStability: stability,
          newDifficulty: difficulty,
          newInterval: sm2Result.interval,
          newRepetitions: sm2Result.repetitions,
          nextReviewAt: sm2Result.nextReviewAt,
          gradedAt: gradedAt,
        ));
        await _local.markGradeSynced(pendingId);
      } catch (_) {
        // Grade is queued locally; sync will happen later.
      }

      return const Right(unit);
    } catch (e) {
      return Left(Failure.cache(message: 'Failed to save grade locally.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSession({
    required String deckId,
    required int totalCards,
    required int newCards,
    required int reviewCards,
    required int againCount,
    required int hardCount,
    required int goodCount,
    required int easyCount,
    required int durationSeconds,
  }) async {
    final sessionId = _generateId();
    final completedAt = DateTime.now();

    try {
      await _local.saveSession(StudySessionsLocalTableCompanion(
        id: Value(sessionId),
        deckId: Value(deckId),
        totalCards: Value(totalCards),
        newCards: Value(newCards),
        reviewCards: Value(reviewCards),
        againCount: Value(againCount),
        hardCount: Value(hardCount),
        goodCount: Value(goodCount),
        easyCount: Value(easyCount),
        durationSeconds: Value(durationSeconds),
        completedAt: Value(completedAt),
      ));

      try {
        await _remote.saveSession(SessionRequestDto(
          id: sessionId,
          deckId: deckId,
          totalCards: totalCards,
          newCards: newCards,
          reviewCards: reviewCards,
          againCount: againCount,
          hardCount: hardCount,
          goodCount: goodCount,
          easyCount: easyCount,
          durationSeconds: durationSeconds,
          completedAt: completedAt,
        ));
        await _local.markSessionSynced(sessionId);
      } catch (_) {
        // Session queued locally; sync will happen later.
      }

      return const Right(unit);
    } catch (e) {
      return Left(Failure.cache(message: 'Failed to save session locally.'));
    }
  }

  @override
  Future<Either<Failure, int>> syncPendingGrades() async {
    try {
      int synced = 0;

      final grades = await _local.getUnsyncedGrades();
      for (final g in grades) {
        try {
          await _remote.gradeCard(GradeRequestDto(
            cardId: g.cardId,
            deckId: g.deckId,
            grade: g.grade,
            newEaseFactor: g.newEaseFactor,
            newStability: g.newStability,
            newDifficulty: g.newDifficulty,
            newInterval: g.newInterval,
            newRepetitions: g.newRepetitions,
            nextReviewAt: g.nextReviewAt,
            gradedAt: g.gradedAt,
          ));
          await _local.markGradeSynced(g.id);
          synced++;
        } catch (_) {
          continue;
        }
      }

      final sessions = await _local.getUnsyncedSessions();
      for (final s in sessions) {
        try {
          await _remote.saveSession(SessionRequestDto(
            id: s.id,
            deckId: s.deckId,
            totalCards: s.totalCards,
            newCards: s.newCards,
            reviewCards: s.reviewCards,
            againCount: s.againCount,
            hardCount: s.hardCount,
            goodCount: s.goodCount,
            easyCount: s.easyCount,
            durationSeconds: s.durationSeconds,
            completedAt: s.completedAt,
          ));
          await _local.markSessionSynced(s.id);
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

  @override
  Future<Either<Failure, Unit>> toggleFavorite(
    String cardId, {
    required bool isFavorite,
  }) async {
    try {
      await _local.toggleFavorite(cardId, isFavorite: isFavorite);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.cache(message: 'Failed to update favorite.'));
    }
  }

  @override
  Future<Either<Failure, Flashcard>> createCard({
    required String deckId,
    required String front,
    required String back,
    required String note,
  }) async {
    try {
      final d = await _remote.createCard(deckId, front, back, note);
      await _local.upsertCards([_dtoToCompanion(d)]);
      return Right(_dtoToFlashcard(d));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Flashcard>> updateCard({
    required String deckId,
    required String cardId,
    required String front,
    required String back,
    required String note,
  }) async {
    try {
      final d = await _remote.updateCard(deckId, cardId, front, back, note);
      await _local.upsertCards([_dtoToCompanion(d)]);
      return Right(_dtoToFlashcard(d));
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCard({
    required String deckId,
    required String cardId,
  }) async {
    try {
      await _remote.deleteCard(deckId, cardId);
      await _local.deleteCard(cardId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  Flashcard _dtoToFlashcard(FlashcardDto d) => Flashcard(
        id: d.id,
        deckId: d.deckId,
        front: d.front,
        back: d.back,
        hint: d.hint,
        easeFactor: d.easeFactor,
        interval: d.interval,
        repetitions: d.repetitions,
        nextReviewAt: d.nextReviewAt,
        lastStudiedAt: d.lastStudiedAt,
        isFavorite: d.isFavorite,
        isDifficult: d.isDifficult,
        againCount: d.againCount,
        updatedAt: d.updatedAt,
      );

  FlashcardsLocalTableCompanion _dtoToCompanion(FlashcardDto d) =>
      FlashcardsLocalTableCompanion(
        id: Value(d.id),
        deckId: Value(d.deckId),
        front: Value(d.front),
        back: Value(d.back),
        hint: Value(d.hint),
        easeFactor: Value(d.easeFactor),
        interval: Value(d.interval),
        repetitions: Value(d.repetitions),
        nextReviewAt: Value(d.nextReviewAt),
        lastStudiedAt: Value(d.lastStudiedAt),
        isFavorite: Value(d.isFavorite),
        isDifficult: Value(d.isDifficult),
        againCount: Value(d.againCount),
        updatedAt: Value(d.updatedAt),
      );

  Flashcard _rowToFlashcard(FlashcardsLocalTableData row) => Flashcard(
        id: row.id,
        deckId: row.deckId,
        front: row.front,
        back: row.back,
        hint: row.hint,
        easeFactor: row.easeFactor,
        interval: row.interval,
        repetitions: row.repetitions,
        nextReviewAt: row.nextReviewAt,
        lastStudiedAt: row.lastStudiedAt,
        isFavorite: row.isFavorite,
        isDifficult: row.isDifficult,
        againCount: row.againCount,
        updatedAt: row.updatedAt,
      );

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
      return Failure.rateLimited(
        message: e.message ?? 'Too many requests.',
      );
    }
    return Failure.server(
      code: e.response?.statusCode?.toString() ?? 'unknown',
      message: e.message ?? 'Server error.',
    );
  }
}
