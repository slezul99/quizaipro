import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// Library deck card — "deck cover" layout. A coloured cover band carries the
/// deck initial and content-type marks; a clean white info strip below holds
/// the title and a single calm stats line. Built from scratch to read like a
/// real deck of cards rather than a busy data tile.
class LibraryDeckCard extends StatelessWidget {
  const LibraryDeckCard({
    super.key,
    required this.deck,
    required this.tokens,
    required this.onTap,
    required this.onActionsTap,
  });

  final LibraryDeck deck;
  final AuroraTokens tokens;
  final VoidCallback onTap;
  final VoidCallback onActionsTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;
    final cover = _hexToColor(deck.coverColorHex);
    final initial =
        deck.title.trim().isNotEmpty ? deck.title.trim()[0].toUpperCase() : '?';

    return Material(
      color: tokens.backgroundSurface,
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            border: Border.all(color: tokens.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Cover band ──────────────────────────────────────────────
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cover,
                        Color.lerp(cover, Colors.black, 0.32)!,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Big watermark initial.
                      Positioned(
                        left: tokens.space12,
                        bottom: -6,
                        child: Text(
                          initial,
                          style: tt.displayLarge?.copyWith(
                            fontSize: 72,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                      // Favourite + overflow controls.
                      Positioned(
                        top: tokens.space4,
                        right: tokens.space4,
                        child: Row(
                          children: [
                            if (deck.isFavorite)
                              const Padding(
                                padding: EdgeInsets.only(right: 2),
                                child: Icon(Icons.favorite_rounded,
                                    size: 16, color: Colors.white),
                              ),
                            _GlassIconButton(
                              icon: Icons.more_horiz_rounded,
                              onTap: onActionsTap,
                            ),
                          ],
                        ),
                      ),
                      // Content-type marks.
                      Positioned(
                        bottom: tokens.space8,
                        right: tokens.space8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (deck.hasFlashcards)
                              const _CoverMark(icon: Icons.style_rounded),
                            if (deck.hasTests) ...[
                              SizedBox(width: tokens.space4),
                              const _CoverMark(icon: Icons.fact_check_rounded),
                            ],
                            if (deck.isArchived) ...[
                              SizedBox(width: tokens.space4),
                              const _CoverMark(icon: Icons.archive_rounded),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Info strip ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(tokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      deck.title,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tokens.space8),
                    Row(
                      children: [
                        Text(
                          l.marketplaceCardCount(deck.cardCount),
                          style: tt.labelSmall?.copyWith(
                            color: tokens.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (deck.dueCount > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: tokens.space8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: tokens.stateError.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(tokens.radiusFull),
                            ),
                            child: Text(
                              '${deck.dueCount}',
                              style: tt.labelSmall?.copyWith(
                                color: tokens.stateError,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

/// Small translucent white circular icon button shown over the cover band.
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

/// A frosted content-type pill on the cover (flashcards / quiz / archived).
class _CoverMark extends StatelessWidget {
  const _CoverMark({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 13, color: Colors.white),
    );
  }
}
