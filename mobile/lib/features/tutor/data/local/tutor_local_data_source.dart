import 'package:drift/drift.dart';

import 'package:quizaipro_mobile/core/storage/drift/app_database.dart';

abstract interface class TutorLocalDataSource {
  Future<List<ConversationsLocalTableData>> getConversations();
  Future<ConversationsLocalTableData?> getConversation(String id);
  Future<void> saveConversation(ConversationsLocalTableCompanion companion);
  Future<void> updateConversationTitle(String id, String title);
  Future<void> updateConversationPin(String id, {required bool isPinned});
  Future<void> deleteConversation(String id);
  Future<void> updateConversationMeta({
    required String id,
    required String? lastMessagePreview,
    required int messageCount,
    required DateTime updatedAt,
  });
  Future<List<TutorMessagesLocalTableData>> getMessages(String conversationId);
  Future<void> saveMessage(TutorMessagesLocalTableCompanion companion);
  Future<void> saveMessages(List<TutorMessagesLocalTableCompanion> companions);
  Future<List<ConversationsLocalTableData>> searchConversations(String query);
  Future<List<ConversationsLocalTableData>> getUnsyncedConversations();
  Future<List<TutorMessagesLocalTableData>> getUnsyncedMessages();
  Future<void> markConversationSynced(String id);
  Future<void> markMessageSynced(String id);
}

class TutorLocalDataSourceImpl implements TutorLocalDataSource {
  TutorLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<ConversationsLocalTableData>> getConversations() =>
      (_db.select(_db.conversationsLocalTable)
            ..orderBy([
              (t) => OrderingTerm.desc(t.isPinned),
              (t) => OrderingTerm.desc(t.updatedAt),
            ]))
          .get();

  @override
  Future<ConversationsLocalTableData?> getConversation(String id) =>
      (_db.select(_db.conversationsLocalTable)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  @override
  Future<void> saveConversation(
    ConversationsLocalTableCompanion companion,
  ) =>
      _db
          .into(_db.conversationsLocalTable)
          .insertOnConflictUpdate(companion);

  @override
  Future<void> updateConversationTitle(String id, String title) =>
      (_db.update(_db.conversationsLocalTable)
            ..where((t) => t.id.equals(id)))
          .write(ConversationsLocalTableCompanion(
        title: Value(title),
        synced: const Value(false),
      ));

  @override
  Future<void> updateConversationPin(
    String id, {
    required bool isPinned,
  }) =>
      (_db.update(_db.conversationsLocalTable)
            ..where((t) => t.id.equals(id)))
          .write(ConversationsLocalTableCompanion(
        isPinned: Value(isPinned),
        synced: const Value(false),
      ));

  @override
  Future<void> deleteConversation(String id) async {
    await (_db.delete(_db.tutorMessagesLocalTable)
          ..where((t) => t.conversationId.equals(id)))
        .go();
    await (_db.delete(_db.conversationsLocalTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> updateConversationMeta({
    required String id,
    required String? lastMessagePreview,
    required int messageCount,
    required DateTime updatedAt,
  }) =>
      (_db.update(_db.conversationsLocalTable)
            ..where((t) => t.id.equals(id)))
          .write(ConversationsLocalTableCompanion(
        lastMessagePreview: Value(lastMessagePreview),
        messageCount: Value(messageCount),
        updatedAt: Value(updatedAt),
      ));

  @override
  Future<List<TutorMessagesLocalTableData>> getMessages(
    String conversationId,
  ) =>
      (_db.select(_db.tutorMessagesLocalTable)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  @override
  Future<void> saveMessage(TutorMessagesLocalTableCompanion companion) =>
      _db
          .into(_db.tutorMessagesLocalTable)
          .insertOnConflictUpdate(companion);

  @override
  Future<void> saveMessages(
    List<TutorMessagesLocalTableCompanion> companions,
  ) =>
      _db.batch((b) {
        b.insertAllOnConflictUpdate(_db.tutorMessagesLocalTable, companions);
      });

  @override
  Future<List<ConversationsLocalTableData>> searchConversations(
    String query,
  ) {
    final q = '%${query.toLowerCase()}%';
    return (_db.select(_db.conversationsLocalTable)
          ..where((t) => t.title.lower().like(q))
          ..orderBy([
            (t) => OrderingTerm.desc(t.isPinned),
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .get();
  }

  @override
  Future<List<ConversationsLocalTableData>> getUnsyncedConversations() =>
      (_db.select(_db.conversationsLocalTable)
            ..where((t) => t.synced.equals(false)))
          .get();

  @override
  Future<List<TutorMessagesLocalTableData>> getUnsyncedMessages() =>
      (_db.select(_db.tutorMessagesLocalTable)
            ..where((t) => t.synced.equals(false)))
          .get();

  @override
  Future<void> markConversationSynced(String id) =>
      (_db.update(_db.conversationsLocalTable)
            ..where((t) => t.id.equals(id)))
          .write(const ConversationsLocalTableCompanion(
        synced: Value(true),
      ));

  @override
  Future<void> markMessageSynced(String id) =>
      (_db.update(_db.tutorMessagesLocalTable)
            ..where((t) => t.id.equals(id)))
          .write(const TutorMessagesLocalTableCompanion(
        synced: Value(true),
      ));
}
