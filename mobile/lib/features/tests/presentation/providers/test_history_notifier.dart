import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/tests/domain/entities/test_history_item.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_providers.dart';

part 'test_history_notifier.g.dart';

@riverpod
Future<List<TestHistoryItem>> testHistory(
  TestHistoryRef ref, {
  required String deckId,
}) async {
  final useCase = ref.watch(getTestHistoryUseCaseProvider);
  final result = await useCase(GetTestHistoryParams(deckId: deckId));
  return result.fold(
    (failure) => throw failure,
    (items) => items,
  );
}
