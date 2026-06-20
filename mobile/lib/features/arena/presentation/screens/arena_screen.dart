import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: tokens.backgroundCanvas,
      appBar: AppBar(title: Text(l10n.navArena)),
      body: Center(
        child: Text(
          l10n.arenaComingSoon,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: tokens.textTertiary),
        ),
      ),
    );
  }
}
