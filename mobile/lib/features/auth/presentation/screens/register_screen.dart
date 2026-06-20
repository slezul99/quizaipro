import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/auth_back_app_bar.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/register_form_body.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: tokens.backgroundCanvas,
      body: Stack(
        children: [
          AuthGradientHeader(tokens: tokens),
          SafeArea(
            child: Column(
              children: [
                AuthBackAppBar(onBack: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(tokens.space24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: tokens.space48),
                        Text(
                          l10n.authRegisterTitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: tokens.textPrimary),
                        ),
                        SizedBox(height: tokens.space8),
                        Text(
                          l10n.authRegisterSubtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: tokens.textSecondary),
                        ),
                        SizedBox(height: tokens.space32),
                        const RegisterFormBody(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
