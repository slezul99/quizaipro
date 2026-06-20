import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/explain_card_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/ai_generation_providers.dart';

part 'explain_card_notifier.g.dart';

@riverpod
class ExplainCardNotifier extends _$ExplainCardNotifier {
  @override
  AsyncValue<String> build({
    required String question,
    required String answer,
    String? deckId,
  }) =>
      const AsyncValue.loading();

  Future<void> explain() async {
    state = const AsyncValue.loading();
    final useCase = ref.read(explainCardUseCaseProvider);
    final result = await useCase(ExplainCardParams(
      question: question,
      answer: answer,
      deckId: deckId,
    ));
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.userMessage, StackTrace.current),
      (explanation) => state = AsyncValue.data(explanation),
    );
  }
}
