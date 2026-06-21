import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/evolution_stage.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/evolution_tree_animation.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// First-look card that introduces the streak tree to new users: it shows their
/// current (early) tree and explains it will grow as they keep coming back.
/// Only surfaced for early stages so it doesn't nag established users.
class TreeIntroCard extends StatelessWidget {
  const TreeIntroCard({
    super.key,
    required this.tokens,
    required this.stage,
  });

  final AuroraTokens tokens;
  final EvolutionStage stage;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final accent = stage.palette.primary;

    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.streakJourneyName),
      child: Container(
        padding: EdgeInsets.all(tokens.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.16),
              accent.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: EvolutionTreeAnimation(stage: stage, size: 64),
            ),
            SizedBox(width: tokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🌱 ${l.streakTreeIntroTitle}',
                    style: tokens.titleSmall.copyWith(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: tokens.space4),
                  Text(
                    l.streakTreeIntroBody,
                    style: tokens.bodySmall.copyWith(
                      color: tokens.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: tokens.space8),
                  Row(
                    children: [
                      Text(
                        l.streakTreeIntroCta,
                        style: tokens.labelMedium.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 18, color: accent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
