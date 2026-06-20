import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/collection.dart';

class CollectionCard extends StatelessWidget {
  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
    required this.tokens,
  });

  final Collection collection;
  final VoidCallback onTap;
  final AuroraTokens tokens;

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Color swatch
            Container(
              width: 72,
              height: 88,
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(tokens.radiusLg),
                ),
              ),
              child: Icon(
                Icons.collections_bookmark_rounded,
                color: Colors.white.withOpacity(0.85),
                size: 32,
              ),
            ),
            // Info
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
                    SizedBox(height: tokens.space4),
                    Text(
                      collection.description,
                      style: tt.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tokens.space8),
                    Row(
                      children: [
                        Icon(
                          Icons.style_outlined,
                          size: 13,
                          color: tokens.textTertiary,
                        ),
                        SizedBox(width: tokens.space4),
                        Text(
                          AppLocalizations.of(context)!.marketplaceDeckCount(collection.deckCount),
                          style: tt.labelSmall,
                        ),
                        SizedBox(width: tokens.space12),
                        Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: tokens.textTertiary,
                        ),
                        SizedBox(width: tokens.space4),
                        Expanded(
                          child: Text(
                            collection.curatorName,
                            style: tt.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
