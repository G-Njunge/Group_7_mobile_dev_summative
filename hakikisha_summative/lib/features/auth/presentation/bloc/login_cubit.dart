import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/validators.dart';
import 'form_status.dart';

class LoginState extends Equatable {
  const LoginState({
    this.status = FormStatus.idle,
    this.fieldErrors = const {},
    this.errorMessage,
  });

  final FormStatus status;
  final Map<AuthField, String> fieldErrors;

  /// Message for the error snackbar when logging in fails.
  final String? errorMessage;

  bool get isSubmitting => status == FormStatus.submitting;

  @override
  List<Object?> get props => [status, fieldErrors, errorMessage];
}

/// Login form. On success the AuthBloc's stream picks up the signed-in user
/// and the router moves on, so this cubit doesn't navigate.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginState());

  final AuthRepository _repository;

  /// Clears a field's error as soon as the user edits it.
  void fieldEdited(AuthField field) {
    if (!state.fieldErrors.containsKey(field)) return;
    emit(
      LoginState(
        status: state.status,
        fieldErrors: Map.of(state.fieldErrors)..remove(field),
        errorMessage: state.errorMessage,
      ),
    );
  }

  Future<void> submit({required String email, required String password}) async {
    if (state.isSubmitting) return;

    final errors = collectErrors({
      AuthField.email: validateEmail(email),
      AuthField.password: validateLoginPassword(password),
    });
    if (errors.isNotEmpty) {
      emit(LoginState(fieldErrors: errors));
      return;
    }

    emit(const LoginState(status: FormStatus.submitting));
    try {
      await _repository.logIn(email: email, password: password);
      // The page may already be gone (the router swapped screens).
      if (!isClosed) emit(const LoginState(status: FormStatus.success));
    } on AuthFailure catch (failure) {
      if (!isClosed) {
        emit(
          LoginState(status: FormStatus.failure, errorMessage: failure.message),
        );
      }
    }
  }
}
