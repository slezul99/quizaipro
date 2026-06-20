import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_decks_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_favorites_notifier.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_providers.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/recent_decks_notifier.dart';

/// Bottom sheet to create a new deck or edit an existing one's title/description.
/// Returns true if a deck was created/updated.
Future<bool?> showDeckEditorSheet(BuildContext context, {LibraryDeck? deck}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
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

  bool get _isEdit => widget.deck != null;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Введите название колоды');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(libraryRepositoryProvider);
    final result = _isEdit
        ? await repo.updateDeck(
            deckId: widget.deck!.id, title: title, description: _desc.text.trim())
        : await repo.createDeck(title: title, description: _desc.text.trim());

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _saving = false;
        _error = 'Не удалось сохранить. Проверьте соединение.';
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
              _isEdit ? 'Редактировать колоду' : 'Новая колода',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: t.space16),
            TextField(
              controller: _title,
              autofocus: !_isEdit,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Название',
                hintText: 'Например: История Узбекистана',
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
                labelText: 'Описание (необязательно)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(t.radiusMd),
                ),
              ),
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
                    : Text(_isEdit ? 'Сохранить' : 'Создать'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
