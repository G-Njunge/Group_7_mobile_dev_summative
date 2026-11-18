import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pharmacy_model.dart';

class PharmacyRemoteDataSource {
  PharmacyRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<PharmacyModel>> watchPharmacies() => _firestore
      .collection('pharmacies')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (document) => PharmacyModel.fromJson(
                document.data(),
                documentId: document.id,
              ),
            )
            .toList(),
      );
}
