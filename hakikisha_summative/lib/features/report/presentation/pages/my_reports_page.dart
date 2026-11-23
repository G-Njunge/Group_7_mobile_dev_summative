import 'dart:async';

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../pharmacy/domain/entities/pharmacy_entity.dart';
import '../../domain/entities/report_entity.dart';
import '../bloc/report_cubit.dart';
import '../bloc/report_state.dart';

class MyReportsPage extends StatelessWidget {
  const MyReportsPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GetIt.instance<ReportCubit>(),
    child: _MyReportsView(userId: userId),
  );
}

class _MyReportsView extends StatefulWidget {
  const _MyReportsView({required this.userId});

  final String userId;

  @override
  State<_MyReportsView> createState() => _MyReportsViewState();
}

class _MyReportsViewState extends State<_MyReportsView> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<ReportCubit>().start(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<ReportCubit, ReportState>(
    listenWhen: (previous, current) =>
        previous.actionErrorMessage != current.actionErrorMessage &&
        current.actionErrorMessage != null,
    listener: (context, state) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.actionErrorMessage!)));
    },
    builder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('My reports')),
      body: switch (state.reportsStatus) {
        MyReportsStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        MyReportsStatus.error => _LoadError(
          message: state.errorMessage ?? 'Could not load your reports.',
          onRetry: () => unawaited(
            context.read<ReportCubit>().start(userId: widget.userId),
          ),
        ),
        MyReportsStatus.loaded when state.reports.isEmpty =>
          const _EmptyReports(),
        MyReportsStatus.loaded => _ReportList(
          reports: state.reports,
          pharmacies: state.pharmacies,
          actionReportId: state.actionReportId,
          onEdit: (report) => _editReport(report, state.pharmacies),
          onDelete: _deleteReport,
        ),
      },
    ),
  );

  Future<void> _editReport(
    ReportEntity report,
    List<PharmacyEntity> pharmacies,
  ) async {
    if (!report.isPending) return;
    final cubit = context.read<ReportCubit>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _EditReportDialog(
        report: report,
        pharmacies: pharmacies,
        onSave: (description, pharmacyId) => cubit.updateReport(
          report: report,
          description: description,
          pharmacyId: pharmacyId,
        ),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Report updated.')));
    }
  }

  Future<void> _deleteReport(ReportEntity report) async {
    if (!report.isPending) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw report?'),
        content: const Text(
          'This will permanently delete your pending report.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep report'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;

    final deleted = await context.read<ReportCubit>().deleteReport(report);
    if (deleted && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Report withdrawn.')));
    }
  }
}

class _ReportList extends StatelessWidget {
  const _ReportList({
    required this.reports,
    required this.pharmacies,
    required this.actionReportId,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ReportEntity> reports;
  final List<PharmacyEntity> pharmacies;
  final String? actionReportId;
  final ValueChanged<ReportEntity> onEdit;
  final ValueChanged<ReportEntity> onDelete;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: reports.length,
    separatorBuilder: (_, _) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final report = reports[index];
      final pharmacy = _pharmacyName(report.pharmacyId, pharmacies);
      final isWorking = actionReportId != null;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.isPending
                          ? 'Pending'
                          : _statusLabel(report.status),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Chip(label: Text(_statusLabel(report.status))),
                ],
              ),
              Text(pharmacy),
              if (report.createdAt != null)
                Text(
                  'Submitted ${_formatDate(report.createdAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              Text(report.description),
              if (report.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.photoUrls.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        report.photoUrls[index],
                        width: 160,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(
                          width: 160,
                          height: 120,
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (report.isPending) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: isWorking ? null : () => onEdit(report),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      onPressed: isWorking ? null : () => onDelete(report),
                      icon: isWorking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline),
                      label: const Text('Withdraw'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );

  String _pharmacyName(String pharmacyId, List<PharmacyEntity> pharmacies) {
    for (final pharmacy in pharmacies) {
      if (pharmacy.pharmacyId == pharmacyId) return pharmacy.name;
    }
    return 'Pharmacy no longer available';
  }

  String _statusLabel(String status) => switch (status) {
    'pending' => 'Pending',
    'reviewed' => 'Reviewed',
    _ => status,
  };

  String _formatDate(DateTime date) =>
      '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _EditReportDialog extends StatefulWidget {
  const _EditReportDialog({
    required this.report,
    required this.pharmacies,
    required this.onSave,
  });

  final ReportEntity report;
  final List<PharmacyEntity> pharmacies;
  final Future<bool> Function(String description, String pharmacyId) onSave;

  @override
  State<_EditReportDialog> createState() => _EditReportDialogState();
}

class _EditReportDialogState extends State<_EditReportDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late String? _pharmacyId;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.report.description,
    );
    _pharmacyId =
        widget.pharmacies.any(
          (pharmacy) => pharmacy.pharmacyId == widget.report.pharmacyId,
        )
        ? widget.report.pharmacyId
        : null;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit pending report'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              maxLength: 2000,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a description.'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _pharmacyId,
              decoration: const InputDecoration(
                labelText: 'Pharmacy',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final pharmacy in widget.pharmacies)
                  DropdownMenuItem(
                    value: pharmacy.pharmacyId,
                    child: Text(
                      pharmacy.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) => setState(() => _pharmacyId = value),
              validator: (value) => value == null ? 'Select a pharmacy.' : null,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _isSaving ? null : _save,
        child: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save'),
      ),
    ],
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final saved = await widget.onSave(
      _descriptionController.text,
      _pharmacyId!,
    );
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Could not save the report. Please try again.';
      });
    }
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text('You have not submitted any reports yet.'),
    ),
  );
}
