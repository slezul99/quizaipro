import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/core/utils/mcq_text.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/flashcard.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/providers/flashcard_providers.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/deck_cards_provider.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_decks_notifier.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

const int _kDefaultOptions = 4;
const int _kMaxOptions = 10;
const int _kMinOptions = 2;

/// Letter labels for options: A, B, C … (Latin, matching the backend MCQ parser).
String _letterFor(int index) => String.fromCharCode(65 + index);

final RegExp _optionPrefix = RegExp(r'^[A-Za-zА-Яа-яЁё]\s*[)\.\:\-]\s+');

String _stripPrefix(String line) => line.replaceFirst(_optionPrefix, '').trim();

/// Bottom sheet to add or edit a quiz card. The card is authored as a question
/// plus a list of options (default 4, expandable to 10), with a radio marking
/// the correct one. On save it is serialised into the deck's MCQ text format
/// (`front` = "question\nA) …\nB) …", `back` = correct option), so the test and
/// flashcard flows parse it exactly like quiz/AI-generated decks.
Future<bool?> showCardEditorSheet(
  BuildContext context, {
  required String deckId,
  Flashcard? card,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CardEditorSheet(deckId: deckId, card: card),
  );
}

class _CardEditorSheet extends ConsumerStatefulWidget {
  const _CardEditorSheet({required this.deckId, this.card});
  final String deckId;
  final Flashcard? card;

  @override
  ConsumerState<_CardEditorSheet> createState() => _CardEditorSheetState();
}

class _CardEditorSheetState extends ConsumerState<_CardEditorSheet> {
  late final TextEditingController _question;
  late final TextEditingController _note;
  final List<TextEditingController> _options = [];
  int _correct = 0;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.card != null;

  @override
  void initState() {
    super.initState();
    _question = TextEditingController(text: mcqStem(widget.card?.front ?? ''));
    _note = TextEditingController(text: widget.card?.hint ?? '');
    _hydrateOptions();
  }

  void _hydrateOptions() {
    final front = widget.card?.front ?? '';
    final back = (widget.card?.back ?? '').trim();
    final optionLines = mcqOptions(front);

    if (optionLines.isNotEmpty) {
      // Existing MCQ card — restore options and find the correct one.
      final backLetter = _optionPrefix.hasMatch(back)
          ? back.trimLeft().substring(0, 1).toUpperCase()
          : null;
      final backText = _stripPrefix(back).toLowerCase();
      for (var i = 0; i < optionLines.length && i < _kMaxOptions; i++) {
        final text = _stripPrefix(optionLines[i]);
        _options.add(TextEditingController(text: text));
        final matchesLetter = backLetter != null && _letterFor(i) == backLetter;
        final matchesText = backText.isNotEmpty && text.toLowerCase() == backText;
        if (matchesLetter || matchesText) _correct = i;
      }
    } else if (_isEdit && back.isNotEmpty) {
      // Plain flashcard being upgraded — seed the answer as the first option.
      _options.add(TextEditingController(text: back));
      for (var i = 1; i < _kDefaultOptions; i++) {
        _options.add(TextEditingController());
      }
      _correct = 0;
    } else {
      for (var i = 0; i < _kDefaultOptions; i++) {
        _options.add(TextEditingController());
      }
    }
    while (_options.length < _kMinOptions) {
      _options.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _question.dispose();
    _note.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_options.length >= _kMaxOptions) return;
    setState(() => _options.add(TextEditingController()));
  }

  void _removeOption(int index) {
    if (_options.length <= _kMinOptions) return;
    setState(() {
      _options.removeAt(index).dispose();
      if (_correct >= _options.length) _correct = _options.length - 1;
      if (_correct > index) _correct -= 1;
    });
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final question = _question.text.trim();
    if (question.isEmpty) {
      setState(() => _error = l.cardEditorErrorQuestion);
      return;
    }

    // Keep only filled options, remembering which one is correct.
    final filled = <String>[];
    int? correctInFilled;
    for (var i = 0; i < _options.length; i++) {
      final text = _options[i].text.trim();
      if (text.isEmpty) continue;
      if (i == _correct) correctInFilled = filled.length;
      filled.add(text);
    }

    if (filled.length < _kMinOptions) {
      setState(() => _error = l.cardEditorErrorMinOptions(_kMinOptions));
      return;
    }
    if (correctInFilled == null) {
      setState(() => _error = l.cardEditorErrorMarkCorrect);
      return;
    }

    final front = StringBuffer(question);
    String correctAnswer = '';
    for (var i = 0; i < filled.length; i++) {
      final line = '${_letterFor(i)}) ${filled[i]}';
      front.write('\n$line');
      if (i == correctInFilled) correctAnswer = line;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final repo = ref.read(flashcardRepositoryProvider);
    final note = _note.text.trim();
    final result = _isEdit
        ? await repo.updateCard(
            deckId: widget.deckId,
            cardId: widget.card!.id,
            front: front.toString(),
            back: correctAnswer,
            note: note,
          )
        : await repo.createCard(
            deckId: widget.deckId,
            front: front.toString(),
            back: correctAnswer,
            note: note,
          );

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _saving = false;
        _error = l.cardEditorErrorSave;
      }),
      (_) {
        ref.invalidate(deckCardsProvider(widget.deckId));
        ref.read(libraryDecksNotifierProvider.notifier).refresh();
        Navigator.pop(context, true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.aurora;
    final tt = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;
    final canAdd = _options.length < _kMaxOptions;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: t.backgroundSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(t.radiusLg)),
        ),
        padding: EdgeInsets.fromLTRB(t.space20, t.space12, t.space20, t.space24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.surfaceSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: t.space20),
              Text(
                _isEdit ? l.cardEditorTitleEdit : l.cardEditorTitleNew,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: t.space16),

