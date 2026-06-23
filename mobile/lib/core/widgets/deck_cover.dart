import 'dart:io';

import 'package:flutter/material.dart';

/// Number of bundled cover presets shipped in `assets/covers/`
/// (`cover_01.jpg` … `cover_24.jpg`).
const int kDeckCoverPresetCount = 24;

/// The preset ids the cover picker offers (`cover_01` … `cover_24`).
List<String> get kDeckCoverPresets => List.generate(
      kDeckCoverPresetCount,
      (i) => 'cover_${(i + 1).toString().padLeft(2, '0')}',
    );

/// Resolves a deck `cover` field to an [ImageProvider], or `null` when the deck
/// has no cover image (the caller then falls back to a colour gradient).
///
/// Supported cover values:
///  • `cover_NN`               → bundled asset `assets/covers/cover_NN.jpg`
///  • `http(s)://…`            → remote image (web marketplace covers)
///  • `file:<path>` / `<path>` → a custom image picked from the gallery
ImageProvider? deckCoverImage(String? cover) {
  final c = cover?.trim() ?? '';
  if (c.isEmpty) return null;
  if (c.startsWith('cover_')) return AssetImage('assets/covers/$c.jpg');
  if (c.startsWith('http://') || c.startsWith('https://')) {
    return NetworkImage(c);
  }
  final path = c.startsWith('file:') ? c.substring(5) : c;
  if (path.isEmpty) return null;
  return FileImage(File(path));
}

/// Whether [cover] points at a real image (preset / file / url) rather than
/// being empty.
bool hasDeckCover(String? cover) => deckCoverImage(cover) != null;

/// A deck cover background that fills its parent: paints the [cover] image
/// (`BoxFit.cover`) when one is set, otherwise a soft [color] gradient.
///
/// A top-down dark scrim is applied over images so floating badges/labels stay
/// legible; pass [scrim] = false to disable it.
class DeckCoverBackground extends StatelessWidget {
  const DeckCoverBackground({
    super.key,
    required this.cover,
    required this.color,
    this.scrim = true,
    this.child,
  });

  final String? cover;
  final Color color;
  final bool scrim;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final image = deckCoverImage(cover);
    if (image == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, Color.lerp(color, Colors.black, 0.18)!],
          ),
        ),
        child: child,
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(image: image, fit: BoxFit.cover),
        if (scrim)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0x00000000), Color(0x4D000000)],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
        if (child != null) child!,
      ],
    );
  }
}
