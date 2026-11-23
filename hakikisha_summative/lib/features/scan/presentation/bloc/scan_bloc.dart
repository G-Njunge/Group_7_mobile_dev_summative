import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/scan_record_entity.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../domain/usecases/verify_medicine_usecase.dart';
import 'scan_event.dart';
import 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanRepository repository;
  final VerifyMedicineUseCase verifyMedicineUseCase;
  final String Function() getCurrentUserId;
  final bool Function() shouldSaveHistory;
  final Duration animationDuration;

  static bool _defaultSaveHistory() => true;

  ScanBloc({
    required this.repository,
    required this.verifyMedicineUseCase,
    required this.getCurrentUserId,
    this.shouldSaveHistory = _defaultSaveHistory,
    this.animationDuration = const Duration(
      seconds: 2,
    ), // Required 2s animation[cite: 21]
  }) : super(const ScanInitial()) {
    on<ScanCodeSubmitted>(_onScanCodeSubmitted);
    on<ScanResetRequested>(_onScanResetRequested);
  }

  Future<void> _onScanCodeSubmitted(
    ScanCodeSubmitted event,
    Emitter<ScanState> emit,
  ) async {
    final cleanedCode = event.code.trim();
    if (cleanedCode.isEmpty) {
      emit(const ScanFailure('Please enter or scan a valid batch or barcode.'));
      return;
    }

    emit(ScanVerifying(cleanedCode));

    try {
      // Run lookup and 2-second scanning animation concurrently[cite: 21]
      final results = await Future.wait([
        _performVerification(cleanedCode),
        Future<void>.delayed(animationDuration),
      ]);

      final verificationResult = results[0] as dynamic;
      final userId = getCurrentUserId();
      var saved = false;

      if (userId.isNotEmpty && shouldSaveHistory()) {
        final record = ScanRecordEntity(
          scanId: '',
          userId: userId,
          batchId: verificationResult.batch?.batchId ?? '',
          result: verificationResult.firestoreResultValue,
          method: event.method,
          scannedAt: DateTime.now(),
        );
        await repository.saveScanRecord(record);
        saved = true;
      }

      emit(ScanComplete(result: verificationResult, savedToHistory: saved));
    } catch (e) {
      emit(
        const ScanFailure(
          'Unable to verify medicine right now. Check your connection and try again.',
        ),
      );
    }
  }

  Future<dynamic> _performVerification(String code) async {
    final batch = await repository.findBatchByCode(code);
    final medicine = batch != null
        ? await repository.getMedicineById(batch.medicineId)
        : null;

    return verifyMedicineUseCase.execute(
      queriedCode: code,
      batch: batch,
      medicine: medicine,
    );
  }

  void _onScanResetRequested(
    ScanResetRequested event,
    Emitter<ScanState> emit,
  ) {
    emit(const ScanInitial());
  }
}
