import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class LibraryDeckListTile extends StatelessWidget {
  const LibraryDeckListTile({
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
    final l10n = AppLocalizations.of(context)!;
    final coverColor = _hexToColor(deck.coverColorHex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tokens.backgroundSurface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: tokens.borderSubtle),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space12,
          vertical: tokens.space12,
        ),
        child: Row(
          children: [
            // Color swatch
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
              ),
              child: deck.isArchived
                  ? Icon(
                      Icons.archive_outlined,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    )
                  : null,
            ),
            SizedBox(width: tokens.space12),
            // Title & stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.title,
                    style: tt.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.space4),
                  Row(
                    children: [
                      Icon(Icons.style_outlined,
                          size: 13, color: tokens.textTertiary),
                      SizedBox(width: tokens.space4),
                      Text(
                        l10n.marketplaceCardCount(deck.cardCount),
                        style: tt.labelSmall,
                      ),
                      if (deck.dueCount > 0) ...[
                        SizedBox(width: tokens.space8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.space8,
                            vertical: tokens.space2,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.stateErrorSurface,
                            borderRadius:
                                BorderRadius.circular(tokens.radiusFull),
                          ),
                          child: Text(
                            l10n.libraryDueCount(deck.dueCount),
                            style: tt.labelSmall?.copyWith(
                              color: tokens.stateError,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (deck.isFavorite)
              Padding(
                padding: EdgeInsets.only(right: tokens.space4),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: tokens.stateError,
                ),
              ),
            IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                color: tokens.textTertiary,
              ),
              onPressed: onActionsTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
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
