import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/activity_item.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/activity_item_tile.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_mode.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    super.key,
    required this.activity,
    required this.tokens,
    required this.titleLabel,
    required this.emptyLabel,
    required this.hasDueReviews,
  });

  final List<ActivityItem> activity;
  final AuroraTokens tokens;
  final String titleLabel;
  final String emptyLabel;
  final bool hasDueReviews;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleLabel,
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: tokens.space16),
        if (activity.isEmpty)
          _PremiumEmptyState(
            emptyLabel: emptyLabel,
            tokens: tokens,
            l10n: l10n,
            hasDueReviews: hasDueReviews,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activity.length,
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              final isLast = index == activity.length - 1;
              final item = activity[index];

              return Stack(
                children: [
                  // Vertical Timeline Line segment (zero intrinsic height overhead)
                  if (!(isFirst && isLast))
                    Positioned(
                      top: isFirst ? 28 : 0,
                      bottom: isLast ? null : 0,
                      height: isLast ? 28 : null,
                      left: 20, // Center of 40px icon space
                      child: Container(
                        width: 2,
                        color: tokens.borderStrong.withOpacity(0.3),
                      ),
                    ),
                  // Row content
                  Padding(
                    padding: EdgeInsets.only(bottom: tokens.space16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Timeline Node Icon/Dot
                        SizedBox(
                          width: 42,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tokens.backgroundCanvas,
                                border: Border.all(
                                  color: _typeColor(item.type, tokens),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  _typeIcon(item.type),
                                  size: 14,
                                  color: _typeColor(item.type, tokens),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: tokens.space12),
                        // Right Timeline Card
                        Expanded(
                          child: ActivityItemTile(
                            item: item,
                            tokens: tokens,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  IconData _typeIcon(ActivityType type) => switch (type) {
        ActivityType.study => Icons.menu_book_rounded,
        ActivityType.test => Icons.quiz_rounded,
        ActivityType.duel => Icons.sports_esports_rounded,
        ActivityType.aiTutor => Icons.smart_toy_rounded,
      };

  Color _typeColor(ActivityType type, AuroraTokens tokens) => switch (type) {
        ActivityType.study => tokens.brandGradientStart,
        ActivityType.test => tokens.brandGradientMid,
        ActivityType.duel => tokens.brandGradientEnd,
        ActivityType.aiTutor => tokens.stateInfo,
      };
}

class _PremiumEmptyState extends StatelessWidget {
  const _PremiumEmptyState({
    required this.emptyLabel,
    required this.tokens,
    required this.l10n,
    required this.hasDueReviews,
  });

  final String emptyLabel;
  final AuroraTokens tokens;
  final AppLocalizations l10n;
  final bool hasDueReviews;

  @override
  Widget build(BuildContext context) {
    // Gracefully split emptyLabel into title and description
    final parts = emptyLabel.split('. ');
    final title = parts.isNotEmpty ? parts[0] : emptyLabel;
    final description = parts.length > 1 ? parts[1] : '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space24,
        vertical: tokens.space32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.backgroundSurface.withOpacity(0.7),
            tokens.backgroundSurface.withOpacity(0.4),
          ],
        ),
        border: Border.all(
          color: tokens.borderDefault.withOpacity(0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(tokens.radiusL),
        boxShadow: tokens.shadowCard,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Illustration / Icon wrapper with glowing background
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  tokens.brandGradientStart.withOpacity(0.15),
                  tokens.brandGradientStart.withOpacity(0.0),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.history_toggle_off_rounded,
                size: 44,
                color: tokens.brandGradientStart.withOpacity(0.8),
              ),
            ),
          ),
          SizedBox(height: tokens.space20),
          // Title
          Text(
            title,
            style: tokens.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (description.isNotEmpty) ...[
            SizedBox(height: tokens.space8),
            // Description
            Text(
              description,
              style: tokens.bodySmall.copyWith(
                color: tokens.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: tokens.space24),
          // CTA Button
          SizedBox(
            height: 40,
            child: FilledButton(
              onPressed: () {
                if (hasDueReviews) {
                  context.pushNamed(
                    AppRoutes.studySessionName,
                    queryParameters: {
                      'mode': StudyMode.review.name,
                      'deckTitle': l10n.dashboardReadyToStudy,
                    },
                  );
                } else {
                  context.goNamed(AppRoutes.libraryName);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: tokens.brandPrimary,
                foregroundColor: tokens.textOnBrand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusM),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: tokens.space20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasDueReviews
                        ? Icons.play_arrow_rounded
                        : Icons.library_books_rounded,
                    size: 18,
                  ),
                  SizedBox(width: tokens.space8),
                  Text(
                    hasDueReviews ? l10n.dashboardStartStudying : l10n.navLibrary,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
