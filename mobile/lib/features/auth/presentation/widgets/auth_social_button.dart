import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    required this.label,
    required this.fallbackIcon,
    required this.tokens,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData fallbackIcon;
  final AuroraTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: tokens.borderDefault),
        foregroundColor: tokens.textPrimary,
        backgroundColor: tokens.backgroundSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(fallbackIcon, size: 22, color: tokens.textSecondary),
          SizedBox(width: tokens.space8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: tokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
