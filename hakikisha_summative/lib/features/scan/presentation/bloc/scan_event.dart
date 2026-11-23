import 'package:equatable/equatable.dart';
import '../../domain/entities/scan_record_entity.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class ScanCodeSubmitted extends ScanEvent {
  final String code;
  final ScanMethod method;

  const ScanCodeSubmitted({
    required this.code,
    required this.method,
  });

  @override
  List<Object?> get props => [code, method];
}

class ScanResetRequested extends ScanEvent {
  const ScanResetRequested();
}
