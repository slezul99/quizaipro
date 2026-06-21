import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_review.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/deck_reviews_notifier.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

const _amber = Color(0xFFF59E0B);

class DeckReviewsSection extends ConsumerWidget {
  const DeckReviewsSection({
    super.key,
    required this.deckId,
    required this.tokens,
    required this.l,
  });

  final String deckId;
  final AuroraTokens tokens;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final async = ref.watch(deckReviewsNotifierProvider(deckId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('⭐ ${l.marketplaceReviews}',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const Spacer(),
            async.maybeWhen(
              data: (r) => r.ratingCount > 0
                  ? Text('★ ${r.rating}  ·  ${r.ratingCount}',
                      style: tt.titleSmall?.copyWith(
                          color: _amber, fontWeight: FontWeight.w700))
                  : Text(l.marketplaceNoRatings,
                      style: tt.labelSmall?.copyWith(color: tokens.textTertiary)),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(height: tokens.space12),
        async.when(
          loading: () => Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.space16),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text(l.errorNetwork,
              style: TextStyle(color: tokens.textSecondary)),
          data: (r) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RateForm(deckId: deckId, mine: r.myReview, tokens: tokens, l: l),
              SizedBox(height: tokens.space16),
              if (r.reviews.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: tokens.space12),
                  child: Center(
                    child: Text(l.marketplaceNoReviews,
                        style: tt.bodySmall?.copyWith(color: tokens.textTertiary)),
                  ),
                )
              else
                ...r.reviews.map((rev) =>
                    _ReviewTile(deckId: deckId, review: rev, tokens: tokens, l: l)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Star picker + optional text → create/update the current user's review.
class _RateForm extends ConsumerStatefulWidget {
  const _RateForm({
    required this.deckId,
    required this.mine,
    required this.tokens,
    required this.l,
  });

  final String deckId;
  final DeckReview? mine;
  final AuroraTokens tokens;
  final AppLocalizations l;

  @override
  ConsumerState<_RateForm> createState() => _RateFormState();
}

class _RateFormState extends ConsumerState<_RateForm> {
  late int _stars = widget.mine?.stars ?? 0;
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.mine?.text ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars < 1) return;
    setState(() => _busy = true);
    await ref
        .read(deckReviewsNotifierProvider(widget.deckId).notifier)
        .submit(_stars, _ctrl.text.trim());
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _delete() async {
    setState(() => _busy = true);
    await ref
        .read(deckReviewsNotifierProvider(widget.deckId).notifier)
        .deleteMine();
    if (mounted) setState(() {
      _busy = false;
      _stars = 0;
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final l = widget.l;
    return Container(
      padding: EdgeInsets.all(t.space16),
      decoration: BoxDecoration(
        color: t.backgroundSurface,
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: t.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l.marketplaceRateThis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              for (var i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: _busy ? null : () => setState(() => _stars = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Icon(
                      i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: i <= _stars ? _amber : t.textTertiary,
                      size: 28,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: t.space8),
          TextField(
            controller: _ctrl,
            maxLines: 2,
            maxLength: 1000,
            enabled: !_busy,
            decoration: InputDecoration(
              hintText: l.marketplaceReviewHint,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(t.radiusMd),
              ),
            ),
          ),
          SizedBox(height: t.space8),
          Row(
            children: [
              FilledButton(
                onPressed: (_busy || _stars < 1) ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: t.brandGradientStart,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(t.radiusMd),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(widget.mine != null
                        ? l.marketplaceUpdateReview
                        : l.marketplaceSubmitReview),
              ),
              if (widget.mine != null)
                TextButton(
                  onPressed: _busy ? null : _delete,
                  child: Text(l.delete,
                      style: TextStyle(color: t.stateError)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends ConsumerWidget {
  const _ReviewTile({
    required this.deckId,
    required this.review,
    required this.tokens,
    required this.l,
  });

  final String deckId;
  final DeckReview review;
  final AuroraTokens tokens;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.only(bottom: tokens.space8),
      padding: EdgeInsets.all(tokens.space12),
      decoration: BoxDecoration(
        color: tokens.backgroundSurface,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(
          color: review.isMine
              ? tokens.brandGradientStart.withOpacity(0.4)
              : tokens.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.isMine ? l.marketplaceYou : review.author,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= review.stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: _amber,
                      size: 14,
                    ),
                ],
              ),
            ],
          ),
          if (review.text.isNotEmpty) ...[
            SizedBox(height: tokens.space4),
            Text(review.text,
                style: tt.bodySmall?.copyWith(color: tokens.textSecondary)),
          ],
          if (!review.isMine)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => ref
                    .read(deckReviewsNotifierProvider(deckId).notifier)
                    .report(review.id),
                icon: Icon(Icons.flag_outlined,
                    size: 14, color: tokens.textTertiary),
                label: Text(l.marketplaceReportReview,
                    style: tt.labelSmall?.copyWith(color: tokens.textTertiary)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
