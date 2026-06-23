import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';

class LibrarySortSheet extends StatelessWidget {
  const LibrarySortSheet({
    super.key,
    required this.selected,
    required this.tokens,
    required this.onSelect,
    required this.titleLabel,
  });

  final LibrarySortBy selected;
  final AuroraTokens tokens;
  final ValueChanged<LibrarySortBy> onSelect;
  final String titleLabel;

  static Future<LibrarySortBy?> show(
    BuildContext context, {
    required LibrarySortBy selected,
    required AuroraTokens tokens,
    required String titleLabel,
    required Map<LibrarySortBy, String> labels,
  }) =>
      showModalBottomSheet<LibrarySortBy>(
        context: context,
    useRootNavigator: true,
        builder: (_) => LibrarySortSheet(
          selected: selected,
          tokens: tokens,
          titleLabel: titleLabel,
          onSelect: (s) => Navigator.of(context).pop(s),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titleLabel, style: tt.titleMedium),
          SizedBox(height: tokens.space16),
          ...LibrarySortBy.values.map(
            (s) => _SortOption(
              sort: s,
              selected: selected == s,
              tokens: tokens,
              onTap: () => onSelect(s),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.sort,
    required this.selected,
    required this.tokens,
    required this.onTap,
  });

  final LibrarySortBy sort;
  final bool selected;
  final AuroraTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space16,
          vertical: tokens.space12,
        ),
        margin: EdgeInsets.only(bottom: tokens.space8),
        decoration: BoxDecoration(
          color: selected
              ? tokens.brandGradientStart.withOpacity(0.1)
              : tokens.backgroundSurface,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(
            color: selected ? tokens.brandGradientStart : tokens.borderDefault,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _sortLabel(context, sort),
                style: tt.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? tokens.brandGradientStart : tokens.textPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_rounded,
                color: tokens.brandGradientStart,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  String _sortLabel(BuildContext context, LibrarySortBy s) {
    final l10n = AppLocalizations.of(context)!;
    return switch (s) {
      LibrarySortBy.createdAt => l10n.librarySortDateAdded,
      LibrarySortBy.name => l10n.librarySortName,
      LibrarySortBy.recentlyStudied => l10n.librarySortRecent,
      LibrarySortBy.cardCount => l10n.librarySortCardCount,
      LibrarySortBy.dueCards => l10n.librarySortDueCards,
    };
  }
}
