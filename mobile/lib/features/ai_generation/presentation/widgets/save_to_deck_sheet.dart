import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/deck_summary.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generated_card.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/save_generated_cards_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/ai_generation_providers.dart';

Future<bool> showSaveToDeckSheet({
  required BuildContext context,
  required List<GeneratedCard> cards,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SaveToDeckSheet(cards: cards),
  );
  return result ?? false;
}

class _SaveToDeckSheet extends ConsumerStatefulWidget {
  const _SaveToDeckSheet({required this.cards});

  final List<GeneratedCard> cards;

  @override
  ConsumerState<_SaveToDeckSheet> createState() => _SaveToDeckSheetState();
}

class _SaveToDeckSheetState extends ConsumerState<_SaveToDeckSheet> {
  List<DeckSummary>? _decks;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _selectedDeckId;
  bool _showNewDeckField = false;
  final _newDeckController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  @override
  void dispose() {
    _newDeckController.dispose();
    super.dispose();
  }

  Future<void> _loadDecks() async {
    final useCase = ref.read(getUserDecksUseCaseProvider);
    final result = await useCase(const NoParams());
    result.fold(
      (f) => setState(() {
        _isLoading = false;
        _errorMessage = f.userMessage;
      }),
      (decks) => setState(() {
        _isLoading = false;
        _decks = decks;
      }),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;

    String? deckId = _selectedDeckId;

    if (_showNewDeckField) {
      final title = _newDeckController.text.trim();
      if (title.isEmpty) {
        setState(() => _errorMessage = AppLocalizations.of(context).aiSaveErrorNoName);
        return;
      }
      setState(() => _isSaving = true);
      final createResult =
          await ref.read(createDeckUseCaseProvider).call(title);
      final created = createResult.fold((f) {
        setState(() {
          _isSaving = false;
          _errorMessage = f.userMessage;
        });
        return null;
      }, (d) => d);
      if (created == null) return;
      deckId = created.id;
    }

    if (deckId == null) {
      setState(() => _errorMessage = AppLocalizations.of(context).aiSaveErrorNoDeck);
      return;
    }

    setState(() => _isSaving = true);

    final saveResult = await ref
        .read(saveGeneratedCardsUseCaseProvider)
        .call(SaveGeneratedCardsParams(deckId: deckId, cards: widget.cards));

    saveResult.fold(
      (f) => setState(() {
        _isSaving = false;
        _errorMessage = f.userMessage;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: aurora.backgroundCanvas,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(aurora.radiusXl),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: aurora.space12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: aurora.borderDefault,
                borderRadius: BorderRadius.circular(aurora.radiusFull),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(aurora.space20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).aiSaveToDeck(widget.cards.length),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: aurora.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: aurora.textSecondary),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: aurora.space20),
                child: Container(
                  padding: EdgeInsets.all(aurora.space12),
                  decoration: BoxDecoration(
                    color: aurora.stateErrorSurface,
                    borderRadius: BorderRadius.circular(aurora.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: aurora.stateError, size: 16),
                      SizedBox(width: aurora.space8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: aurora.stateError),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: aurora.brandGradientStart),
                    )
                  : ListView(
                      controller: controller,
                      padding: EdgeInsets.symmetric(
                          horizontal: aurora.space20),
                      children: [
                        // New deck option
                        GestureDetector(
                          onTap: () => setState(() {
                            _showNewDeckField = !_showNewDeckField;
                            _selectedDeckId = null;
                          }),
                          child: Container(
                            margin: EdgeInsets.only(bottom: aurora.space8),
                            padding: EdgeInsets.all(aurora.space16),
                            decoration: BoxDecoration(
                              color: _showNewDeckField
                                  ? aurora.brandGradientStart.withOpacity(0.08)
                                  : aurora.backgroundSurface,
                              border: Border.all(
                                color: _showNewDeckField
                                    ? aurora.brandGradientStart
                                    : aurora.borderDefault,
                              ),
                              borderRadius:
                                  BorderRadius.circular(aurora.radiusMd),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.add_circle_outline_rounded,
                                    color: aurora.brandGradientStart, size: 20),
                                SizedBox(width: aurora.space12),
                                Text(
                                  AppLocalizations.of(context).aiSaveCreateNew,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: aurora.brandGradientStart,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_showNewDeckField)
                          Padding(
                            padding: EdgeInsets.only(bottom: aurora.space12),
                            child: TextField(
                              controller: _newDeckController,
                              autofocus: true,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: aurora.textPrimary),
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).aiSaveDeckName,
                                hintStyle: theme.textTheme.bodyMedium
                                    ?.copyWith(color: aurora.textTertiary),
                                filled: true,
                                fillColor: aurora.backgroundSurface,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(aurora.radiusMd),
                                  borderSide:
                                      BorderSide(color: aurora.borderDefault),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(aurora.radiusMd),
                                  borderSide: BorderSide(
                                      color: aurora.brandGradientStart),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: aurora.space16,
                                    vertical: aurora.space12),
                              ),
                            ),
                          ),
                        // Existing decks
                        if (_decks != null)
                          ..._decks!.map((deck) {
                            final isSelected = _selectedDeckId == deck.id;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedDeckId = deck.id;
                                _showNewDeckField = false;
                              }),
                              child: Container(
                                margin:
                                    EdgeInsets.only(bottom: aurora.space8),
                                padding: EdgeInsets.all(aurora.space16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? aurora.brandGradientStart
                                          .withOpacity(0.08)
                                      : aurora.backgroundSurface,
                                  border: Border.all(
                                    color: isSelected
                                        ? aurora.brandGradientStart
                                        : aurora.borderDefault,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(aurora.radiusMd),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.layers_rounded,
                                      size: 20,
                                      color: isSelected
                                          ? aurora.brandGradientStart
                                          : aurora.textSecondary,
                                    ),
                                    SizedBox(width: aurora.space12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            deck.title,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: aurora.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (deck.cardCount > 0)
                                            Text(
                                              AppLocalizations.of(context).aiStudioCardsCount(deck.cardCount),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                      color:
                                                          aurora.textSecondary),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check_circle_rounded,
                                          color: aurora.brandGradientStart,
                                          size: 20),
                                  ],
                                ),
                              ),
                            );
                          }),
                        SizedBox(height: aurora.space20),
                      ],
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(aurora.space20, 0, aurora.space20,
                  aurora.space32 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: (_selectedDeckId != null || _showNewDeckField) &&
                            !_isSaving
                        ? LinearGradient(colors: [
                            aurora.brandGradientStart,
                            aurora.brandGradientEnd
                          ])
                        : null,
                    color: (_selectedDeckId != null || _showNewDeckField) &&
                            !_isSaving
                        ? null
                        : aurora.borderDefault,
                    borderRadius: BorderRadius.circular(aurora.radiusMd),
                  ),
                  child: TextButton(
                    onPressed: (_selectedDeckId != null || _showNewDeckField) &&
                            !_isSaving
                        ? _save
                        : null,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(aurora.radiusMd),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            AppLocalizations.of(context).aiSaveSaveCards,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
