import 'package:flutter/material.dart';

class ManualEntrySheet extends StatefulWidget {
  final ValueChanged<String> onCodeSubmitted;

  const ManualEntrySheet({super.key, required this.onCodeSubmitted});

  @override
  State<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<ManualEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop();
      widget.onCodeSubmitted(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter Batch or GTIN Code',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Type the batch number printed on the medicine box or blister pack.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Batch Number / GTIN',
                hintText: 'e.g. RW24-0871',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().length < 3) {
                  return 'Enter at least 3 characters';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52, // >= 48dp accessibility rule[cite: 20]
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Verify Batch'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
