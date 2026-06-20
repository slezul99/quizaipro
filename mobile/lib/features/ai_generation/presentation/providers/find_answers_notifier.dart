import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/find_answers_result.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/find_answers_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/ai_generation_providers.dart';

part 'find_answers_notifier.freezed.dart';
part 'find_answers_notifier.g.dart';

@freezed
class FindAnswersState with _$FindAnswersState {
  const factory FindAnswersState({
    @Default('') String query,
    @Default(false) bool isSearching,
    FindAnswersResult? result,
    String? errorMessage,
  }) = _FindAnswersState;
}

@riverpod
class FindAnswersNotifier extends _$FindAnswersNotifier {
  @override
  FindAnswersState build() => const FindAnswersState();

  void setQuery(String value) =>
      state = state.copyWith(query: value, errorMessage: null);

  Future<void> search({String? deckId}) async {
    final q = state.query.trim();
    if (q.isEmpty || state.isSearching) return;

    state = state.copyWith(isSearching: true, errorMessage: null, result: null);

    final useCase = ref.read(findAnswersUseCaseProvider);
    final result = await useCase(FindAnswersParams(question: q, deckId: deckId));

    result.fold(
      (failure) => state =
          state.copyWith(isSearching: false, errorMessage: failure.userMessage),
      (r) => state = state.copyWith(isSearching: false, result: r),
    );
  }

  void clear() => state = const FindAnswersState();
}
