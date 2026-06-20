import 'package:drift/drift.dart';

class TestQuestionsLocalTable extends Table {
  @override
  String get tableName => 'test_questions_local';

  TextColumn get id => text()();
  TextColumn get deckId => text()();
  TextColumn get question => text()();
  TextColumn get correctAnswer => text()();
  TextColumn get optionsJson => text()();
  TextColumn get topic => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class TestResultsLocalTable extends Table {
  @override
  String get tableName => 'test_results_local';

  TextColumn get id => text()();
  TextColumn get deckId => text()();
  TextColumn get deckTitle => text()();
  IntColumn get totalQuestions => integer()();
  IntColumn get correctCount => integer()();
  IntColumn get durationSeconds => integer()();
  TextColumn get answersJson => text()();
  TextColumn get questionsJson => text()();
  DateTimeColumn get completedAt => dateTime()();
  BoolColumn get synced =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
