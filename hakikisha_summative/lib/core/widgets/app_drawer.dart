import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_assets.dart';
import '../l10n/generated/app_localizations.dart';
import '../router/app_routes.dart';
import '../session/session_cubit.dart';
import '../theme/app_palette.dart';
import 'confirm_dialog.dart';

/// Side menu for every signed-in screen. Uses `go` rather than `push`, so
/// switching sections replaces the stack instead of growing it.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static final _destinations =
      <
        ({IconData icon, String route, String Function(AppLocalizations) label})
      >[
        (
          icon: Icons.home_outlined,
          route: AppRoutes.home,
          label: (l) => l.navHome,
        ),
        (
          icon: Icons.history,
          route: AppRoutes.history,
          label: (l) => l.navHistory,
        ),
        (
          icon: Icons.local_pharmacy_outlined,
          route: AppRoutes.pharmacies,
          label: (l) => l.navPharmacies,
        ),
        (
          icon: Icons.report_outlined,
          route: AppRoutes.report,
          label: (l) => l.navReport,
        ),
        (
          icon: Icons.assignment_outlined,
          route: AppRoutes.myReports,
          label: (l) => l.navMyReports,
        ),
        (
          icon: Icons.person_outline,
          route: AppRoutes.profile,
          label: (l) => l.navProfile,
        ),
        (
          icon: Icons.settings_outlined,
          route: AppRoutes.settings,
          label: (l) => l.navSettings,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final selected = _destinations.indexWhere(
      (d) => location == d.route || location.startsWith('${d.route}/'),
    );

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Image.asset(
                    AppAssets.logo,
                    height: 40,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      l10n.appName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            for (final (index, d) in _destinations.indexed)
              _DrawerTile(
                icon: d.icon,
                label: d.label(l10n),
                selected: index == selected,
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(d.route);
                },
              ),
            const Divider(height: 24, indent: 16, endIndent: 16),
            _DrawerTile(
              icon: Icons.logout,
              label: l10n.navLogout,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: () => _confirmLogout(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    // Read before the await: the drawer may be gone once the dialog closes.
    final session = context.read<SessionCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.logoutTitle,
      message: l10n.logoutMessage,
      confirmLabel: l10n.navLogout,
      cancelLabel: l10n.stayLoggedIn,
      showLogo: true,
    );
    // The router's redirect sends the user to the landing page.
    if (confirmed) await session.signOut();
  }
}

/// One drawer row. A ListTile (unlike NavigationDrawerDestination) wraps long
/// labels, so large font sizes and Swahili labels never overflow.
class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        selected: selected,
        leading: Icon(icon, color: selected ? null : iconColor),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        onTap: onTap,
        shape: const StadiumBorder(),
        iconColor: palette.heading,
        textColor: palette.text,
        selectedColor: palette.onBrand,
        selectedTileColor: palette.brand,
      ),
    );
  }
}
