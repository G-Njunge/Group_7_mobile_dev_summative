import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/entities/scan_record_entity.dart';
import '../../domain/repositories/scan_repository.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import '../widgets/manual_entry_sheet.dart';
import 'camera_scanner_page.dart';
import 'scan_result_page.dart';

class HomeScanPage extends StatelessWidget {
  final String userFirstName;
  final String userId;
  final ScanRepository scanRepository;
  final VoidCallback onOpenPharmacyMap;
  final void Function({String? medicineName, String? batchNumber}) onOpenReport;
  final VoidCallback onOpenHistory;

  const HomeScanPage({
    super.key,
    required this.userFirstName,
    required this.userId,
    required this.scanRepository,
    required this.onOpenPharmacyMap,
    required this.onOpenReport,
    required this.onOpenHistory,
  });

  Future<void> _handleGalleryUpload(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null || !context.mounted) return;

    final controller = MobileScannerController();
    try {
      final capture = await controller.analyzeImage(image.path);
      final rawValue = capture?.barcodes.firstOrNull?.rawValue;

      if (!context.mounted) return;
      if (rawValue != null && rawValue.isNotEmpty) {
        context.read<ScanBloc>().add(
              ScanCodeSubmitted(code: rawValue, method: ScanMethod.upload),
            );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No barcode detected in image. Try manual entry.'),
          ),
        );
      }
    } finally {
      await controller.dispose();
    }
  }

  void _openManualSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ManualEntrySheet(
        onCodeSubmitted: (code) {
          context.read<ScanBloc>().add(
                ScanCodeSubmitted(code: code, method: ScanMethod.manual),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanBloc, ScanState>(
      listener: (context, state) {
        if (state is ScanComplete) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ScanResultPage(
                result: state.result,
                onOpenPharmacyMap: onOpenPharmacyMap,
                onOpenReport: () => onOpenReport(
                  medicineName: state.result.medicine?.name,
                  batchNumber: state.result.batch?.batchNumber ??
                      state.result.queriedCode,
                ),
              ),
            ),
          );
        } else if (state is ScanFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<ScanBloc, ScanState>(
        builder: (context, state) {
          final isVerifying = state is ScanVerifying;

          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'MURAHO, ${userFirstName.toUpperCase()}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              letterSpacing: 1.2,
                              color: const Color(0xFF1B4332),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'What are you checking today?',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // Primary Scan CTA (>= 48dp accessible touch target)[cite: 20, 21]
                      SizedBox(
                        height: 120,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4332),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ScanBloc>(),
                                  child: const CameraScannerPage(),
                                ),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_scanner, size: 36),
                              SizedBox(width: 16),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scan medicine',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('Point your camera at the pack'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Secondary inputs: Enter code & Upload photo[cite: 16, 21]
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 64,
                              child: OutlinedButton.icon(
                                onPressed: () => _openManualSheet(context),
                                icon: const Icon(Icons.keyboard_alt_outlined),
                                label: const Text('Enter code'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 64,
                              child: OutlinedButton.icon(
                                onPressed: () => _handleGalleryUpload(context),
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Upload photo'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Verified Pharmacy quick card (routes to M4)[cite: 16, 21]
                      Card(
                        child: ListTile(
                          minVerticalPadding: 14,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFD8F3DC),
                            child: Icon(
                              Icons.local_pharmacy,
                              color: Color(0xFF1B4332),
                            ),
                          ),
                          title: const Text(
                            'Find a verified pharmacy',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text('Licensed pharmacies in Kigali'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: onOpenPharmacyMap,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Live Recent Scan card synced with Firestore scans stream[cite: 21]
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RECENT SCAN',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: onOpenHistory,
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                      StreamBuilder<ScanRecordEntity?>(
                        stream: scanRepository.watchLatestScan(userId),
                        builder: (context, snapshot) {
                          final latest = snapshot.data;
                          if (latest == null) {
                            return const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No scans yet. Scan a medicine pack to verify its Rwanda FDA batch status.',
                                ),
                              ),
                            );
                          }

                          final isGenuine = latest.result == 'genuine';
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                isGenuine
                                    ? Icons.verified
                                    : Icons.warning_amber_rounded,
                                color: isGenuine
                                    ? const Color(0xFF1B4332)
                                    : const Color(0xFF9B2226),
                              ),
                              title: Text(
                                latest.medicineName ??
                                    'Batch ${latest.batchNumber ?? latest.batchId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${latest.result.toUpperCase()} • via ${latest.method.name}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: onOpenHistory,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 2-second scanning overlay[cite: 21]
              if (isVerifying)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Card(
                      margin: EdgeInsets.all(32),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Verifying against Rwanda FDA registry...',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
