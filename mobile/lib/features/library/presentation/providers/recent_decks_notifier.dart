import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/get_recent_decks_use_case.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_providers.dart';

part 'recent_decks_notifier.g.dart';

@Riverpod(keepAlive: true)
class RecentDecksNotifier extends _$RecentDecksNotifier {
  @override
  Future<List<LibraryDeck>> build() async {
    final useCase = ref.read(getRecentDecksUseCaseProvider);
    final result = await useCase(const GetRecentDecksParams(limit: 10));
    return result.fold((f) => throw f, (decks) => decks);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
