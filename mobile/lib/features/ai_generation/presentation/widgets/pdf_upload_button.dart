// IMPORTANT: Add 'file_picker: ">=10.0.0 <10.1.1"' to pubspec.yaml to enable PDF upload.
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class PdfUploadButton extends StatelessWidget {
  const PdfUploadButton({
    super.key,
    required this.fileName,
    required this.onPicked,
    required this.onClear,
  });

  final String? fileName;
  final void Function(String filePath, String fileName) onPicked;
  final VoidCallback onClear;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.path == null) return;
    onPicked(file.path!, file.name);
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final hasPdf = fileName != null;

    return GestureDetector(
      onTap: hasPdf ? null : _pick,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(aurora.space16),
        decoration: BoxDecoration(
          color: hasPdf
              ? aurora.stateSuccessSurface
              : aurora.backgroundSurface,
          border: Border.all(
            color: hasPdf ? aurora.stateSuccess : aurora.borderDefault,
            width: hasPdf ? 1.5 : 1,
            style: hasPdf ? BorderStyle.solid : BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(aurora.radiusMd),
        ),
        child: hasPdf
            ? Row(
                children: [
                  Icon(Icons.picture_as_pdf_rounded,
                      color: aurora.stateSuccess, size: 24),
                  SizedBox(width: aurora.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: aurora.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          AppLocalizations.of(context).aiStudioPdfReady,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: aurora.stateSuccess,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.close_rounded, color: aurora.stateError, size: 18),
                    onPressed: onClear,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file_rounded,
                      color: aurora.textSecondary, size: 24),
                  SizedBox(width: aurora.space12),
                  Text(
                    AppLocalizations.of(context).aiStudioPdfChoose,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: aurora.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
