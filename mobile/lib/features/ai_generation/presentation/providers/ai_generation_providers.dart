import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/di/providers.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/data/local/generation_local_data_source.dart';
import 'package:quizaipro_mobile/features/ai_generation/data/remote/ai_generation_remote_data_source.dart';
import 'package:quizaipro_mobile/features/ai_generation/data/repositories/ai_generation_repository_impl.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/repositories/ai_generation_repository.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/create_deck_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/explain_card_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/find_answers_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/generate_from_pdf_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/generate_from_text_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/generate_from_topic_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/get_generation_history_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/get_job_status_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/get_user_decks_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/save_generated_cards_use_case.dart';

export 'package:quizaipro_mobile/core/usecase/usecase.dart' show NoParams;
export 'package:quizaipro_mobile/features/ai_generation/domain/usecases/explain_card_use_case.dart'
    show ExplainCardParams;
export 'package:quizaipro_mobile/features/ai_generation/domain/usecases/find_answers_use_case.dart'
    show FindAnswersParams;
export 'package:quizaipro_mobile/features/ai_generation/domain/usecases/generate_from_pdf_use_case.dart'
    show GenerateFromPdfParams;
export 'package:quizaipro_mobile/features/ai_generation/domain/usecases/generate_from_text_use_case.dart'
    show GenerateFromTextParams;
export 'package:quizaipro_mobile/features/ai_generation/domain/usecases/generate_from_topic_use_case.dart'
    show GenerateFromTopicParams;
export 'package:quizaipro_mobile/features/ai_generation/domain/usecases/save_generated_cards_use_case.dart'
    show SaveGeneratedCardsParams;

part 'ai_generation_providers.g.dart';

// ── L1 Infrastructure ─────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
AiGenerationRemoteDataSource aiGenerationRemoteDataSource(
        AiGenerationRemoteDataSourceRef ref) =>
    AiGenerationRemoteDataSourceImpl(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
GenerationLocalDataSource generationLocalDataSource(
        GenerationLocalDataSourceRef ref) =>
    GenerationLocalDataSourceImpl(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
AiGenerationRepository aiGenerationRepository(
        AiGenerationRepositoryRef ref) =>
    AiGenerationRepositoryImpl(
      remoteDataSource: ref.watch(aiGenerationRemoteDataSourceProvider),
      localDataSource: ref.watch(generationLocalDataSourceProvider),
    );

// ── L2 Use Cases ──────────────────────────────────────────────────────────

@riverpod
GenerateFromTopicUseCase generateFromTopicUseCase(
        GenerateFromTopicUseCaseRef ref) =>
    GenerateFromTopicUseCase(ref.watch(aiGenerationRepositoryProvider));

@riverpod
GenerateFromTextUseCase generateFromTextUseCase(
        GenerateFromTextUseCaseRef ref) =>
    GenerateFromTextUseCase(ref.watch(aiGenerationRepositoryProvider));

@riverpod
GenerateFromPdfUseCase generateFromPdfUseCase(
        GenerateFromPdfUseCaseRef ref) =>
    GenerateFromPdfUseCase(ref.watch(aiGenerationRepositoryProvider));

@riverpod
GetJobStatusUseCase getJobStatusUseCase(GetJobStatusUseCaseRef ref) =>
    GetJobStatusUseCase(ref.watch(aiGenerationRepositoryProvider));

@riverpod
GetGenerationHistoryUseCase getGenerationHistoryUseCase(
        GetGenerationHistoryUseCaseRef ref) =>
    GetGenerationHistoryUseCase(ref.watch(aiGenerationRepositoryProvider));

@riverpod
SaveGeneratedCardsUseCase saveGeneratedCardsUseCase(
        SaveGeneratedCardsUseCaseRef ref) =>
    SaveGeneratedCardsUseCase(ref.watch(aiGenerationRepositoryProvider));

@riverpod
CreateDeckUseCase createDeckUseCase(CreateDeckUseCaseRef ref) =>
    CreateDeckUseCase(ref.watch(aiGenerationRepositoryProvider));

@riverpod
FindAnswersUseCase findAnswersUseCase(FindAnswersUseCaseRef ref) =>
    FindAnswersUseCase(ref.watch(aiGenerationRepositoryProvider));

@riverpod
ExplainCardUseCase explainCardUseCase(ExplainCardUseCaseRef ref) =>
    ExplainCardUseCase(ref.watch(aiGenerationRepositoryProvider));

@riverpod
GetUserDecksUseCase getUserDecksUseCase(GetUserDecksUseCaseRef ref) =>
    GetUserDecksUseCase(ref.watch(aiGenerationRepositoryProvider));
