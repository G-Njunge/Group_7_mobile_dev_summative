import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'session_source.dart';

/// Holds the current [SessionStatus] for the whole app. Created once at
/// start-up; the router listens to it to redirect between public and private
/// screens.
class SessionCubit extends Cubit<SessionStatus> {
  SessionCubit(this._source) : super(SessionStatus.unknown) {
    _subscription = _source.watch().listen(emit);
  }

  final SessionSource _source;
  late final StreamSubscription<SessionStatus> _subscription;

  /// Re-reads the status, e.g. after the verify-email screen reloads the user,
  /// in case the platform doesn't emit a user change for it.
  void refresh() => emit(_source.current);

  Future<void> signOut() => _source.signOut();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
