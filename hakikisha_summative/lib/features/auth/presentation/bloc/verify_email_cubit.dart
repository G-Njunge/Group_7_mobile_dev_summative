import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'form_status.dart';

class VerifyEmailState extends Equatable {
  const VerifyEmailState({
    this.status = FormStatus.idle,
    this.secondsLeft = 0,
    this.errorMessage,
  });

  final FormStatus status;

  /// Resend cooldown. 0 means "Resend email" can be tapped.
  final int secondsLeft;
  final String? errorMessage;

  bool get canResend => secondsLeft == 0 && status != FormStatus.submitting;

  @override
  List<Object?> get props => [status, secondsLeft, errorMessage];
}

/// "Resend email" on the Verify email screen, with a cooldown so people
/// don't hit Firebase's too-many-requests limit.
class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  VerifyEmailCubit(this._repository, {this.cooldownSeconds = 60})
    : super(const VerifyEmailState());

  final AuthRepository _repository;
  final int cooldownSeconds;
  Timer? _timer;

  Future<void> resend() async {
    if (!state.canResend) return;

    emit(const VerifyEmailState(status: FormStatus.submitting));
    try {
      await _repository.sendEmailVerification();
      if (isClosed) return;
      emit(
        VerifyEmailState(
          status: FormStatus.success,
          secondsLeft: cooldownSeconds,
        ),
      );
      _startCooldown();
    } on AuthFailure catch (failure) {
      if (!isClosed) {
        emit(
          VerifyEmailState(
            status: FormStatus.failure,
            errorMessage: failure.message,
          ),
        );
      }
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final left = state.secondsLeft - 1;
      if (left <= 0) {
        timer.cancel();
        emit(const VerifyEmailState());
      } else {
        emit(VerifyEmailState(status: state.status, secondsLeft: left));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
