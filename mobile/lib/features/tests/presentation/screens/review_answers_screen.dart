import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_answer.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_option.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_question.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_session_notifier.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_session_state.dart';
import 'package:quizaipro_mobile/features/tests/presentation/widgets/answer_option.dart';
import 'package:quizaipro_mobile/features/tests/presentation/widgets/question_card.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class ReviewAnswersScreen extends ConsumerWidget {
  const ReviewAnswersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(testSessionNotifierProvider);

    if (state is! TestSessionStateCompleted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final result = state.result;
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: aurora.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: aurora.backgroundCanvas,
        elevation: 0,
        title: Text(
          l10n.testsReviewTitle,
          style: theme.textTheme.titleMedium?.copyWith(color: aurora.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: aurora.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(aurora.space20),
        itemCount: result.questions.length,
        separatorBuilder: (_, __) => SizedBox(height: aurora.space24),
        itemBuilder: (context, index) {
          final question = result.questions[index];
          final answer = result.answers
              .where((a) => a.questionId == question.id)
              .firstOrNull;
          return _ReviewItem(
            question: question,
            answer: answer,
            questionNumber: index + 1,
            totalQuestions: result.questions.length,
          );
        },
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.question,
    required this.answer,
    required this.questionNumber,
    required this.totalQuestions,
  });

  final TestQuestion question;
  final TestAnswer? answer;
  final int questionNumber;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final isCorrect = answer?.isCorrect ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCorrect ? aurora.stateSuccessSurface : aurora.stateErrorSurface,
              ),
              alignment: Alignment.center,
              child: Icon(
                isCorrect ? Icons.check_rounded : Icons.close_rounded,
                size: 16,
                color: isCorrect ? aurora.stateSuccess : aurora.stateError,
              ),
            ),
            SizedBox(width: aurora.space8),
            Text(
              AppLocalizations.of(context)!
                  .testsReviewQuestionOf(questionNumber, totalQuestions),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: aurora.textSecondary,
                  ),
            ),
          ],
        ),
        SizedBox(height: aurora.space12),
        QuestionCard(
          question: question,
          questionNumber: questionNumber,
          totalQuestions: totalQuestions,
        ),
        SizedBox(height: aurora.space12),
        ...question.options.map((option) {
          final optState = _optionState(option, answer);
          return Padding(
            padding: EdgeInsets.only(bottom: aurora.space8),
            child: AnswerOptionWidget(
              option: option,
              optionState: optState,
            ),
          );
        }),
      ],
    );
  }

  AnswerOptionState _optionState(TestOption option, TestAnswer? answer) {
    if (option.isCorrect) return AnswerOptionState.correct;
    if (answer?.selectedOptionId == option.id && !option.isCorrect) {
      return AnswerOptionState.incorrect;
    }
    return AnswerOptionState.idle;
  }
}
