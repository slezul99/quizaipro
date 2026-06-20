import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

enum PasswordStrength {
  empty,
  weak,
  fair,
  strong,
  veryStrong;

  static PasswordStrength evaluate(String password) {
    if (password.isEmpty) return empty;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return switch (score) {
      1 => weak,
      2 => fair,
      3 || 4 => strong,
      _ => veryStrong,
    };
  }

  String label(AppLocalizations l10n) => switch (this) {
        empty => '',
        weak => l10n.authPasswordStrengthWeak,
        fair => l10n.authPasswordStrengthFair,
        strong => l10n.authPasswordStrengthStrong,
        veryStrong => l10n.authPasswordStrengthVeryStrong,
      };

  int get filledSegments => switch (this) {
        empty => 0,
        weak => 1,
        fair => 2,
        strong => 3,
        veryStrong => 4,
      };
}

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({
    required this.strength,
    required this.tokens,
    super.key,
  });

  final PasswordStrength strength;
  final AuroraTokens tokens;

  Color _color() => switch (strength) {
        PasswordStrength.weak => tokens.stateError,
        PasswordStrength.fair => tokens.stateWarning,
        PasswordStrength.strong => tokens.stateSuccess,
        PasswordStrength.veryStrong => tokens.stateSuccess,
        _ => tokens.borderDefault,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              final filled = i < strength.filledSegments;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 3,
                  margin: EdgeInsets.only(right: i < 3 ? tokens.space4 : 0),
                  decoration: BoxDecoration(
                    color: filled ? color : tokens.borderSubtle,
                    borderRadius: BorderRadius.circular(tokens.radiusFull),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(width: tokens.space8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            strength.label(l10n),
            key: ValueKey(strength),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
