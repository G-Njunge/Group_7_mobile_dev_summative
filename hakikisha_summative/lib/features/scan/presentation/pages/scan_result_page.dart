import 'package:flutter/material.dart';

import '../../domain/entities/verification_outcome.dart';
import '../widgets/verification_checklist_card.dart';

class ScanResultPage extends StatelessWidget {
  final VerificationResult result;
  final VoidCallback onOpenReport;
  final VoidCallback onOpenPharmacyMap;

  const ScanResultPage({
    super.key,
    required this.result,
    required this.onOpenReport,
    required this.onOpenPharmacyMap,
  });

  @override
  Widget build(BuildContext context) {
    final isGenuine = result.status == VerificationStatus.genuine;
    final bannerColor = isGenuine
        ? const Color(0xFF1B4332)
        : const Color(0xFF9B2226);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan result')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Banner (Genuine vs Flagged / Not Found)[cite: 16, 17, 21]
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bannerColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isGenuine
                              ? Icons.verified_rounded
                              : Icons.dangerous_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isGenuine
                              ? 'VERIFIED GENUINE'
                              : 'DO NOT USE — FLAGGED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _headlineForResult(result),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _descriptionForResult(result),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Medicine & Batch Details Card
              if (result.medicine != null && result.batch != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${result.medicine!.name} ${result.medicine!.strength}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _detailRow(
                          'Manufacturer',
                          result.medicine!.manufacturer,
                        ),
                        _detailRow('Batch Number', result.batch!.batchNumber),
                        _detailRow(
                          'Expiry Date',
                          '${result.batch!.expiryDate.month.toString().padLeft(2, '0')}/${result.batch!.expiryDate.year}',
                        ),
                        _detailRow(
                          'Rwanda FDA Reg No.',
                          result.medicine!.rfdaRegNo,
                        ),
                        _detailRow(
                          'Registry Status',
                          result.batch!.status.toUpperCase(),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              const VerificationChecklistCard(),
              const SizedBox(height: 20),

              // Cross-feature actions into M4 (Report & Pharmacy Map)[cite: 21]
              if (!isGenuine) ...[
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF9B2226),
                    ),
                    onPressed: onOpenReport,
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Report to Rwanda FDA'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: onOpenPharmacyMap,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Find Verified Pharmacy Nearby'),
                ),
              ),
              if (isGenuine) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: TextButton.icon(
                    onPressed: onOpenReport,
                    icon: const Icon(Icons.report_problem_outlined),
                    label: const Text('Something looks wrong? Report pack'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _headlineForResult(VerificationResult r) {
    switch (r.status) {
      case VerificationStatus.genuine:
        return 'Registered & genuine';
      case VerificationStatus.notFound:
        return 'Batch not found in registry';
      case VerificationStatus.flagged:
        switch (r.flagReason) {
          case FlagReason.recalled:
            return 'This batch was recalled';
          case FlagReason.counterfeit:
            return 'Suspected counterfeit batch';
          case FlagReason.expired:
            return 'This medicine has expired';
          case FlagReason.none:
            return 'This pack is flagged';
        }
    }
  }

  String _descriptionForResult(VerificationResult r) {
    switch (r.status) {
      case VerificationStatus.genuine:
        return 'This batch is registered with the Rwanda FDA and matches the manufacturer record.';
      case VerificationStatus.notFound:
        return 'Code "${r.queriedCode}" did not match any authorized Rwanda FDA batch. Do not consume until confirmed.';
      case VerificationStatus.flagged:
        return 'Do not take this medicine. Return it to the seller and submit a report below.';
    }
  }
}
