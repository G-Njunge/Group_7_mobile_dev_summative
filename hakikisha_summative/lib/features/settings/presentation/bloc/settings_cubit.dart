import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsState extends Equatable {
  const SettingsState(this.settings, {this.saveFailed = false});

  final AppSettings settings;

  /// True right after a save failed and the change was rolled back. The
  /// settings page shows a snackbar for it.
  final bool saveFailed;

  @override
  List<Object> get props => [settings, saveFailed];
}

/// App-wide settings. Starts with the saved values, so the theme and language
/// are right from the first frame.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(SettingsRepository repository)
    : _repository = repository,
      super(SettingsState(repository.load()));

  final SettingsRepository _repository;

  /// Applies [change] to the current settings straight away (the UI updates
  /// instantly) and saves the result. If saving fails, rolls back.
  ///
  /// Taking a function rather than a finished [AppSettings] means two quick
  /// changes in a row both apply, instead of the second one overwriting the
  /// first with stale values from the last rebuild.
  ///
  /// Usage: `cubit.update((s) => s.copyWith(vibration: false))`.
  Future<void> update(AppSettings Function(AppSettings current) change) async {
    final previous = state.settings;
    final next = change(previous);
    if (next == previous) return;
    emit(SettingsState(next));
    try {
      await _repository.save(next);
    } on Exception {
      emit(SettingsState(previous, saveFailed: true));
    }
  }
}
