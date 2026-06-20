import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/deck_actions_handler.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_view_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/search_library_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/deck_actions_sheet.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_deck_card.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_deck_list_tile.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/library_empty_state.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class LibrarySearchScreen extends ConsumerStatefulWidget {
  const LibrarySearchScreen({super.key});

  @override
  ConsumerState<LibrarySearchScreen> createState() =>
      _LibrarySearchScreenState();
}

class _LibrarySearchScreenState extends ConsumerState<LibrarySearchScreen> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.aurora;
    final l = AppLocalizations.of(context)!;
    final isGrid = ref.watch(libraryViewNotifierProvider);
    final searchAsync = ref.watch(searchLibraryNotifierProvider);

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
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: l.librarySearchHint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: t.textTertiary,
                size: 20,
              ),
              filled: false,
            ),
            textInputAction: TextInputAction.search,
            onChanged: (v) {
              if (v.isEmpty) {
                ref.read(searchLibraryNotifierProvider.notifier).clear();
              }
            },
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                ref
                    .read(searchLibraryNotifierProvider.notifier)
                    .search(v.trim());
              }
            },
          ),
        ),
      ),
      body: searchAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(t.space32),
            child: Text(e.toString(),
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        data: (state) {
          if (state.isIdle) {
            return LibraryEmptyState(
              tokens: t,
              message: l.librarySearchIdle,
              icon: Icons.search_rounded,
            );
          }
          if (state.isEmpty) {
            return LibraryEmptyState(
              tokens: t,
              message: l.librarySearchEmpty,
              icon: Icons.find_in_page_outlined,
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification &&
                  n.metrics.extentAfter < 200 &&
                  state.hasMore &&
                  !state.isLoadingMore) {
                ref.read(searchLibraryNotifierProvider.notifier).loadMore();
              }
              return false;
            },
            child: isGrid
                ? GridView.builder(
                    padding: EdgeInsets.all(t.space20),
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
                            color: t.backgroundSurfaceElevated,
                            borderRadius: BorderRadius.circular(t.radiusLg),
                          ),
                        );
                      }
                      final deck = state.items[i];
                      return LibraryDeckCard(
                        deck: deck,
                        tokens: t,
                        onTap: () => context.pushNamed(
                          AppRoutes.libraryDeckName,
                          pathParameters: {'deckId': deck.id},
                        ),
                        onActionsTap: () async {
                          final action = await DeckActionsSheet.show(
                            context,
                            deck: deck,
                            tokens: t,
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
                            tokens: t,
                            l: l,
                          );
                        },
                      );
                    },
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(t.space20),
                    itemCount:
                        state.items.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => SizedBox(height: t.space12),
                    itemBuilder: (_, i) {
                      if (i == state.items.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(t.space16),
                            child: const CircularProgressIndicator(),
                          ),
                        );
                      }
                      final deck = state.items[i];
                      return LibraryDeckListTile(
                        deck: deck,
                        tokens: t,
                        onTap: () => context.pushNamed(
                          AppRoutes.libraryDeckName,
                          pathParameters: {'deckId': deck.id},
                        ),
                        onActionsTap: () async {
                          final action = await DeckActionsSheet.show(
                            context,
                            deck: deck,
                            tokens: t,
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
                            tokens: t,
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
