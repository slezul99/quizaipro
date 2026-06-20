import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({required this.tokens, super.key});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: tokens.borderSubtle, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.space12),
          child: Text(
            AppLocalizations.of(context)!.authOrContinueWith,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: tokens.textTertiary,
            ),
          ),
        ),
        Expanded(child: Divider(color: tokens.borderSubtle, thickness: 1)),
      ],
    );
  }
}
