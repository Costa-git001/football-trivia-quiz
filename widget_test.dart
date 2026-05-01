import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:costa_trivia_quiz/main.dart';

void main() {
  testWidgets('shows the Costa Trivia Quiz start screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'leaderboard_entries': <String>[]});

    await tester.pumpWidget(const CostaTriviaQuizApp());
    await tester.pumpAndSettle();

    expect(find.text('Costa Trivia Quiz'), findsOneWidget);
    expect(find.text('Player name'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Start Game'), findsOneWidget);
  });
}
