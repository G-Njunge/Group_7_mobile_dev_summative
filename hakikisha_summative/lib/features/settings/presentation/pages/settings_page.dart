import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/neumorphic.dart';
import '../../../../core/widgets/segmented_pill.dart';
import '../../domain/entities/app_settings.dart';
import '../bloc/settings_cubit.dart';

/// Theme, language, scan feedback and history preferences. Every change is
/// applied instantly and saved on the device by [SettingsCubit].
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.navSettings,
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listenWhen: (_, current) => current.saveFailed,
        listener: (context, _) =>
            showAppSnackBar(context, l10n.settingsSaveError),
        builder: (context, state) {
          final settings = state.settings;
          final update = context.read<SettingsCubit>().update;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              SectionLabel(l10n.settingsAppearance),
              NeuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PickerLabel(l10n.settingsTheme),
                    SegmentedPill(
                      selected: settings.theme,
                      onChanged: (v) => update((s) => s.copyWith(theme: v)),
                      options: [
                        PillOption(ThemePreference.system, l10n.themeSystem),
                        PillOption(ThemePreference.light, l10n.themeLight),
                        PillOption(ThemePreference.dark, l10n.themeDark),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _PickerLabel(l10n.settingsLanguage),
                    SegmentedPill(
                      selected: settings.language,
                      onChanged: (v) => update((s) => s.copyWith(language: v)),
                      options: [
                        for (final language in AppLanguage.values)
                          PillOption(language, language.nativeName),
                      ],
                    ),
                  ],
                ),
              ),
              SectionLabel(l10n.settingsScanning),
              _SwitchCard(
                tiles: [
                  _SwitchTile(
                    icon: Icons.volume_up_outlined,
                    title: l10n.scanSound,
                    subtitle: l10n.scanSoundHint,
                    value: settings.scanSound,
                    onChanged: (v) => update((s) => s.copyWith(scanSound: v)),
                  ),
                  _SwitchTile(
                    icon: Icons.vibration,
                    title: l10n.vibration,
                    subtitle: l10n.vibrationHint,
                    value: settings.vibration,
                    onChanged: (v) => update((s) => s.copyWith(vibration: v)),
                  ),
                ],
              ),
              SectionLabel(l10n.settingsPrivacy),
              _SwitchCard(
                tiles: [
                  _SwitchTile(
                    icon: Icons.history,
                    title: l10n.saveHistory,
                    subtitle: l10n.saveHistoryHint,
                    value: settings.saveHistory,
                    onChanged: (v) => update((s) => s.copyWith(saveHistory: v)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PickerLabel extends StatelessWidget {
  const _PickerLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

/// A card of switch rows separated by dividers.
class _SwitchCard extends StatelessWidget {
  const _SwitchCard({required this.tiles});

  final List<_SwitchTile> tiles;

  @override
  Widget build(BuildContext context) => NeuCard(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      children: [
        for (final (i, tile) in tiles.indexed) ...[
          if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
          tile,
        ],
      ],
    ),
  );
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: Icon(icon),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle),
    value: value,
    onChanged: onChanged,
  );
}
