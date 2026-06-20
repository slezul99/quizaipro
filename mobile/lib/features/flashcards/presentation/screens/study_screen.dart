import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/card_grade.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_mode.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/providers/study_session_notifier.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/providers/study_session_state.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/screens/study_completion_screen.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/widgets/flashcard_widget.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/widgets/grade_buttons.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/widgets/session_header.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/widgets/session_progress_bar.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({
    super.key,
    required this.deckId,
    required this.mode,
    required this.deckTitle,
  });

  final String deckId;
  final StudyMode mode;
  final String deckTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(studySessionNotifierProvider(
      deckId: deckId,
      mode: mode,
      deckTitle: deckTitle,
    ));

    return sessionAsync.when(
      loading: () => _LoadingScaffold(deckTitle: deckTitle),
      error: (e, _) => _ErrorScaffold(
        deckTitle: deckTitle,
        message: e is Failure ? e.userMessage : e.toString(),
      ),
      data: (state) {
        // Queue came back empty (e.g. tapped "review fading" but nothing local
        // is actually fading) — show a friendly all-caught-up state instead of
        // a fake completion trophy for zero cards.
        if (state.stats.total == 0) {
          return _StudyEmptyScaffold(deckTitle: deckTitle);
        }
        if (state.isComplete) {
          return StudyCompletionScreen(
            stats: state.stats,
            deckTitle: state.deckTitle,
            onStudyAgain: () => ref.invalidate(
              studySessionNotifierProvider(
                deckId: deckId,
                mode: mode,
                deckTitle: deckTitle,
              ),
            ),
          );
        }
        return _StudyContent(
          deckId: deckId,
          mode: mode,
          deckTitle: deckTitle,
          state: state,
        );
      },
    );
  }
}

class _StudyContent extends ConsumerWidget {
  const _StudyContent({
    required this.deckId,
    required this.mode,
    required this.deckTitle,
    required this.state,
  });

  final String deckId;
  final StudyMode mode;
  final String deckTitle;
  final StudySessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.aurora;
    final notifier = ref.read(studySessionNotifierProvider(
      deckId: deckId,
      mode: mode,
      deckTitle: deckTitle,
    ).notifier);

    final card = state.currentCard;
    if (card == null) return const SizedBox.shrink();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _confirmQuit(context);
      },
      child: Scaffold(
        backgroundColor: tokens.backgroundCanvas,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.space8,
                  tokens.space8,
                  tokens.space16,
                  0,
                ),
                child: SessionHeader(
                  deckTitle: state.deckTitle,
                  modeName: _modeName(l10n, state.mode),
                  onQuit: () => _confirmQuit(context),
                  quitTooltip: l10n.flashcardsQuit,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.space16,
                  tokens.space16,
                  tokens.space16,
                  tokens.space8,
                ),
                child: SessionProgressBar(
                  progress: state.progress,
                  currentIndex: state.stats.reviewed,
                  total: state.totalInQueue,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.space16),
                  child: Center(
                    child: FlashcardWidget(
                      card: card,
                      isFlipped: state.isCardFlipped,
                      onTap: () => notifier.flipCard(),
                      tapLabel: l10n.flashcardsCardFlip,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.space12,
                  tokens.space8,
                  tokens.space12,
                  tokens.space24,
                ),
                child: GradeButtons(
                  visible: state.isCardFlipped,
                  onGrade: (grade) => notifier.gradeCard(grade),
                  labels: [
                    l10n.flashcardsAgain,
                    l10n.flashcardsHard,
                    l10n.flashcardsGood,
                    l10n.flashcardsEasy,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _modeName(AppLocalizations l10n, StudyMode m) => switch (m) {
        StudyMode.smart => l10n.flashcardsModeSmart,
        StudyMode.newCards => l10n.flashcardsModeNew,
        StudyMode.review => l10n.flashcardsModeReview,
        StudyMode.difficult => l10n.flashcardsModeDifficult,
        StudyMode.favorite => l10n.flashcardsModeFavorite,
        StudyMode.fading => l10n.flashcardsModeFading,
      };

  Future<void> _confirmQuit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.flashcardsQuit),
        content: Text(l10n.flashcardsQuitConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.flashcardsQuitNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.flashcardsQuitYes),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold({required this.deckTitle});
  final String deckTitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    return Scaffold(
      backgroundColor: tokens.backgroundCanvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(tokens.space16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded,
                        color: tokens.textSecondary),
                  ),
                  SizedBox(width: tokens.space8),
                  Text(
                    deckTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({
    required this.deckTitle,
    required this.message,
  });

  final String deckTitle;
  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: tokens.backgroundCanvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(tokens.space16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded,
                        color: tokens.textSecondary),
                  ),
                  SizedBox(width: tokens.space8),
                  Text(
                    deckTitle,
                    style: tt.titleMedium?.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(tokens.space32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: tokens.stateErrorSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.error_outline_rounded,
                            color: tokens.stateError, size: 36),
                      ),
                      SizedBox(height: tokens.space16),
                      Text(
                        l10n.flashcardsLoadError,
                        style: tt.titleMedium?.copyWith(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: tokens.space8),
                      Text(
                        message,
                        style: tt.bodyMedium
                            ?.copyWith(color: tokens.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: tokens.space24),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.back),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when a study session is launched but its queue is empty — e.g. the
/// user tapped "review fading" yet nothing local is actually below target
/// retention. Friendlier than a completion trophy for zero cards.
class _StudyEmptyScaffold extends StatelessWidget {
  const _StudyEmptyScaffold({required this.deckTitle});

  final String deckTitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: tokens.backgroundCanvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(tokens.space16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: tokens.textSecondary),
                  ),
                  SizedBox(width: tokens.space8),
                  Text(
                    deckTitle,
                    style: tt.titleMedium?.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(tokens.space32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: tokens.stateSuccessSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_circle_outline_rounded,
                            color: tokens.stateSuccess, size: 36),
                      ),
                      SizedBox(height: tokens.space16),
                      Text(
                        l10n.dashboardAllCaughtUp,
                        style: tt.titleMedium?.copyWith(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: tokens.space24),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.back),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
