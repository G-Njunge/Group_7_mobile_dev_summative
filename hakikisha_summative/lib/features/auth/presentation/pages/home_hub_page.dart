// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../pharmacy/presentation/bloc/pharmacy_map_cubit.dart';
import '../../../pharmacy/presentation/pages/pharmacy_map_page.dart';
import '../../../report/presentation/pages/counterfeit_report_page.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_colors.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/neumorphic.dart';
import '../widgets/waves_background.dart';

/// TEMPORARY home hub shown after sign-in, so every feature that's merged can
/// be reached while the real Home (M2) and app shell / drawer / router (M5)
/// are still being built. Each teammate switches their card on by giving it
/// an `onTap` once their page is on main.
class HomeHubPage extends StatelessWidget {
  const HomeHubPage({super.key});

  Future<void> _logOut(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    if (await showLogoutDialog(context)) {
      bloc.add(const AuthLogoutRequested());
    }
  }

  void _openPharmacyMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // BlocProvider owns the cubit, so it's closed when the map is left.
        builder: (_) => BlocProvider(
          create: (_) => GetIt.instance<PharmacyMapCubit>(),
          child: Builder(
            builder: (context) =>
                PharmacyMapPage(cubit: context.read<PharmacyMapCubit>()),
          ),
        ),
      ),
    );
  }

  void _openCounterfeitReport(BuildContext context, String userId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CounterfeitReportPage(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final firstName = (user?.fullName ?? '').trim().split(' ').first;

    final features = <_Feature>[
      _Feature(
        icon: Icons.local_pharmacy_outlined,
        title: 'Find a verified pharmacy',
        subtitle: 'Map, search and directions',
        onTap: () => _openPharmacyMap(context),
      ),
      const _Feature(
        icon: Icons.qr_code_scanner,
        title: 'Scan medicine',
        subtitle: 'Check a pack against the registry',
      ),
      const _Feature(
        icon: Icons.history,
        title: 'Scan history',
        subtitle: 'Your past checks',
      ),
      _Feature(
        icon: Icons.report_outlined,
        title: 'Report counterfeit medicine',
        subtitle: 'Tell the Pharmacy and Poisons Board',
        onTap: user == null
            ? null
            : () => _openCounterfeitReport(context, user.uid),
      ),
      const _Feature(
        icon: Icons.person_outline,
        title: 'Profile',
        subtitle: 'Name, phone and photo',
      ),
      const _Feature(
        icon: Icons.settings_outlined,
        title: 'Settings',
        subtitle: 'Theme, language and sounds',
      ),
    ];

    return Scaffold(
      body: WavesBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Two columns of cards on wide screens (landscape, tablets).
              final columns = constraints.maxWidth >= 600 ? 2 : 1;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName.isEmpty
                              ? 'HABARI'
                              : 'HABARI, ${firstName.toUpperCase()}',
                          style: const TextStyle(
                            color: AuthColors.textMuted,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'What are you checking today?',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AuthColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        if (user != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: const TextStyle(color: AuthColors.text),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            for (final feature in features)
                              SizedBox(
                                width: columns == 1
                                    ? double.infinity
                                    : (constraints.maxWidth.clamp(0, 900) -
                                              40 -
                                              16) /
                                          2,
                                child: _FeatureCard(feature: feature),
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: PrimaryButton(
                            label: 'Log out',
                            expand: false,
                            onPressed: () => _logOut(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// `null` until the owner's page is merged; the card then shows
  /// "Coming soon" and can't be tapped.
  final VoidCallback? onTap;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final available = feature.onTap != null;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: Neu.raisedCircle(distance: 3, blur: 8),
            child: Icon(
              feature.icon,
              color: available ? AuthColors.primary : AuthColors.textMuted,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: available ? AuthColors.primary : AuthColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  available ? feature.subtitle : 'Coming soon',
                  style: const TextStyle(color: AuthColors.textMuted),
                ),
              ],
            ),
          ),
          if (available)
            const Icon(Icons.chevron_right, color: AuthColors.primary),
        ],
      ),
    );

    return Semantics(
      button: available,
      enabled: available,
      child: available
          ? DecoratedBox(
              decoration: Neu.raisedBox(radius: 20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: feature.onTap,
                  child: content,
                ),
              ),
            )
          // Pressed-in look for features that aren't merged yet.
          : NeuInset(radius: 20, color: AuthColors.surface, child: content),
    );
  }
}