              // Question
              _FieldLabel(l.cardEditorQuestionLabel, tokens: t),
              SizedBox(height: t.space8),
              TextField(
                controller: _question,
                autofocus: !_isEdit,
                maxLines: 4,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(t, hint: l.cardEditorQuestionHint),
              ),
              SizedBox(height: t.space20),

              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FieldLabel(l.cardEditorOptionsLabel, tokens: t),
                  Text(
                    '${_options.length}/$_kMaxOptions',
                    style: tt.labelSmall?.copyWith(color: t.textTertiary),
                  ),
                ],
              ),
              SizedBox(height: t.space4),
              Text(
                l.cardEditorMarkCorrect,
                style: tt.bodySmall?.copyWith(color: t.textTertiary),
              ),
              SizedBox(height: t.space12),
              ...List.generate(_options.length, (i) => _optionRow(t, tt, i)),
              SizedBox(height: t.space4),

              // Add option
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: canAdd ? _addOption : null,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: Text(
                    canAdd ? l.cardEditorAddOption : l.cardEditorMaxOptions(_kMaxOptions),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: canAdd ? t.brandPrimary : t.textTertiary,
                  ),
                ),
              ),
              SizedBox(height: t.space12),

              // Explanation
              _FieldLabel(l.cardEditorExplanationLabel, tokens: t),
              SizedBox(height: t.space8),
              TextField(
                controller: _note,
                maxLines: 3,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(t, hint: l.cardEditorExplanationHint),
              ),

              if (_error != null) ...[
                SizedBox(height: t.space12),
                Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 16, color: t.stateError),
                    SizedBox(width: t.space8),
                    Expanded(
                      child: Text(_error!,
                          style: tt.bodySmall?.copyWith(color: t.stateError)),
                    ),
                  ],
                ),
              ],
              SizedBox(height: t.space20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: t.brandPrimary,
                    foregroundColor: t.textOnBrand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(t.radiusMd),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEdit ? l.save : l.libraryDeckAddCard),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionRow(AuroraTokens t, TextTheme tt, int i) {
    final isCorrect = i == _correct;
    final canRemove = _options.length > _kMinOptions;
    return Padding(
      padding: EdgeInsets.only(bottom: t.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Correct selector
          GestureDetector(
            onTap: () => setState(() => _correct = i),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCorrect ? t.stateSuccess : Colors.transparent,
                border: Border.all(
                  color: isCorrect ? t.stateSuccess : t.borderStrong,
                  width: 2,
                ),
              ),
              child: isCorrect
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : Text(
                      _letterFor(i),
                      style: tt.labelMedium?.copyWith(
                        color: t.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          SizedBox(width: t.space12),
          Expanded(
            child: TextField(
              controller: _options[i],
              textCapitalization: TextCapitalization.sentences,
              decoration: _inputDecoration(
                t,
                hint: AppLocalizations.of(context)!.cardEditorOptionHint(_letterFor(i)),
                dense: true,
                focusColor: isCorrect ? t.stateSuccess : null,
              ),
            ),
          ),
          if (canRemove)
            IconButton(
              icon: Icon(Icons.close_rounded, size: 20, color: t.textTertiary),
              onPressed: () => _removeOption(i),
              splashRadius: 20,
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    AuroraTokens t, {
    String? hint,
    bool dense = false,
    Color? focusColor,
  }) {
    return InputDecoration(
      hintText: hint,
      isDense: dense,
      contentPadding: dense
          ? EdgeInsets.symmetric(horizontal: t.space12, vertical: t.space12)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusMd),
        borderSide: BorderSide(
          color: focusColor?.withValues(alpha: 0.6) ?? t.borderSubtle,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusMd),
        borderSide: BorderSide(color: focusColor ?? t.brandPrimary, width: 2),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.tokens});
  final String text;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: tokens.textPrimary,
          ),
    );
  }
}
