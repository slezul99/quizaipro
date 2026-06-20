// Renders the real RetentionCard widget and asserts it surfaces the FSRS
// numbers (now %, one-week forecast, fading count) the backend supplies.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/retention_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/retention_card.dart';

void main() {
  testWidgets('shows retention %, forecast and fading count', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light().copyWith(extensions: const [AuroraTokens.light]),
        home: const Scaffold(
          body: RetentionCard(
            retention: RetentionSummary(now: 34, forecast: 31, fading: 33, studied: 33),
            tokens: AuroraTokens.light,
            title: 'Retention',
            forecastLabel: 'in a week',
            fadingLabel: 'fading',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retention'), findsOneWidget);
    expect(find.text('34%'), findsOneWidget);
    expect(find.text('in a week 31%'), findsOneWidget);
    expect(find.text('33 fading'), findsOneWidget);
  });

  testWidgets('hides the fading line when nothing is fading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light().copyWith(extensions: const [AuroraTokens.light]),
        home: const Scaffold(
          body: RetentionCard(
            retention: RetentionSummary(now: 92, forecast: 90, fading: 0, studied: 10),
            tokens: AuroraTokens.light,
            title: 'Retention',
            forecastLabel: 'in a week',
            fadingLabel: 'fading',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('92%'), findsOneWidget);
    expect(find.textContaining('fading'), findsNothing);
  });
}
