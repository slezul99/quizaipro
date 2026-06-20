import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/generation_job_notifier.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/widgets/generated_card_preview.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/widgets/save_to_deck_sheet.dart';

class GenerationResultsScreen extends ConsumerStatefulWidget {
  const GenerationResultsScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<GenerationResultsScreen> createState() =>
      _GenerationResultsScreenState();
}

class _GenerationResultsScreenState
    extends ConsumerState<GenerationResultsScreen> {
  Set<int> _selectedIndices = {};
  bool _allSelected = true;

  void _toggleCard(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
      _allSelected = false;
    });
  }

  void _toggleAll(int cardCount) {
    setState(() {
      if (_selectedIndices.length == cardCount) {
        _selectedIndices = {};
        _allSelected = false;
      } else {
        _selectedIndices = Set.from(List.generate(cardCount, (i) => i));
        _allSelected = true;
      }
    });
  }

  void _initSelection(int count) {
    if (_selectedIndices.isEmpty && _allSelected) {
      _selectedIndices = Set.from(List.generate(count, (i) => i));
    }
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final jobAsync =
        ref.watch(generationJobNotifierProvider(jobId: widget.jobId));

    return Scaffold(
      backgroundColor: aurora.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: aurora.backgroundCanvas,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: aurora.textPrimary),
          onPressed: () {
            context.goNamed(AppRoutes.aiGenerationStudioName);
          },
        ),
        title: jobAsync.maybeWhen(
          data: (job) => Text(
            '${job.cards.length} ${AppLocalizations.of(context).aiResultsTitle}',
            style: theme.textTheme.titleSmall
                ?.copyWith(color: aurora.textPrimary),
          ),
          orElse: () => Text(
            AppLocalizations.of(context).aiResultsTitleDefault,
            style: theme.textTheme.titleSmall
                ?.copyWith(color: aurora.textPrimary),
          ),
        ),
      ),
      body: jobAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: aurora.brandGradientStart),
        ),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: aurora.stateError)),
        ),
        data: (job) {
          if (job.cards.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(aurora.space32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sentiment_dissatisfied_outlined,
                        size: 48, color: aurora.textSecondary),
                    SizedBox(height: aurora.space16),
                    Text(
                      AppLocalizations.of(context).aiResultsEmpty,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: aurora.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: aurora.space8),
                    Text(
                      AppLocalizations.of(context).aiResultsEmptySubtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: aurora.textSecondary),
                    ),
                    SizedBox(height: aurora.space24),
                    OutlinedButton(
                      onPressed: () =>
                          context.goNamed(AppRoutes.aiGenerationStudioName),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: aurora.borderDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(aurora.radiusMd),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context).aiResultsTryAgain,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: aurora.textPrimary)),
                    ),
                  ],
                ),
              ),
            );
          }

          _initSelection(job.cards.length);

          return Column(
            children: [
              // Selection controls
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: aurora.space20, vertical: aurora.space12),
                color: aurora.backgroundSurface,
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).aiResultsSelected(_selectedIndices.length, job.cards.length),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: aurora.textSecondary),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _toggleAll(job.cards.length),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: aurora.space8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _selectedIndices.length == job.cards.length
                            ? AppLocalizations.of(context).aiResultsDeselectAll
                            : AppLocalizations.of(context).aiResultsSelectAll,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: aurora.brandGradientStart),
                      ),
                    ),
                  ],
                ),
              ),

              // Cards list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(aurora.space16),
                  itemCount: job.cards.length,
                  itemBuilder: (_, i) => GeneratedCardPreview(
                    card: job.cards[i],
                    index: i,
                    isSelected: _selectedIndices.contains(i),
                    onToggle: () => _toggleCard(i),
                  ),
                ),
              ),

              // Bottom save bar
              Container(
                padding: EdgeInsets.fromLTRB(
                  aurora.space20,
                  aurora.space16,
                  aurora.space20,
                  aurora.space20 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: aurora.backgroundCanvas,
                  border: Border(
                      top: BorderSide(color: aurora.borderDefault)),
                ),
                child: Row(
                  children: [
                    // Try again
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.goNamed(AppRoutes.aiGenerationStudioName),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(AppLocalizations.of(context).aiResultsNew),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: aurora.borderDefault),
                        foregroundColor: aurora.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(aurora.radiusMd),
                        ),
                      ),
                    ),
                    SizedBox(width: aurora.space12),

                    // Save button
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: _selectedIndices.isNotEmpty
                              ? LinearGradient(colors: [
                                  aurora.brandGradientStart,
                                  aurora.brandGradientEnd
                                ])
                              : null,
                          color: _selectedIndices.isEmpty
                              ? aurora.borderDefault
                              : null,
                          borderRadius:
                              BorderRadius.circular(aurora.radiusMd),
                        ),
                        child: TextButton.icon(
                          onPressed: _selectedIndices.isNotEmpty
                              ? () async {
                                  final selected = _selectedIndices
                                      .map((i) => job.cards[i])
                                      .toList();
                                  final saved = await showSaveToDeckSheet(
                                    context: context,
                                    cards: selected,
                                  );
                                  if (saved && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${selected.length} ${AppLocalizations.of(context).aiResultsCardsSaved}'),
                                        backgroundColor: aurora.stateSuccess,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.save_alt_rounded,
                              color: Colors.white, size: 16),
                          label: Text(
                            AppLocalizations.of(context).aiResultsSaveToDeck,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(aurora.radiusMd),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
