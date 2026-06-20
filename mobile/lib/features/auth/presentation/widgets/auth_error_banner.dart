import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({
    required this.message,
    required this.tokens,
    required this.onDismiss,
    super.key,
  });

  final String message;
  final AuroraTokens tokens;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.space12),
      decoration: BoxDecoration(
        color: tokens.stateErrorSurface,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.stateError.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: tokens.stateError, size: 18),
          SizedBox(width: tokens.space8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: tokens.stateError,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded, color: tokens.stateError, size: 16),
          ),
        ],
      ),
    );
  }
}
