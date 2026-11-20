/// Firestore collection names and enum-like field values from the ERD
/// (README "Firestore contract"). Models, queries and `firestore.rules` must
/// all use these exact strings.
abstract final class FirestoreCollections {
  static const users = 'users';
  static const medicines = 'medicines';
  static const batches = 'batches';
  static const scans = 'scans';
  static const reports = 'reports';
  static const pharmacies = 'pharmacies';
}

/// `users.authProvider`
abstract final class AuthProviders {
  static const password = 'password';
  static const google = 'google';
}

/// `batches.status`
abstract final class BatchStatus {
  static const valid = 'valid';
  static const recalled = 'recalled';
  static const counterfeit = 'counterfeit';
}

/// `scans.result`
abstract final class ScanResult {
  static const genuine = 'genuine';
  static const flagged = 'flagged';
  static const notFound = 'notFound';
}

/// `scans.method`
abstract final class ScanMethod {
  static const camera = 'camera';
  static const manual = 'manual';
  static const upload = 'upload';
}

/// `reports.status`
abstract final class ReportStatus {
  static const pending = 'pending';
  static const reviewed = 'reviewed';
}
