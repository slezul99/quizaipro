import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({
    required this.label,
    required this.tokens,
    required this.onTap,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final AuroraTokens tokens;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: isLoading ? null : tokens.brandGradient,
          color: isLoading ? tokens.borderDefault : null,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: tokens.brandGradientStart,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
