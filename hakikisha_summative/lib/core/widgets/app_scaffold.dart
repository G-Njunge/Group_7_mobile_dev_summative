import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_assets.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_palette.dart';
import 'app_drawer.dart';
import 'neumorphic.dart';

/// Standard screen frame from the Figma file: waves background, a raised
/// menu/back tile with the screen title, and the app drawer.
///
/// The leading tile is a back chevron when there's a page to pop (pushed
/// screens such as a scan result) and the drawer menu otherwise.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showLogo = false,
    this.showDrawer = true,
    this.maxContentWidth = 640,
    this.floatingActionButton,
  });

  final Widget body;
  final String? title;

  /// Shows the small logo next to the menu tile (Home screen).
  final bool showLogo;

  /// Public screens (login, register) have no drawer.
  final bool showDrawer;

  /// Keeps forms and lists readable in landscape and on tablets. Pass `null`
  /// for full-bleed content such as the map.
  final double? maxContentWidth;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    final maxWidth = maxContentWidth;
    return Scaffold(
      drawer: showDrawer && !canPop ? const AppDrawer() : null,
      floatingActionButton: floatingActionButton,
      body: WavesBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                title: title,
                showLogo: showLogo,
                leading: canPop
                    ? _Leading.back
                    : showDrawer
                    ? _Leading.menu
                    : _Leading.none,
              ),
              Expanded(
                child: maxWidth == null
                    ? body
                    : Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: body,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Leading { back, menu, none }

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.showLogo,
    required this.leading,
  });

  final String? title;
  final bool showLogo;
  final _Leading leading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = this.title;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          switch (leading) {
            _Leading.back => _TileButton(
              icon: Icons.chevron_left,
              tooltip: l10n.back,
              onPressed: () => context.pop(),
            ),
            _Leading.menu => _TileButton(
              icon: Icons.menu,
              tooltip: l10n.openMenu,
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            _Leading.none => const SizedBox.shrink(),
          },
          if (showLogo) ...[
            const SizedBox(width: 12),
            Image.asset(AppAssets.logo, height: 36, excludeFromSemantics: true),
          ],
          if (title != null) ...[
            if (leading != _Leading.none) const SizedBox(width: 16),
            Expanded(
              // Announced as a heading by screen readers.
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The 48dp raised square holding the menu or back icon.
class _TileButton extends StatelessWidget {
  const _TileButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: SizedBox.square(
      dimension: 48,
      child: NeuCard(
        padding: EdgeInsets.zero,
        radius: 14,
        onTap: onPressed,
        child: Icon(icon, color: context.palette.heading),
      ),
    ),
  );
}

/// Full-screen wavy background from the Figma screens, faded in dark mode.
class WavesBackground extends StatelessWidget {
  const WavesBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.background,
        image: DecorationImage(
          image: const AssetImage(AppAssets.wavesBackground),
          fit: BoxFit.cover,
          opacity: isDark ? 0.06 : 1,
        ),
      ),
      child: child,
    );
  }
}

/// Small uppercase heading above a group of cards ("RECENT SCANS").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: context.palette.heading,
      ),
    ),
  );
}
