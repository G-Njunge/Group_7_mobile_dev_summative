import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/validators.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;
  StreamSubscription<ProfileEntity?>? _subscription;

  ProfileCubit(this._repository) : super(const ProfileState());

  /// Listens to this user's profile so edits show up without a refresh.
  void start(String uid) {
    _subscription?.cancel();
    _subscription = _repository.watchProfile(uid).listen(
      (profile) {
        // Once deletion starts, the document disappearing is expected.
        if (state.status == ProfileStatus.deleting ||
            state.status == ProfileStatus.deleted) {
          return;
        }
        if (profile == null) {
          emit(
            state.copyWith(
              status: ProfileStatus.error,
              errorMessage: 'We could not find your profile.',
            ),
          );
        } else {
          emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
        }
      },
      onError: (_) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Could not load your profile.',
        ),
      ),
    );
  }

  Future<void> updateProfile({required String fullName, String? phone}) async {
    final current = state.profile;
    if (current == null) return;

    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      // Same format as registration: +250788123456, or null if blank/invalid.
      final normalizedPhone = normalizeRwandanPhone(phone ?? '');
      await _repository.updateProfile(
        uid: current.uid,
        fullName: fullName.trim(),
        phone: normalizedPhone,
        photoUrl: current.photoUrl,
      );
      emit(state.copyWith(status: ProfileStatus.saved));
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Could not save your changes. Please try again.',
        ),
      );
    }
  }

  Future<void> deleteAccount() async {
    final current = state.profile;
    if (current == null) return;

    emit(state.copyWith(status: ProfileStatus.deleting));
    try {
      await _repository.deleteAccount(current.uid);
      emit(state.copyWith(status: ProfileStatus.deleted));
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Could not delete your account. You may need to log in again first.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
