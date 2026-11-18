import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/scan_entity.dart';
import '../../domain/repositories/history_repository.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _repository;
  StreamSubscription<List<ScanEntity>>? _subscription;

  HistoryCubit(this._repository) : super(const HistoryState());

  /// Starts listening to this user's scans. Firestore pushes a new list
  /// every time something changes, so the screen updates without a refresh.
  void start(String userId) {
    _subscription?.cancel();
    _subscription = _repository
        .watchScans(userId)
        .listen(
          (scans) =>
              emit(state.copyWith(status: HistoryStatus.loaded, scans: scans)),
          onError: (_) => emit(
            state.copyWith(
              status: HistoryStatus.error,
              errorMessage: 'Could not load your scan history.',
            ),
          ),
        );
  }

  void setFilter(HistoryFilter filter) => emit(state.copyWith(filter: filter));

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
