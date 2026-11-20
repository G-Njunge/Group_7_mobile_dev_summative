import 'package:equatable/equatable.dart';

import '../../domain/entities/scan_summary.dart';

enum HistoryStatus { loading, loaded, error }

enum HistoryFilter { all, genuine, flagged }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<ScanSummary> scans;
  final HistoryFilter filter;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.loading,
    this.scans = const [],
    this.filter = HistoryFilter.all,
    this.errorMessage,
  });

  /// The scans the screen should show, after the filter tab is applied.
  List<ScanSummary> get visibleScans {
    switch (filter) {
      case HistoryFilter.all:
        return scans;
      case HistoryFilter.genuine:
        return scans
            .where((s) => s.scan.result.toLowerCase() == 'genuine')
            .toList();
      case HistoryFilter.flagged:
        return scans
            .where((s) => s.scan.result.toLowerCase() == 'flagged')
            .toList();
    }
  }

  int get totalCount => scans.length;
  int get genuineCount =>
      scans.where((s) => s.scan.result.toLowerCase() == 'genuine').length;
  int get flaggedCount =>
      scans.where((s) => s.scan.result.toLowerCase() == 'flagged').length;

  HistoryState copyWith({
    HistoryStatus? status,
    List<ScanSummary>? scans,
    HistoryFilter? filter,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      scans: scans ?? this.scans,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, scans, filter, errorMessage];
}
