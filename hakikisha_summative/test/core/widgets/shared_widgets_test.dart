import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/core/widgets/app_buttons.dart';
import 'package:hakikisha_summative/core/widgets/app_scaffold.dart';
import 'package:hakikisha_summative/core/widgets/app_snack_bar.dart';
import 'package:hakikisha_summative/core/widgets/app_text_field.dart';
import 'package:hakikisha_summative/core/widgets/confirm_dialog.dart';
import 'package:hakikisha_summative/core/widgets/neumorphic.dart';
import 'package:hakikisha_summative/core/widgets/segmented_pill.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('fires onPressed and is at least 48dp tall', (tester) async {
      var taps = 0;
      await tester.pumpPage(
        PrimaryButton(label: 'Log in', onPressed: () => taps++),
      );

      await tester.tap(find.text('Log in'));
      expect(taps, 1);
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('shows a spinner and ignores taps while loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpPage(
        PrimaryButton(label: 'Log in', loading: true, onPressed: () => taps++),
        settle: false,
      );

      await tester.tap(find.text('Log in'), warnIfMissed: false);
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  testWidgets('SecondaryButton renders an icon and fires', (tester) async {
    var taps = 0;
    await tester.pumpPage(
      SecondaryButton(label: 'Call', icon: Icons.call, onPressed: () => taps++),
    );

    await tester.tap(find.text('Call'));
    expect(taps, 1);
    expect(find.byIcon(Icons.call), findsOneWidget);
  });

  group('AppTextField', () {
    testWidgets('shows the validator message below the field in a Form', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpPage(
        Form(
          key: formKey,
          child: AppTextField(
            label: 'Batch number',
            validator: (v) =>
                (v ?? '').isEmpty ? 'Enter the batch number' : null,
          ),
        ),
      );
      expect(find.text('BATCH NUMBER'), findsOneWidget);

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter the batch number'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'PA23-0871');
      expect(formKey.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Enter the batch number'), findsNothing);
    });

    testWidgets('errorText from a bloc wins over the validator', (
      tester,
    ) async {
      await tester.pumpPage(
        const AppTextField(label: 'Email', errorText: 'Email already in use'),
      );
      expect(find.text('Email already in use'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('password toggle shows and hides the text', (tester) async {
      await tester.pumpPage(
        const AppTextField(label: 'Password', obscure: true),
      );
      bool obscured() =>
          tester.widget<TextField>(find.byType(TextField)).obscureText;

      expect(obscured(), isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(obscured(), isFalse);
    });
  });

  testWidgets('SegmentedPill reports the tapped option', (tester) async {
    String? picked;
    await tester.pumpPage(
      SegmentedPill<String>(
        selected: 'all',
        onChanged: (v) => picked = v,
        options: const [
          PillOption('all', 'All'),
          PillOption('flagged', 'Flagged'),
        ],
      ),
    );

    await tester.tap(find.text('Flagged'));
    expect(picked, 'flagged');
  });

  group('showConfirmDialog', () {
    Future<bool?> run(WidgetTester tester, String tap) async {
      bool? result;
      await tester.pumpPage(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showConfirmDialog(
              context,
              title: 'Delete scan?',
              message: 'This cannot be undone.',
              confirmLabel: 'Delete',
              cancelLabel: 'Keep',
              showLogo: true,
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete scan?'), findsOneWidget);
      await tester.tap(find.text(tap));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('returns true on confirm', (tester) async {
      expect(await run(tester, 'Delete'), isTrue);
    });

    testWidgets('returns false on cancel', (tester) async {
      expect(await run(tester, 'Keep'), isFalse);
    });
  });

  testWidgets('showAppSnackBar shows each type', (tester) async {
    late BuildContext ctx;
    await tester.pumpPage(
      Builder(
        builder: (context) {
          ctx = context;
          return const SizedBox();
        },
      ),
    );

    for (final type in SnackType.values) {
      showAppSnackBar(ctx, 'msg ${type.name}', type: type);
      await tester.pump();
      expect(find.text('msg ${type.name}'), findsOneWidget);
    }
  });

  testWidgets('NeuCard is tappable and SectionLabel is uppercase', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpPage(
      Column(
        children: [
          const SectionLabel('Recent scans'),
          NeuCard(
            onTap: () => taps++,
            child: const NeuInset(child: Text('card')),
          ),
        ],
      ),
    );

    expect(find.text('RECENT SCANS'), findsOneWidget);
    await tester.tap(find.text('card'));
    expect(taps, 1);
  });

  testWidgets(
    'AppScaffold on a root page shows the menu and opens the drawer',
    (tester) async {
      await tester.pumpPage(
        const AppScaffold(title: 'Home', showLogo: true, body: SizedBox()),
      );

      expect(find.text('Home'), findsOneWidget);
      await tester.tap(find.byTooltip('Open menu'));
      await tester.pumpAndSettle();
      expect(find.text('Scan history'), findsOneWidget);
    },
  );
}
