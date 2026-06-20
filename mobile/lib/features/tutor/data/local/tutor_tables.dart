import 'package:drift/drift.dart';

class ConversationsLocalTable extends Table {
  @override
  String get tableName => 'conversations_local';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get deckId => text().nullable()();
  TextColumn get deckTitle => text().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get messageCount => integer().withDefault(const Constant(0))();
  TextColumn get lastMessagePreview => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TutorMessagesLocalTable extends Table {
  @override
  String get tableName => 'tutor_messages_local';

  TextColumn get id => text()();
  TextColumn get conversationId => text()();
  TextColumn get role => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
