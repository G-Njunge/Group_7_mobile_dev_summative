import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/neumorphic.dart';
import '../../domain/entities/report_entity.dart';
import '../bloc/report_cubit.dart';
import '../bloc/report_state.dart';
import '../widgets/report_form_fields.dart';

/// Figma 10 "Report a medicine". [prefill] carries the medicine and batch when
/// the user arrives from a scan result.
class CounterfeitReportPage extends StatelessWidget {
  const CounterfeitReportPage({
    required this.userId,
    this.prefill = const ReportDraft(),
    super.key,
  });

  final String userId;
  final ReportDraft prefill;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        GetIt.instance<ReportCubit>()..start(userId: userId, prefill: prefill),
    child: _ReportView(userId: userId),
  );
}

class _ReportView extends StatefulWidget {
  const _ReportView({required this.userId});

  final String userId;

  @override
  State<_ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<_ReportView> {
  // Holds the form key only; all data lives in ReportCubit.
  final _formKey = GlobalKey<FormState>();

  void _submit(ReportCubit cubit) {
    if (_formKey.currentState!.validate()) cubit.submit(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportCubit>();
    return AppScaffold(
      title: 'Report a medicine',
      body: BlocConsumer<ReportCubit, ReportState>(
        listenWhen: (previous, current) =>
            current.errorMessage != null &&
            previous.errorMessage != current.errorMessage,
        listener: (context, state) =>
            showAppSnackBar(context, state.errorMessage!),
        builder: (context, state) {
          if (state.isSubmitted) return const _ReportSent();
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                Text(
                  'Your report helps the Rwanda FDA find fake and substandard '
                  'medicines. Add as much detail as you can.',
                  style: TextStyle(color: context.palette.textMuted),
                ),
                const SizedBox(height: 20),
                ReportFormFields(
                  initial: state.draft,
                  pharmacies: state.pharmacies,
                  enabled: !state.isSubmitting,
                  onChanged: cubit.updateDraft,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: state.isSubmitting ? 'Sending…' : 'Submit report',
                  icon: Icons.send_outlined,
                  loading: state.isSubmitting,
                  onPressed: () => _submit(cubit),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'My reports',
                  icon: Icons.assignment_outlined,
                  onPressed: () => context.go(AppRoutes.myReports),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Shown after a report is saved, in place of the form.
class _ReportSent extends StatelessWidget {
  const _ReportSent();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        NeuCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: palette.heading,
              ),
              const SizedBox(height: 16),
              Text(
                'Report sent',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you. You can edit or withdraw it from My reports while '
                'it is still pending.',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textMuted),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'View my reports',
                onPressed: () => context.go(AppRoutes.myReports),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Back to Home',
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
