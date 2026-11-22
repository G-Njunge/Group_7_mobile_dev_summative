import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String? phone;
  final String authProvider;
  final String? photoUrl;
  final DateTime? createdAt;

  const ProfileEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone,
    required this.authProvider,
    this.photoUrl,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    uid,
    fullName,
    email,
    phone,
    authProvider,
    photoUrl,
    createdAt,
  ];
}
