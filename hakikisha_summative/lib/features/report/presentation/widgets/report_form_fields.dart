import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/neumorphic.dart';
import '../../../pharmacy/domain/entities/pharmacy_entity.dart';
import '../../domain/entities/report_entity.dart';

/// The report form fields from the Figma "Report a medicine" screen, shared by
/// the new-report page and the edit sheet on My reports.
///
/// Holds only the text controllers (local UI state); every change is passed
/// up through [onChanged] as a full [ReportDraft], which the cubit keeps.
class ReportFormFields extends StatefulWidget {
  const ReportFormFields({
    super.key,
    required this.initial,
    required this.pharmacies,
    required this.onChanged,
    this.enabled = true,
  });

  final ReportDraft initial;
  final List<PharmacyEntity> pharmacies;
  final ValueChanged<ReportDraft> onChanged;
  final bool enabled;

  @override
  State<ReportFormFields> createState() => _ReportFormFieldsState();
}

class _ReportFormFieldsState extends State<ReportFormFields> {
  late final _medicine = TextEditingController(
    text: widget.initial.medicineName,
  );
  late final _batch = TextEditingController(text: widget.initial.batchNumber);
  late final _location = TextEditingController(
    text: widget.initial.purchaseLocation,
  );
  late final _description = TextEditingController(
    text: widget.initial.description,
  );
  // Listenable instead of setState, like AppTextField.
  late final _pharmacyId = ValueNotifier<String?>(widget.initial.pharmacyId);

  @override
  void dispose() {
    for (final c in [_medicine, _batch, _location, _description]) {
      c.dispose();
    }
    _pharmacyId.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged(
    ReportDraft(
      medicineName: _medicine.text,
      batchNumber: _batch.text,
      purchaseLocation: _location.text,
      pharmacyId: _pharmacyId.value,
      description: _description.text,
    ),
  );

  String? _required(String? value, String message) =>
      (value ?? '').trim().isEmpty ? message : null;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String?>(
    valueListenable: _pharmacyId,
    builder: (context, pharmacyId, _) => _fields(pharmacyId),
  );

  Widget _fields(String? pharmacyId) {
    // A pharmacy that was deleted after selection falls back to "not listed".
    final listed = widget.pharmacies.any((p) => p.pharmacyId == pharmacyId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Medicine name',
          hint: 'e.g. Coartem 80/480',
          controller: _medicine,
          enabled: widget.enabled,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          validator: (v) => _required(v, 'Enter the name of the medicine.'),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Batch number (optional)',
          hint: 'Printed on the pack, e.g. PA23-0871',
          controller: _batch,
          enabled: widget.enabled,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 16),
        _PharmacyPicker(
          pharmacies: widget.pharmacies,
          selected: listed ? pharmacyId : null,
          enabled: widget.enabled,
          onChanged: (id) {
            _pharmacyId.value = id;
            _emit();
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: listed
              ? 'Shop details (optional)'
              : 'Where did you buy it? (optional)',
          hint: 'Shop name, street, town',
          controller: _location,
          enabled: widget.enabled,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'What looked wrong?',
          hint: 'Packaging, seal, colour, taste, effect…',
          controller: _description,
          enabled: widget.enabled,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          validator: (v) => _required(v, 'Tell us what looked wrong.'),
          onChanged: (_) => _emit(),
        ),
      ],
    );
  }
}

/// Neumorphic dropdown of verified pharmacies, with "not listed" as the first
/// option so an empty or unknown list never blocks a report.
class _PharmacyPicker extends StatelessWidget {
  const _PharmacyPicker({
    required this.pharmacies,
    required this.selected,
    required this.onChanged,
    required this.enabled,
  });

  final List<PharmacyEntity> pharmacies;
  final String? selected;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHARMACY (OPTIONAL)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: palette.heading,
          ),
        ),
        const SizedBox(height: 8),
        NeuInset(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: selected,
                dropdownColor: palette.surface,
                borderRadius: BorderRadius.circular(14),
                style: TextStyle(fontSize: 16, color: palette.text),
                iconEnabledColor: palette.heading,
                onChanged: enabled ? onChanged : null,
                items: [
                  DropdownMenuItem<String?>(
                    child: Text(
                      pharmacies.isEmpty
                          ? 'No pharmacies listed yet'
                          : 'Not listed / not sure',
                      style: TextStyle(color: palette.textMuted),
                    ),
                  ),
                  for (final p in pharmacies)
                    DropdownMenuItem<String?>(
                      value: p.pharmacyId,
                      child: Text(
                        '${p.name} · ${p.address}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
