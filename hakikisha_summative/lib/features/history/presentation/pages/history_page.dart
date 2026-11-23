import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/scan_summary.dart';
import '../bloc/history_cubit.dart';
import '../bloc/history_state.dart';
import '../widgets/history_stats.dart';
import '../widgets/scan_detail_sheet.dart';
import '../widgets/scan_tile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.navHistory,
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          switch (state.status) {
            case HistoryStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case HistoryStatus.error:
              return _Message(
                icon: Icons.error_outline,
                text: l10n.historyLoadError,
              );
            case HistoryStatus.loaded:
              return _HistoryList(state: state);
          }
        },
      ),
    );
  }
}

/// Asks first, then deletes. The live feed removes the row by itself, so
/// there is nothing to refresh.
Future<void> _confirmDelete(BuildContext context, ScanSummary summary) async {
  final l10n = AppLocalizations.of(context);
  final cubit = context.read<HistoryCubit>();

  final confirmed = await showConfirmDialog(
    context,
    title: l10n.historyDeleteTitle,
    message: l10n.historyDeleteMessage,
    confirmLabel: l10n.historyDeleteConfirm,
    cancelLabel: l10n.historyDeleteCancel,
  );
  if (!confirmed || !context.mounted) return;

  final deleted = await cubit.deleteScan(summary.scan.scanId);
  if (!context.mounted) return;

  if (deleted) {
    showAppSnackBar(context, l10n.historyDeleted, type: SnackType.success);
  } else {
    showAppSnackBar(context, l10n.historyDeleteError);
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scans = state.visibleScans;

    // One scrollable for the whole page, so nothing overflows on a short
    // screen or in landscape.
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: HistoryStats(
            state: state,
            onSelect: context.read<HistoryCubit>().setFilter,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              l10n.historyRecentScans,
              style: TextStyle(
                color: context.palette.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        if (scans.isEmpty)
          SliverToBoxAdapter(
            child: _Message(icon: Icons.history, text: l10n.historyEmpty),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.builder(
              itemCount: scans.length,
              itemBuilder: (context, index) {
                final summary = scans[index];
                return ScanTile(
                  summary: summary,
                  onTap: () => showScanDetailSheet(context, summary),
                  onDelete: () => _confirmDelete(context, summary),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
