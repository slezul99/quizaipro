import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_job.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/ai_generation_providers.dart';

part 'generation_job_notifier.g.dart';

@Riverpod(keepAlive: true)
class GenerationJobNotifier extends _$GenerationJobNotifier {
  Timer? _timer;

  @override
  AsyncValue<GenerationJob> build({required String jobId}) {
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    Future.microtask(startPolling);
    return const AsyncValue.loading();
  }

  Future<void> startPolling() async {
    await _fetchStatus();
    if (state.value?.isTerminal == true) return;
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: AppConstants.aiGenerationPollIntervalMs),
      (_) => _fetchStatus(),
    );
  }

  Future<void> _fetchStatus() async {
    final useCase = ref.read(getJobStatusUseCaseProvider);
    final result = await useCase(jobId);
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.userMessage, StackTrace.current),
      (job) {
        state = AsyncValue.data(job);
        if (job.isTerminal) {
          _timer?.cancel();
          _timer = null;
        }
      },
    );
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = const AsyncValue.loading();
  }
}
