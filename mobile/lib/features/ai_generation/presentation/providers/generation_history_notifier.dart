import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_job.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/ai_generation_providers.dart';

part 'generation_history_notifier.g.dart';

@riverpod
Future<List<GenerationJob>> generationHistory(
    GenerationHistoryRef ref) async {
  final useCase = ref.read(getGenerationHistoryUseCaseProvider);
  final result = await useCase(const NoParams());
  return result.fold(
    (failure) => throw failure.userMessage,
    (jobs) => jobs,
  );
}
