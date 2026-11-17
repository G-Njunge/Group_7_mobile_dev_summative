import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/validators.dart';
import 'form_status.dart';

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.status = FormStatus.idle,
    this.fieldErrors = const {},
    this.errorMessage,
    this.sentTo,
  });

  final FormStatus status;
  final Map<AuthField, String> fieldErrors;
  final String? errorMessage;

  /// The address the reset link went to, once sent.
  final String? sentTo;

  bool get isSubmitting => status == FormStatus.submitting;

  @override
  List<Object?> get props => [status, fieldErrors, errorMessage, sentTo];
}

/// Sends password reset links. Used by Forgot password (send) and Check your
/// inbox (resend).
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._repository) : super(const ForgotPasswordState());

  final AuthRepository _repository;

  void fieldEdited(AuthField field) {
    if (!state.fieldErrors.containsKey(field)) return;
    emit(ForgotPasswordState(status: state.status, sentTo: state.sentTo));
  }

  Future<void> submit(String email) async {
    if (state.isSubmitting) return;

    final error = validateEmail(email);
    if (error != null) {
      emit(ForgotPasswordState(fieldErrors: {AuthField.email: error}));
      return;
    }

    emit(const ForgotPasswordState(status: FormStatus.submitting));
    try {
      await _repository.sendPasswordResetEmail(email);
      if (!isClosed) {
        emit(
          ForgotPasswordState(status: FormStatus.success, sentTo: email.trim()),
        );
      }
    } on AuthFailure catch (failure) {
      if (!isClosed) {
        emit(
          ForgotPasswordState(
            status: FormStatus.failure,
            errorMessage: failure.message,
          ),
        );
      }
    }
  }
}
