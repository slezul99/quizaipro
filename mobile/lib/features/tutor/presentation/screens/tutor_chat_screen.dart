import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/providers/chat_notifier.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/providers/chat_state.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/providers/conversations_notifier.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/widgets/chat_input.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/widgets/message_bubble.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/widgets/tutor_shimmer.dart';

class TutorChatScreen extends ConsumerStatefulWidget {
  const TutorChatScreen({
    super.key,
    required this.conversationId,
    required this.conversationTitle,
    this.deckId,
  });

  final String conversationId;
  final String conversationTitle;
  final String? deckId;

  @override
  ConsumerState<TutorChatScreen> createState() => _TutorChatScreenState();
}

class _TutorChatScreenState extends ConsumerState<TutorChatScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(_chatNotifier.notifier)
          .loadHistory()
          .then((_) => _scrollToBottom());
    });
  }

  // Returns the family provider instance for this conversation.
  // The generated type is handled by Riverpod's type system at build time.
  get _chatNotifier => chatNotifierProvider(
        conversationId: widget.conversationId,
        conversationTitle: widget.conversationTitle,
        deckId: widget.deckId,
      );

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_chatNotifier);
    final notifier = ref.read(_chatNotifier.notifier);
    final aurora = context.aurora;
    final theme = Theme.of(context);

    ref.listen<ChatState>(_chatNotifier, (_, next) {
      if (next.messages.length > (state.messages.length) ||
          next.streamingBuffer.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
      // Update conversation list meta when a new assistant message arrives
      if (next.messages.isNotEmpty && !next.isStreaming) {
        final last = next.messages.last;
        if (last.isAssistant) {
          ref.read(conversationsNotifierProvider.notifier).updateLastMessage(
                widget.conversationId,
                last.content.length > 80
                    ? '${last.content.substring(0, 80)}…'
                    : last.content,
              );
        }
      }
    });

    return Scaffold(
      backgroundColor: aurora.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: aurora.backgroundCanvas,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: aurora.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conversationTitle,
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: aurora.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.deckId != null)
              Text(
                AppLocalizations.of(context).tutorWithDeckContext,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: aurora.brandGradientStart),
              ),
          ],
        ),
        actions: [
          if (state.isStreaming)
            Padding(
              padding: EdgeInsets.only(right: aurora.space12),
              child: Center(
                child: _StreamingIndicator(),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (state.errorMessage != null)
            _ErrorBanner(
              message: state.errorMessage!,
              onDismiss: notifier.clearError,
            ),
          Expanded(
            child: state.isLoadingHistory && state.messages.isEmpty
                ? const ChatShimmer()
                : _MessageList(
                    state: state,
                    scrollController: _scrollController,
                  ),
          ),
          ChatInput(
            isStreaming: state.isStreaming,
            onSend: (content) async {
              await notifier.sendMessage(content);
            },
            onStop: notifier.cancelStream,
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.state,
    required this.scrollController,
  });

  final ChatState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;

    if (state.messages.isEmpty && !state.isStreaming) {
      return _WelcomeView();
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(aurora.space16),
      itemCount: state.messages.length + (state.isStreaming ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length && state.isStreaming) {
          return StreamingBubble(text: state.streamingBuffer);
        }
        return MessageBubble(message: state.messages[index]);
      },
    );
  }
}

class _WelcomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(aurora.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [aurora.brandGradientStart, aurora.brandGradientEnd],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
            SizedBox(height: aurora.space20),
            Text(
              AppLocalizations.of(context).tutorAskAnything,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: aurora.textPrimary),
            ),
            SizedBox(height: aurora.space8),
            Text(
              AppLocalizations.of(context).tutorWelcomeSubtitle,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: aurora.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: aurora.space16,
        vertical: aurora.space8,
      ),
      color: aurora.stateErrorSurface,
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 16, color: aurora.stateError),
          SizedBox(width: aurora.space8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: aurora.stateError,
                  ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded,
                size: 16, color: aurora.stateError),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _StreamingIndicator extends StatefulWidget {
  @override
  State<_StreamingIndicator> createState() => _StreamingIndicatorState();
}

class _StreamingIndicatorState extends State<_StreamingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i / 3;
          final t = ((_controller.value - delay) % 1.0).abs();
          final opacity = (1 - (t * 2 - 1).abs()).clamp(0.3, 1.0);
          return Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: aurora.brandGradientStart.withOpacity(opacity),
            ),
          );
        }),
      ),
    );
  }
}
