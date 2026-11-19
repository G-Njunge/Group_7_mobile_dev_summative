import 'package:flutter/material.dart';

import '../bloc/history_state.dart';
import 'scan_tile.dart';

/// The 14 / 12 / 2 cards at the top. Tapping one filters the list.
class HistoryStats extends StatelessWidget {
  final HistoryState state;
  final ValueChanged<HistoryFilter> onSelect;

  const HistoryStats({super.key, required this.state, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Scans',
              count: state.totalCount,
              selected: state.filter == HistoryFilter.all,
              onTap: () => onSelect(HistoryFilter.all),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Genuine',
              count: state.genuineCount,
              color: resultColor('genuine'),
              selected: state.filter == HistoryFilter.genuine,
              onTap: () => onSelect(HistoryFilter.genuine),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Flagged',
              count: state.flaggedCount,
              color: resultColor('flagged'),
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
  final String label;
  final int count;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
