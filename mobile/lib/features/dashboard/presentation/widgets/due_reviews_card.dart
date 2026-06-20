import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/due_reviews_summary.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_mode.dart';

class DueReviewsCard extends StatelessWidget {
  const DueReviewsCard({
    super.key,
    required this.dueReviews,
    required this.tokens,
    required this.titleLabel,
    required this.overdueLabel,
    required this.startLabel,
    required this.allCaughtUpLabel,
  });

  final DueReviewsSummary dueReviews;
  final AuroraTokens tokens;
  final String titleLabel;
  final String overdueLabel;
  final String startLabel;
  final String allCaughtUpLabel;

  @override
  Widget build(BuildContext context) {
    if (!dueReviews.hasDue) {
      return Container(
        padding: EdgeInsets.all(tokens.space20),
        decoration: BoxDecoration(
          color: tokens.surfaceCard,
          borderRadius: BorderRadius.circular(tokens.radiusL),
          boxShadow: tokens.shadowCard,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF22c55e).withOpacity(0.12),
                borderRadius: BorderRadius.circular(tokens.radiusM),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF22c55e),
              ),
            ),
            SizedBox(width: tokens.space12),
            Expanded(
              child: Text(
                allCaughtUpLabel,
                style: tokens.titleSmall.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(tokens.space20),
      decoration: BoxDecoration(
        color: tokens.surfaceCard,
        borderRadius: BorderRadius.circular(tokens.radiusL),
        boxShadow: tokens.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.brandPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(tokens.radiusM),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: tokens.brandPrimary,
                ),
              ),
              SizedBox(width: tokens.space12),
              Expanded(
                child: Text(
                  titleLabel,
                  style: tokens.titleSmall.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              _CountBadge(
                count: dueReviews.totalDue,
                hasOverdue: dueReviews.hasOverdue,
                tokens: tokens,
              ),
            ],
          ),
          if (dueReviews.hasOverdue) ...[
            SizedBox(height: tokens.space8),
            Text(
              '${dueReviews.overdue} $overdueLabel',
              style: tokens.bodySmall.copyWith(
                color: const Color(0xFFef4444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          SizedBox(height: tokens.space16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.pushNamed(
                AppRoutes.studySessionName,
                queryParameters: {
                  'mode': StudyMode.review.name,
                  'deckTitle': titleLabel,
                },
              ),
              style: FilledButton.styleFrom(
                backgroundColor: tokens.brandPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusM),
                ),
              ),
              child: Text(startLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.hasOverdue,
    required this.tokens,
  });

  final int count;
  final bool hasOverdue;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space12,
        vertical: tokens.space4,
      ),
      decoration: BoxDecoration(
        color: hasOverdue
            ? const Color(0xFFef4444).withOpacity(0.12)
            : tokens.brandPrimary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(tokens.radiusXL),
      ),
      child: Text(
        '$count',
        style: tokens.labelMedium.copyWith(
          color: hasOverdue ? const Color(0xFFef4444) : tokens.brandPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
