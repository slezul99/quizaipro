import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_decks_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_favorites_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_providers.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/recent_decks_notifier.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// Bottom sheet to create a new deck or edit an existing one's title/description.
/// Returns true if a deck was created/updated.
Future<bool?> showDeckEditorSheet(BuildContext context, {LibraryDeck? deck}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true, // render above the shell + centre FAB
    backgroundColor: Colors.transparent,
    builder: (_) => _DeckEditorSheet(deck: deck),
  );
}

class _DeckEditorSheet extends ConsumerStatefulWidget {
  const _DeckEditorSheet({this.deck});
  final LibraryDeck? deck;

  @override
  ConsumerState<_DeckEditorSheet> createState() => _DeckEditorSheetState();
}

class _DeckEditorSheetState extends ConsumerState<_DeckEditorSheet> {
  late final TextEditingController _title =
      TextEditingController(text: widget.deck?.title ?? '');
  late final TextEditingController _desc =
      TextEditingController(text: widget.deck?.description ?? '');
  bool _saving = false;
  String? _error;

  // Selected deck colour (hex). Null = keep the auto/derived colour.
  late String? _color = widget.deck?.coverColorHex;

  /// Preset palette the user can pick from.
  static const List<String> _palette = [
    '#6366F1', '#8B5CF6', '#EC4899', '#F43F5E', '#EF4444', '#F97316',
    '#F59E0B', '#EAB308', '#22C55E', '#10B981', '#14B8A6', '#06B6D4',
    '#0EA5E9', '#3B82F6', '#64748B', '#0F172A',
  ];

  bool get _isEdit => widget.deck != null;

  Color _hex(String h) =>
      Color(int.parse('FF${h.replaceAll('#', '')}', radix: 16));

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = l.deckEditorErrorName);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(libraryRepositoryProvider);
    final result = _isEdit
        ? await repo.updateDeck(
            deckId: widget.deck!.id,
            title: title,
            description: _desc.text.trim(),
            color: _color)
        : await repo.createDeck(
            title: title, description: _desc.text.trim(), color: _color);

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _saving = false;
        _error = l.cardEditorErrorSave;
      }),
      (_) {
        ref.read(libraryDecksNotifierProvider.notifier).refresh();
        ref.invalidate(recentDecksNotifierProvider);
        ref.invalidate(libraryFavoritesNotifierProvider);
        Navigator.pop(context, true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.aurora;
    final tt = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: t.backgroundSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(t.radiusLg)),
        ),
        padding: EdgeInsets.fromLTRB(
            t.space20, t.space12, t.space20, t.space24),
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
              _isEdit ? l.libraryDeckEditTooltip : l.deckEditorTitleNew,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: t.space16),
            TextField(
              controller: _title,
              autofocus: !_isEdit,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.deckEditorNameLabel,
                hintText: l.deckEditorNameHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(t.radiusMd),
                ),
              ),
            ),
            SizedBox(height: t.space12),
            TextField(
              controller: _desc,
              maxLines: 3,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.deckEditorDescLabel,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(t.radiusMd),
                ),
              ),
            ),
            SizedBox(height: t.space16),
            // Live preview of the deck cover with the chosen colour.
            Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _color != null
                      ? [_hex(_color!), _hex(_color!).withValues(alpha: 0.75)]
                      : [t.brandGradientStart, t.brandGradientEnd],
                ),
                borderRadius: BorderRadius.circular(t.radiusMd),
              ),
              padding: EdgeInsets.symmetric(horizontal: t.space16),
              child: Row(
                children: [
                  const Text('📚', style: TextStyle(fontSize: 24)),
                  SizedBox(width: t.space12),
                  Expanded(
                    child: Text(
                      _title.text.trim().isEmpty
                          ? l.deckEditorNameHint
                          : _title.text.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: t.space12),
            Text(l.deckEditorColorLabel,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: t.space8),
            Wrap(
              spacing: t.space8,
              runSpacing: t.space8,
              children: [
                for (final hex in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _color = hex),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _hex(hex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (_color?.toUpperCase() == hex)
                              ? t.textPrimary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: (_color?.toUpperCase() == hex)
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
              ],
            ),
            if (_error != null) ...[
              SizedBox(height: t.space8),
              Text(_error!,
                  style: tt.bodySmall?.copyWith(color: t.stateError)),
            ],
            SizedBox(height: t.space20),
            SizedBox(
              width: double.infinity,
              height: 50,
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
                    : Text(_isEdit ? l.save : l.deckEditorCreate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
