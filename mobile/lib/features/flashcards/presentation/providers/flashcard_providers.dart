import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/di/providers.dart';
import 'package:quizaipro_mobile/features/flashcards/data/local/flashcard_local_data_source.dart';
import 'package:quizaipro_mobile/features/flashcards/data/remote/flashcard_remote_data_source.dart';
import 'package:quizaipro_mobile/features/flashcards/data/repositories/flashcard_repository_impl.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/repositories/flashcard_repository.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/usecases/grade_card_use_case.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/usecases/load_study_queue_use_case.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/usecases/save_session_use_case.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/usecases/sync_pending_grades_use_case.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_providers.dart';

part 'flashcard_providers.g.dart';

// ── L1: Data Sources ─────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
FlashcardRemoteDataSource flashcardRemoteDataSource(
  FlashcardRemoteDataSourceRef ref,
) =>
    FlashcardRemoteDataSourceImpl(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
FlashcardLocalDataSource flashcardLocalDataSource(
  FlashcardLocalDataSourceRef ref,
) =>
    FlashcardLocalDataSourceImpl(ref.watch(appDatabaseProvider));

// ── L1: Repository ────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
FlashcardRepository flashcardRepository(FlashcardRepositoryRef ref) =>
    FlashcardRepositoryImpl(
      remoteDataSource: ref.watch(flashcardRemoteDataSourceProvider),
      localDataSource: ref.watch(flashcardLocalDataSourceProvider),
    );

// ── L2: Use Cases ─────────────────────────────────────────────────────────────

@riverpod
LoadStudyQueueUseCase loadStudyQueueUseCase(
  LoadStudyQueueUseCaseRef ref,
) =>
    LoadStudyQueueUseCase(
      ref.watch(flashcardRepositoryProvider),
      ref.watch(libraryRepositoryProvider),
    );

@riverpod
GradeCardUseCase gradeCardUseCase(GradeCardUseCaseRef ref) =>
    GradeCardUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
SaveSessionUseCase saveSessionUseCase(SaveSessionUseCaseRef ref) =>
    SaveSessionUseCase(ref.watch(flashcardRepositoryProvider));

@riverpod
SyncPendingGradesUseCase syncPendingGradesUseCase(
  SyncPendingGradesUseCaseRef ref,
) =>
    SyncPendingGradesUseCase(ref.watch(flashcardRepositoryProvider));
