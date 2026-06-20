import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class SessionHeader extends StatelessWidget {
  const SessionHeader({
    super.key,
    required this.deckTitle,
    required this.modeName,
    required this.onQuit,
    required this.quitTooltip,
  });

  final String deckTitle;
  final String modeName;
  final VoidCallback onQuit;
  final String quitTooltip;

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Tooltip(
          message: quitTooltip,
          child: IconButton(
            onPressed: onQuit,
            icon: Icon(Icons.close_rounded, color: tokens.textSecondary),
          ),
        ),
        SizedBox(width: tokens.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deckTitle,
                style: tt.titleMedium?.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                modeName,
                style:
                    tt.labelSmall?.copyWith(color: tokens.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
