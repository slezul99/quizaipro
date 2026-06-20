import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class LibraryEmptyState extends StatelessWidget {
  const LibraryEmptyState({
    super.key,
    required this.tokens,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.actionLabel,
  });

  final AuroraTokens tokens;
  final String message;
  final IconData icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: tokens.textTertiary),
            SizedBox(height: tokens.space16),
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: tokens.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (action != null && actionLabel != null) ...[
              SizedBox(height: tokens.space24),
              FilledButton(
                onPressed: action,
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.brandGradientStart,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
