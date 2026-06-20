import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_detail.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/deck_detail_notifier.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/deck_preview_sheet.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/marketplace_error_view.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class DeckDetailScreen extends ConsumerWidget {
  const DeckDetailScreen({super.key, required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.aurora;
    final l = AppLocalizations.of(context)!;

    return ref.watch(deckDetailNotifierProvider(deckId)).when(
      loading: () => Scaffold(
        backgroundColor: t.backgroundCanvas,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: t.backgroundCanvas,
        appBar: AppBar(backgroundColor: t.backgroundCanvas),
        body: MarketplaceErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(deckDetailNotifierProvider(deckId)),
          tokens: t,
          retryLabel: l.retry,
        ),
      ),
      data: (state) => _DeckDetailContent(
        deckId: deckId,
        state: state,
        tokens: t,
        l: l,
      ),
    );
  }
}

class _DeckDetailContent extends ConsumerWidget {
  const _DeckDetailContent({
    required this.deckId,
    required this.state,
    required this.tokens,
    required this.l,
  });

  final String deckId;
  final DeckDetailState state;
  final AuroraTokens tokens;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = state.detail;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) context.pop();
      },
      child: Scaffold(
        backgroundColor: tokens.backgroundCanvas,
      body: CustomScrollView(
        slivers: [
          _DeckSliverHeader(detail: detail, tokens: tokens),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(tokens.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  _StatsRow(detail: detail, tokens: tokens, l: l),
                  SizedBox(height: tokens.space20),

                  // Description
                  if (detail.description.isNotEmpty) ...[
                    Text(l.marketplaceDeckAbout,
                        style: Theme.of(context).textTheme.titleSmall),
                    SizedBox(height: tokens.space8),
                    Text(
                      detail.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.textSecondary,
                          ),
                    ),
                    SizedBox(height: tokens.space20),
                  ],

                  // Tags
                  if (detail.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: tokens.space8,
                      runSpacing: tokens.space8,
                      children: detail.tags
                          .map(
                            (tag) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: tokens.space12,
                                vertical: tokens.space4,
                              ),
                              decoration: BoxDecoration(
                                color: tokens.backgroundSurfaceElevated,
                                borderRadius:
                                    BorderRadius.circular(tokens.radiusFull),
                                border: Border.all(color: tokens.borderSubtle),
                              ),
                              child: Text(
                                '#$tag',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: tokens.textSecondary),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: tokens.space20),
                  ],

                  // Preview cards button
                  if (state.previewCards.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => _showPreview(context, state, detail),
                      icon: const Icon(Icons.flip_rounded),
                      label: Text(l.marketplaceDeckPreview),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(tokens.radiusMd),
                        ),
                      ),
                    ),

                  SizedBox(height: tokens.space16),

                  // Clone error
                  if (state.cloneError != null)
                    Container(
                      padding: EdgeInsets.all(tokens.space12),
                      margin: EdgeInsets.only(bottom: tokens.space12),
                      decoration: BoxDecoration(
                        color: tokens.stateErrorSurface,
                        borderRadius: BorderRadius.circular(tokens.radiusMd),
                      ),
                      child: Text(
                        state.cloneError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.stateError,
                            ),
                      ),
                    ),

                  // Clone button
                  _CloneButton(
                    detail: detail,
                    isCloning: state.isCloning,
                    tokens: tokens,
                    l: l,
                    onClone: () => ref
                        .read(deckDetailNotifierProvider(deckId).notifier)
                        .cloneDeck(),
                  ),

                  SizedBox(height: tokens.space32),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  void _showPreview(
    BuildContext context,
    DeckDetailState state,
    DeckDetail detail,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: tokens.backgroundSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusXl)),
      ),
      builder: (_) => DeckPreviewSheet(
        cards: state.previewCards,
        deckTitle: detail.title,
        tokens: tokens,
        previewLabel: l.marketplaceDeckPreview,
        frontLabel: l.marketplaceCardFront,
        backLabel: l.marketplaceCardBack,
      ),
    );
  }
}

class _DeckSliverHeader extends StatelessWidget {
  const _DeckSliverHeader({
    required this.detail,
    required this.tokens,
  });

  final DeckDetail detail;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final coverColor = _hexToColor(detail.coverColorHex);
    final tt = Theme.of(context).textTheme;

    return SliverAppBar(
      backgroundColor: tokens.backgroundCanvas,
      expandedHeight: 220,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: coverColor,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [coverColor, coverColor.withOpacity(0.6)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(tokens.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (detail.isPro)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.space8,
                        vertical: tokens.space4,
                      ),
                      decoration: BoxDecoration(
                        gradient: tokens.brandGradient,
                        borderRadius: BorderRadius.circular(tokens.radiusFull),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.marketplaceProBadge,
                        style: tt.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  SizedBox(height: tokens.space8),
                  Text(
                    detail.title,
                    style: tt.headlineSmall?.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.space4),
                  Text(
                    detail.authorName,
                    style: tt.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.detail,
    required this.tokens,
    required this.l,
  });

  final DeckDetail detail;
  final AuroraTokens tokens;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
          icon: Icons.style_outlined,
          value: '${detail.cardCount}',
          label: l.marketplaceCards,
          tokens: tokens,
        ),
        _StatItem(
          icon: Icons.star_rounded,
          value: detail.rating.toStringAsFixed(1),
          label: l.marketplaceRating,
          tokens: tokens,
          iconColor: const Color(0xFFF59E0B),
        ),
        _StatItem(
          icon: Icons.file_copy_outlined,
          value: '${detail.cloneCount}',
          label: l.marketplaceClones,
          tokens: tokens,
        ),
        _StatItem(
          icon: Icons.favorite_border_rounded,
          value: '${detail.likeCount}',
          label: l.marketplaceLikes,
          tokens: tokens,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.tokens,
    this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final AuroraTokens tokens;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: tokens.space12),
        margin: EdgeInsets.only(right: tokens.space8),
        decoration: BoxDecoration(
          color: tokens.backgroundSurface,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor ?? tokens.brandGradientStart),
            SizedBox(height: tokens.space4),
            Text(value,
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(label,
                style: tt.labelSmall?.copyWith(color: tokens.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class _CloneButton extends StatelessWidget {
  const _CloneButton({
    required this.detail,
    required this.isCloning,
    required this.tokens,
    required this.l,
    required this.onClone,
  });

  final DeckDetail detail;
  final bool isCloning;
  final AuroraTokens tokens;
  final AppLocalizations l;
  final VoidCallback onClone;

  @override
  Widget build(BuildContext context) {
    if (detail.isClonedByUser) {
      return Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: tokens.stateSuccessSurface,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.stateSuccess.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded,
                color: tokens.stateSuccess, size: 20),
            SizedBox(width: tokens.space8),
            Text(
              l.marketplaceDeckAlreadyCloned,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.stateSuccess,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    return FilledButton(
      onPressed: isCloning ? null : onClone,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: tokens.brandGradientStart,
        disabledBackgroundColor: tokens.brandGradientStart.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
      ),
      child: isCloning
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(l.marketplaceDeckClone),
    );
  }
}
