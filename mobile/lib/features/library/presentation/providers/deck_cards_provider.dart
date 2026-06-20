import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/flashcards/domain/entities/flashcard.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/providers/flashcard_providers.dart';

part 'deck_cards_provider.g.dart';

/// All flashcards belonging to a deck the user owns, for the "Cards"
/// section on the library deck detail screen. Local-first via
/// [FlashcardRepository.getCardsForDeck] (same source the study session
/// uses), so it works offline once a deck has been opened before.
@riverpod
Future<List<Flashcard>> deckCards(DeckCardsRef ref, String deckId) async {
  final result = await ref.watch(flashcardRepositoryProvider).getCardsForDeck(deckId);
  return result.fold((failure) => throw failure, (cards) => cards);
}
