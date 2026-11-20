abstract interface class ReportRepository {
  Future<void> createCounterfeitReport({
    required String userId,
    required String pharmacyId,
    required String description,
  });
}
