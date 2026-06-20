import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/di/providers.dart';
import 'package:quizaipro_mobile/features/tests/data/local/test_local_data_source.dart';
import 'package:quizaipro_mobile/features/tests/data/remote/test_remote_data_source.dart';
import 'package:quizaipro_mobile/features/tests/data/repositories/test_repository_impl.dart';
import 'package:quizaipro_mobile/features/tests/domain/repositories/test_repository.dart';
import 'package:quizaipro_mobile/features/tests/domain/usecases/get_test_history_use_case.dart';
import 'package:quizaipro_mobile/features/tests/domain/usecases/load_test_questions_use_case.dart';
import 'package:quizaipro_mobile/features/tests/domain/usecases/submit_test_use_case.dart';
import 'package:quizaipro_mobile/features/tests/domain/usecases/sync_pending_tests_use_case.dart';

export 'package:quizaipro_mobile/features/tests/domain/usecases/get_test_history_use_case.dart'
    show GetTestHistoryParams;
export 'package:quizaipro_mobile/features/tests/domain/usecases/load_test_questions_use_case.dart'
    show LoadTestQuestionsParams;

part 'test_providers.g.dart';

// ── L1: Data Sources ─────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
TestRemoteDataSource testRemoteDataSource(TestRemoteDataSourceRef ref) =>
    TestRemoteDataSourceImpl(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
TestLocalDataSource testLocalDataSource(TestLocalDataSourceRef ref) =>
    TestLocalDataSourceImpl(ref.watch(appDatabaseProvider));

// ── L1: Repository ────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
TestRepository testRepository(TestRepositoryRef ref) => TestRepositoryImpl(
      remoteDataSource: ref.watch(testRemoteDataSourceProvider),
      localDataSource: ref.watch(testLocalDataSourceProvider),
    );

// ── L2: Use Cases ─────────────────────────────────────────────────────────────

@riverpod
LoadTestQuestionsUseCase loadTestQuestionsUseCase(
  LoadTestQuestionsUseCaseRef ref,
) =>
    LoadTestQuestionsUseCase(ref.watch(testRepositoryProvider));

@riverpod
SubmitTestUseCase submitTestUseCase(SubmitTestUseCaseRef ref) =>
    SubmitTestUseCase(ref.watch(testRepositoryProvider));

@riverpod
GetTestHistoryUseCase getTestHistoryUseCase(GetTestHistoryUseCaseRef ref) =>
    GetTestHistoryUseCase(ref.watch(testRepositoryProvider));

@riverpod
SyncPendingTestsUseCase syncPendingTestsUseCase(
  SyncPendingTestsUseCaseRef ref,
) =>
    SyncPendingTestsUseCase(ref.watch(testRepositoryProvider));
