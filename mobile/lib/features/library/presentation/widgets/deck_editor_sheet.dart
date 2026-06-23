import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/core/widgets/deck_cover.dart';
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

  // Selected cover: a preset id (`cover_NN`), a local file path, or null=none.
  late String? _cover = widget.deck?.coverUrl;
  final ImagePicker _picker = ImagePicker();

  /// Preset palette the user can pick from.
  static const List<String> _palette = [
    '#6366F1', '#8B5CF6', '#EC4899', '#F43F5E', '#EF4444', '#F97316',
    '#F59E0B', '#EAB308', '#22C55E', '#10B981', '#14B8A6', '#06B6D4',
    '#0EA5E9', '#3B82F6', '#64748B', '#0F172A',
  ];

  bool get _isEdit => widget.deck != null;

  Color _hex(String h) =>
      Color(int.parse('FF${h.replaceAll('#', '')}', radix: 16));

  /// Pick a custom cover from the gallery and copy it into the app's documents
  /// dir (so the path stays valid after the picker's temp file is cleaned up).
  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (picked == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final covers = Directory(p.join(dir.path, 'deck_covers'));
      if (!covers.existsSync()) covers.createSync(recursive: true);
      final ext = p.extension(picked.path).isEmpty
          ? '.jpg'
          : p.extension(picked.path);
      final dest = p.join(
          covers.path, 'cover_${DateTime.now().millisecondsSinceEpoch}$ext');
      await File(picked.path).copy(dest);
      if (!mounted) return;
      setState(() => _cover = dest);
    } catch (_) {
      // Picker cancelled or permission denied — keep the current cover.
    }
  }

  /// One selectable cover thumbnail in the horizontal picker strip.
  Widget _coverChip(
    AuroraTokens t, {
    required bool selected,
    required VoidCallback onTap,
    ImageProvider? image,
    Widget? child,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: t.space8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 84,
          decoration: BoxDecoration(
            color: t.surfaceSubtle,
            borderRadius: BorderRadius.circular(t.radiusMd),
            border: Border.all(
              color: selected ? t.brandPrimary : t.surfaceSubtle,
              width: 2.5,
            ),
            image: image != null
                ? DecorationImage(image: image, fit: BoxFit.cover)
                : null,
          ),
          alignment: Alignment.center,
          child: selected && image != null
              ? const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 26,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 6)])
              : child,
        ),
      ),
    );
  }

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
            color: _color,
            cover: _cover)
        : await repo.createDeck(
            title: title,
            description: _desc.text.trim(),
            color: _color,
            cover: _cover);

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
            // Live preview of the deck cover (chosen image or colour).
            ClipRRect(
              borderRadius: BorderRadius.circular(t.radiusMd),
              child: SizedBox(
                height: 76,
                width: double.infinity,
                child: DeckCoverBackground(
                  cover: _cover,
                  color: _color != null ? _hex(_color!) : t.brandGradientStart,
                  child: Padding(
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
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                shadows: const [
                                  Shadow(color: Colors.black54, blurRadius: 6)
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
            SizedBox(height: t.space16),
            Text(l.deckEditorCoverLabel,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: t.space8),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                children: [
                  // No cover.
                  _coverChip(t,
                      selected: _cover == null,
                      onTap: () => setState(() => _cover = null),
                      child: Icon(Icons.block_rounded,
                          color: t.textTertiary, size: 22)),
                  // Pick from gallery.
                  _coverChip(t,
                      selected: false,
                      onTap: _pickFromGallery,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded,
                              color: t.brandPrimary, size: 22),
                          Text(l.deckEditorCoverGallery,
                              style: tt.labelSmall
                                  ?.copyWith(color: t.brandPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      )),
                  // Currently-selected custom (gallery) cover, if any.
                  if (_cover != null && !_cover!.startsWith('cover_'))
                    _coverChip(t,
                        selected: true,
                        onTap: () {},
                        image: deckCoverImage(_cover)),
                  // Bundled presets.
                  for (final id in kDeckCoverPresets)
                    _coverChip(t,
                        selected: _cover == id,
                        onTap: () => setState(() => _cover = id),
                        image: AssetImage('assets/covers/$id.jpg')),
                ],
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
                    : Text(_isEdit ? l.save : l.deckEditorCreate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
