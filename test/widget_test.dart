import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('onboarding leads to sign in', (tester) async {
    await tester.pumpWidget(const BudgetWiseApp());

    expect(find.text('Track your spending effortlessly'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('BudgetWise'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('sign in opens the dashboard', (tester) async {
    await tester.pumpWidget(const BudgetWiseApp());
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('TOTAL NET BALANCE'), findsOneWidget);
  });
}
