import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/neumorphic.dart';
import '../../domain/entities/report_entity.dart';
import '../bloc/report_cubit.dart';
import '../bloc/report_state.dart';
import '../widgets/report_form_fields.dart';

/// The user's reports: read, edit and withdraw while pending.
class MyReportsPage extends StatelessWidget {
  const MyReportsPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GetIt.instance<ReportCubit>()..start(userId: userId),
    child: const _MyReportsView(),
  );
}

class _MyReportsView extends StatelessWidget {
  const _MyReportsView();

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'My reports',
    body: BlocConsumer<ReportCubit, ReportState>(
      listenWhen: (previous, current) =>
          current.actionErrorMessage != null &&
          previous.actionErrorMessage != current.actionErrorMessage,
      listener: (context, state) =>
          showAppSnackBar(context, state.actionErrorMessage!),
      builder: (context, state) => switch (state.reportsStatus) {
        MyReportsStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        MyReportsStatus.error => _Message(
          icon: Icons.cloud_off_outlined,
          text: state.errorMessage ?? "We couldn't load your reports.",
        ),
        MyReportsStatus.loaded when state.reports.isEmpty => const _Message(
          icon: Icons.assignment_outlined,
          text: "You haven't reported a medicine yet.",
          showReportButton: true,
        ),
        MyReportsStatus.loaded => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          itemCount: state.reports.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) => index == state.reports.length
              ? SecondaryButton(
                  label: 'Report another medicine',
                  icon: Icons.add,
                  onPressed: () => context.go(AppRoutes.report),
                )
              : _ReportCard(report: state.reports[index], state: state),
        ),
      },
    ),
  );
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.state});

  final ReportEntity report;
  final ReportState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final busy = state.actionReportId == report.reportId;
    final where = [
      state.pharmacyName(report.pharmacyId),
      report.purchaseLocation,
    ].whereType<String>().join(' · ');
    final details = [
      if (report.batchNumber != null) 'Batch ${report.batchNumber}',
      if (where.isNotEmpty) where,
      if (report.createdAt != null) 'Sent ${_formatDate(report.createdAt!)}',
    ];

    return NeuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.medicineName.isEmpty
                      ? 'Medicine report'
                      : report.medicineName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _StatusPill(pending: report.isPending),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              details.join('\n'),
              style: TextStyle(color: palette.textMuted, fontSize: 13),
            ),
          ],
          const SizedBox(height: 10),
          Text(report.description, style: TextStyle(color: palette.text)),
          if (report.isPending) ...[
            const SizedBox(height: 8),
            if (busy)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              // Wrap, not Row: on narrow phones or large text the buttons
              // move to a second line instead of overflowing.
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: state.actionReportId == null
                        ? () => _edit(context)
                        : null,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: state.actionReportId == null
                        ? () => _withdraw(context)
                        : null,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Withdraw'),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<ReportCubit>();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _EditReportSheet(report: report),
      ),
    );
    if (saved == true && context.mounted) {
      showAppSnackBar(context, 'Report updated.', type: SnackType.success);
    }
  }

  Future<void> _withdraw(BuildContext context) async {
    final cubit = context.read<ReportCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Withdraw this report?',
      message: 'It will be deleted and can no longer be reviewed.',
      confirmLabel: 'Withdraw',
      cancelLabel: 'Keep report',
    );
    if (!confirmed) return;
    final deleted = await cubit.deleteReport(report);
    if (deleted && context.mounted) {
      showAppSnackBar(context, 'Report withdrawn.', type: SnackType.success);
    }
  }
}

/// Bottom sheet that edits a pending report with the same fields as the form.
class _EditReportSheet extends StatefulWidget {
  const _EditReportSheet({required this.report});

  final ReportEntity report;

  @override
  State<_EditReportSheet> createState() => _EditReportSheetState();
}

class _EditReportSheetState extends State<_EditReportSheet> {
  // The form key and the draft being edited; no setState needed.
  final _formKey = GlobalKey<FormState>();
  late ReportDraft _draft = widget.report.draft;

  Future<void> _save(ReportCubit cubit) async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await cubit.updateReport(
      report: widget.report,
      draft: _draft,
    );
    if (saved && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportCubit>();
    return Padding(
      // Lift the sheet above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) => Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              Text(
                'Edit report',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ReportFormFields(
                initial: _draft,
                pharmacies: state.pharmacies,
                enabled: state.actionReportId == null,
                onChanged: (draft) => _draft = draft,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save changes',
                loading: state.actionReportId == widget.report.reportId,
                onPressed: () => _save(cubit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.pending});

  final bool pending;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: pending ? palette.field : palette.brand,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          pending ? 'Pending' : 'Reviewed',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: pending ? palette.heading : palette.onBrand,
          ),
        ),
      ),
    );
  }
}

/// Centred icon and text for the empty and error states.
class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.showReportButton = false,
  });

  final IconData icon;
  final String text;
  final bool showReportButton;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 48),
        Icon(icon, size: 56, color: palette.heading),
        const SizedBox(height: 16),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.textMuted),
        ),
        if (showReportButton) ...[
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Report a medicine',
            onPressed: () => context.go(AppRoutes.report),
          ),
        ],
      ],
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final local = date.toLocal();
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}
