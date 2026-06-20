import 'package:drift/drift.dart';

import 'package:quizaipro_mobile/core/storage/drift/app_database.dart';

abstract interface class TestLocalDataSource {
  Future<bool> hasQuestionsForDeck(String deckId);
  Future<List<TestQuestionsLocalTableData>> getQuestionsForDeck(
    String deckId,
  );
  Future<void> cacheQuestions(
    List<TestQuestionsLocalTableCompanion> questions,
  );
  Future<void> saveResult(TestResultsLocalTableCompanion result);
  Future<List<TestResultsLocalTableData>> getTestHistory(String deckId);
  Future<List<TestResultsLocalTableData>> getUnsyncedResults();
  Future<void> markResultSynced(String id);
}

class TestLocalDataSourceImpl implements TestLocalDataSource {
  TestLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<bool> hasQuestionsForDeck(String deckId) async {
    final rows = await (_db.selectOnly(_db.testQuestionsLocalTable)
          ..addColumns([_db.testQuestionsLocalTable.id])
          ..where(_db.testQuestionsLocalTable.deckId.equals(deckId))
          ..limit(1))
        .get();
    return rows.isNotEmpty;
  }

  @override
  Future<List<TestQuestionsLocalTableData>> getQuestionsForDeck(
    String deckId,
  ) =>
      (_db.select(_db.testQuestionsLocalTable)
            ..where((t) => t.deckId.equals(deckId)))
          .get();

  @override
  Future<void> cacheQuestions(
    List<TestQuestionsLocalTableCompanion> questions,
  ) =>
      _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.testQuestionsLocalTable,
          questions,
        );
      });

  @override
  Future<void> saveResult(TestResultsLocalTableCompanion result) =>
      _db
          .into(_db.testResultsLocalTable)
          .insertOnConflictUpdate(result);

  @override
  Future<List<TestResultsLocalTableData>> getTestHistory(
    String deckId,
  ) =>
      (_db.select(_db.testResultsLocalTable)
            ..where((t) => t.deckId.equals(deckId))
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
          .get();

  @override
  Future<List<TestResultsLocalTableData>> getUnsyncedResults() =>
      (_db.select(_db.testResultsLocalTable)
            ..where((t) => t.synced.equals(false)))
          .get();

  @override
  Future<void> markResultSynced(String id) =>
      (_db.update(_db.testResultsLocalTable)
            ..where((t) => t.id.equals(id)))
          .write(const TestResultsLocalTableCompanion(
        synced: Value(true),
      ));
}
