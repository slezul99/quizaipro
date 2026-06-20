import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/marketplace_filter.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/subject.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.subjects,
    required this.tokens,
    required this.onApply,
    required this.sortLabel,
    required this.difficultyLabel,
    required this.proOnlyLabel,
    required this.applyLabel,
    required this.resetLabel,
    required this.allSubjectsLabel,
  });

  final MarketplaceFilter initialFilter;
  final List<Subject> subjects;
  final AuroraTokens tokens;
  final ValueChanged<MarketplaceFilter> onApply;
  final String sortLabel;
  final String difficultyLabel;
  final String proOnlyLabel;
  final String applyLabel;
  final String resetLabel;
  final String allSubjectsLabel;

  static Future<MarketplaceFilter?> show(
    BuildContext context, {
    required MarketplaceFilter initialFilter,
    required List<Subject> subjects,
    required AuroraTokens tokens,
    required String sortLabel,
    required String difficultyLabel,
    required String proOnlyLabel,
    required String applyLabel,
    required String resetLabel,
    required String allSubjectsLabel,
  }) =>
      showModalBottomSheet<MarketplaceFilter>(
        context: context,
        isScrollControlled: true,
        builder: (_) => FilterBottomSheet(
          initialFilter: initialFilter,
          subjects: subjects,
          tokens: tokens,
          onApply: (f) => Navigator.of(context).pop(f),
          sortLabel: sortLabel,
          difficultyLabel: difficultyLabel,
          proOnlyLabel: proOnlyLabel,
          applyLabel: applyLabel,
          resetLabel: resetLabel,
          allSubjectsLabel: allSubjectsLabel,
        ),
      );

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late MarketplaceFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        padding: EdgeInsets.fromLTRB(
          t.space20,
          t.space8,
          t.space20,
          t.space20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sort
            Text(widget.sortLabel, style: tt.titleSmall),
            SizedBox(height: t.space12),
            _SortRow(
              selected: _filter.sortBy,
              tokens: t,
              onChange: (s) => setState(() => _filter = _filter.copyWith(sortBy: s)),
            ),
            SizedBox(height: t.space20),

            // Difficulty
            Text(widget.difficultyLabel, style: tt.titleSmall),
            SizedBox(height: t.space12),
            _DifficultyRow(
              selected: _filter.difficulty,
              tokens: t,
              onChange: (d) => setState(() => _filter = _filter.copyWith(difficulty: d)),
            ),
            SizedBox(height: t.space20),

            // Pro only
            Row(
              children: [
                Expanded(
                  child: Text(widget.proOnlyLabel, style: tt.titleSmall),
                ),
                Switch(
                  value: _filter.proOnly,
                  onChanged: (v) =>
                      setState(() => _filter = _filter.copyWith(proOnly: v)),
                ),
              ],
            ),
            SizedBox(height: t.space32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(
                      () => _filter = const MarketplaceFilter(),
                    ),
                    child: Text(widget.resetLabel),
                  ),
                ),
                SizedBox(width: t.space12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => widget.onApply(_filter),
                    style: FilledButton.styleFrom(
                      backgroundColor: t.brandGradientStart,
                    ),
                    child: Text(widget.applyLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({
    required this.selected,
    required this.tokens,
    required this.onChange,
  });

  final MarketplaceSortBy selected;
  final AuroraTokens tokens;
  final ValueChanged<MarketplaceSortBy> onChange;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.space8,
      children: MarketplaceSortBy.values
          .map(
            (s) => ChoiceChip(
              label: Text(_sortLabel(context, s)),
              selected: selected == s,
              onSelected: (_) => onChange(s),
              selectedColor: tokens.brandGradientStart.withOpacity(0.15),
            ),
          )
          .toList(),
    );
  }

  String _sortLabel(BuildContext context, MarketplaceSortBy s) {
    final l10n = AppLocalizations.of(context)!;
    return switch (s) {
      MarketplaceSortBy.popular => l10n.marketplaceSortPopular,
      MarketplaceSortBy.newest => l10n.marketplaceSortNewest,
      MarketplaceSortBy.rating => l10n.marketplaceSortRating,
      MarketplaceSortBy.alphabetical => l10n.marketplaceSortAlphabetical,
    };
  }
}

class _DifficultyRow extends StatelessWidget {
  const _DifficultyRow({
    required this.selected,
    required this.tokens,
    required this.onChange,
  });

  final DeckDifficulty? selected;
  final AuroraTokens tokens;
  final ValueChanged<DeckDifficulty?> onChange;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: tokens.space8,
      children: [
        ChoiceChip(
          label: Text(AppLocalizations.of(context)!.libraryFilterDifficultyAny),
          selected: selected == null,
          onSelected: (_) => onChange(null),
          selectedColor: tokens.brandGradientStart.withOpacity(0.15),
        ),
        ...DeckDifficulty.values.map(
          (d) => ChoiceChip(
            label: Text(_diffLabel(context, d)),
            selected: selected == d,
            onSelected: (_) => onChange(d),
            selectedColor: tokens.brandGradientStart.withOpacity(0.15),
          ),
        ),
      ],
    );
  }

  String _diffLabel(BuildContext context, DeckDifficulty d) {
    final l10n = AppLocalizations.of(context)!;
    return switch (d) {
      DeckDifficulty.beginner => l10n.libraryFilterDifficultyBeginner,
      DeckDifficulty.intermediate => l10n.libraryFilterDifficultyIntermediate,
      DeckDifficulty.advanced => l10n.libraryFilterDifficultyAdvanced,
    };
  }
}
