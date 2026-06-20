import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/di/providers.dart';
import 'package:quizaipro_mobile/features/tutor/data/local/tutor_local_data_source.dart';
import 'package:quizaipro_mobile/features/tutor/data/remote/sse_connection_manager.dart';
import 'package:quizaipro_mobile/features/tutor/data/remote/tutor_remote_data_source.dart';
import 'package:quizaipro_mobile/features/tutor/data/repositories/tutor_repository_impl.dart';
import 'package:quizaipro_mobile/features/tutor/domain/repositories/tutor_repository.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/create_conversation_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/delete_conversation_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/get_conversations_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/get_messages_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/pin_conversation_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/rename_conversation_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/search_conversations_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/send_message_use_case.dart';
import 'package:quizaipro_mobile/features/tutor/domain/usecases/sync_pending_messages_use_case.dart';

export 'package:quizaipro_mobile/core/usecase/usecase.dart' show NoParams;
export 'package:quizaipro_mobile/features/tutor/domain/usecases/create_conversation_use_case.dart'
    show CreateConversationParams;
export 'package:quizaipro_mobile/features/tutor/domain/usecases/pin_conversation_use_case.dart'
    show PinConversationParams;
export 'package:quizaipro_mobile/features/tutor/domain/usecases/rename_conversation_use_case.dart'
    show RenameConversationParams;
export 'package:quizaipro_mobile/features/tutor/domain/usecases/send_message_use_case.dart'
    show SendMessageParams;

part 'tutor_providers.g.dart';

// ── L1: Infrastructure ────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
SseConnectionManager sseConnectionManager(SseConnectionManagerRef ref) =>
    SseConnectionManager(ref.watch(sseDioProvider));

@Riverpod(keepAlive: true)
TutorRemoteDataSource tutorRemoteDataSource(TutorRemoteDataSourceRef ref) =>
    TutorRemoteDataSourceImpl(
      dio: ref.watch(dioProvider),
      sseManager: ref.watch(sseConnectionManagerProvider),
    );

@Riverpod(keepAlive: true)
TutorLocalDataSource tutorLocalDataSource(TutorLocalDataSourceRef ref) =>
    TutorLocalDataSourceImpl(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
TutorRepository tutorRepository(TutorRepositoryRef ref) =>
    TutorRepositoryImpl(
      remoteDataSource: ref.watch(tutorRemoteDataSourceProvider),
      localDataSource: ref.watch(tutorLocalDataSourceProvider),
    );

// ── L2: Use Cases ─────────────────────────────────────────────────────────────

@riverpod
GetConversationsUseCase getConversationsUseCase(
  GetConversationsUseCaseRef ref,
) =>
    GetConversationsUseCase(ref.watch(tutorRepositoryProvider));

@riverpod
CreateConversationUseCase createConversationUseCase(
  CreateConversationUseCaseRef ref,
) =>
    CreateConversationUseCase(ref.watch(tutorRepositoryProvider));

@riverpod
RenameConversationUseCase renameConversationUseCase(
  RenameConversationUseCaseRef ref,
) =>
    RenameConversationUseCase(ref.watch(tutorRepositoryProvider));

@riverpod
PinConversationUseCase pinConversationUseCase(
  PinConversationUseCaseRef ref,
) =>
    PinConversationUseCase(ref.watch(tutorRepositoryProvider));

@riverpod
DeleteConversationUseCase deleteConversationUseCase(
  DeleteConversationUseCaseRef ref,
) =>
    DeleteConversationUseCase(ref.watch(tutorRepositoryProvider));

@riverpod
GetMessagesUseCase getMessagesUseCase(GetMessagesUseCaseRef ref) =>
    GetMessagesUseCase(ref.watch(tutorRepositoryProvider));

@riverpod
SendMessageUseCase sendMessageUseCase(SendMessageUseCaseRef ref) =>
    SendMessageUseCase(ref.watch(tutorRepositoryProvider));

@riverpod
SearchConversationsUseCase searchConversationsUseCase(
  SearchConversationsUseCaseRef ref,
) =>
    SearchConversationsUseCase(ref.watch(tutorRepositoryProvider));

@riverpod
SyncPendingMessagesUseCase syncPendingMessagesUseCase(
  SyncPendingMessagesUseCaseRef ref,
) =>
    SyncPendingMessagesUseCase(ref.watch(tutorRepositoryProvider));
