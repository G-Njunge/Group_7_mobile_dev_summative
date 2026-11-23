import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/validators.dart';
import 'form_status.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.status = FormStatus.idle,
    this.fieldErrors = const {},
    this.passwordStrong = false,
    this.errorMessage,
  });

  final FormStatus status;
  final Map<AuthField, String> fieldErrors;

  /// Drives the green "Strong password" hint while typing.
  final bool passwordStrong;

  /// Message for the error snackbar when creating the account fails.
  final String? errorMessage;

  bool get isSubmitting => status == FormStatus.submitting;

  RegisterState _copyWith({
    FormStatus? status,
    Map<AuthField, String>? fieldErrors,
    bool? passwordStrong,
  }) => RegisterState(
    status: status ?? this.status,
    fieldErrors: fieldErrors ?? this.fieldErrors,
    passwordStrong: passwordStrong ?? this.passwordStrong,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    fieldErrors,
    passwordStrong,
    errorMessage,
  ];
}

/// Register form. On success the new (unverified) user arrives through the
/// AuthBloc's stream and the router shows Verify email.
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._repository) : super(const RegisterState());

  final AuthRepository _repository;

  void fieldEdited(AuthField field) {
    if (!state.fieldErrors.containsKey(field)) return;
    emit(
      state._copyWith(fieldErrors: Map.of(state.fieldErrors)..remove(field)),
    );
  }

  void passwordChanged(String password) {
    emit(
      state._copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(AuthField.password),
        passwordStrong: validateNewPassword(password) == null,
      ),
    );
  }

  Future<void> submit({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (state.isSubmitting) return;

    final errors = collectErrors({
      AuthField.fullName: validateFullName(fullName),
      AuthField.email: validateEmail(email),
      AuthField.phone: validatePhone(phone),
      AuthField.password: validateNewPassword(password),
    });
    if (errors.isNotEmpty) {
      emit(
        RegisterState(
          fieldErrors: errors,
          passwordStrong: state.passwordStrong,
        ),
      );
      return;
    }

    emit(RegisterState(status: FormStatus.submitting, passwordStrong: true));
    try {
      await _repository.signUp(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      if (!isClosed) {
        emit(
          const RegisterState(status: FormStatus.success, passwordStrong: true),
        );
      }
    } on AuthFailure catch (failure) {
      if (!isClosed) {
        emit(
          RegisterState(
            status: FormStatus.failure,
            passwordStrong: true,
            errorMessage: failure.message,
          ),
        );
      }
    }
  }
}
