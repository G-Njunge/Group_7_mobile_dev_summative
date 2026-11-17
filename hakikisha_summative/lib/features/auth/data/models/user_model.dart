import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A document in the `users` collection. Field names follow the Firestore
/// contract in README.md exactly. The doc ID is the Firebase Auth `uid`.
class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.authProvider,
    this.phone,
    this.photoUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'] as String,
    fullName: json['fullName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    authProvider: json['authProvider'] as String? ?? providerPassword,
    phone: json['phone'] as String?,
    photoUrl: json['photoUrl'] as String?,
    // Null in the first local snapshot after a write with
    // FieldValue.serverTimestamp(), until the server fills it in.
    createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
  );

  static const providerPassword = 'password';
  static const providerGoogle = 'google';

  final String uid;
  final String fullName;
  final String email;

  /// `password` or `google`.
  final String authProvider;

  /// `null` for Google users, who don't give a phone number.
  final String? phone;
  final String? photoUrl;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'authProvider': authProvider,
    'photoUrl': photoUrl,
    'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
  };

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
