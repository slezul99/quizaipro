import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/core/utils/mcq_text.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/algorithms/retention_calculator.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/flashcard.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_mode.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/providers/flashcard_providers.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/deck_cards_provider.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_decks_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_favorites_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_state.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_providers.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/recent_decks_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/card_editor_sheet.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/deck_editor_sheet.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_empty_state.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// Library deck detail — shown when the user opens one of *their own* decks
/// from the Library tab.
///
/// The deck is looked up by id in the already-loaded Library providers
/// (my decks / recent / favorites) rather than fetched again: every entry
/// point that navigates here (`LibraryScreen`, `LibrarySearchScreen`,
/// `DeckActionsHandler`) already populated those caches with the full
/// [LibraryDeck], so no extra network round-trip or backend endpoint is
/// needed.
class LibraryDeckDetailScreen extends ConsumerWidget {
  const LibraryDeckDetailScreen({super.key, required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.aurora;
    final l = AppLocalizations.of(context);

    final myDecks = ref.watch(libraryDecksNotifierProvider);
    final recentDecks = ref.watch(recentDecksNotifierProvider);
    final favorites = ref.watch(libraryFavoritesNotifierProvider);

    final deck = _findDeck(myDecks, recentDecks, favorites);
    final stillLoading = deck == null &&
        (myDecks.isLoading || recentDecks.isLoading || favorites.isLoading);

    return Scaffold(
      backgroundColor: t.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: t.backgroundCanvas,
        elevation: 0,
        foregroundColor: t.textPrimary,
        actions: deck == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l.libraryDeckEditTooltip,
                  onPressed: () => showDeckEditorSheet(context, deck: deck),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: l.libraryDeckDeleteTooltip,
                  onPressed: () => _confirmDeleteDeck(context, ref, deck.id),
                ),
              ],
      ),
      body: stillLoading
          ? const Center(child: CircularProgressIndicator())
          : deck == null
              ? LibraryEmptyState(
                  tokens: t,
                  icon: Icons.search_off_rounded,
                  message: l.libraryDeckDetailNotFound,
                )
              : _DeckDetailBody(deck: deck, tokens: t, l: l),
    );
  }

  LibraryDeck? _findDeck(
    AsyncValue<DecksListState> myDecks,
    AsyncValue<List<LibraryDeck>> recentDecks,
    AsyncValue<FavoritesListState> favorites,
  ) {
    for (final deck in myDecks.valueOrNull?.items ?? const <LibraryDeck>[]) {
      if (deck.id == deckId) return deck;
    }
    for (final deck in recentDecks.valueOrNull ?? const <LibraryDeck>[]) {
      if (deck.id == deckId) return deck;
    }
    for (final deck in favorites.valueOrNull?.items ?? const <LibraryDeck>[]) {
      if (deck.id == deckId) return deck;
    }
    return null;
  }
}

class _DeckDetailBody extends ConsumerWidget {
  const _DeckDetailBody({required this.deck, required this.tokens, required this.l});

