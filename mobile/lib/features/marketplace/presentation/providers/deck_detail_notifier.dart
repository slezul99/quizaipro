import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_card_preview.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_detail.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/clone_deck_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/get_deck_cards_preview_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/usecases/get_deck_detail_use_case.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';

part 'deck_detail_notifier.g.dart';

class DeckDetailState {
  const DeckDetailState({
    required this.detail,
    this.previewCards = const [],
    this.isCloning = false,
    this.cloneSuccess = false,
    this.cloneError,
  });

  final DeckDetail detail;
  final List<DeckCardPreview> previewCards;
  final bool isCloning;
  final bool cloneSuccess;
  final String? cloneError;

  DeckDetailState copyWith({
    DeckDetail? detail,
    List<DeckCardPreview>? previewCards,
    bool? isCloning,
    bool? cloneSuccess,
    String? cloneError,
    bool clearCloneError = false,
  }) =>
      DeckDetailState(
        detail: detail ?? this.detail,
        previewCards: previewCards ?? this.previewCards,
        isCloning: isCloning ?? this.isCloning,
        cloneSuccess: cloneSuccess ?? this.cloneSuccess,
        cloneError: clearCloneError ? null : (cloneError ?? this.cloneError),
      );
}

@riverpod
class DeckDetailNotifier extends _$DeckDetailNotifier {
  @override
  Future<DeckDetailState> build(String deckId) async {
    final getDetail = ref.read(getDeckDetailUseCaseProvider);
    final getCards = ref.read(getDeckCardsPreviewUseCaseProvider);

    final (detailResult, cardsResult) = await (
      getDetail(GetDeckDetailParams(deckId: deckId)),
      getCards(GetDeckCardsPreviewParams(deckId: deckId, limit: 5)),
    ).wait;

    final detail = detailResult.fold((f) => throw f, (d) => d);
    final cards = cardsResult.fold((_) => <DeckCardPreview>[], (c) => c);

    return DeckDetailState(detail: detail, previewCards: cards);
  }

  Future<void> cloneDeck() async {
    final current = state.valueOrNull;
    if (current == null || current.isCloning) return;

    state = AsyncData(current.copyWith(
      isCloning: true,
      cloneSuccess: false,
      clearCloneError: true,
    ));

    final useCase = ref.read(cloneDeckUseCaseProvider);
    final result = await useCase(CloneDeckParams(deckId: deckId));

    result.fold(
      (f) => state = AsyncData(current.copyWith(
        isCloning: false,
        cloneError: f.userMessage,
      )),
      (_) => state = AsyncData(current.copyWith(
        isCloning: false,
        cloneSuccess: true,
        detail: current.detail.copyWith(isClonedByUser: true),
      )),
    );
  }
}