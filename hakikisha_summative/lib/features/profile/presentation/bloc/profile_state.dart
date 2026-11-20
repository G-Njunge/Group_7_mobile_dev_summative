import 'package:equatable/equatable.dart';

import '../../domain/entities/profile_entity.dart';

enum ProfileStatus { loading, loaded, saving, saved, deleting, deleted, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.loading,
    this.profile,
    this.errorMessage,
  });

  /// Not passing an errorMessage clears the old one.
  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
