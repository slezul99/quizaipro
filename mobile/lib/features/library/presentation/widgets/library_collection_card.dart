import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_collection.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class LibraryCollectionCard extends StatelessWidget {
  const LibraryCollectionCard({
    super.key,
    required this.collection,
    required this.tokens,
    required this.onTap,
  });

  final LibraryCollection collection;
  final AuroraTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final coverColor = _hexToColor(collection.coverColorHex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tokens.backgroundSurface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: tokens.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 80,
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(tokens.radiusLg),
                ),
              ),
              child: Icon(
                Icons.collections_bookmark_rounded,
                color: Colors.white.withOpacity(0.85),
                size: 30,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(tokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: tt.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (collection.description.isNotEmpty) ...[
                      SizedBox(height: tokens.space4),
                      Text(
                        collection.description,
                        style: tt.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: tokens.space8),
                    Row(
                      children: [
                        Icon(Icons.style_outlined,
                            size: 13, color: tokens.textTertiary),
                        SizedBox(width: tokens.space4),
                        Text(
                          AppLocalizations.of(context)!
                              .marketplaceDeckCount(collection.deckCount),
                          style: tt.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: tokens.space12),
              child: Icon(
                Icons.chevron_right_rounded,
                color: tokens.textTertiary,
              ),
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
