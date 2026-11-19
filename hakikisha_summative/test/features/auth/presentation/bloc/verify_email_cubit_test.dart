import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/auth/domain/failures/auth_failure.dart';
import 'package:hakikisha_summative/features/auth/domain/repositories/auth_repository.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/form_status.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/verify_email_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  test('resend starts a cooldown that counts down to zero', () {
    fakeAsync((async) {
      when(() => repository.sendEmailVerification()).thenAnswer((_) async {});
      final cubit = VerifyEmailCubit(repository, cooldownSeconds: 3);

      cubit.resend();
      async.flushMicrotasks();
      expect(cubit.state.status, FormStatus.success);
      expect(cubit.state.secondsLeft, 3);
      expect(cubit.state.canResend, isFalse);

      async.elapse(const Duration(seconds: 1));
      expect(cubit.state.secondsLeft, 2);

      async.elapse(const Duration(seconds: 2));
      expect(cubit.state.secondsLeft, 0);
      expect(cubit.state.canResend, isTrue);

      cubit.close();
    });
  });

  test('ignores taps during the cooldown', () {
    fakeAsync((async) {
      when(() => repository.sendEmailVerification()).thenAnswer((_) async {});
      final cubit = VerifyEmailCubit(repository, cooldownSeconds: 60);

      cubit.resend();
      async.flushMicrotasks();
      cubit.resend();
      async.flushMicrotasks();

      verify(() => repository.sendEmailVerification()).called(1);
      cubit.close();
    });
  });

  test('shows a readable message and no cooldown when sending fails', () async {
    when(() => repository.sendEmailVerification())
        .thenThrow(AuthFailure.fromCode('too-many-requests'));
    final cubit = VerifyEmailCubit(repository);

    await cubit.resend();

    expect(cubit.state.status, FormStatus.failure);
    expect(cubit.state.errorMessage, contains('Too many attempts'));
    expect(cubit.state.canResend, isTrue);
    await cubit.close();
  });
}
