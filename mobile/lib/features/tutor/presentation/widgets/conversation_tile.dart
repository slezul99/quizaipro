import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/conversation.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onRename,
    required this.onPin,
    required this.onDelete,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(aurora.space16),
        decoration: BoxDecoration(
          color: aurora.backgroundSurface,
          borderRadius: BorderRadius.circular(aurora.radiusMd),
          border: Border.all(
            color: conversation.isPinned
                ? aurora.brandGradientStart.withOpacity(0.4)
                : aurora.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    aurora.brandGradientStart,
                    aurora.brandGradientEnd,
                  ],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(width: aurora.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (conversation.isPinned) ...[
                        Icon(
                          Icons.push_pin_rounded,
                          size: 12,
                          color: aurora.brandGradientStart,
                        ),
                        SizedBox(width: aurora.space4),
                      ],
                      Expanded(
                        child: Text(
                          conversation.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: aurora.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (conversation.lastMessagePreview != null) ...[
                    SizedBox(height: aurora.space4),
                    Text(
                      conversation.lastMessagePreview!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: aurora.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (conversation.deckTitle != null) ...[
                    SizedBox(height: aurora.space4),
                    Row(
                      children: [
                        Icon(
                          Icons.layers_rounded,
                          size: 12,
                          color: aurora.textTertiary,
                        ),
                        SizedBox(width: aurora.space4),
                        Flexible(
                          child: Text(
                            conversation.deckTitle!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: aurora.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            _ContextMenu(
              isPinned: conversation.isPinned,
              onRename: onRename,
              onPin: onPin,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextMenu extends StatelessWidget {
  const _ContextMenu({
    required this.isPinned,
    required this.onRename,
    required this.onPin,
    required this.onDelete,
  });

  final bool isPinned;
  final VoidCallback onRename;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return PopupMenuButton<_Action>(
      icon: Icon(Icons.more_vert_rounded, color: aurora.textTertiary, size: 20),
      color: aurora.backgroundSurfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(aurora.radiusMd),
      ),
      onSelected: (action) {
        switch (action) {
          case _Action.rename:
            onRename();
          case _Action.pin:
            onPin();
          case _Action.delete:
            onDelete();
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: _Action.rename,
          child: _MenuItem(
            icon: Icons.edit_rounded,
            label: AppLocalizations.of(context).tutorRename,
          ),
        ),
        PopupMenuItem(
          value: _Action.pin,
          child: _MenuItem(
            icon: isPinned
                ? Icons.push_pin_outlined
                : Icons.push_pin_rounded,
            label: isPinned ? AppLocalizations.of(context).tutorUnpin : AppLocalizations.of(context).tutorPin,
          ),
        ),
        PopupMenuItem(
          value: _Action.delete,
          child: _MenuItem(
            icon: Icons.delete_outline_rounded,
            label: AppLocalizations.of(context).tutorDelete,
            isDestructive: true,
          ),
        ),
      ],
    );
  }
}

enum _Action { rename, pin, delete }

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final color = isDestructive ? aurora.stateError : aurora.textPrimary;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: aurora.space12),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}
