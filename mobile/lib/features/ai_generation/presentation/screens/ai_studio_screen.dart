import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_source.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/find_answers_notifier.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/studio_notifier.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/studio_state.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/widgets/pdf_upload_button.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/widgets/quality_mode_selector.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/widgets/source_selector.dart';

class AiStudioScreen extends ConsumerStatefulWidget {
  const AiStudioScreen({super.key});

  @override
  ConsumerState<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends ConsumerState<AiStudioScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    ref.listen(
      studioNotifierProvider.select((s) => s.submittedJobId),
      (_, jobId) {
        if (jobId != null) {
          ref.read(studioNotifierProvider.notifier).clearSubmittedJob();
          context.pushNamed(
            AppRoutes.aiGenerationProgressName,
            queryParameters: {'jobId': jobId},
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: aurora.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: aurora.backgroundCanvas,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: aurora.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context).aiStudioTitle,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: aurora.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: aurora.textSecondary),
            onPressed: () =>
                context.pushNamed(AppRoutes.aiGenerationHistoryName),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: aurora.brandGradientStart,
          unselectedLabelColor: aurora.textSecondary,
          indicatorColor: aurora.brandGradientStart,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: AppLocalizations.of(context).aiStudioTabGenerate),
            Tab(text: AppLocalizations.of(context).aiStudioTabFindAnswers),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GenerateTab(),
          _FindAnswersTab(),
        ],
      ),
    );
  }
}

// ── Generate Tab ─────────────────────────────────────────────────────────────

class _GenerateTab extends ConsumerStatefulWidget {
  const _GenerateTab();

  @override
  ConsumerState<_GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends ConsumerState<_GenerateTab> {
  final _topicController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final state = ref.watch(studioNotifierProvider);
    final notifier = ref.read(studioNotifierProvider.notifier);

    final cardCounts = [5, 10, 15, 20, 30];

    return SingleChildScrollView(
      padding: EdgeInsets.all(aurora.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source selector
          SourceSelector(
            selected: state.source,
            onChanged: notifier.setSource,
          ),
          SizedBox(height: aurora.space20),

          // Dynamic input area
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey(state.source),
              child: _buildInputArea(context, aurora, theme, state, notifier),
            ),
          ),
          SizedBox(height: aurora.space20),

          // Card count selector
          Text(
            AppLocalizations.of(context).aiStudioCardCountLabel,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: aurora.textSecondary),
          ),
          SizedBox(height: aurora.space8),
          Wrap(
            spacing: aurora.space8,
            children: cardCounts.map((count) {
              final selected = count == state.cardCount;
              return ChoiceChip(
                label: Text('$count'),
                selected: selected,
                onSelected: (_) => notifier.setCardCount(count),
                selectedColor: aurora.brandGradientStart.withOpacity(0.15),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: selected
                      ? aurora.brandGradientStart
                      : aurora.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: aurora.backgroundSurface,
                side: BorderSide(
                  color: selected
                      ? aurora.brandGradientStart
                      : aurora.borderDefault,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(aurora.radiusSm),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: aurora.space20),

          // Quality mode
          QualityModeSelector(
            selected: state.qualityMode,
            onChanged: notifier.setQualityMode,
          ),
          SizedBox(height: aurora.space24),

          // Error
          if (state.errorMessage != null)
            Container(
              margin: EdgeInsets.only(bottom: aurora.space16),
              padding: EdgeInsets.all(aurora.space12),
              decoration: BoxDecoration(
                color: aurora.stateErrorSurface,
                borderRadius: BorderRadius.circular(aurora.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: aurora.stateError, size: 16),
                  SizedBox(width: aurora.space8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: aurora.stateError),
                    ),
                  ),
                ],
              ),
            ),

          // Generate button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: state.canGenerate
                    ? LinearGradient(colors: [
                        aurora.brandGradientStart,
                        aurora.brandGradientEnd,
                      ])
                    : null,
                color: state.canGenerate ? null : aurora.borderDefault,
                borderRadius: BorderRadius.circular(aurora.radiusMd),
              ),
              child: TextButton(
                onPressed: state.canGenerate ? notifier.generate : null,
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(aurora.radiusMd),
                  ),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: aurora.space8),
                          Text(
                            AppLocalizations.of(context).aiStudioGenerate,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: aurora.space32),
        ],
      ),
    );
  }

  Widget _buildInputArea(
    BuildContext context,
    AuroraTokens aurora,
    ThemeData theme,
    StudioState state,
    StudioNotifier notifier,
  ) {
    switch (state.source) {
      case GenerationSource.topic:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).aiStudioTopicLabel,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: aurora.textSecondary),
            ),
            SizedBox(height: aurora.space8),
            TextField(
              controller: _topicController,
              onChanged: notifier.setTopic,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: aurora.textPrimary),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).aiStudioTopicHint,
                hintStyle: theme.textTheme.bodyMedium
                    ?.copyWith(color: aurora.textTertiary),
                filled: true,
                fillColor: aurora.backgroundSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(aurora.radiusMd),
                  borderSide: BorderSide(color: aurora.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(aurora.radiusMd),
                  borderSide:
                      BorderSide(color: aurora.brandGradientStart),
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: aurora.space16, vertical: aurora.space12),
              ),
            ),
          ],
        );

      case GenerationSource.text:
        final charCount = state.bodyText.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).aiStudioTextLabel,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: aurora.textSecondary),
            ),
            SizedBox(height: aurora.space8),
            TextField(
              controller: _textController,
              onChanged: notifier.setBodyText,
              maxLines: 8,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: aurora.textPrimary),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).aiStudioTextHint,
                hintStyle: theme.textTheme.bodySmall
                    ?.copyWith(color: aurora.textTertiary),
                filled: true,
                fillColor: aurora.backgroundSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(aurora.radiusMd),
                  borderSide: BorderSide(color: aurora.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(aurora.radiusMd),
                  borderSide:
                      BorderSide(color: aurora.brandGradientStart),
                ),
                contentPadding: EdgeInsets.all(aurora.space16),
              ),
            ),
            SizedBox(height: aurora.space4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                charCount < 50
                    ? AppLocalizations.of(context).aiStudioCharCountNeedMore(charCount, 50 - charCount)
                    : AppLocalizations.of(context).aiStudioCharCount(charCount),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: charCount >= 50
                      ? aurora.stateSuccess
                      : aurora.textSecondary,
                ),
              ),
            ),
          ],
        );

      case GenerationSource.pdf:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).aiStudioPdfLabel,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: aurora.textSecondary),
            ),
            SizedBox(height: aurora.space8),
            PdfUploadButton(
              fileName: state.pdfFileName,
              onPicked: notifier.setPdf,
              onClear: notifier.clearPdf,
            ),
          ],
        );
    }
  }
}

