import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// Library deck card — built from scratch to the picked recipe:
///  • shape/style of a stacked deck (cards peeking out behind it),
///  • a light, friendly soft-colour palette (white card, pastel accents),
///  • a progress ring + bar showing how much of the deck is mastered.
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

    // "Mastered" share = cards that aren't currently due. New decks → 0%.
    final mastered = deck.cardCount > 0
        ? ((deck.cardCount - deck.dueCount).clamp(0, deck.cardCount)) /
            deck.cardCount
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // ── Stacked-deck layers peeking out behind the main card ────────
          Positioned(
            top: 0,
            left: 18,
            right: 6,
            child: _StackLayer(color: cover.withValues(alpha: 0.22), height: 34),
          ),
          Positioned(
            top: 7,
            left: 10,
            right: 6,
            child: _StackLayer(color: cover.withValues(alpha: 0.40), height: 34),
          ),
          // ── Main (light) card ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              decoration: BoxDecoration(
                color: tokens.backgroundSurface,
                borderRadius: BorderRadius.circular(tokens.radiusLg),
                border: Border.all(color: cover.withValues(alpha: 0.22)),
                boxShadow: [
                  BoxShadow(
                    color: cover.withValues(alpha: 0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(tokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RingBadge(
                          progress: mastered,
                          color: cover,
                          initial: initial,
                        ),
                        const Spacer(),
                        if (deck.isFavorite)
                          Padding(
                            padding: const EdgeInsets.only(right: 2, top: 2),
                            child: Icon(Icons.favorite_rounded,
                                size: 15, color: tokens.stateError),
                          ),
                        GestureDetector(
                          onTap: onActionsTap,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Icon(Icons.more_horiz_rounded,
                                size: 20, color: tokens.textTertiary),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      deck.title,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tokens.space4),
                    Row(
                      children: [
                        Text(
                          l.marketplaceCardCount(deck.cardCount),
                          style: tt.labelSmall?.copyWith(
                            color: tokens.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (deck.dueCount > 0) ...[
                          SizedBox(width: tokens.space8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: tokens.stateError,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: tokens.space4),
                          Text(
                            '${deck.dueCount}',
                            style: tt.labelSmall?.copyWith(
                              color: tokens.stateError,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        if (deck.isArchived) ...[
                          SizedBox(width: tokens.space8),
                          Icon(Icons.archive_rounded,
                              size: 12, color: tokens.textTertiary),
                        ],
                      ],
                    ),
                    SizedBox(height: tokens.space10),
                    // Progress bar — how much of the deck is mastered.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(tokens.radiusFull),
                      child: Stack(
                        children: [
                          Container(height: 5, color: tokens.surfaceSubtle),
                          FractionallySizedBox(
                            widthFactor: mastered.clamp(0.04, 1.0),
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    cover,
                                    Color.lerp(cover, Colors.white, 0.30)!,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

/// One of the offset "cards" peeking out from behind the main deck card.
class _StackLayer extends StatelessWidget {
  const _StackLayer({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
}

/// A soft progress ring with the deck initial on a pastel disc in its centre.
class _RingBadge extends StatelessWidget {
  const _RingBadge({
    required this.progress,
    required this.color,
    required this.initial,
  });

  final double progress;
  final Color color;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(
        painter: _RingPainter(progress: progress.clamp(0.0, 1.0), color: color),
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = color.withValues(alpha: 0.16);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [color, Color.lerp(color, Colors.white, 0.4)!],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, track);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
