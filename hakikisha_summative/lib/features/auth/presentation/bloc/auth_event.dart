part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to the auth stream. Added once when the app starts.
final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

/// The user confirmed "Log out" in the logout dialog.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// The user tapped "I've verified" on the Verify email screen.
final class AuthVerificationCheckRequested extends AuthEvent {
  const AuthVerificationCheckRequested();
}
