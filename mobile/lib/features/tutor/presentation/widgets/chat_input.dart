import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.onSend,
    this.isStreaming = false,
    this.onStop,
  });

  final ValueChanged<String> onSend;
  final bool isStreaming;
  final VoidCallback? onStop;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isStreaming) return;
    _controller.clear();
    setState(() => _hasText = false);
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        aurora.space16,
        aurora.space8,
        aurora.space16,
        aurora.space8 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: aurora.backgroundSurface,
        border: Border(top: BorderSide(color: aurora.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: aurora.backgroundSurfaceElevated,
                borderRadius: BorderRadius.circular(aurora.radiusLg),
                border: Border.all(color: aurora.borderDefault),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: aurora.textPrimary),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).tutorInputHint,
                  hintStyle: theme.textTheme.bodyMedium
                      ?.copyWith(color: aurora.textTertiary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: aurora.space16,
                    vertical: aurora.space12,
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          SizedBox(width: aurora.space8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.isStreaming
                ? _StopButton(onStop: widget.onStop)
                : _SendButton(
                    enabled: _hasText,
                    onSend: _send,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onSend});

  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return GestureDetector(
      onTap: enabled ? onSend : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: [aurora.brandGradientStart, aurora.brandGradientEnd],
                )
              : null,
          color: enabled ? null : aurora.borderSubtle,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.send_rounded,
          size: 20,
          color: enabled ? Colors.white : aurora.textTertiary,
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({this.onStop});
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return GestureDetector(
      onTap: onStop,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: aurora.stateErrorSurface,
          shape: BoxShape.circle,
          border: Border.all(color: aurora.stateError),
        ),
        child: Icon(
          Icons.stop_rounded,
          size: 20,
          color: aurora.stateError,
        ),
      ),
    );
  }
}
