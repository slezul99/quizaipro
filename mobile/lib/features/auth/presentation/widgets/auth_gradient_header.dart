import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

/// Renders the Aurora brand gradient as either a fixed-height top strip
/// (login / register screens) or a full-screen background (welcome screen).
class AuthGradientHeader extends StatelessWidget {
  const AuthGradientHeader({
    required this.tokens,
    this.fullScreen = false,
    super.key,
  });

  final AuroraTokens tokens;
  final bool fullScreen;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        tokens.brandGradientStart,
        tokens.brandGradientMid,
        tokens.brandGradientEnd,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    if (fullScreen) {
      return DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: const SizedBox.expand(),
      );
    }

    return SizedBox(
      height: 180,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: const SizedBox.expand(),
      ),
    );
  }
}
