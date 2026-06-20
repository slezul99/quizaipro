import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/conversation.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/providers/chat_notifier.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/providers/conversations_notifier.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/widgets/conversation_tile.dart';
import 'package:quizaipro_mobile/features/tutor/presentation/widgets/tutor_shimmer.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsNotifierProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationsNotifierProvider);
    final notifier = ref.read(conversationsNotifierProvider.notifier);
    final aurora = context.aurora;
    final theme = Theme.of(context);

    final displayList = state.isSearching ? state.searchResults : null;
    final pinned = state.pinned;
    final unpinned = state.unpinned;

    return Scaffold(
      backgroundColor: aurora.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: aurora.backgroundCanvas,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).tutorTitle,
          style: theme.textTheme.titleMedium?.copyWith(color: aurora.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: aurora.textPrimary),
            onPressed: () => _showCreateDialog(context, notifier),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              aurora.space16,
              0,
              aurora.space16,
              aurora.space12,
            ),
            child: _SearchBar(
              controller: _searchController,
              onChanged: (q) => notifier.search(q),
              onClear: () {
                _searchController.clear();
                notifier.clearSearch();
              },
            ),
          ),
          Expanded(
            child: state.isLoading && state.conversations.isEmpty
                ? const TutorShimmer()
                : state.errorMessage != null && state.conversations.isEmpty
                    ? _ErrorView(
                        message: state.errorMessage!,
                        onRetry: () => notifier.load(),
                      )
                    : displayList != null
                        ? _SearchResults(
                            results: displayList,
                            query: state.searchQuery,
                            onTap: (c) => _openChat(c),
                            onRename: (c) =>
                                _showRenameDialog(context, notifier, c),
                            onPin: (c) => notifier.togglePin(c.id),
                            onDelete: (c) =>
                                _confirmDelete(context, notifier, c),
                          )
                        : state.conversations.isEmpty
                            ? _EmptyView(
                                onCreate: () =>
                                    _showCreateDialog(context, notifier),
                              )
                            : _ConversationList(
                                pinned: pinned,
                                unpinned: unpinned,
                                onTap: (c) => _openChat(c),
                                onRename: (c) =>
                                    _showRenameDialog(context, notifier, c),
                                onPin: (c) => notifier.togglePin(c.id),
                                onDelete: (c) =>
                                    _confirmDelete(context, notifier, c),
                              ),
          ),
        ],
      ),
    );
  }

  void _openChat(Conversation conversation) {
    ref.invalidate(chatNotifierProvider(
      conversationId: conversation.id,
      conversationTitle: conversation.title,
      deckId: conversation.deckId,
    ));
    context.pushNamed(
      AppRoutes.tutorChatName,
      queryParameters: {
        'conversationId': conversation.id,
        'conversationTitle': conversation.title,
        if (conversation.deckId != null) 'deckId': conversation.deckId!,
      },
    );
  }

  Future<void> _showCreateDialog(
    BuildContext context,
    ConversationsNotifier notifier,
  ) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.tutorNewConversation),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l.tutorConversationTitle,
          ),
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.tutorCreate),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      final conversation = await notifier.createConversation(
        title: controller.text.trim(),
      );
      if (conversation != null && context.mounted) {
        _openChat(conversation);
      }
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    ConversationsNotifier notifier,
    Conversation conversation,
  ) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: conversation.title);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.tutorRenameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.tutorNewTitle),
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.tutorRename),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      await notifier.rename(conversation.id, controller.text.trim());
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ConversationsNotifier notifier,
    Conversation conversation,
  ) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.tutorDeleteTitle),
        content: Text(l.tutorDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.tutorDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) await notifier.delete(conversation.id);
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).tutorSearch,
        hintStyle: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: aurora.textTertiary),
        prefixIcon: Icon(Icons.search_rounded, color: aurora.textTertiary),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded, color: aurora.textTertiary),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: aurora.backgroundSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(aurora.radiusMd),
          borderSide: BorderSide(color: aurora.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(aurora.radiusMd),
          borderSide: BorderSide(color: aurora.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(aurora.radiusMd),
          borderSide: BorderSide(color: aurora.brandGradientStart),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: aurora.space12),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.pinned,
    required this.unpinned,
    required this.onTap,
    required this.onRename,
    required this.onPin,
    required this.onDelete,
  });

  final List<Conversation> pinned;
  final List<Conversation> unpinned;
  final ValueChanged<Conversation> onTap;
  final ValueChanged<Conversation> onRename;
  final ValueChanged<Conversation> onPin;
  final ValueChanged<Conversation> onDelete;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: aurora.space16),
      children: [
        if (pinned.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: aurora.space8),
            child: Text(
              AppLocalizations.of(context).tutorPinnedSection,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: aurora.textSecondary),
            ),
          ),
          ...pinned.map(
            (c) => Padding(
              padding: EdgeInsets.only(bottom: aurora.space8),
              child: _tile(c),
            ),
          ),
          SizedBox(height: aurora.space8),
        ],
        if (unpinned.isNotEmpty) ...[
          if (pinned.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: aurora.space8),
              child: Text(
                AppLocalizations.of(context).tutorConversationsSection,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: aurora.textSecondary),
              ),
            ),
          ...unpinned.map(
            (c) => Padding(
              padding: EdgeInsets.only(bottom: aurora.space8),
              child: _tile(c),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tile(Conversation c) => ConversationTile(
        conversation: c,
        onTap: () => onTap(c),
        onRename: () => onRename(c),
        onPin: () => onPin(c),
        onDelete: () => onDelete(c),
      );
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.results,
    required this.query,
    required this.onTap,
    required this.onRename,
    required this.onPin,
    required this.onDelete,
  });

  final List<Conversation> results;
  final String query;
  final ValueChanged<Conversation> onTap;
  final ValueChanged<Conversation> onRename;
  final ValueChanged<Conversation> onPin;
  final ValueChanged<Conversation> onDelete;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    if (results.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).tutorNoResults(query),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: aurora.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: aurora.space16),
      itemCount: results.length,
      separatorBuilder: (_, __) => SizedBox(height: aurora.space8),
      itemBuilder: (_, i) => ConversationTile(
        conversation: results[i],
        onTap: () => onTap(results[i]),
        onRename: () => onRename(results[i]),
        onPin: () => onPin(results[i]),
        onDelete: () => onDelete(results[i]),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [aurora.brandGradientStart, aurora.brandGradientEnd],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          SizedBox(height: aurora.space20),
          Text(
            AppLocalizations.of(context).tutorEmpty,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: aurora.textPrimary),
          ),
          SizedBox(height: aurora.space8),
          Text(
            AppLocalizations.of(context).tutorEmptySubtitle,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: aurora.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: aurora.space24),
          GestureDetector(
            onTap: onCreate,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: aurora.space24,
                vertical: aurora.space12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    aurora.brandGradientStart,
                    aurora.brandGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(aurora.radiusMd),
              ),
              child: Text(
                AppLocalizations.of(context).tutorNewConversation,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(aurora.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: aurora.textTertiary),
            SizedBox(height: aurora.space16),
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: aurora.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: aurora.space16),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).tutorRetry),
            ),
          ],
        ),
      ),
    );
  }
}
