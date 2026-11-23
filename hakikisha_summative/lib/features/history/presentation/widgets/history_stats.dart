import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/neumorphic.dart';
import '../bloc/history_state.dart';

/// The Scans / Genuine / Flagged cards at the top. Tapping one filters the
/// list below.
class HistoryStats extends StatelessWidget {
  const HistoryStats({super.key, required this.state, required this.onSelect});

  final HistoryState state;
  final ValueChanged<HistoryFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: l10n.historyScans,
              count: state.totalCount,
              selected: state.filter == HistoryFilter.all,
              onTap: () => onSelect(HistoryFilter.all),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: l10n.historyGenuine,
              count: state.genuineCount,
              color: palette.success,
              selected: state.filter == HistoryFilter.genuine,
              onTap: () => onSelect(HistoryFilter.genuine),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: l10n.historyFlagged,
              count: state.flaggedCount,
              color: palette.danger,
              selected: state.filter == HistoryFilter.flagged,
              onTap: () => onSelect(HistoryFilter.flagged),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final int count;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? palette.brand : Colors.transparent,
          width: 2,
        ),
      ),
      child: NeuCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color ?? palette.heading,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: palette.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
