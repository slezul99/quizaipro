import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    super.key,
    required this.tokens,
    required this.studyLabel,
    required this.discoverLabel,
    required this.aiTutorLabel,
    required this.aiStudioLabel,
  });

  final AuroraTokens tokens;
  final String studyLabel;
  final String discoverLabel;
  final String aiTutorLabel;
  final String aiStudioLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.school_rounded,
            label: studyLabel,
            gradient: tokens.brandGradient,
            onTap: () => context.pushNamed(
              AppRoutes.studySessionName,
              queryParameters: {
                'deckTitle': AppLocalizations.of(context)!.dashboardReadyToStudy,
              },
            ),
            tokens: tokens,
          ),
        ),
        SizedBox(width: tokens.space12),
        Expanded(
          child: _ActionButton(
            icon: Icons.explore_rounded,
            label: discoverLabel,
            gradient: LinearGradient(
              colors: [const Color(0xFF06b6d4), const Color(0xFF3b82f6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => context.goNamed(AppRoutes.discoverName),
            tokens: tokens,
          ),
        ),
        SizedBox(width: tokens.space12),
        Expanded(
          child: _ActionButton(
            icon: Icons.smart_toy_rounded,
            label: aiTutorLabel,
            gradient: LinearGradient(
              colors: [const Color(0xFF8b5cf6), const Color(0xFFec4899)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => context.pushNamed(AppRoutes.tutorName),
            tokens: tokens,
          ),
        ),
        SizedBox(width: tokens.space12),
        Expanded(
          child: _ActionButton(
            icon: Icons.auto_awesome_rounded,
            label: aiStudioLabel,
            gradient: LinearGradient(
              colors: [const Color(0xFFf59e0b), const Color(0xFFef4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () =>
                context.pushNamed(AppRoutes.aiGenerationStudioName),
            tokens: tokens,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    required this.tokens,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: tokens.space16,
          horizontal: tokens.space4,
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(tokens.radiusL),
          boxShadow: tokens.shadowCard,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(height: tokens.space8),
            Text(
              label,
              style: tokens.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