// ── Find Answers Tab ──────────────────────────────────────────────────────────

class _FindAnswersTab extends ConsumerStatefulWidget {
  const _FindAnswersTab();

  @override
  ConsumerState<_FindAnswersTab> createState() => _FindAnswersTabState();
}

class _FindAnswersTabState extends ConsumerState<_FindAnswersTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final state = ref.watch(findAnswersNotifierProvider);
    final notifier = ref.read(findAnswersNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.all(aurora.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).aiStudioFindAnswersLabel,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: aurora.textSecondary),
          ),
          SizedBox(height: aurora.space8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: notifier.setQuery,
                  minLines: 2,
                  maxLines: 4,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: aurora.textPrimary),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).aiStudioFindAnswersHint,
                    hintStyle: theme.textTheme.bodyMedium
                        ?.copyWith(color: aurora.textTertiary),
                    filled: true,
                    fillColor: aurora.backgroundSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(aurora.radiusMd),
                      borderSide: BorderSide(color: aurora.borderDefault),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(aurora.radiusMd),
                      borderSide:
                          BorderSide(color: aurora.brandGradientStart),
                    ),
                    contentPadding: EdgeInsets.all(aurora.space16),
                  ),
                ),
              ),
              SizedBox(width: aurora.space12),
              Container(
                decoration: BoxDecoration(
                  gradient: state.query.trim().isNotEmpty
                      ? LinearGradient(colors: [
                          aurora.brandGradientStart,
                          aurora.brandGradientEnd
                        ])
                      : null,
                  color: state.query.trim().isEmpty
                      ? aurora.borderDefault
                      : null,
                  borderRadius: BorderRadius.circular(aurora.radiusMd),
                ),
                child: IconButton(
                  icon: state.isSearching
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.search_rounded,
                          color: Colors.white),
                  onPressed: state.query.trim().isNotEmpty && !state.isSearching
                      ? () => notifier.search()
                      : null,
                ),
              ),
            ],
          ),

          if (state.errorMessage != null)
            Padding(
              padding: EdgeInsets.only(top: aurora.space16),
              child: Container(
                padding: EdgeInsets.all(aurora.space12),
                decoration: BoxDecoration(
                  color: aurora.stateErrorSurface,
                  borderRadius: BorderRadius.circular(aurora.radiusSm),
                ),
                child: Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: aurora.stateError),
                ),
              ),
            ),

          if (state.result != null) ...[
            SizedBox(height: aurora.space24),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(aurora.space20),
              decoration: BoxDecoration(
                color: aurora.backgroundSurface,
                borderRadius: BorderRadius.circular(aurora.radiusMd),
                border: Border.all(color: aurora.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [
                            aurora.brandGradientStart,
                            aurora.brandGradientEnd
                          ]),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 14),
                      ),
                      SizedBox(width: aurora.space8),
                      Text(
                        AppLocalizations.of(context).aiStudioAiAnswer,
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: aurora.brandGradientStart,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: aurora.space16),
                  Text(
                    state.result!.explanation,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: aurora.textPrimary, height: 1.6),
                  ),
                  if (state.result!.keyPoints.isNotEmpty) ...[
                    SizedBox(height: aurora.space16),
                    Text(
                      AppLocalizations.of(context).aiStudioKeyPoints,
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: aurora.textSecondary,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: aurora.space8),
                    ...state.result!.keyPoints.map(
                      (point) => Padding(
                        padding: EdgeInsets.only(bottom: aurora.space8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: aurora.brandGradientStart,
                              ),
                            ),
                            SizedBox(width: aurora.space8),
                            Expanded(
                              child: Text(
                                point,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: aurora.textPrimary, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          SizedBox(height: aurora.space32),
        ],
      ),
    );
  }
}
