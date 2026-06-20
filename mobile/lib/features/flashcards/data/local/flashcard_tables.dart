import 'package:drift/drift.dart';

class FlashcardsLocalTable extends Table {
  @override
  String get tableName => 'flashcards_local';

  TextColumn get id => text()();
  TextColumn get deckId => text()();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get hint => text().nullable()();
  RealColumn get easeFactor =>
      real().withDefault(const Constant(2.5))();
  IntColumn get interval =>
      integer().withDefault(const Constant(1))();
  IntColumn get repetitions =>
      integer().withDefault(const Constant(0))();
  // FSRS scheduler state (null until the card's first FSRS review; legacy
  // SM-2 cards are seeded from easeFactor/interval on that first review).
  RealColumn get stability => real().nullable()();
  RealColumn get difficulty => real().nullable()();
  DateTimeColumn get nextReviewAt => dateTime().nullable()();
  DateTimeColumn get lastStudiedAt => dateTime().nullable()();
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isDifficult =>
      boolean().withDefault(const Constant(false))();
  IntColumn get againCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PendingGradesTable extends Table {
  @override
  String get tableName => 'pending_grades';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardId => text()();
  TextColumn get deckId => text()();
  IntColumn get grade => integer()();
  RealColumn get newEaseFactor => real()();
  IntColumn get newInterval => integer()();
  IntColumn get newRepetitions => integer()();
  RealColumn get newStability => real().nullable()();
  RealColumn get newDifficulty => real().nullable()();
  DateTimeColumn get nextReviewAt => dateTime()();
  DateTimeColumn get gradedAt => dateTime()();
  BoolColumn get synced =>
      boolean().withDefault(const Constant(false))();
}

class StudySessionsLocalTable extends Table {
  @override
  String get tableName => 'study_sessions_local';

  TextColumn get id => text()();
  TextColumn get deckId => text()();
  IntColumn get totalCards => integer()();
  IntColumn get newCards => integer()();
  IntColumn get reviewCards => integer()();
  IntColumn get againCount => integer()();
  IntColumn get hardCount => integer()();
  IntColumn get goodCount => integer()();
  IntColumn get easyCount => integer()();
  IntColumn get durationSeconds => integer()();
  DateTimeColumn get completedAt => dateTime()();
  BoolColumn get synced =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
