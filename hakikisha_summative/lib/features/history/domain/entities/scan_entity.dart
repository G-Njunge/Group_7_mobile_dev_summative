class ScanEntity {
  final String scanId;
  final String userId;
  final String? batchId;
  final String result;
  final String method;
  final DateTime scannedAt;

  const ScanEntity({
    required this.scanId,
    required this.userId,
    this.batchId,
    required this.result,
    required this.method,
    required this.scannedAt,
  });
}
