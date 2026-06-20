import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/activity_item.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// Full-screen detail for a single recent-activity entry. Replaces the old
/// inline expand-in-place: tapping an activity item now opens this page, so the
/// home feed stays compact and the Q&A review gets room to breathe.
class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key, required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: tokens.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: tokens.backgroundCanvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: tokens.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          item.title,
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.w800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.space20,
          tokens.space8,
          tokens.space20,
          tokens.space32,
        ),
        children: [
          _SummaryHeader(item: item, tokens: tokens, l10n: l10n),
          SizedBox(height: tokens.space20),
          Text(
            l10n.aiExplainQuestion.toUpperCase(),
            style: tokens.labelMedium.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: tokens.textTertiary,
            ),
          ),
          SizedBox(height: tokens.space12),
          ...item.map(
            study: (s) => s.details
                .map((d) => _StudyDetailCard(detail: d, tokens: tokens, l10n: l10n))
                .toList(),
            test: (t) => t.details
                .map((d) => _TestDetailCard(detail: d, tokens: tokens, l10n: l10n))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.item,
    required this.tokens,
    required this.l10n,
  });

  final ActivityItem item;
  final AuroraTokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = item.map(
      study: (s) => (Icons.menu_book_rounded, l10n.dashboardActivitySummary(s.cardsReviewed, '').trim()),
      test: (t) {
        final pct =
            t.totalQuestions > 0 ? (t.correctCount * 100 ~/ t.totalQuestions) : 0;
        return (Icons.quiz_rounded, '$pct% (${t.correctCount}/${t.totalQuestions})');
      },
    );

    return Container(
      padding: EdgeInsets.all(tokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tokens.brandGradientStart, tokens.brandGradientEnd],
        ),
        borderRadius: BorderRadius.circular(tokens.radiusL),
        boxShadow: tokens.shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          SizedBox(width: tokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timeAgo(l10n, item.timestamp),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '+${item.xpEarned} XP',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(AppLocalizations l10n, DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 60) return l10n.dashboardTimeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.dashboardTimeAgoHours(diff.inHours);
    return l10n.dashboardTimeAgoDays(diff.inDays);
  }
}

class _StudyDetailCard extends StatelessWidget {
  const _StudyDetailCard({
    required this.detail,
    required this.tokens,
    required this.l10n,
  });

  final StudyCardReviewDetail detail;
  final AuroraTokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: tokens.space12),
      padding: EdgeInsets.all(tokens.space16),
      decoration: BoxDecoration(
        color: tokens.surfaceCard,
        borderRadius: BorderRadius.circular(tokens.radiusL),
        boxShadow: tokens.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.front,
            style: tokens.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: tokens.space12),
          _AnswerPill(
            label: l10n.aiExplainAnswer,
            text: detail.back,
            color: tokens.stateSuccess,
            surface: tokens.stateSuccessSurface,
            tokens: tokens,
          ),
          if (detail.explanation != null && detail.explanation!.isNotEmpty) ...[
            SizedBox(height: tokens.space12),
            Text(
              detail.explanation!,
              style: tokens.bodySmall.copyWith(
                color: tokens.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: tokens.space12),
          Row(
            children: [
              _GradeBadge(grade: detail.grade, tokens: tokens, l10n: l10n),
              const Spacer(),
              Text(
                '+${detail.xpEarned} XP',
                style: tokens.labelMedium.copyWith(
                  color: tokens.brandPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestDetailCard extends StatelessWidget {
  const _TestDetailCard({
    required this.detail,
    required this.tokens,
    required this.l10n,
  });

  final TestQuestionAttemptDetail detail;
  final AuroraTokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: tokens.space12),
      padding: EdgeInsets.all(tokens.space16),
      decoration: BoxDecoration(
        color: tokens.surfaceCard,
        borderRadius: BorderRadius.circular(tokens.radiusL),
        boxShadow: tokens.shadowCard,
        border: Border.all(
          color: (detail.isCorrect ? tokens.stateSuccess : tokens.stateError)
              .withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                detail.isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 18,
                color: detail.isCorrect ? tokens.stateSuccess : tokens.stateError,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  detail.front,
                  style: tokens.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space12),
          // Wrong answer: show what the learner picked, then the correct one.
          if (!detail.isCorrect && detail.selectedAnswer != null) ...[
            _AnswerPill(
              label: l10n.flashcardsAgain,
              text: detail.selectedAnswer!,
              color: tokens.stateError,
              surface: tokens.stateErrorSurface,
              tokens: tokens,
            ),
            SizedBox(height: tokens.space8),
          ],
          _AnswerPill(
            label: l10n.aiExplainAnswer,
            text: detail.correctAnswer,
            color: tokens.stateSuccess,
            surface: tokens.stateSuccessSurface,
            tokens: tokens,
          ),
          SizedBox(height: tokens.space12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '+${detail.xpEarned} XP',
              style: tokens.labelMedium.copyWith(
                color: detail.isCorrect ? tokens.stateSuccess : tokens.textTertiary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerPill extends StatelessWidget {
  const _AnswerPill({
    required this.label,
    required this.text,
    required this.color,
    required this.surface,
    required this.tokens,
  });

  final String label;
  final String text;
  final Color color;
  final Color surface;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space12,
        vertical: tokens.space8,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(tokens.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tokens.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({
    required this.grade,
    required this.tokens,
    required this.l10n,
  });

  final int grade;
  final AuroraTokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (label, textColor, bgColor) = _style();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space12,
        vertical: tokens.space4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(tokens.radiusM),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: tokens.labelMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  (String, Color, Color) _style() {
    if (grade <= 1) {
      return (l10n.flashcardsAgain, tokens.stateError, tokens.stateErrorSurface);
    } else if (grade <= 3) {
      return (l10n.flashcardsHard, tokens.stateWarning, tokens.stateWarningSurface);
    } else if (grade == 4) {
      return (l10n.flashcardsGood, tokens.stateInfo, tokens.stateInfoSurface);
    }
    return (l10n.flashcardsEasy, tokens.stateSuccess, tokens.stateSuccessSurface);
  }
}
