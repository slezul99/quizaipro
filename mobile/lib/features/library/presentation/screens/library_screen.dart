import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/deck_actions_handler.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_collections_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_decks_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_favorites_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_filter_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_view_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/recent_decks_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/deck_actions_sheet.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_collection_card.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_deck_card.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_deck_list_tile.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_empty_state.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/deck_editor_sheet.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_filter_sheet.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_search_bar.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_shimmer.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_sort_sheet.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
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

    return Scaffold(
      backgroundColor: t.backgroundCanvas,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDeckEditorSheet(context),
        backgroundColor: t.brandPrimary,
        foregroundColor: t.textOnBrand,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Колода'),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: t.backgroundCanvas,
            title: Text(l.libraryTitle,
                style: Theme.of(context).textTheme.titleLarge),
            pinned: true,
            floating: true,
            snap: true,
            bottom: TabBar(
              controller: _tabCtrl,
              tabs: [
                Tab(text: l.libraryTabDecks),
                Tab(text: l.libraryTabCollections),
                Tab(text: l.libraryTabFavorites),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _DecksTab(tokens: t),
            _CollectionsTab(tokens: t),
            _FavoritesTab(tokens: t),
          ],
        ),
      ),
    );
  }
}

// ─── Decks Tab ───────────────────────────────────────────────────────────────

class _DecksTab extends ConsumerWidget {
  const _DecksTab({required this.tokens});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final filter = ref.watch(libraryFilterNotifierProvider);
    final isGrid = ref.watch(libraryViewNotifierProvider);
    final decksAsync = ref.watch(libraryDecksNotifierProvider);
    final recentAsync = ref.watch(recentDecksNotifierProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(libraryDecksNotifierProvider.notifier).refresh();
        await ref.read(recentDecksNotifierProvider.notifier).refresh();
      },
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
              child: LibrarySearchBar(
                tokens: tokens,
                hintText: l.librarySearchHint,
                onTap: () =>
                    context.pushNamed(AppRoutes.librarySearchName),
              ),
            ),
          ),

          // Recent decks
          recentAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (recents) {
              if (recents.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: _RecentSection(
                  decks: recents,
                  tokens: tokens,
                  label: l.libraryRecentDecks,
                ),
              );
            },
          ),

          // Sort/filter row
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space20,
                tokens.space4,
                tokens.space20,
                tokens.space12,
              ),
              child: _SortFilterRow(
                tokens: tokens,
                l: l,
                isGrid: isGrid,
                filter: filter,
              ),
            ),
          ),

          // Decks
          decksAsync.when(
            loading: () => SliverFillRemaining(
              hasScrollBody: false,
              child: LibraryShimmer(tokens: tokens, isGrid: isGrid),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorView(
                tokens: tokens,
                message: e.toString(),
                retryLabel: l.retry,
                onRetry: () => ref.invalidate(libraryDecksNotifierProvider),
              ),
            ),
            data: (state) {
              if (state.items.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: LibraryEmptyState(
                    tokens: tokens,
                    message: l.libraryNoDecks,
                    icon: Icons.style_outlined,
                  ),
                );
              }
              if (isGrid) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.space20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        if (i == state.items.length) {
                          if (state.isLoadingMore) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state.hasMore) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ref
                                  .read(libraryDecksNotifierProvider.notifier)
                                  .loadMore();
                            });
                          }
                          return const SizedBox.shrink();
                        }
                        final deck = state.items[i];
                        return LibraryDeckCard(
                          deck: deck,
                          tokens: tokens,
                          onTap: () => _openDeck(context, deck.id),
                          onActionsTap: () =>
                              _showActions(context, ref, deck, l),
                        );
                      },
                      childCount:
                          state.items.length + (state.hasMore ? 1 : 0),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: tokens.space20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      if (i == state.items.length) {
                        if (state.isLoadingMore) {
                          return Padding(
                            padding: EdgeInsets.all(tokens.space16),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (state.hasMore) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(libraryDecksNotifierProvider.notifier)
                                .loadMore();
                          });
                        }
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.only(bottom: tokens.space12),
                        child: LibraryDeckListTile(
                          deck: state.items[i],
                          tokens: tokens,
                          onTap: () => _openDeck(context, state.items[i].id),
                          onActionsTap: () =>
                              _showActions(context, ref, state.items[i], l),
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

  void _openDeck(BuildContext context, String deckId) {
    context.pushNamed(
      AppRoutes.libraryDeckName,
      pathParameters: {'deckId': deckId},
    );
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    LibraryDeck deck,
    AppLocalizations l,
  ) async {
    final action = await DeckActionsSheet.show(
      context,
      deck: deck,
      tokens: tokens,
      studyLabel: l.libraryActionStudy,
      favoriteLabel: l.libraryActionFavorite,
      unfavoriteLabel: l.libraryActionUnfavorite,
      archiveLabel: l.libraryActionArchive,
      unarchiveLabel: l.libraryActionUnarchive,
      deleteLabel: l.libraryActionDelete,
    );
    if (action == null || !context.mounted) return;
    await DeckActionsHandler.handle(
      context: context,
      ref: ref,
      deck: deck,
      action: action,
      tokens: tokens,
      l: l,
    );
  }
}

