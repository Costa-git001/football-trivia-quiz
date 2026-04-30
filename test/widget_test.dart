import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:costa_trivia_quiz/main.dart';

void main() {
  testWidgets('shows the Costa Trivia Quiz start screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'high_score': 0});

    await tester.pumpWidget(const CostaTriviaQuizApp());
    await tester.pumpAndSettle();

    expect(find.text('Costa Trivia Quiz'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
    expect(find.text('High Score: 0/10'), findsOneWidget);
  });
}
