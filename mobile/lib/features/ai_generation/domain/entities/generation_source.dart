import 'package:flutter/material.dart';

enum GenerationSource { topic, text, pdf }

extension GenerationSourceX on GenerationSource {
  String get label => switch (this) {
        GenerationSource.topic => 'Topic',
        GenerationSource.text => 'Text',
        GenerationSource.pdf => 'PDF',
      };

  IconData get icon => switch (this) {
        GenerationSource.topic => Icons.lightbulb_outline_rounded,
        GenerationSource.text => Icons.text_fields_rounded,
        GenerationSource.pdf => Icons.picture_as_pdf_rounded,
      };
}
