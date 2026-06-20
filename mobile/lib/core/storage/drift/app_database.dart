import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/features/flashcards/data/local/flashcard_tables.dart';
import 'package:quizaipro_mobile/features/tests/data/local/test_tables.dart';
import 'package:quizaipro_mobile/features/ai_generation/data/local/generation_tables.dart';
import 'package:quizaipro_mobile/features/tutor/data/local/tutor_tables.dart';

part 'app_database.g.dart';

// Tables are registered here as features are implemented.
// Each feature adds its table definitions to this list and increments
// schemaVersion with a corresponding MigrationStrategy step.

@DriftDatabase(tables: [
  FlashcardsLocalTable,
  PendingGradesTable,
  StudySessionsLocalTable,
  TestQuestionsLocalTable,
  TestResultsLocalTable,
  ConversationsLocalTable,
  TutorMessagesLocalTable,
  GenerationJobsLocalTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String dbDirectory)
      : super(_openConnection(dbDirectory));

  @override
  int get schemaVersion => AppConstants.driftDbVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(flashcardsLocalTable);
            await m.createTable(pendingGradesTable);
            await m.createTable(studySessionsLocalTable);
          }
          if (from < 3) {
            await m.createTable(testQuestionsLocalTable);
            await m.createTable(testResultsLocalTable);
          }
          if (from < 4) {
            await m.createTable(conversationsLocalTable);
            await m.createTable(tutorMessagesLocalTable);
          }
          if (from < 5) {
            await m.createTable(generationJobsLocalTable);
          }
          if (from < 6) {
            // FSRS scheduler state.
            await m.addColumn(flashcardsLocalTable, flashcardsLocalTable.stability);
            await m.addColumn(flashcardsLocalTable, flashcardsLocalTable.difficulty);
            await m.addColumn(pendingGradesTable, pendingGradesTable.newStability);
            await m.addColumn(pendingGradesTable, pendingGradesTable.newDifficulty);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );

  static QueryExecutor _openConnection(String dbDirectory) {
    return NativeDatabase.createInBackground(
      File(p.join(dbDirectory, AppConstants.driftDbFileName)),
      logStatements: false,
    );
  }
}
