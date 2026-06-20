import 'package:drift/drift.dart';

import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/core/storage/drift/app_database.dart';

abstract interface class FlashcardLocalDataSource {
  Future<bool> hasCardsForDeck(String deckId);
  Future<List<FlashcardsLocalTableData>> getCardsForDeck(String deckId);
  Future<void> upsertCards(List<FlashcardsLocalTableCompanion> cards);
  Future<void> deleteCard(String cardId);
  Future<void> updateCardSm2({
    required String cardId,
    required double easeFactor,
    required double stability,
    required double difficulty,
    required int interval,
    required int repetitions,
    required DateTime nextReviewAt,
    required DateTime lastStudiedAt,
    required int againCount,
  });
  Future<void> toggleFavorite(String cardId, {required bool isFavorite});
  Future<int> insertPendingGrade(PendingGradesTableCompanion grade);
  Future<List<PendingGradesTableData>> getUnsyncedGrades();
  Future<void> markGradeSynced(int id);
  Future<void> saveSession(StudySessionsLocalTableCompanion session);
  Future<List<StudySessionsLocalTableData>> getUnsyncedSessions();
  Future<void> markSessionSynced(String id);
}

class FlashcardLocalDataSourceImpl implements FlashcardLocalDataSource {
  FlashcardLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<bool> hasCardsForDeck(String deckId) async {
    final query = _db.selectOnly(_db.flashcardsLocalTable)
      ..addColumns([_db.flashcardsLocalTable.id])
      ..limit(1);

    if (deckId.isNotEmpty) {
      query.where(_db.flashcardsLocalTable.deckId.equals(deckId));
    }

    final count = await query.get();
    return count.isNotEmpty;
  }

  @override
  Future<List<FlashcardsLocalTableData>> getCardsForDeck(
    String deckId,
  ) {
    final query = _db.select(_db.flashcardsLocalTable);
    if (deckId.isNotEmpty) {
      query.where((t) => t.deckId.equals(deckId));
    }
    return query.get();
  }

  @override
  Future<void> upsertCards(
    List<FlashcardsLocalTableCompanion> cards,
  ) =>
      _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.flashcardsLocalTable, cards);
      });

  @override
  Future<void> deleteCard(String cardId) =>
      (_db.delete(_db.flashcardsLocalTable)
            ..where((t) => t.id.equals(cardId)))
          .go();

  @override
  Future<void> updateCardSm2({
    required String cardId,
    required double easeFactor,
    required double stability,
    required double difficulty,
    required int interval,
    required int repetitions,
    required DateTime nextReviewAt,
    required DateTime lastStudiedAt,
    required int againCount,
  }) {
    // Difficulty flag now reads the FSRS difficulty (1..10, higher = harder).
    final isDifficult =
        difficulty >= AppConstants.srsDifficultFsrsThreshold ||
            againCount >= AppConstants.srsDifficultAgainThreshold;
    return (_db.update(_db.flashcardsLocalTable)
          ..where((t) => t.id.equals(cardId)))
        .write(FlashcardsLocalTableCompanion(
      easeFactor: Value(easeFactor),
      stability: Value(stability),
      difficulty: Value(difficulty),
      interval: Value(interval),
      repetitions: Value(repetitions),
      nextReviewAt: Value(nextReviewAt),
      lastStudiedAt: Value(lastStudiedAt),
      isDifficult: Value(isDifficult),
      againCount: Value(againCount),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> toggleFavorite(
    String cardId, {
    required bool isFavorite,
  }) =>
      (_db.update(_db.flashcardsLocalTable)
            ..where((t) => t.id.equals(cardId)))
          .write(FlashcardsLocalTableCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(DateTime.now()),
      ));

  @override
  Future<int> insertPendingGrade(PendingGradesTableCompanion grade) =>
      _db.into(_db.pendingGradesTable).insert(grade);

  @override
  Future<List<PendingGradesTableData>> getUnsyncedGrades() =>
      (_db.select(_db.pendingGradesTable)
            ..where((t) => t.synced.equals(false)))
          .get();

  @override
  Future<void> markGradeSynced(int id) =>
      (_db.update(_db.pendingGradesTable)
            ..where((t) => t.id.equals(id)))
          .write(const PendingGradesTableCompanion(
        synced: Value(true),
      ));

  @override
  Future<void> saveSession(StudySessionsLocalTableCompanion session) =>
      _db
          .into(_db.studySessionsLocalTable)
          .insertOnConflictUpdate(session);

  @override
  Future<List<StudySessionsLocalTableData>> getUnsyncedSessions() =>
      (_db.select(_db.studySessionsLocalTable)
            ..where((t) => t.synced.equals(false)))
          .get();

  @override
  Future<void> markSessionSynced(String id) =>
      (_db.update(_db.studySessionsLocalTable)
            ..where((t) => t.id.equals(id)))
          .write(const StudySessionsLocalTableCompanion(
        synced: Value(true),
      ));
}
