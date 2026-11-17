import 'package:equatable/equatable.dart';

import '../../domain/entities/scan_entity.dart';

enum HistoryStatus { loading, loaded, error }

enum HistoryFilter { all, genuine, flagged }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<ScanEntity> scans;
  final HistoryFilter filter;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.loading,
    this.scans = const [],
    this.filter = HistoryFilter.all,
    this.errorMessage,
  });

  /// The scans the screen should show, after the filter tab is applied.
  List<ScanEntity> get visibleScans {
    switch (filter) {
      case HistoryFilter.all:
        return scans;
      case HistoryFilter.genuine:
        return scans.where((s) => s.result.toLowerCase() == 'genuine').toList();
      case HistoryFilter.flagged:
        return scans.where((s) => s.result.toLowerCase() == 'flagged').toList();
    }
  }

  HistoryState copyWith({
    HistoryStatus? status,
    List<ScanEntity>? scans,
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
