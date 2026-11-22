import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/profile/presentation/bloc/edit_profile_form_cubit.dart';

void main() {
  late EditProfileFormCubit cubit;

  setUp(() => cubit = EditProfileFormCubit());
  tearDown(() => cubit.close());

  test('an empty name is rejected', () {
    final ok = cubit.validate(fullName: '  ', phone: '');

    expect(ok, isFalse);
    expect(cubit.state.nameError, isNotNull);
  });

  test('a blank phone is fine because it is optional', () {
    final ok = cubit.validate(fullName: 'Amina Wanjiru', phone: '');

    expect(ok, isTrue);
    expect(cubit.state.phoneError, isNull);
  });

  test('a phone that is not a Kenyan mobile number is rejected', () {
    final ok = cubit.validate(fullName: 'Amina Wanjiru', phone: 'abc123');

    expect(ok, isFalse);
    expect(cubit.state.phoneError, isNotNull);
  });

  test('typing in a field clears its error', () {
    cubit.validate(fullName: '', phone: '');
    cubit.clearNameError();

    expect(cubit.state.nameError, isNull);
  });
}
