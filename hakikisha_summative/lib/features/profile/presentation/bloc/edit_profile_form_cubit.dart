import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/validators.dart';

/// Field errors for the Edit profile form.
class EditProfileFormState extends Equatable {
  final String? nameError;
  final String? phoneError;

  const EditProfileFormState({this.nameError, this.phoneError});

  bool get isValid => nameError == null && phoneError == null;

  @override
  List<Object?> get props => [nameError, phoneError];
}

class EditProfileFormCubit extends Cubit<EditProfileFormState> {
  EditProfileFormCubit() : super(const EditProfileFormState());

  /// Checks both fields, shows any errors, and returns true if all is fine.
  /// Phone is optional (Google users have none), but if it is typed it must
  /// be a valid Rwandan number, using the same rules as Register.
  bool validate({required String fullName, required String phone}) {
    final next = EditProfileFormState(
      nameError: validateFullName(fullName),
      phoneError: phone.trim().isEmpty ? null : validatePhone(phone),
    );
    emit(next);
    return next.isValid;
  }

  void clearNameError() {
    if (state.nameError == null) return;
    emit(EditProfileFormState(phoneError: state.phoneError));
  }

  void clearPhoneError() {
    if (state.phoneError == null) return;
    emit(EditProfileFormState(nameError: state.nameError));
  }
}
