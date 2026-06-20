import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/auth_or_divider.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class WelcomeActionCard extends StatelessWidget {
  const WelcomeActionCard({
    required this.tokens,
    required this.socialLoading,
    required this.onGetStarted,
    required this.onLogin,
    required this.onGoogle,
    required this.onApple,
    super.key,
  });

  final AuroraTokens tokens;
  final bool socialLoading;
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radiusXl),
        child: Container(
          decoration: BoxDecoration(
            color: tokens.backgroundSurface.withAlpha(230),
            borderRadius: BorderRadius.circular(tokens.radiusXl),
            border: Border.all(color: Colors.white.withAlpha(51)),
          ),
          padding: EdgeInsets.all(tokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthGradientButton(
                label: l10n.authGetStarted,
                tokens: tokens,
                onTap: onGetStarted,
              ),
              SizedBox(height: tokens.space12),
              OutlinedButton(
                onPressed: onLogin,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(color: tokens.brandGradientStart, width: 1.5),
                  foregroundColor: tokens.brandGradientStart,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                ),
                child: Text(
                  l10n.authAlreadyHaveAccount,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(height: tokens.space20),
              AuthOrDivider(tokens: tokens),
              SizedBox(height: tokens.space16),
              if (socialLoading)
                Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: tokens.brandGradientStart,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    AuthSocialButton(
                      label: l10n.authContinueWithGoogle,
                      fallbackIcon: Icons.g_mobiledata_rounded,
                      tokens: tokens,
                      onTap: onGoogle,
                    ),
                    if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                      SizedBox(height: tokens.space12),
                      AuthSocialButton(
                        label: l10n.authContinueWithApple,
                        fallbackIcon: Icons.apple_rounded,
                        tokens: tokens,
                        onTap: onApple,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
