import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'form_status.dart';

class GoogleSignInState extends Equatable {
  const GoogleSignInState({this.status = FormStatus.idle, this.errorMessage});

  final FormStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == FormStatus.submitting;

  @override
  List<Object?> get props => [status, errorMessage];
}

/// "Continue with Google". On success the AuthBloc's stream picks up the
/// user and the router moves on (Google users skip Verify email, because
/// Google has already verified their address).
class GoogleSignInCubit extends Cubit<GoogleSignInState> {
  GoogleSignInCubit(this._repository) : super(const GoogleSignInState());

  final AuthRepository _repository;

  Future<void> signIn() async {
    if (state.isSubmitting) return;

    emit(const GoogleSignInState(status: FormStatus.submitting));
    try {
      final user = await _repository.signInWithGoogle();
      if (isClosed) return;
      // null = the user closed the account picker. Not an error, so no
      // snackbar: just go back to idle.
      emit(
        GoogleSignInState(
          status: user == null ? FormStatus.idle : FormStatus.success,
        ),
      );
    } on AuthFailure catch (failure) {
      if (!isClosed) {
        emit(
          GoogleSignInState(
            status: FormStatus.failure,
            errorMessage: failure.message,
          ),
        );
      }
    }
  }
}
