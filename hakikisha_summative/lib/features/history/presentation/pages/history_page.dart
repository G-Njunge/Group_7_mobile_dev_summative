import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/history_cubit.dart';
import '../bloc/history_state.dart';
import '../widgets/history_stats.dart';
import '../widgets/scan_detail_sheet.dart';
import '../widgets/scan_tile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan history')),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          switch (state.status) {
            case HistoryStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case HistoryStatus.error:
              return _Message(
                icon: Icons.error_outline,
                text: state.errorMessage ?? 'Something went wrong.',
              );
            case HistoryStatus.loaded:
              return _HistoryList(state: state);
          }
        },
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final HistoryState state;

  const _HistoryList({required this.state});

  @override
  Widget build(BuildContext context) {
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
        const SliverToBoxAdapter(child: _SectionLabel('RECENT SCANS')),
        if (scans.isEmpty)
          const SliverToBoxAdapter(
            child: _Message(icon: Icons.history, text: 'No scans to show yet.'),
          )
        else
          SliverList.builder(
            itemCount: scans.length,
            itemBuilder: (context, index) => ScanTile(
              summary: scans[index],
              onTap: () => showScanDetailSheet(context, scans[index]),
            ),
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Message({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
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
