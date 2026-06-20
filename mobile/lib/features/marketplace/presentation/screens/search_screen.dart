import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/subject.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_filter_notifier.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/subjects_notifier.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/search_notifier.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/deck_card.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/filter_bottom_sheet.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/marketplace_error_view.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/marketplace_search_bar.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _ctrl;
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.extentAfter < 200) {
      ref.read(searchNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.aurora;
    final l = AppLocalizations.of(context)!;
    final filter = ref.watch(marketplaceFilterNotifierProvider);
    final subjectsAsync = ref.watch(subjectsNotifierProvider);
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      backgroundColor: t.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: t.backgroundCanvas,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(right: t.space16),
          child: MarketplaceSearchBar(
            tokens: t,
            hintText: l.marketplaceSearchHint,
            onTap: null,
            readOnly: false,
            controller: _ctrl,
            autofocus: true,
            onChanged: (q) {
              if (q.isEmpty) {
                ref.read(searchNotifierProvider.notifier).clear();
              }
            },
            onSubmitted: (q) {
              if (q.trim().isNotEmpty) {
                ref.read(searchNotifierProvider.notifier).search(q.trim());
              }
            },
            onFilterTap: () async {
              final subjects = subjectsAsync.valueOrNull ?? <Subject>[];
              final newFilter = await FilterBottomSheet.show(
                context,
                initialFilter: filter,
                subjects: subjects,
                tokens: t,
                sortLabel: l.marketplaceFilterSort,
                difficultyLabel: l.marketplaceFilterDifficulty,
                proOnlyLabel: l.marketplaceFilterProOnly,
                applyLabel: l.marketplaceFilterApply,
                resetLabel: l.marketplaceFilterReset,
                allSubjectsLabel: l.marketplaceFilterAllSubjects,
              );
              if (newFilter != null) {
                ref
                    .read(searchNotifierProvider.notifier)
                    .applyFilter(newFilter);
              }
            },
            hasActiveFilter: !filter.isDefault,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          final state = searchState;

          if (state.isSearching && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.searchFailure != null) {
            return MarketplaceErrorView(
              message: state.searchFailure!.userMessage,
              onRetry: () => ref
                  .read(searchNotifierProvider.notifier)
                  .search(_ctrl.text.trim()),
              tokens: t,
              retryLabel: l.retry,
            );
          }

          if (state.isIdle) {
            return _IdleHint(tokens: t, message: l.marketplaceSearchIdle);
          }

          if (state.isEmpty && !state.isLoadingMore) {
            return _EmptyResults(tokens: t, message: l.marketplaceSearchEmpty);
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification &&
                  n.metrics.extentAfter < 200 &&
                  state.hasMore &&
                  !state.isLoadingMore) {
                ref.read(searchNotifierProvider.notifier).loadMore();
              }
              return false;
            },
            child: GridView.builder(
              controller: _scrollCtrl,
              padding: EdgeInsets.all(t.space20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: state.items.length + (state.isLoadingMore ? 2 : 0),
              itemBuilder: (_, i) {
                if (i >= state.items.length) {
                  return Container(
                    decoration: BoxDecoration(
                      color: t.backgroundSurfaceElevated,
                      borderRadius: BorderRadius.circular(t.radiusLg),
                    ),
                  );
                }
                final deck = state.items[i];
                return DeckCard(
                  deck: deck,
                  tokens: t,
                  onTap: () => context.pushNamed(
                    AppRoutes.discoverDeckName,
                    pathParameters: {'deckId': deck.id},
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _IdleHint extends StatelessWidget {
  const _IdleHint({required this.tokens, required this.message});

  final AuroraTokens tokens;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 56, color: tokens.textTertiary),
            SizedBox(height: tokens.space16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.tokens, required this.message});

  final AuroraTokens tokens;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.find_in_page_outlined, size: 56, color: tokens.textTertiary),
            SizedBox(height: tokens.space16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
