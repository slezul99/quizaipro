import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';

enum DeckAction { study, favorite, archive, delete }

class DeckActionsSheet extends StatelessWidget {
  const DeckActionsSheet({
    super.key,
    required this.deck,
    required this.tokens,
    required this.onAction,
    required this.studyLabel,
    required this.favoriteLabel,
    required this.unfavoriteLabel,
    required this.archiveLabel,
    required this.unarchiveLabel,
    required this.deleteLabel,
  });

  final LibraryDeck deck;
  final AuroraTokens tokens;
  final ValueChanged<DeckAction> onAction;
  final String studyLabel;
  final String favoriteLabel;
  final String unfavoriteLabel;
  final String archiveLabel;
  final String unarchiveLabel;
  final String deleteLabel;

  static Future<DeckAction?> show(
    BuildContext context, {
    required LibraryDeck deck,
    required AuroraTokens tokens,
    required String studyLabel,
    required String favoriteLabel,
    required String unfavoriteLabel,
    required String archiveLabel,
    required String unarchiveLabel,
    required String deleteLabel,
  }) =>
      showModalBottomSheet<DeckAction>(
        context: context,
    useRootNavigator: true,
        builder: (_) => DeckActionsSheet(
          deck: deck,
          tokens: tokens,
          onAction: (a) => Navigator.of(context).pop(a),
          studyLabel: studyLabel,
          favoriteLabel: favoriteLabel,
          unfavoriteLabel: unfavoriteLabel,
          archiveLabel: archiveLabel,
          unarchiveLabel: unarchiveLabel,
          deleteLabel: deleteLabel,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.space20,
        tokens.space16,
        tokens.space20,
        tokens.space32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Deck header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _hexToColor(deck.coverColorHex),
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                ),
              ),
              SizedBox(width: tokens.space12),
              Expanded(
                child: Text(
                  deck.title,
                  style: tt.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space20),
          const Divider(),
          SizedBox(height: tokens.space8),

          // Study
          _ActionTile(
            icon: Icons.play_circle_outline_rounded,
            label: studyLabel,
            tokens: tokens,
            onTap: () => onAction(DeckAction.study),
          ),

          // Favorite toggle
          _ActionTile(
            icon: deck.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: deck.isFavorite ? unfavoriteLabel : favoriteLabel,
            tokens: tokens,
            color: deck.isFavorite ? tokens.stateError : null,
            onTap: () => onAction(DeckAction.favorite),
          ),

          // Archive toggle
          _ActionTile(
            icon: deck.isArchived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined,
            label: deck.isArchived ? unarchiveLabel : archiveLabel,
            tokens: tokens,
            onTap: () => onAction(DeckAction.archive),
          ),

          const Divider(),
          SizedBox(height: tokens.space4),

          // Delete
          _ActionTile(
            icon: Icons.delete_outline_rounded,
            label: deleteLabel,
            tokens: tokens,
            color: tokens.stateError,
            onTap: () => onAction(DeckAction.delete),
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.tokens,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final AuroraTokens tokens;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? tokens.textPrimary;
    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: effectiveColor,
            ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: tokens.space4),
    );
  }
}
