import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/archive_deck_use_case.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/delete_deck_use_case.dart';
import 'package:quizaipro_mobile/features/library/domain/usecases/toggle_favorite_use_case.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_decks_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_favorites_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_providers.dart';
import 'package:quizaipro_mobile/features/library/presentation/widgets/deck_actions_sheet.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

abstract final class DeckActionsHandler {
  static Future<void> handle({
    required BuildContext context,
    required WidgetRef ref,
    required LibraryDeck deck,
    required DeckAction action,
    required AuroraTokens tokens,
    required AppLocalizations l,
  }) async {
    switch (action) {
      case DeckAction.study:
        context.pushNamed(
          AppRoutes.studySessionName,
          queryParameters: {'deckId': deck.id},
        );

      case DeckAction.favorite:
        await _toggleFavorite(context, ref, deck, tokens, l);

      case DeckAction.archive:
        await _toggleArchive(context, ref, deck, tokens, l);

      case DeckAction.delete:
        await _deleteDeck(context, ref, deck, tokens, l);
    }
  }

  static Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    LibraryDeck deck,
    AuroraTokens tokens,
    AppLocalizations l,
  ) async {
    final newValue = !deck.isFavorite;
    ref
        .read(libraryDecksNotifierProvider.notifier)
        .optimisticToggleFavorite(deck.id, newValue);

    final useCase = ref.read(toggleFavoriteUseCaseProvider);
    final result = await useCase(ToggleFavoriteParams(deckId: deck.id));

    result.fold(
      (f) {
        ref
            .read(libraryDecksNotifierProvider.notifier)
            .revertFavorite(deck.id, deck.isFavorite);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.userMessage)),
          );
        }
      },
      (isFavorite) {
        if (!isFavorite) {
          ref
              .read(libraryFavoritesNotifierProvider.notifier)
              .removeDeck(deck.id);
        } else {
          ref.invalidate(libraryFavoritesNotifierProvider);
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFavorite
                    ? l.libraryFavoriteAdded
                    : l.libraryFavoriteRemoved,
              ),
            ),
          );
        }
      },
    );
  }

  static Future<void> _toggleArchive(
    BuildContext context,
    WidgetRef ref,
    LibraryDeck deck,
    AuroraTokens tokens,
    AppLocalizations l,
  ) async {
    final useCase = ref.read(archiveDeckUseCaseProvider);
    final result = await useCase(
      ArchiveDeckParams(deckId: deck.id, archive: !deck.isArchived),
    );
    result.fold(
      (f) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.userMessage)),
          );
        }
      },
      (_) {
        ref
            .read(libraryDecksNotifierProvider.notifier)
            .updateArchiveStatus(deck.id, !deck.isArchived);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                deck.isArchived
                    ? l.libraryUnarchived
                    : l.libraryArchived,
              ),
            ),
          );
        }
      },
    );
  }

  static Future<void> _deleteDeck(
    BuildContext context,
    WidgetRef ref,
    LibraryDeck deck,
    AuroraTokens tokens,
    AppLocalizations l,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.libraryDeleteTitle),
        content: Text(l.libraryDeleteConfirm(deck.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: tokens.stateError,
            ),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final useCase = ref.read(deleteDeckUseCaseProvider);
    final result = await useCase(DeleteDeckParams(deckId: deck.id));
    result.fold(
      (f) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.userMessage)),
          );
        }
      },
      (_) {
        ref
            .read(libraryDecksNotifierProvider.notifier)
            .removeDeck(deck.id);
        ref
            .read(libraryFavoritesNotifierProvider.notifier)
            .removeDeck(deck.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.libraryDeleted)),
          );
        }
      },
    );
  }
}
