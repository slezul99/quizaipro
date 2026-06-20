import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class LibrarySearchBar extends StatelessWidget {
  const LibrarySearchBar({
    super.key,
    required this.tokens,
    required this.hintText,
    required this.onTap,
  });

  final AuroraTokens tokens;
  final String hintText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: tokens.backgroundSurface,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderDefault),
        ),
        child: Row(
          children: [
            SizedBox(width: tokens.space16),
            Icon(Icons.search_rounded, color: tokens.textTertiary, size: 20),
            SizedBox(width: tokens.space12),
            Text(
              hintText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
