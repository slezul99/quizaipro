// Basic smoke test: verifies the app boots and renders a MaterialApp.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quizaipro_mobile/app.dart';

void main() {
  testWidgets('App boots and renders MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: App()),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