// ─── Collections Tab ─────────────────────────────────────────────────────────

class _CollectionsTab extends ConsumerWidget {
  const _CollectionsTab({required this.tokens});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final async = ref.watch(libraryCollectionsNotifierProvider);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(libraryCollectionsNotifierProvider.notifier).refresh(),
      child: async.when(
        loading: () => LibraryShimmer(tokens: tokens, isGrid: false),
        error: (e, _) => _ErrorView(
          tokens: tokens,
          message: e.toString(),
          retryLabel: l.retry,
          onRetry: () => ref.invalidate(libraryCollectionsNotifierProvider),
        ),
        data: (state) {
          if (state.items.isEmpty) {
            return LibraryEmptyState(
              tokens: tokens,
              message: l.libraryNoCollections,
              icon: Icons.collections_bookmark_outlined,
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification &&
                  n.metrics.extentAfter < 200 &&
                  state.hasMore &&
                  !state.isLoadingMore) {
                ref
                    .read(libraryCollectionsNotifierProvider.notifier)
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
                return LibraryCollectionCard(
                  collection: state.items[i],
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

// ─── Favorites Tab ───────────────────────────────────────────────────────────

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab({required this.tokens});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isGrid = ref.watch(libraryViewNotifierProvider);
    final async = ref.watch(libraryFavoritesNotifierProvider);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(libraryFavoritesNotifierProvider.notifier).refresh(),
      child: async.when(
        loading: () => LibraryShimmer(tokens: tokens, isGrid: isGrid),
        error: (e, _) => _ErrorView(
          tokens: tokens,
          message: e.toString(),
          retryLabel: l.retry,
          onRetry: () => ref.invalidate(libraryFavoritesNotifierProvider),
        ),
        data: (state) {
          if (state.items.isEmpty) {
            return LibraryEmptyState(
              tokens: tokens,
              message: l.libraryNoFavorites,
              icon: Icons.favorite_border_rounded,
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification &&
                  n.metrics.extentAfter < 200 &&
                  state.hasMore &&
                  !state.isLoadingMore) {
                ref
                    .read(libraryFavoritesNotifierProvider.notifier)
                    .loadMore();
              }
              return false;
            },
            child: isGrid
                ? GridView.builder(
                    padding: EdgeInsets.all(tokens.space20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount:
                        state.items.length + (state.isLoadingMore ? 2 : 0),
                    itemBuilder: (_, i) {
                      if (i >= state.items.length) {
                        return Container(
                          decoration: BoxDecoration(
                            color: tokens.backgroundSurfaceElevated,
                            borderRadius: BorderRadius.circular(tokens.radiusLg),
                          ),
                        );
                      }
                      final deck = state.items[i];
                      return LibraryDeckCard(
                        deck: deck,
                        tokens: tokens,
                        onTap: () => context.pushNamed(
                          AppRoutes.libraryDeckName,
                          pathParameters: {'deckId': deck.id},
                        ),
                        onActionsTap: () async {
                          final action = await DeckActionsSheet.show(
                            context,
                            deck: deck,
                            tokens: tokens,
                            studyLabel: l.libraryActionStudy,
                            favoriteLabel: l.libraryActionFavorite,
                            unfavoriteLabel: l.libraryActionUnfavorite,
                            archiveLabel: l.libraryActionArchive,
                            unarchiveLabel: l.libraryActionUnarchive,
                            deleteLabel: l.libraryActionDelete,
                          );
                          if (action == null || !context.mounted) return;
                          await DeckActionsHandler.handle(
                            context: context,
                            ref: ref,
                            deck: deck,
                            action: action,
                            tokens: tokens,
                            l: l,
                          );
                        },
                      );
                    },
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(tokens.space20),
                    itemCount:
                        state.items.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        SizedBox(height: tokens.space12),
                    itemBuilder: (_, i) {
                      if (i == state.items.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(tokens.space16),
                            child: const CircularProgressIndicator(),
                          ),
                        );
                      }
                      final deck = state.items[i];
                      return LibraryDeckListTile(
                        deck: deck,
                        tokens: tokens,
                        onTap: () => context.pushNamed(
                          AppRoutes.libraryDeckName,
                          pathParameters: {'deckId': deck.id},
                        ),
                        onActionsTap: () async {
                          final action = await DeckActionsSheet.show(
                            context,
                            deck: deck,
                            tokens: tokens,
                            studyLabel: l.libraryActionStudy,
                            favoriteLabel: l.libraryActionFavorite,
                            unfavoriteLabel: l.libraryActionUnfavorite,
                            archiveLabel: l.libraryActionArchive,
                            unarchiveLabel: l.libraryActionUnarchive,
                            deleteLabel: l.libraryActionDelete,
                          );
                          if (action == null || !context.mounted) return;
                          await DeckActionsHandler.handle(
                            context: context,
                            ref: ref,
                            deck: deck,
                            action: action,
                            tokens: tokens,
                            l: l,
                          );
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _RecentSection extends StatelessWidget {
  const _RecentSection({
    required this.decks,
    required this.tokens,
    required this.label,
  });

  final List<LibraryDeck> decks;
  final AuroraTokens tokens;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space20,
            tokens.space4,
            tokens.space20,
            tokens.space8,
          ),
          child: Text(label,
              style: Theme.of(context).textTheme.titleSmall),
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: tokens.space20),
            scrollDirection: Axis.horizontal,
            itemCount: decks.length,
            separatorBuilder: (_, __) => SizedBox(width: tokens.space12),
            itemBuilder: (_, i) => _RecentDeckChip(
              deck: decks[i],
              tokens: tokens,
            ),
          ),
        ),
        SizedBox(height: tokens.space16),
      ],
    );
  }
}

class _RecentDeckChip extends StatelessWidget {
  const _RecentDeckChip({required this.deck, required this.tokens});

  final LibraryDeck deck;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final coverColor = _hexToColor(deck.coverColorHex);
    final tt = Theme.of(context).textTheme;
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: tokens.backgroundSurface,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: coverColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(tokens.radiusMd),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(tokens.space8),
            child: Text(
              deck.title,
              style: tt.labelSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

class _SortFilterRow extends ConsumerWidget {
  const _SortFilterRow({
    required this.tokens,
    required this.l,
    required this.isGrid,
    required this.filter,
  });

  final AuroraTokens tokens;
  final AppLocalizations l;
  final bool isGrid;
  final dynamic filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Sort button
        _ChipButton(
          icon: Icons.sort_rounded,
          label: _sortLabel(ref.watch(libraryFilterNotifierProvider).sortBy),
          tokens: tokens,
          onTap: () async {
            final current = ref.read(libraryFilterNotifierProvider);
            final result = await LibrarySortSheet.show(
              context,
              selected: current.sortBy,
              tokens: tokens,
              titleLabel: l.librarySortTitle,
              labels: {},
            );
            if (result != null) {
              ref.read(libraryFilterNotifierProvider.notifier).setSort(result);
            }
          },
        ),
        SizedBox(width: tokens.space8),
        // Filter button
        _ChipButton(
          icon: Icons.tune_rounded,
          label: l.libraryFilter,
          tokens: tokens,
          isActive: !ref.watch(libraryFilterNotifierProvider).isDefault,
          onTap: () async {
            final current = ref.read(libraryFilterNotifierProvider);
            final result = await LibraryFilterSheet.show(
              context,
              initialFilter: current,
              tokens: tokens,
              applyLabel: l.libraryFilterApply,
              resetLabel: l.libraryFilterReset,
              difficultyLabel: l.libraryFilterDifficulty,
              archivedLabel: l.libraryFilterArchived,
              dueOnlyLabel: l.libraryFilterDueOnly,
            );
            if (result != null) {
              ref
                  .read(libraryFilterNotifierProvider.notifier)
                  .applyFilter(result);
            }
          },
        ),
        const Spacer(),
        // Grid/List toggle
        IconButton(
          icon: Icon(
            isGrid ? Icons.list_rounded : Icons.grid_view_rounded,
            color: tokens.textSecondary,
          ),
          onPressed: () =>
              ref.read(libraryViewNotifierProvider.notifier).toggleView(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  String _sortLabel(LibrarySortBy sortBy) => switch (sortBy.name) {
        'createdAt' => l.librarySortDateAdded,
        'name' => l.librarySortName,
        'recentlyStudied' => l.librarySortRecent,
        'cardCount' => l.librarySortCardCount,
        'dueCards' => l.librarySortDueCards,
        _ => l.librarySortDateAdded,
      };
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.icon,
    required this.label,
    required this.tokens,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final AuroraTokens tokens;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space12,
          vertical: tokens.space8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? tokens.brandGradientStart.withOpacity(0.1)
              : tokens.backgroundSurface,
          borderRadius: BorderRadius.circular(tokens.radiusFull),
          border: Border.all(
            color: isActive ? tokens.brandGradientStart : tokens.borderDefault,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? tokens.brandGradientStart
                  : tokens.textSecondary,
            ),
            SizedBox(width: tokens.space4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? tokens.brandGradientStart
                        : tokens.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.tokens,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final AuroraTokens tokens;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: tokens.stateError),
            SizedBox(height: tokens.space16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.space20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(retryLabel),
              style: FilledButton.styleFrom(
                backgroundColor: tokens.brandGradientStart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
