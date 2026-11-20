part of 'auth_bloc.dart';

enum AuthStatus {
  /// App just started; waiting for the first auth event.
  unknown,

  /// Nobody is signed in.
  unauthenticated,

  /// Signed in with email/password but the email isn't verified yet.
  unverified,

  /// Signed in and verified; can use the app.
  authenticated,
}

/// Result of the last "I've verified" check, used for feedback on the
/// Verify email screen.
enum VerificationCheck { idle, checking, notVerified, failed }

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user,
    this.verificationCheck = VerificationCheck.idle,
    this.errorMessage,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  factory AuthState.fromUser(AppUser? user) {
    if (user == null) {
      return const AuthState._(status: AuthStatus.unauthenticated);
    }
    return AuthState._(
      status: user.emailVerified
          ? AuthStatus.authenticated
          : AuthStatus.unverified,
      user: user,
    );
  }

  final AuthStatus status;
  final AppUser? user;
  final VerificationCheck verificationCheck;
  final String? errorMessage;

  AuthState copyWith({
    VerificationCheck? verificationCheck,
    String? errorMessage,
  }) => AuthState._(
    status: status,
    user: user,
    verificationCheck: verificationCheck ?? this.verificationCheck,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, user, verificationCheck, errorMessage];
}
