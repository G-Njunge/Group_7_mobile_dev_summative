import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha/features/scan/domain/entities/batch_entity.dart';
import 'package:hakikisha/features/scan/domain/entities/medicine_entity.dart';
import 'package:hakikisha/features/scan/domain/entities/verification_outcome.dart';
import 'package:hakikisha/features/scan/domain/usecases/verify_medicine_usecase.dart';

void main() {
  late VerifyMedicineUseCase useCase;
  const sampleMed = MedicineEntity(
    medicineId: 'med_1',
    name: 'Panadol Advance',
    manufacturer: 'GSK',
    rfdaRegNo: 'RWANDA-FDA24/HM/1029',
    dosageForm: 'Tablet',
    strength: '500mg',
  );

  setUp(() {
    useCase = VerifyMedicineUseCase();
  });

  test('returns genuine when batch is valid and not expired', () {
    final batch = BatchEntity(
      batchId: 'b_1',
      medicineId: 'med_1',
      batchNumber: 'RW24-0871',
      gtin: '6161100001234',
      expiryDate: DateTime(2027, 8, 1),
      status: 'valid',
    );

    final result = useCase.execute(
      queriedCode: 'RW24-0871',
      batch: batch,
      medicine: sampleMed,
      clock: DateTime(2026, 11, 23),
    );

    expect(result.status, VerificationStatus.genuine);
    expect(result.flagReason, FlagReason.none);
  });

  test('returns flagged (recalled) when batch status is recalled', () {
    final batch = BatchEntity(
      batchId: 'b_2',
      medicineId: 'med_1',
      batchNumber: 'RW24-0999',
      gtin: '6161100009999',
      expiryDate: DateTime(2027, 8, 1),
      status: 'recalled',
    );

    final result = useCase.execute(
      queriedCode: 'RW24-0999',
      batch: batch,
      medicine: sampleMed,
      clock: DateTime(2026, 11, 23),
    );

    expect(result.status, VerificationStatus.flagged);
    expect(result.flagReason, FlagReason.recalled);
  });

  test('returns flagged (expired) when expiryDate is in the past', () {
    final batch = BatchEntity(
      batchId: 'b_3',
      medicineId: 'med_1',
      batchNumber: 'RW22-0100',
      gtin: '6161100000100',
      expiryDate: DateTime(2025, 1, 15),
      status: 'valid',
    );

    final result = useCase.execute(
      queriedCode: 'RW22-0100',
      batch: batch,
      medicine: sampleMed,
      clock: DateTime(2026, 11, 23),
    );

    expect(result.status, VerificationStatus.flagged);
    expect(result.flagReason, FlagReason.expired);
  });

  test('returns notFound when batch is null', () {
    final result = useCase.execute(
      queriedCode: 'UNKNOWN-123',
      batch: null,
      medicine: null,
    );

    expect(result.status, VerificationStatus.notFound);
  });
}
