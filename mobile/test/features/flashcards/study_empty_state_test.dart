// Drives StudyScreen with an empty queue (e.g. tapped "review fading" but
// nothing is actually fading): it must show the friendly all-caught-up state,
// not a completion trophy for zero cards.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/session_stats.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_mode.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/providers/study_session_notifier.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/providers/study_session_state.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/screens/study_completion_screen.dart';
import 'package:quizaipro_mobile/features/flashcards/presentation/screens/study_screen.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class _FakeStudyNotifier extends StudySessionNotifier {
  _FakeStudyNotifier(this._state);
  final StudySessionState _state;
  @override
  Future<StudySessionState> build({
    required String deckId,
    required StudyMode mode,
    required String deckTitle,
  }) async =>
      _state;
}

void main() {
  testWidgets('empty fading queue shows all-caught-up, not a trophy',
      (tester) async {
    final emptyState = StudySessionState(
      queue: const [],
      currentIndex: 0,
      isCardFlipped: false,
      stats: SessionStats(total: 0, startedAt: DateTime(2026, 1, 1)),
      mode: StudyMode.fading,
      deckId: 'd1',
      deckTitle: 'Geography',
      isComplete: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionNotifierProvider(
            deckId: 'd1',
            mode: StudyMode.fading,
            deckTitle: 'Geography',
          ).overrideWith(() => _FakeStudyNotifier(emptyState)),
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
          home: const StudyScreen(
            deckId: 'd1',
            mode: StudyMode.fading,
            deckTitle: 'Geography',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All caught up! 🎉'), findsOneWidget);
    expect(find.byType(StudyCompletionScreen), findsNothing);
  });
}
