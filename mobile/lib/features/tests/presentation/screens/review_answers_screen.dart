import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/followup_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/mistake_diagnosis.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_answer.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_option.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_question.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_providers.dart';
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

class _ReviewItem extends ConsumerStatefulWidget {
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
  ConsumerState<_ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends ConsumerState<_ReviewItem> {
  MistakeDiagnosis? _diag;
  bool _diagLoading = false;
  String? _diagError;

  FollowupQuestion? _fq;
  bool _fqLoading = false;
  String? _fqError;
  String? _picked;

  String? get _chosenText {
    final id = widget.answer?.selectedOptionId;
    if (id == null) return null;
    return widget.question.options.where((o) => o.id == id).firstOrNull?.text;
  }

  String get _correctText =>
      widget.question.correctOption?.text ?? widget.question.correctAnswer;

  Future<void> _runDiagnose() async {
    if (_diag != null || _diagLoading) return;
    setState(() {
      _diagLoading = true;
      _diagError = null;
    });
    final res = await ref.read(diagnosisRepositoryProvider).diagnose(
          question: widget.question.question,
          chosen: _chosenText ?? '',
          correct: _correctText,
        );
    if (!mounted) return;
    res.fold(
      (_) => setState(() {
        _diagError = AppLocalizations.of(context)!.testsDiagnoseError;
        _diagLoading = false;
      }),
      (d) => setState(() {
        _diag = d;
        _diagLoading = false;
      }),
    );
  }

  Future<void> _runFollowup() async {
    if (_fq != null || _fqLoading) return;
    setState(() {
      _fqLoading = true;
      _fqError = null;
    });
    final res = await ref.read(diagnosisRepositoryProvider).followup(
          question: widget.question.question,
          correct: _correctText,
          misconception: _diag?.misconception,
        );
    if (!mounted) return;
    res.fold(
      (_) => setState(() {
        _fqError = AppLocalizations.of(context)!.testsFollowupError;
        _fqLoading = false;
      }),
      (q) => setState(() {
        _fq = q;
        _fqLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final isCorrect = widget.answer?.isCorrect ?? false;

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
              AppLocalizations.of(context)!.testsReviewQuestionOf(
                  widget.questionNumber, widget.totalQuestions),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: aurora.textSecondary,
                  ),
            ),
          ],
        ),
        SizedBox(height: aurora.space12),
        QuestionCard(
          question: widget.question,
          questionNumber: widget.questionNumber,
          totalQuestions: widget.totalQuestions,
        ),
        SizedBox(height: aurora.space12),
        ...widget.question.options.map((option) {
          final optState = _optionState(option, widget.answer);
          return Padding(
            padding: EdgeInsets.only(bottom: aurora.space8),
            child: AnswerOptionWidget(
              option: option,
              optionState: optState,
            ),
          );
        }),
        if (!isCorrect) _buildAiSection(context, aurora),
      ],
    );
  }

  Widget _buildAiSection(BuildContext context, AuroraTokens aurora) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: aurora.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_diag == null)
            OutlinedButton.icon(
              onPressed: _diagLoading ? null : _runDiagnose,
              icon: _diagLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.psychology_alt_rounded, size: 18),
              label: Text(
                  _diagLoading ? l10n.testsDiagnoseLoading : l10n.testsDiagnoseButton),
              style: OutlinedButton.styleFrom(foregroundColor: aurora.brandPrimary),
            ),
          if (_diagError != null)
            Padding(
              padding: EdgeInsets.only(top: aurora.space8),
              child: Text(_diagError!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: aurora.stateError)),
            ),
          if (_diag != null) _buildDiagnosisCard(context, aurora, _diag!),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(
      BuildContext context, AuroraTokens aurora, MistakeDiagnosis d) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(aurora.space16),
      decoration: BoxDecoration(
        color: aurora.surfaceSubtle,
        borderRadius: BorderRadius.circular(aurora.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section(context, aurora, l10n.testsDiagnoseWhyWrong, d.whyWrong,
              aurora.stateError),
          if (d.whyCorrect.isNotEmpty)
            _section(context, aurora, l10n.testsDiagnoseWhyCorrect,
                d.whyCorrect, aurora.stateSuccess),
          if (d.misconception.isNotEmpty)
            _section(context, aurora, l10n.testsDiagnoseMisconception,
                d.misconception, aurora.brandPrimary),
          if (d.tip.isNotEmpty)
            _section(context, aurora, '💡 ${l10n.testsDiagnoseTip}', d.tip,
                aurora.brandPrimary),
          SizedBox(height: aurora.space12),
          _buildFollowup(context, aurora),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, AuroraTokens aurora, String heading,
      String body, Color accent) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: aurora.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading.toUpperCase(),
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: accent, fontWeight: FontWeight.bold)),
          SizedBox(height: aurora.space4),
          Text(body,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: aurora.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildFollowup(BuildContext context, AuroraTokens aurora) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_fq == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: _fqLoading ? null : _runFollowup,
            icon: _fqLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.fitness_center_rounded, size: 18),
            label: Text(
                _fqLoading ? l10n.testsDiagnoseLoading : l10n.testsFollowupButton),
            style: TextButton.styleFrom(foregroundColor: aurora.brandPrimary),
          ),
          if (_fqError != null)
            Text(_fqError!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: aurora.stateError)),
        ],
      );
    }

    final fq = _fq!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fq.question,
            style: theme.textTheme.titleSmall
                ?.copyWith(color: aurora.textPrimary, fontWeight: FontWeight.bold)),
        SizedBox(height: aurora.space8),
        ...fq.options.map((opt) => _buildFollowupOption(context, aurora, fq, opt)),
        if (_picked != null) ...[
          SizedBox(height: aurora.space4),
          Text(
            _picked == fq.correctLetter
                ? l10n.testsFollowupCorrect
                : l10n.testsFollowupWrong,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _picked == fq.correctLetter
                  ? aurora.stateSuccess
                  : aurora.stateError,
            ),
          ),
          if (fq.explanation.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: aurora.space4),
              child: Text(fq.explanation,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: aurora.textSecondary)),
            ),
        ],
      ],
    );
  }

  Widget _buildFollowupOption(BuildContext context, AuroraTokens aurora,
      FollowupQuestion fq, FollowupOption opt) {
    final theme = Theme.of(context);
    final answered = _picked != null;
    final isRight = opt.letter == fq.correctLetter;
    final isPicked = _picked == opt.letter;

    Color bg = aurora.surfaceCard;
    Color border = aurora.surfaceCard;
    if (answered && isRight) {
      bg = aurora.stateSuccessSurface;
      border = aurora.stateSuccess;
    } else if (answered && isPicked && !isRight) {
      bg = aurora.stateErrorSurface;
      border = aurora.stateError;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: aurora.space8),
      child: InkWell(
        borderRadius: BorderRadius.circular(aurora.radiusM),
        onTap: answered ? null : () => setState(() => _picked = opt.letter),
        child: Container(
          padding: EdgeInsets.all(aurora.space12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(aurora.radiusM),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Text('${opt.letter}. ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: aurora.textSecondary, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(opt.text,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: aurora.textPrimary)),
              ),
              if (answered && isRight)
                Icon(Icons.check_rounded, size: 18, color: aurora.stateSuccess),
              if (answered && isPicked && !isRight)
                Icon(Icons.close_rounded, size: 18, color: aurora.stateError),
            ],
          ),
        ),
      ),
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
