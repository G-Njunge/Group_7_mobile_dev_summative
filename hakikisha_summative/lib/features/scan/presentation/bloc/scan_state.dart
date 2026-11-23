import 'package:equatable/equatable.dart';

import '../../domain/entities/verification_outcome.dart';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {
  const ScanInitial();
}

class ScanVerifying extends ScanState {
  final String code;

  const ScanVerifying(this.code);

  @override
  List<Object?> get props => [code];
}

class ScanComplete extends ScanState {
  final VerificationResult result;
  final bool savedToHistory;

  const ScanComplete({required this.result, this.savedToHistory = true});

  @override
  List<Object?> get props => [result, savedToHistory];
}

class ScanFailure extends ScanState {
  final String message;

  const ScanFailure(this.message);

  @override
  List<Object?> get props => [message];
}
