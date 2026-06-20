import 'package:drift/drift.dart';

import 'package:quizaipro_mobile/core/storage/drift/app_database.dart';

abstract interface class GenerationLocalDataSource {
  Future<void> saveJob(GenerationJobsLocalTableCompanion companion);
  Future<GenerationJobsLocalTableData?> getJob(String jobId);
  Future<List<GenerationJobsLocalTableData>> getHistory();
  Future<void> updateJobStatus({
    required String jobId,
    required String status,
    required int progress,
    String? generatedCardsJson,
    String? errorMessage,
    DateTime? completedAt,
  });
}

class GenerationLocalDataSourceImpl implements GenerationLocalDataSource {
  GenerationLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> saveJob(GenerationJobsLocalTableCompanion companion) =>
      _db.into(_db.generationJobsLocalTable).insertOnConflictUpdate(companion);

  @override
  Future<GenerationJobsLocalTableData?> getJob(String jobId) =>
      (_db.select(_db.generationJobsLocalTable)
            ..where((t) => t.id.equals(jobId)))
          .getSingleOrNull();

  @override
  Future<List<GenerationJobsLocalTableData>> getHistory() =>
      (_db.select(_db.generationJobsLocalTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  @override
  Future<void> updateJobStatus({
    required String jobId,
    required String status,
    required int progress,
    String? generatedCardsJson,
    String? errorMessage,
    DateTime? completedAt,
  }) =>
      (_db.update(_db.generationJobsLocalTable)
            ..where((t) => t.id.equals(jobId)))
          .write(GenerationJobsLocalTableCompanion(
        status: Value(status),
        progress: Value(progress),
        generatedCardsJson: Value(generatedCardsJson),
        errorMessage: Value(errorMessage),
        completedAt: Value(completedAt),
      ));
}
