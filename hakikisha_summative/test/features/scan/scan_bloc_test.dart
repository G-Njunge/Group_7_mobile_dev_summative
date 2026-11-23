import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hakikisha_summative/features/scan/domain/entities/batch_entity.dart';
import 'package:hakikisha_summative/features/scan/domain/entities/medicine_entity.dart';
import 'package:hakikisha_summative/features/scan/domain/entities/scan_record_entity.dart';
import 'package:hakikisha_summative/features/scan/domain/entities/verification_outcome.dart';
import 'package:hakikisha_summative/features/scan/domain/repositories/scan_repository.dart';
import 'package:hakikisha_summative/features/scan/domain/usecases/verify_medicine_usecase.dart';
import 'package:hakikisha_summative/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:hakikisha_summative/features/scan/presentation/bloc/scan_event.dart';
import 'package:hakikisha_summative/features/scan/presentation/bloc/scan_state.dart';

class MockScanRepository extends Mock implements ScanRepository {}

class FakeScanRecord extends Fake implements ScanRecordEntity {}

void main() {
  late MockScanRepository mockRepo;
  late VerifyMedicineUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeScanRecord());
  });

  setUp(() {
    mockRepo = MockScanRepository();
    useCase = VerifyMedicineUseCase();
  });

  blocTest<ScanBloc, ScanState>(
    'emits [ScanVerifying, ScanComplete] and saves scan record when valid batch found',
    build: () {
      when(() => mockRepo.findBatchByCode('RW24-0871')).thenAnswer(
        (_) async => BatchEntity(
          batchId: 'b1',
          medicineId: 'm1',
          batchNumber: 'RW24-0871',
          gtin: '123456',
          expiryDate: DateTime(2028, 1, 1),
          status: 'valid',
        ),
      );
      when(() => mockRepo.getMedicineById('m1')).thenAnswer(
        (_) async => const MedicineEntity(
          medicineId: 'm1',
          name: 'Coartem 80/480',
          manufacturer: 'Novartis',
          rfdaRegNo: 'RWANDA-FDA24/HM/0042',
          dosageForm: 'Tablet',
          strength: '80/480mg',
        ),
      );
      when(() => mockRepo.saveScanRecord(any())).thenAnswer((_) async {});

      return ScanBloc(
        repository: mockRepo,
        verifyMedicineUseCase: useCase,
        getCurrentUserId: () => 'user_123',
        animationDuration: Duration.zero,
      );
    },
    act: (bloc) => bloc.add(
      const ScanCodeSubmitted(code: 'RW24-0871', method: ScanMethod.manual),
    ),
    expect: () => [
      const ScanVerifying('RW24-0871'),
      isA<ScanComplete>().having(
        (s) => s.result.status,
        'status',
        VerificationStatus.genuine,
      ),
    ],
    verify: (_) {
      verify(() => mockRepo.saveScanRecord(any())).called(1);
    },
  );

  blocTest<ScanBloc, ScanState>(
    'skips saving scan record when save-history setting is off',
    build: () {
      when(() => mockRepo.findBatchByCode('RW24-0871')).thenAnswer(
        (_) async => BatchEntity(
          batchId: 'b1',
          medicineId: 'm1',
          batchNumber: 'RW24-0871',
          gtin: '123456',
          expiryDate: DateTime(2028, 1, 1),
          status: 'valid',
        ),
      );
      when(() => mockRepo.getMedicineById('m1')).thenAnswer(
        (_) async => const MedicineEntity(
          medicineId: 'm1',
          name: 'Coartem 80/480',
          manufacturer: 'Novartis',
          rfdaRegNo: 'RWANDA-FDA24/HM/0042',
          dosageForm: 'Tablet',
          strength: '80/480mg',
        ),
      );

      return ScanBloc(
        repository: mockRepo,
        verifyMedicineUseCase: useCase,
        getCurrentUserId: () => 'user_123',
        shouldSaveHistory: () => false,
        animationDuration: Duration.zero,
      );
    },
    act: (bloc) => bloc.add(
      const ScanCodeSubmitted(code: 'RW24-0871', method: ScanMethod.manual),
    ),
    expect: () => [
      const ScanVerifying('RW24-0871'),
      isA<ScanComplete>()
          .having((s) => s.result.status, 'status', VerificationStatus.genuine)
          .having((s) => s.savedToHistory, 'savedToHistory', isFalse),
    ],
    verify: (_) {
      verifyNever(() => mockRepo.saveScanRecord(any()));
    },
  );
}
