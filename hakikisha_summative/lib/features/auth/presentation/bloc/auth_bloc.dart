import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// App-wide session state: who is signed in and whether they can use the app.
///
/// Created once at the top of the app. It listens to the repository's
/// auth stream, so the session survives restarts and any sign-in, sign-up or
/// logout (from any screen) updates every listener at once.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState.unknown()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthVerificationCheckRequested>(_onVerificationCheckRequested);
  }

  final AuthRepository _repository;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) => emit.forEach<AppUser?>(
    _repository.authStateChanges(),
    onData: AuthState.fromUser,
  );

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _repository.logOut();
    } on AuthFailure {
      // Signing out locally practically never fails; if it does, the auth
      // stream still decides the status.
    }
  }

  /// "I've verified" on the Verify email screen. `authStateChanges()` doesn't
  /// fire when an email gets verified, so reload the user and decide here.
  Future<void> _onVerificationCheckRequested(
    AuthVerificationCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.verificationCheck == VerificationCheck.checking) return;
    emit(state.copyWith(verificationCheck: VerificationCheck.checking));

    try {
      final user = await _repository.reloadUser();
      if (user == null || user.emailVerified) {
        emit(AuthState.fromUser(user));
      } else {
        emit(
          AuthState.fromUser(user)
              .copyWith(verificationCheck: VerificationCheck.notVerified),
        );
      }
    } on AuthFailure catch (failure) {
      emit(
        state.copyWith(
          verificationCheck: VerificationCheck.failed,
          errorMessage: failure.message,
        ),
      );
    }
  }
}
