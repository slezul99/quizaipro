import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_question.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_session_notifier.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_session_state.dart';
import 'package:quizaipro_mobile/features/tests/presentation/widgets/answer_option.dart';
import 'package:quizaipro_mobile/features/tests/presentation/widgets/question_card.dart';
import 'package:quizaipro_mobile/features/tests/presentation/widgets/test_progress_bar.dart';
import 'package:quizaipro_mobile/features/tests/presentation/widgets/timer_widget.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class TestSessionScreen extends ConsumerWidget {
  const TestSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(testSessionNotifierProvider);
    final notifier = ref.read(testSessionNotifierProvider.notifier);

    ref.listen<TestSessionState>(testSessionNotifierProvider, (_, next) {
      if (next is TestSessionStateCompleted && context.mounted) {
        context.pushReplacementNamed(AppRoutes.testResultsName);
      }
    });

    return switch (state) {
      TestSessionStateIdle() => const SizedBox.shrink(),
      TestSessionStateLoading() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      TestSessionStateFailed(:final message) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      notifier.reset();
                      context.pop();
                    },
                    child: Text(AppLocalizations.of(context)!.back),
                  ),
                ],
              ),
            ),
          ),
        ),
      TestSessionStateCompleted() => const SizedBox.shrink(),
      TestSessionStateInProgress(
        :final questions,
        :final currentIndex,
        :final answers,
        :final config,
        :final remainingSeconds,
      ) =>
        _SessionBody(
          questions: questions,
          currentIndex: currentIndex,
          answers: answers,
          timedMode: config.timedMode,
          remainingSeconds: remainingSeconds,
          notifier: notifier,
        ),
    };
  }
}

class _SessionBody extends StatelessWidget {
  const _SessionBody({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.timedMode,
    required this.remainingSeconds,
    required this.notifier,
  });

  final List<TestQuestion> questions;
  final int currentIndex;
  final Map<String, String> answers;
  final bool timedMode;
  final int? remainingSeconds;
  final TestSessionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final question = questions[currentIndex];
    final selectedOptionId = answers[question.id];
    final isLast = currentIndex == questions.length - 1;

    return Scaffold(
      backgroundColor: aurora.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: aurora.backgroundCanvas,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: aurora.textPrimary),
          onPressed: () => _confirmQuit(context),
        ),
        title: TestProgressBar(
          current: currentIndex + 1,
          total: questions.length,
        ),
        actions: [
          if (timedMode && remainingSeconds != null)
            Padding(
              padding: EdgeInsets.only(right: aurora.space12),
              child: Center(
                child: TimerWidget(remainingSeconds: remainingSeconds!),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(aurora.space20),
              children: [
                QuestionCard(
                  question: question,
                  questionNumber: currentIndex + 1,
                  totalQuestions: questions.length,
                ),
                SizedBox(height: aurora.space20),
                ...question.options.map((option) {
                  final optState = selectedOptionId == option.id
                      ? AnswerOptionState.selected
                      : AnswerOptionState.idle;
                  return Padding(
                    padding: EdgeInsets.only(bottom: aurora.space12),
                    child: AnswerOptionWidget(
                      option: option,
                      optionState: optState,
                      onTap: () =>
                          notifier.selectAnswer(question.id, option.id),
                    ),
                  );
                }),
              ],
            ),
          ),
          _BottomBar(
            currentIndex: currentIndex,
            isLast: isLast,
            hasAnswer: selectedOptionId != null,
            notifier: notifier,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmQuit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.testsQuitTitle),
        content: Text(l10n.testsQuitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.testsQuitCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.testsQuitConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      notifier.reset();
      context.pop();
    }
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentIndex,
    required this.isLast,
    required this.hasAnswer,
    required this.notifier,
  });

  final int currentIndex;
  final bool isLast;
  final bool hasAnswer;
  final TestSessionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final canProceed = hasAnswer;

    return Container(
      padding: EdgeInsets.fromLTRB(
        aurora.space20,
        aurora.space12,
        aurora.space20,
        aurora.space20 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: aurora.backgroundSurface,
        border: Border(top: BorderSide(color: aurora.borderSubtle)),
      ),
      child: Row(
        children: [
          if (currentIndex > 0) ...[
            OutlinedButton(
              onPressed: notifier.previousQuestion,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: aurora.borderDefault),
                padding: EdgeInsets.symmetric(
                  horizontal: aurora.space16,
                  vertical: aurora.space12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(aurora.radiusMd),
                ),
              ),
              child: Icon(Icons.arrow_back_rounded, color: aurora.textPrimary),
            ),
            SizedBox(width: aurora.space12),
          ],
          Expanded(
            child: GestureDetector(
              onTap: isLast
                  ? () => notifier.submitTest()
                  : (canProceed ? notifier.nextQuestion : null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  gradient: canProceed || isLast
                      ? LinearGradient(
                          colors: [
                            aurora.brandGradientStart,
                            aurora.brandGradientEnd,
                          ],
                        )
                      : null,
                  color: canProceed || isLast ? null : aurora.borderSubtle,
                  borderRadius: BorderRadius.circular(aurora.radiusMd),
                ),
                alignment: Alignment.center,
                child: Text(
                  isLast
                      ? AppLocalizations.of(context)!.testsSubmit
                      : AppLocalizations.of(context)!.testsNext,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: canProceed || isLast
                            ? Colors.white
                            : aurora.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
