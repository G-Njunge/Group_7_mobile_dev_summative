import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/settings/domain/entities/app_settings.dart';
import 'package:hakikisha_summative/features/settings/domain/repositories/settings_repository.dart';
import 'package:hakikisha_summative/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:hakikisha_summative/features/settings/presentation/pages/settings_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockRepo extends Mock implements SettingsRepository {}

void main() {
  late _MockRepo repo;
  late SettingsCubit cubit;

  setUpAll(() => registerFallbackValue(const AppSettings()));

  setUp(() {
    repo = _MockRepo();
    when(() => repo.load()).thenReturn(const AppSettings());
    when(() => repo.save(any())).thenAnswer((_) async {});
    cubit = SettingsCubit(repo);
  });

  tearDown(() => cubit.close());

  /// Pumps the page on a phone of [size] (default: the 360x800 Figma frame).
  Future<void> pumpSettings(
    WidgetTester tester, {
    Locale? locale,
    Size size = const Size(360, 800),
  }) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpPage(
      const SettingsPage(),
      locale: locale ?? const Locale('en'),
      providers: [BlocProvider<SettingsCubit>.value(value: cubit)],
    );
  }

  /// Scrolls the settings list until [text] is on screen, then taps it.
  Future<void> tapRow(WidgetTester tester, String text) async {
    final row = find.text(text);
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(row);
    await tester.pumpAndSettle();
  }

  testWidgets('shows every preference group', (tester) async {
    await pumpSettings(tester);
    await tester.scrollUntilVisible(
      find.text('Save scan history'),
      200,
      scrollable: find.byType(Scrollable).last,
    );

    for (final label in [
      'Settings',
      'APPEARANCE',
      'System',
      'Light',
      'Dark',
      'English',
      'Kiswahili',
      'Scan sound',
      'Vibration',
      'Save scan history',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('choosing Dark updates and saves the theme', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(cubit.state.settings.theme, ThemePreference.dark);
    verify(() => repo.save(const AppSettings(theme: ThemePreference.dark)))
        .called(1);
  });

  testWidgets('toggling a switch saves the new value', (tester) async {
    await pumpSettings(tester);

    await tapRow(tester, 'Save scan history');

    expect(cubit.state.settings.saveHistory, isFalse);
    final toggle = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Save scan history'),
    );
    expect(toggle.value, isFalse);
  });

  testWidgets('a failed save shows a polite error snackbar', (tester) async {
    when(() => repo.save(any())).thenThrow(const SettingsSaveException());
    await pumpSettings(tester);

    await tester.tap(find.text('Vibration'));
    await tester.pump();

    expect(
      find.text("We couldn't save that setting. Please try again."),
      findsOneWidget,
    );
    expect(cubit.state.settings.vibration, isTrue, reason: 'rolled back');
  });

  testWidgets('renders in Swahili', (tester) async {
    await pumpSettings(tester, locale: const Locale('sw'));

    expect(find.text('Mipangilio'), findsOneWidget);
    expect(find.text('Mandhari'), findsOneWidget);
  });

  testWidgets('fits a small phone in landscape without overflow', (
    tester,
  ) async {
    await pumpSettings(tester, size: const Size(640, 360));
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
