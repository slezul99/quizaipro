import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class MarketplaceErrorView extends StatelessWidget {
  const MarketplaceErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    required this.tokens,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final AuroraTokens tokens;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tokens.stateErrorSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                color: tokens.stateError,
                size: 36,
              ),
            ),
            SizedBox(height: tokens.space20),
            Text(
              message,
              style: tt.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.space24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(retryLabel),
              style: FilledButton.styleFrom(
                backgroundColor: tokens.brandGradientStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
