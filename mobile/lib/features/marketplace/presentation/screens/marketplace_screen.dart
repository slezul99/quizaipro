import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/subject.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_filter_notifier.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/explore_decks_notifier.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/subjects_notifier.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/collections_notifier.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/learning_paths_notifier.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/deck_card.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/collection_card.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/learning_path_card.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/marketplace_search_bar.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/filter_bottom_sheet.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/marketplace_shimmer.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/marketplace_error_view.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/subject_chip.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.aurora;
    final l = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.goNamed(AppRoutes.homeName);
      },
      child: Scaffold(
        backgroundColor: t.backgroundCanvas,
        body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: t.backgroundCanvas,
            title: Text(
              l.marketplaceTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            pinned: true,
            floating: true,
            snap: true,
            bottom: TabBar(
              controller: _tabCtrl,
              tabs: [
                Tab(text: l.marketplaceTabExplore),
                Tab(text: l.marketplaceTabCollections),
                Tab(text: l.marketplaceTabPaths),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _ExploreTab(tokens: t),
            _CollectionsTab(tokens: t),
            _PathsTab(tokens: t),
          ],
        ),
      ),
    ),
    );
  }
}

// ─── Explore Tab ────────────────────────────────────────────────────────────

class _ExploreTab extends ConsumerWidget {
  const _ExploreTab({required this.tokens});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final filter = ref.watch(marketplaceFilterNotifierProvider);
    final subjectsAsync = ref.watch(subjectsNotifierProvider);
    final decksAsync = ref.watch(exploreDecksNotifierProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(exploreDecksNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space20,
                tokens.space16,
                tokens.space20,
                tokens.space12,
              ),
              child: MarketplaceSearchBar(
                tokens: tokens,
                hintText: l.marketplaceSearchHint,
                onTap: () => context.pushNamed(AppRoutes.discoverSearchName),
                onFilterTap: () async {
                  final subjects = subjectsAsync.valueOrNull ?? <Subject>[];
                  final newFilter = await FilterBottomSheet.show(
                    context,
                    initialFilter: filter,
                    subjects: subjects,
                    tokens: tokens,
                    sortLabel: l.marketplaceFilterSort,
                    difficultyLabel: l.marketplaceFilterDifficulty,
                    proOnlyLabel: l.marketplaceFilterProOnly,
                    applyLabel: l.marketplaceFilterApply,
                    resetLabel: l.marketplaceFilterReset,
                    allSubjectsLabel: l.marketplaceFilterAllSubjects,
                  );
                  if (newFilter != null) {
                    ref
                        .read(marketplaceFilterNotifierProvider.notifier)
                        .setSort(newFilter.sortBy);
                    ref
                        .read(marketplaceFilterNotifierProvider.notifier)
                        .setDifficulty(newFilter.difficulty);
                    ref
                        .read(marketplaceFilterNotifierProvider.notifier)
                        .setProOnly(newFilter.proOnly);
                  }
                },
                hasActiveFilter: !filter.isDefault,
              ),
            ),
          ),

          // Subject chips
          subjectsAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox(height: 48)),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (subjects) => SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: tokens.space20),
                  scrollDirection: Axis.horizontal,
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => SizedBox(width: tokens.space8),
                  itemBuilder: (_, i) {
                    final s = subjects[i];
                    return SubjectChip(
                      subject: s,
                      selected: filter.subjectId == s.id,
                      tokens: tokens,
                      onTap: () {
                        final notifier = ref
                            .read(marketplaceFilterNotifierProvider.notifier);
                        if (filter.subjectId == s.id) {
                          notifier.setSubject(null);
                        } else {
                          notifier.setSubject(s.id);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: tokens.space16)),

          // Decks grid
          decksAsync.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: _ShimmerFill(),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: MarketplaceErrorView(
                message: e.toString(),
                onRetry: () =>
                    ref.invalidate(exploreDecksNotifierProvider),
                tokens: tokens,
                retryLabel: AppLocalizations.of(context)!.retry,
              ),
            ),
            data: (state) {
              if (state.items.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(tokens: tokens, message: l.marketplaceNoDecks),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: tokens.space20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      if (i == state.items.length) {
                        if (state.isLoadingMore) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(tokens.space16),
                              child: const CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (state.hasMore) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(exploreDecksNotifierProvider.notifier)
                                .loadMore();
                          });
                        }
                        return const SizedBox.shrink();
                      }
                      final deck = state.items[i];
                      return DeckCard(
                        deck: deck,
                        tokens: tokens,
                        onTap: () => context.pushNamed(
                          AppRoutes.discoverDeckName,
                          pathParameters: {'deckId': deck.id},
                        ),
                      );
                    },
                    childCount: state.items.length + (state.hasMore ? 1 : 0),
                  ),
                ),
              );
            },
          ),

          SliverToBoxAdapter(child: SizedBox(height: tokens.space32)),
        ],
      ),
    );
  }
}

// ─── Collections Tab ────────────────────────────────────────────────────────

class _CollectionsTab extends ConsumerWidget {
  const _CollectionsTab({required this.tokens});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final async = ref.watch(collectionsNotifierProvider);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(collectionsNotifierProvider.notifier).refresh(),
      child: async.when(
        loading: () => CollectionsShimmer(tokens: tokens),
        error: (e, _) => MarketplaceErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(collectionsNotifierProvider),
          tokens: tokens,
          retryLabel: l.retry,
        ),
        data: (state) {
          if (state.items.isEmpty) {
            return _EmptyState(tokens: tokens, message: l.marketplaceNoCollections);
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification &&
                  n.metrics.extentAfter < 200 &&
                  state.hasMore &&
                  !state.isLoadingMore) {
                ref
                    .read(collectionsNotifierProvider.notifier)
                    .loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: EdgeInsets.all(tokens.space20),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: tokens.space12),
              itemBuilder: (_, i) {
                if (i == state.items.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(tokens.space16),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }
                final c = state.items[i];
                return CollectionCard(
                  collection: c,
                  tokens: tokens,
                  onTap: () {},
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Paths Tab ───────────────────────────────────────────────────────────────

class _PathsTab extends ConsumerWidget {
  const _PathsTab({required this.tokens});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final async = ref.watch(learningPathsNotifierProvider);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(learningPathsNotifierProvider.notifier).refresh(),
      child: async.when(
        loading: () => CollectionsShimmer(tokens: tokens),
        error: (e, _) => MarketplaceErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(learningPathsNotifierProvider),
          tokens: tokens,
          retryLabel: l.retry,
        ),
        data: (state) {
          if (state.items.isEmpty) {
            return _EmptyState(tokens: tokens, message: l.marketplaceNoPaths);
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification &&
                  n.metrics.extentAfter < 200 &&
                  state.hasMore &&
                  !state.isLoadingMore) {
                ref
                    .read(learningPathsNotifierProvider.notifier)
                    .loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: EdgeInsets.all(tokens.space20),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: tokens.space12),
              itemBuilder: (_, i) {
                if (i == state.items.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(tokens.space16),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }
                final p = state.items[i];
                return LearningPathCard(
                  path: p,
                  tokens: tokens,
                  enrollLabel: l.marketplaceEnroll,
                  onTap: () {},
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tokens, required this.message});

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
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: tokens.textTertiary,
            ),
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

class _ShimmerFill extends StatelessWidget {
  const _ShimmerFill();

  @override
  Widget build(BuildContext context) {
    final t = context.aurora;
    return MarketplaceShimmer(tokens: t);
  }
}
