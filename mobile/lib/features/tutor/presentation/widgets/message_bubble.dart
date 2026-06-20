import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/tutor_message.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final TutorMessage message;

  @override
  Widget build(BuildContext context) {
    return message.isUser
        ? _UserBubble(message: message)
        : _AssistantBubble(message: message);
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});
  final TutorMessage message;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onLongPress: () => _copyToClipboard(context, message.content),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          margin: EdgeInsets.only(
            left: aurora.space48,
            bottom: aurora.space8,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: aurora.space16,
            vertical: aurora.space12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                aurora.brandGradientStart,
                aurora.brandGradientMid,
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(aurora.radiusLg),
              topRight: Radius.circular(aurora.radiusLg),
              bottomLeft: Radius.circular(aurora.radiusLg),
              bottomRight: Radius.circular(aurora.radiusXs),
            ),
          ),
          child: Text(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.tutorCopied)),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.message});
  final TutorMessage message;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _copyToClipboard(context, message.content),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(right: aurora.space8),
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
                size: 16,
                color: Colors.white,
              ),
            ),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                ),
                margin: EdgeInsets.only(
                  right: aurora.space48,
                  bottom: aurora.space8,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: aurora.space16,
                  vertical: aurora.space12,
                ),
                decoration: BoxDecoration(
                  color: aurora.backgroundSurface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(aurora.radiusXs),
                    topRight: Radius.circular(aurora.radiusLg),
                    bottomLeft: Radius.circular(aurora.radiusLg),
                    bottomRight: Radius.circular(aurora.radiusLg),
                  ),
                  border: Border.all(color: aurora.borderSubtle),
                ),
                child: Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: aurora.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.tutorCopied)),
    );
  }
}

/// Streaming bubble — shows incremental text as it arrives.
class StreamingBubble extends StatelessWidget {
  const StreamingBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.only(right: aurora.space8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [aurora.brandGradientStart, aurora.brandGradientEnd],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.75,
              ),
              margin: EdgeInsets.only(
                right: aurora.space48,
                bottom: aurora.space8,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: aurora.space16,
                vertical: aurora.space12,
              ),
              decoration: BoxDecoration(
                color: aurora.backgroundSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(aurora.radiusXs),
                  topRight: Radius.circular(aurora.radiusLg),
                  bottomLeft: Radius.circular(aurora.radiusLg),
                  bottomRight: Radius.circular(aurora.radiusLg),
                ),
                border: Border.all(color: aurora.borderSubtle),
              ),
              child: text.isEmpty
                  ? _PulsingDots()
                  : RichText(
                      text: TextSpan(
                        text: text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: aurora.textPrimary,
                          height: 1.6,
                        ),
                        children: [
                          WidgetSpan(
                            child: _Cursor(),
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cursor extends StatefulWidget {
  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 16,
        margin: const EdgeInsets.only(left: 2),
        color: aurora.brandGradientStart,
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = ((_controller.value - delay) % 1.0).abs();
            final opacity = (1 - (t * 2 - 1).abs()).clamp(0.2, 1.0);
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: aurora.brandGradientStart.withOpacity(opacity),
              ),
            );
          }),
        );
      },
    );
  }
}
