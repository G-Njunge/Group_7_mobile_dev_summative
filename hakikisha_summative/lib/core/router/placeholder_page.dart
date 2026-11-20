import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../widgets/app_scaffold.dart';

/// Stand-in for a screen whose feature hasn't merged yet, so every route is
/// navigable from day one. Delete the route's placeholder once the real page
/// exists.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    this.showDrawer = true,
  });

  final String title;
  final bool showDrawer;

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: title,
    showDrawer: showDrawer,
    body: Center(child: Text(AppLocalizations.of(context).placeholderBody)),
  );
}
