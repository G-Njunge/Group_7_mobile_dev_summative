import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../pharmacy/domain/entities/pharmacy_entity.dart';
import '../bloc/report_cubit.dart';
import '../bloc/report_state.dart';
import 'my_reports_page.dart';

class CounterfeitReportPage extends StatelessWidget {
  const CounterfeitReportPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GetIt.instance<ReportCubit>(),
    child: _CounterfeitReportView(userId: userId),
  );
}

class _CounterfeitReportView extends StatefulWidget {
  const _CounterfeitReportView({required this.userId});

  final String userId;

  @override
  State<_CounterfeitReportView> createState() => _CounterfeitReportViewState();
}

class _CounterfeitReportViewState extends State<_CounterfeitReportView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    unawaited(context.read<ReportCubit>().start(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ReportCubit, ReportState>(
    builder: (context, state) {
      final cubit = context.read<ReportCubit>();
      return Scaffold(
        appBar: AppBar(
          title: const Text('Report suspected counterfeit'),
          actions: [
            IconButton(
              tooltip: 'My reports',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MyReportsPage(userId: widget.userId),
                ),
              ),
              icon: const Icon(Icons.receipt_long_outlined),
            ),
          ],
        ),
        body: state.isSubmitted
            ? _ReportSentView(userId: widget.userId)
            : SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'Tell us what happened and where you encountered the medicine.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        minLines: 4,
                        maxLines: 7,
                        maxLength: 2000,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText:
                              'Describe the medicine and why you suspect it.',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        onChanged: cubit.setDescription,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter a description.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _PharmacyPicker(
                        state: state,
                        onSelected: cubit.selectPharmacy,
                      ),
                      if (state.pharmacyStatus ==
                          ReportPharmacyStatus.error) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () =>
                                unawaited(cubit.start(userId: widget.userId)),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry loading pharmacies'),
                          ),
                        ),
                      ],
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: state.isSubmitting
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  unawaited(
                                    cubit.submit(userId: widget.userId),
                                  );
                                }
                              },
                        icon: state.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_outlined),
                        label: Text(
                          state.isSubmitting ? 'Submitting…' : 'Submit report',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    },
  );
}

class _ReportSentView extends StatelessWidget {
  const _ReportSentView({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Report sent',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Thank you. Your report has been sent to the Pharmacy and Poisons Board.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MyReportsPage(userId: userId),
                ),
              ),
              child: const Text('View my reports'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PharmacyPicker extends StatelessWidget {
  const _PharmacyPicker({required this.state, required this.onSelected});

  final ReportState state;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final isLoading = state.pharmacyStatus == ReportPharmacyStatus.loading;
    final pharmacies = state.pharmacies;
    return DropdownButtonFormField<String>(
      initialValue: state.selectedPharmacyId,
      decoration: InputDecoration(
        labelText: 'Pharmacy',
        border: const OutlineInputBorder(),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      hint: Text(
        isLoading
            ? 'Loading pharmacies…'
            : pharmacies.isEmpty
            ? 'No pharmacies available'
            : 'Select a pharmacy',
      ),
      items: [
        for (final pharmacy in pharmacies)
          DropdownMenuItem(
            value: pharmacy.pharmacyId,
            child: _PharmacyOption(pharmacy: pharmacy),
          ),
      ],
      onChanged: isLoading || pharmacies.isEmpty ? null : onSelected,
      validator: (value) => value == null ? 'Select a pharmacy.' : null,
    );
  }
}

class _PharmacyOption extends StatelessWidget {
  const _PharmacyOption({required this.pharmacy});

  final PharmacyEntity pharmacy;

  @override
  Widget build(BuildContext context) => Text(
    '${pharmacy.name} · ${pharmacy.address}',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
