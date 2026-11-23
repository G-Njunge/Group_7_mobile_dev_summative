import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/app_localizations_delegates.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/session/session_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';

/// Root widget. Provides the app-wide cubits and rebuilds the [MaterialApp]
/// only when the theme or language setting changes.
///
/// Everything is passed in rather than created here, so widget tests can
/// pump the real app with fakes.
class HakikishaApp extends StatelessWidget {
  const HakikishaApp({
    super.key,
    required this.router,
    required this.sessionCubit,
    required this.settingsCubit,
  });

  final GoRouter router;
  final SessionCubit sessionCubit;
  final SettingsCubit settingsCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sessionCubit),
        BlocProvider.value(value: settingsCubit),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.settings.theme != current.settings.theme ||
            previous.settings.language != current.settings.language,
        builder: (context, state) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // ThemePreference mirrors ThemeMode's names one-to-one.
          themeMode: ThemeMode.values.byName(state.settings.theme.name),
          locale: Locale(state.settings.language.code),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
  }
}
