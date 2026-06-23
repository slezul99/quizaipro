import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';

class LibraryFilterSheet extends StatefulWidget {
  const LibraryFilterSheet({
    super.key,
    required this.initialFilter,
    required this.tokens,
    required this.onApply,
    required this.applyLabel,
    required this.resetLabel,
    required this.difficultyLabel,
    required this.archivedLabel,
    required this.dueOnlyLabel,
  });

  final LibraryFilter initialFilter;
  final AuroraTokens tokens;
  final ValueChanged<LibraryFilter> onApply;
  final String applyLabel;
  final String resetLabel;
  final String difficultyLabel;
  final String archivedLabel;
  final String dueOnlyLabel;

  static Future<LibraryFilter?> show(
    BuildContext context, {
    required LibraryFilter initialFilter,
    required AuroraTokens tokens,
    required String applyLabel,
    required String resetLabel,
    required String difficultyLabel,
    required String archivedLabel,
    required String dueOnlyLabel,
  }) =>
      showModalBottomSheet<LibraryFilter>(
        context: context,
    useRootNavigator: true,
        isScrollControlled: true,
        builder: (_) => LibraryFilterSheet(
          initialFilter: initialFilter,
          tokens: tokens,
          onApply: (f) => Navigator.of(context).pop(f),
          applyLabel: applyLabel,
          resetLabel: resetLabel,
          difficultyLabel: difficultyLabel,
          archivedLabel: archivedLabel,
          dueOnlyLabel: dueOnlyLabel,
        ),
      );

  @override
  State<LibraryFilterSheet> createState() => _LibraryFilterSheetState();
}

class _LibraryFilterSheetState extends State<LibraryFilterSheet> {
  late LibraryFilter _filter;

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
      initialChildSize: 0.6,
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
            // Difficulty
            Text(widget.difficultyLabel, style: tt.titleSmall),
            SizedBox(height: t.space12),
            Wrap(
              spacing: t.space8,
              children: [
                ChoiceChip(
                  label: Text(AppLocalizations.of(context)!.libraryFilterDifficultyAny),
                  selected: _filter.difficulty == null,
                  onSelected: (_) =>
                      setState(() => _filter = _filter.copyWith(difficulty: null)),
                  selectedColor: t.brandGradientStart.withOpacity(0.15),
                ),
                ...LibraryDifficulty.values.map(
                  (d) => ChoiceChip(
                    label: Text(_diffLabel(context, d)),
                    selected: _filter.difficulty == d,
                    onSelected: (_) =>
                        setState(() => _filter = _filter.copyWith(difficulty: d)),
                    selectedColor: t.brandGradientStart.withOpacity(0.15),
                  ),
                ),
              ],
            ),
            SizedBox(height: t.space20),

            // Due only
            Row(
              children: [
                Expanded(
                  child: Text(widget.dueOnlyLabel, style: tt.titleSmall),
                ),
                Switch(
                  value: _filter.hasDueOnly,
                  onChanged: (v) =>
                      setState(() => _filter = _filter.copyWith(hasDueOnly: v)),
                ),
              ],
            ),

            // Show archived
            Row(
              children: [
                Expanded(
                  child: Text(widget.archivedLabel, style: tt.titleSmall),
                ),
                Switch(
                  value: _filter.showArchived,
                  onChanged: (v) =>
                      setState(() => _filter = _filter.copyWith(showArchived: v)),
                ),
              ],
            ),

            SizedBox(height: t.space24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _filter = const LibraryFilter()),
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

  String _diffLabel(BuildContext context, LibraryDifficulty d) {
    final l10n = AppLocalizations.of(context)!;
    return switch (d) {
      LibraryDifficulty.beginner => l10n.libraryFilterDifficultyBeginner,
      LibraryDifficulty.intermediate => l10n.libraryFilterDifficultyIntermediate,
      LibraryDifficulty.advanced => l10n.libraryFilterDifficultyAdvanced,
    };
  }
}
