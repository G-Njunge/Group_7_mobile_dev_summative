import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_schema.dart';

/// The only class in the profile feature that talks to Firestore.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection(FirestoreCollections.users).doc(uid);

  /// A live feed of the user's document, or null if it does not exist.
  Stream<Map<String, dynamic>?> watchUser(String uid) =>
      _doc(uid).snapshots().map((snapshot) {
        final data = snapshot.data();
        return data == null ? null : {...data, 'uid': snapshot.id};
      });

  /// Changes only the fields passed in; every other field stays as it was.
  Future<void> updateUser(String uid, Map<String, dynamic> fields) =>
      _doc(uid).update(fields);
}
