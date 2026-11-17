import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/main.dart';

void main() {
  testWidgets('App starts on Landing and opens Login and Register', (
    tester,
  ) async {
    await tester.pumpWidget(const HakikishaApp());
    expect(
      find.text('Know your medicine. Before you take it.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    // Same as pressing the Android back button.
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Try Hakikisha'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(4));
  });
}
