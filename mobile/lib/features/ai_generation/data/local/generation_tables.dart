import 'package:drift/drift.dart';

class GenerationJobsLocalTable extends Table {
  @override
  String get tableName => 'generation_jobs_local';

  TextColumn get id => text()();
  TextColumn get source => text()();
  TextColumn get status => text()();
  IntColumn get progress =>
      integer().withDefault(const Constant(0))();
  TextColumn get topic => text().nullable()();
  TextColumn get inputText => text().nullable()();
  TextColumn get pdfFileName => text().nullable()();
  TextColumn get qualityMode => text()();
  IntColumn get requestedCardCount => integer()();
  TextColumn get generatedCardsJson => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