  final LibraryDeck deck;
  final AuroraTokens tokens;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cardsAsync = ref.watch(deckCardsProvider(deck.id));
    final coverColor = _hexToColor(deck.coverColorHex);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.fromLTRB(
              tokens.space20,
              tokens.space4,
              tokens.space20,
              tokens.space20,
            ),
            padding: EdgeInsets.all(tokens.space20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [coverColor, Color.lerp(coverColor, Colors.black, 0.30)!],
              ),
              borderRadius: BorderRadius.circular(tokens.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: coverColor.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (deck.isPro)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.space8,
                      vertical: tokens.space4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(tokens.radiusFull),
                    ),
                    child: Text(
                      l.marketplaceProBadge,
                      style: tt.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                SizedBox(height: tokens.space8),
                Text(
                  deck.title,
                  style: tt.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (deck.subjectName != null) ...[
                  SizedBox(height: tokens.space4),
                  Text(
                    deck.subjectName!,
                    style: tt.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
                SizedBox(height: tokens.space16),
                Row(
                  children: [
                    _HeroStat(
                      icon: Icons.style_rounded,
                      value: '${deck.cardCount}',
                      label: l.marketplaceCards,
                      tokens: tokens,
                    ),
                    SizedBox(width: tokens.space8),
                    _HeroStat(
                      icon: Icons.schedule_rounded,
                      value: '${deck.dueCount}',
                      label: l.libraryDeckDetailDue,
                      tokens: tokens,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (deck.description.isNotEmpty) ...[
                  Text(l.marketplaceDeckAbout, style: tt.titleSmall),
                  SizedBox(height: tokens.space8),
                  Text(
                    deck.description,
                    style: tt.bodyMedium?.copyWith(color: tokens.textSecondary),
                  ),
                  SizedBox(height: tokens.space20),
                ],
                if (deck.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: tokens.space8,
                    runSpacing: tokens.space8,
                    children: deck.tags
                        .map(
                          (tag) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: tokens.space12,
                              vertical: tokens.space4,
                            ),
                            decoration: BoxDecoration(
                              color: tokens.backgroundSurfaceElevated,
                              borderRadius: BorderRadius.circular(tokens.radiusFull),
                              border: Border.all(color: tokens.borderSubtle),
                            ),
                            child: Text(
                              '#$tag',
                              style: tt.labelSmall?.copyWith(color: tokens.textSecondary),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: tokens.space20),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _DeckActionButton(
                        icon: Icons.school_rounded,
                        label: l.libraryActionStudy,
                        color: tokens.brandGradientStart,
                        enabled: deck.hasFlashcards,
                        tokens: tokens,
                        onTap: deck.hasFlashcards
                            ? () => context.pushNamed(
                                  AppRoutes.studySessionName,
                                  queryParameters: {
                                    'deckId': deck.id,
                                    'deckTitle': deck.title,
                                  },
                                )
                            : () => _showNoContentSheet(context, tokens,
                                isTest: false),
                      ),
                    ),
                    SizedBox(width: tokens.space12),
                    Expanded(
                      child: _DeckActionButton(
                        icon: Icons.fact_check_rounded,
                        label: l.libraryDeckDetailTest,
                        color: tokens.stateInfo,
                        enabled: deck.hasTests,
                        tokens: tokens,
                        onTap: deck.hasTests
                            ? () => context.pushNamed(
                                  AppRoutes.testSetupName,
                                  queryParameters: {
                                    'deckId': deck.id,
                                    'deckTitle': deck.title,
                                  },
                                )
                            : () => _showNoContentSheet(context, tokens,
                                isTest: true),
                      ),
                    ),
                  ],
                ),
                cardsAsync.maybeWhen(
                  data: (cards) {
                    final r = RetentionCalculator.forCards(cards);
                    if (!r.hasData) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(top: tokens.space16),
                      child: _DeckRetentionBadge(
                        result: r,
                        tokens: tokens,
                        l: l,
                        onReviewFading: r.fading > 0
                            ? () => context.pushNamed(
                                  AppRoutes.studySessionName,
                                  queryParameters: {
                                    'deckId': deck.id,
                                    'mode': StudyMode.fading.name,
                                    'deckTitle': deck.title,
                                  },
                                )
                            : null,
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
                SizedBox(height: tokens.space24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.marketplaceCards, style: tt.titleSmall),
                    TextButton.icon(
                      onPressed: () =>
                          showCardEditorSheet(context, deckId: deck.id),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(l.libraryDeckAddCard),
                      style: TextButton.styleFrom(
                        foregroundColor: tokens.brandPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space12),
                _CardsSection(
                  cardsAsync: cardsAsync,
                  tokens: tokens,
                  l: l,
                  deckId: deck.id,
                ),
                SizedBox(height: tokens.space32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }
}

/// Compact per-deck FSRS retention badge: how much of this deck the user
/// remembers now, the one-week forecast, and a tap-through to review the
/// fading cards. Computed locally from the deck's cards (offline-first).
class _DeckRetentionBadge extends StatelessWidget {
  const _DeckRetentionBadge({
    required this.result,
    required this.tokens,
    required this.l,
    this.onReviewFading,
  });

  final DeckRetentionResult result;
  final AuroraTokens tokens;
  final AppLocalizations l;
  final VoidCallback? onReviewFading;

  static const _amber = Color(0xFFf59e0b);

  Color get _accent {
    final now = result.now ?? 0;
    if (now >= 80) return tokens.stateSuccess;
    if (now >= 50) return _amber;
    return tokens.stateError;
  }

  @override
  Widget build(BuildContext context) {
    final now = result.now ?? 0;
    final tappable = onReviewFading != null && result.fading > 0;
    return Material(
      color: tokens.surfaceSubtle,
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: InkWell(
        onTap: tappable ? onReviewFading : null,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(tokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 18)),
                  SizedBox(width: tokens.space8),
                  Expanded(
                    child: Text(
                      l.dashboardRetention,
                      style: tokens.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '$now%',
                    style: tokens.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _accent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.space8),
              Row(
                children: [
                  Text(
                    '${l.dashboardRetentionForecast} ${result.forecast ?? now}%',
                    style: tokens.bodySmall.copyWith(color: tokens.textSecondary),
                  ),
                  if (result.fading > 0) ...[
                    const Spacer(),
                    Text(
                      '${result.fading} ${l.dashboardRetentionFading}',
                      style: tokens.bodySmall.copyWith(
                        color: _amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (onReviewFading != null)
                      Icon(Icons.chevron_right_rounded, size: 18, color: _amber),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Translucent stat pill shown inside the gradient deck hero.
class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.tokens,
  });

  final IconData icon;
  final String value;
  final String label;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space12,
        vertical: tokens.space8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          SizedBox(width: tokens.space8),
          Text(
            value,
            style: tt.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: tokens.space4),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the deck's own flashcards as a tappable, flippable list so users
/// can browse what's actually inside a deck from the Library — mirroring the
/// Marketplace's card-preview affordance, but showing every card.
class _CardsSection extends ConsumerWidget {
  const _CardsSection({
    required this.cardsAsync,
    required this.tokens,
    required this.l,
    required this.deckId,
  });

  final AsyncValue<List<Flashcard>> cardsAsync;
  final AuroraTokens tokens;
  final AppLocalizations l;
  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return cardsAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space24),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space12),
        child: Text(
          l.errorNetwork,
          style: TextStyle(color: tokens.textSecondary),
        ),
      ),
      data: (cards) {
        if (cards.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.space12),
            child: Text(
              l.libraryDeckDetailNoCards,
              style: TextStyle(color: tokens.textSecondary),
            ),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < cards.length; i++)
              _FlashcardTile(
                index: i + 1,
                card: cards[i],
                tokens: tokens,
                frontLabel: l.marketplaceCardFront,
                backLabel: l.marketplaceCardBack,
                onEdit: () => showCardEditorSheet(
                  context,
                  deckId: deckId,
                  card: cards[i],
                ),
                onDelete: () =>
                    _confirmDeleteCard(context, ref, deckId, cards[i].id),
              ),
          ],
        );
      },
    );
  }
}

class _FlashcardTile extends StatefulWidget {
  const _FlashcardTile({
    required this.index,
    required this.card,
    required this.tokens,
    required this.frontLabel,
    required this.backLabel,
    this.onEdit,
    this.onDelete,
  });

  final int index;
  final Flashcard card;
  final AuroraTokens tokens;
  final String frontLabel;
  final String backLabel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<_FlashcardTile> createState() => _FlashcardTileState();
}

class _FlashcardTileState extends State<_FlashcardTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final l = AppLocalizations.of(context)!;
    final card = widget.card;
    final stem = mcqStem(card.front);
    // Options may be inlined in the front (most decks) or in the note/hint.
    var options = mcqOptions(card.front);
    if (options.isEmpty) options = mcqOptions(card.hint ?? '');
    final isMcq = options.length >= 2;
    final accent = isMcq ? t.stateInfo : t.brandGradientStart;

    // Explanation = note (surfaced as hint). For MCQ cards the note often holds
    // the options themselves, not prose — don't show that as an "explanation".
    final hint = (card.hint ?? '').trim();
    final hasExplanation =
        hint.isNotEmpty && hint != card.back && !mcqHasOptions(hint);

    // Minimal tile: only the number + question are shown; tapping anywhere
    // expands the options / answer / explanation. Keeps a long list calm.
    return Container(
      margin: EdgeInsets.only(bottom: t.space12),
      decoration: BoxDecoration(
        color: t.backgroundSurface,
        borderRadius: BorderRadius.circular(t.radiusLg),
        border: Border.all(color: t.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Always-visible header — tap to expand/collapse.
            InkWell(
              borderRadius: BorderRadius.circular(t.radiusLg),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: EdgeInsets.all(t.space16),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: t.surfaceSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${widget.index}',
                        style: t.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: t.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: t.space12),
                    Expanded(
                      child: Text(
                        stem,
                        style: t.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(width: t.space8),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.expand_more_rounded,
                          size: 22, color: t.textTertiary),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded body.
            if (_expanded)
              Padding(
                padding: EdgeInsets.fromLTRB(
                    t.space16, 0, t.space16, t.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMcq) ...[
                      for (var oi = 0; oi < options.length; oi++)
                        Padding(
                          padding: EdgeInsets.only(bottom: t.space4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: t.surfaceSubtle,
                                  borderRadius:
                                      BorderRadius.circular(t.radiusSm),
                                ),
                                child: Text(
                                  String.fromCharCode(65 + oi),
                                  style: t.labelSmall.copyWith(
                                    color: t.textSecondary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              SizedBox(width: t.space8),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child:
                                      Text(options[oi], style: t.bodyMedium),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: t.space8),
                    ],
                    // Answer.
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(t.space12),
                      decoration: BoxDecoration(
                        color: t.surfaceSubtle,
                        borderRadius: BorderRadius.circular(t.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                    color: accent, shape: BoxShape.circle),
                              ),
                              SizedBox(width: t.space4),
                              Text(
                                widget.backLabel.toUpperCase(),
                                style: t.labelSmall.copyWith(
                                  color: t.textTertiary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: t.space4),
                          Text(
                            card.back,
                            style: t.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: t.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasExplanation) ...[
                      SizedBox(height: t.space8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded,
                              size: 14, color: t.textTertiary),
                          SizedBox(width: t.space8),
                          Expanded(
                            child: Text(
                              hint,
                              style: t.bodySmall.copyWith(
                                color: t.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Edit / delete actions (only if provided).
                    if (widget.onEdit != null || widget.onDelete != null) ...[
                      SizedBox(height: t.space8),
                      Row(
                        children: [
                          if (widget.onEdit != null)
                            _MiniAction(
                              icon: Icons.edit_outlined,
                              label: l.commonEdit,
                              color: t.textSecondary,
                              onTap: widget.onEdit!,
                            ),
                          if (widget.onDelete != null) ...[
                            SizedBox(width: t.space8),
                            _MiniAction(
                              icon: Icons.delete_outline_rounded,
                              label: l.delete,
                              color: t.stateError,
                              onTap: widget.onDelete!,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small text+icon action used in the expanded flashcard tile footer.
class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.aurora;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: t.space12, vertical: t.space8),
        decoration: BoxDecoration(
          color: t.surfaceSubtle,
          borderRadius: BorderRadius.circular(t.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            SizedBox(width: t.space4),
            Text(
              label,
              style: t.labelMedium.copyWith(
                  color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary deck action ("Учить" / "Тест"). Both states stay clearly visible:
/// enabled = solid accent gradient with a coloured glow; disabled = a soft
/// accent-tinted surface with a lock hint (never a near-invisible outline).
class _DeckActionButton extends StatelessWidget {
  const _DeckActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.tokens,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final AuroraTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final darker = Color.lerp(color, Colors.black, 0.28)!;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    colors: [color, darker],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: enabled ? null : color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: enabled
                ? null
                : Border.all(color: color.withValues(alpha: 0.35)),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: enabled ? Colors.white : color.withValues(alpha: 0.85),
              ),
              SizedBox(width: tokens.space8),
              Text(
                label,
                style: tokens.titleSmall.copyWith(
                  color: enabled ? Colors.white : color.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!enabled) ...[
                SizedBox(width: tokens.space4),
                Icon(Icons.lock_rounded,
                    size: 13, color: color.withValues(alpha: 0.7)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


/// Friendly bottom sheet shown when the user taps Study on a deck with no
/// flashcards, or Test on a deck with no MCQ cards.
void _showNoContentSheet(
  BuildContext context,
  AuroraTokens tokens, {
  required bool isTest,
}) {
  final accent = isTest ? tokens.stateInfo : tokens.brandGradientStart;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: tokens.backgroundSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
    ),
    builder: (ctx) {
      final tt = Theme.of(ctx).textTheme;
      final l = AppLocalizations.of(ctx)!;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space24,
            tokens.space12,
            tokens.space24,
            tokens.space24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.surfaceSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: tokens.space24),
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.12),
                ),
                child: Icon(
                  isTest ? Icons.fact_check_outlined : Icons.style_outlined,
                  size: 30,
                  color: accent,
                ),
              ),
              SizedBox(height: tokens.space16),
              Text(
                isTest ? l.deckNoTestsTitle : l.deckNoFlashcardsTitle,
                textAlign: TextAlign.center,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: tokens.space8),
              Text(
                isTest ? l.deckNoTestsBody : l.deckNoFlashcardsBody,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
              SizedBox(height: tokens.space24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.brandPrimary,
                    foregroundColor: tokens.textOnBrand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusMd),
                    ),
                  ),
                  child: Text(l.commonGotIt),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool> _confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final l = AppLocalizations.of(ctx)!;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l.delete),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}

Future<void> _confirmDeleteDeck(
    BuildContext context, WidgetRef ref, String deckId) async {
  final l = AppLocalizations.of(context)!;
  final confirmed = await _confirmDelete(
    context,
    title: l.deckDeleteTitle,
    message: l.deckDeleteBody,
  );
  if (!confirmed) return;
  final result = await ref.read(libraryRepositoryProvider).deleteDeck(deckId);
  if (!context.mounted) return;
  result.fold(
    (_) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.deckDeleteFailed)),
    ),
    (_) {
      ref.read(libraryDecksNotifierProvider.notifier).refresh();
      ref.invalidate(recentDecksNotifierProvider);
      ref.invalidate(libraryFavoritesNotifierProvider);
      Navigator.of(context).pop(); // leave the deck detail
    },
  );
}

Future<void> _confirmDeleteCard(BuildContext context, WidgetRef ref,
    String deckId, String cardId) async {
  final l = AppLocalizations.of(context)!;
  final confirmed = await _confirmDelete(
    context,
    title: l.cardDeleteTitle,
    message: l.cardDeleteBody,
  );
  if (!confirmed) return;
  final result = await ref
      .read(flashcardRepositoryProvider)
      .deleteCard(deckId: deckId, cardId: cardId);
  if (!context.mounted) return;
  result.fold(
    (_) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.cardDeleteFailed)),
    ),
    (_) {
      ref.invalidate(deckCardsProvider(deckId));
      ref.read(libraryDecksNotifierProvider.notifier).refresh();
    },
  );
}
