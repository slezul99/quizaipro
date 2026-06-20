// Drives the real ReviewAnswersScreen GUI: confirms the AI "diagnose mistake"
// and reinforcing "follow-up question" flow renders and reacts to taps. The
// network is replaced by a fake DiagnosisRepository so the widget tree — not a
// live backend — is what's under test.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/followup_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/mistake_diagnosis.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_answer.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_config.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_option.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_result.dart';
import 'package:quizaipro_mobile/features/tests/domain/repositories/diagnosis_repository.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_providers.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_session_notifier.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_session_state.dart';
import 'package:quizaipro_mobile/features/tests/presentation/screens/review_answers_screen.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class _FakeSessionNotifier extends TestSessionNotifier {
  _FakeSessionNotifier(this._state);
  final TestSessionState _state;
  @override
  TestSessionState build() => _state;
}

class _FakeDiagnosisRepository implements DiagnosisRepository {
  @override
  Future<Either<Failure, MistakeDiagnosis>> diagnose({
    required String question,
    required String chosen,
    required String correct,
  }) async =>
      const Right(MistakeDiagnosis(
        whyWrong: 'WW_BODY',
        whyCorrect: 'WC_BODY',
        misconception: 'MIS_BODY',
        tip: 'TIP_BODY',
      ));

  @override
  Future<Either<Failure, FollowupQuestion>> followup({
    required String question,
    required String correct,
    String? misconception,
  }) async =>
      const Right(FollowupQuestion(
        question: 'FOLLOWUP_Q',
        options: [
          FollowupOption(letter: 'A', text: 'WRONG_OPT'),
          FollowupOption(letter: 'B', text: 'RIGHT_OPT'),
        ],
        correctLetter: 'B',
        explanation: 'EXPL_BODY',
      ));
}

TestSessionState _completedWithWrongAnswer() {
  const config = TestConfig();
  final question = TestQuestion(
    id: 'q1',
    deckId: 'd1',
    question: 'Capital of Australia?',
    correctAnswer: 'Canberra',
    options: const [
      TestOption(id: 'o1', text: 'Sydney', isCorrect: false),
      TestOption(id: 'o2', text: 'Canberra', isCorrect: true),
    ],
  );
  final answer = TestAnswer(
    questionId: 'q1',
    selectedOptionId: 'o1', // chose the wrong option
    isCorrect: false,
    answeredAt: DateTime(2026, 1, 1),
  );
  return TestSessionState.completed(
    result: TestResult(
      id: 'r1',
      deckId: 'd1',
      deckTitle: 'Geography',
      config: config,
      totalQuestions: 1,
      correctCount: 0,
      durationSeconds: 12,
      answers: [answer],
      questions: [question],
      completedAt: DateTime(2026, 1, 1),
    ),
  );
}

Widget _harness() => ProviderScope(
      overrides: [
        testSessionNotifierProvider
            .overrideWith(() => _FakeSessionNotifier(_completedWithWrongAnswer())),
        diagnosisRepositoryProvider.overrideWithValue(_FakeDiagnosisRepository()),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData.light().copyWith(extensions: const [AuroraTokens.light]),
        home: const ReviewAnswersScreen(),
      ),
    );

void main() {
  testWidgets('diagnose + follow-up flow on a wrong answer', (tester) async {
    // Tall surface so the whole review item renders without scrolling.
    tester.view.physicalSize = const Size(1200, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // The diagnose button is shown for the wrong answer.
    expect(find.text('Why did I get this wrong?'), findsOneWidget);

    // Tap it → diagnosis sections appear.
    await tester.tap(find.text('Why did I get this wrong?'));
    await tester.pumpAndSettle();
    expect(find.text('WW_BODY'), findsOneWidget);
    expect(find.text('WC_BODY'), findsOneWidget);
    expect(find.text('MIS_BODY'), findsOneWidget);
    expect(find.text('TIP_BODY'), findsOneWidget);

    // The follow-up button now appears.
    final followBtn = find.text('Practice: similar question');
    expect(followBtn, findsOneWidget);

    // Tap it → a fresh question with two options renders.
    await tester.tap(followBtn);
    await tester.pumpAndSettle();
    expect(find.text('FOLLOWUP_Q'), findsOneWidget);
    expect(find.text('WRONG_OPT'), findsOneWidget);
    expect(find.text('RIGHT_OPT'), findsOneWidget);

    // Pick the wrong option → "Incorrect" + explanation surface.
    await tester.tap(find.text('WRONG_OPT'));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect'), findsOneWidget);
    expect(find.text('EXPL_BODY'), findsOneWidget);
  });
}
