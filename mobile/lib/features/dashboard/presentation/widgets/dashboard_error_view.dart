import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class DashboardErrorView extends StatelessWidget {
  const DashboardErrorView({
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
                color: const Color(0xFFef4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFef4444),
                size: 36,
              ),
            ),
            SizedBox(height: tokens.space20),
            Text(
              message,
              style: tokens.bodyMedium.copyWith(color: tokens.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.space24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(retryLabel),
              style: FilledButton.styleFrom(
                backgroundColor: tokens.brandPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
