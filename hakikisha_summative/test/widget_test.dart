import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/main.dart';

void main() {
  testWidgets('App starts and shows the app name', (tester) async {
    await tester.pumpWidget(const HakikishaApp());

    expect(find.text('Hakikisha'), findsOneWidget);
  });
}
