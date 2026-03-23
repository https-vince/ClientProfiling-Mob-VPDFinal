import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class EditServicesScreen extends StatefulWidget {
  final List<Map<String, String>> items;

  const EditServicesScreen({Key? key, required this.items}) : super(key: key);

  @override
  State<EditServicesScreen> createState() => _EditServicesScreenState();
}

class _EditServicesScreenState extends State<EditServicesScreen> {
  final _formKey = GlobalKey<FormState>();

  late List<TextEditingController> _particularsCtrl;
  late List<TextEditingController> _amountCtrl;
  late List<TextEditingController> _uomCtrl;

  @override
  void initState() {
    super.initState();
    final src = widget.items.isNotEmpty
        ? widget.items
        : [
            {'particulars': '', 'amount': '', 'uom': ''}
          ];
    _particularsCtrl =
        src.map((e) => TextEditingController(text: e['particulars'])).toList();
    _amountCtrl =
        src.map((e) => TextEditingController(text: e['amount'])).toList();
    _uomCtrl =
        src.map((e) => TextEditingController(text: e['uom'])).toList();
  }

  @override
  void dispose() {
    for (final c in [..._particularsCtrl, ..._amountCtrl, ..._uomCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _particularsCtrl.add(TextEditingController());
      _amountCtrl.add(TextEditingController());
      _uomCtrl.add(TextEditingController());
    });
  }

  void _removeRow(int i) {
    if (_particularsCtrl.length == 1) return;
    setState(() {
      _particularsCtrl[i].dispose();
      _amountCtrl[i].dispose();
      _uomCtrl[i].dispose();
      _particularsCtrl.removeAt(i);
      _amountCtrl.removeAt(i);
      _uomCtrl.removeAt(i);
    });
  }

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = List.generate(
      _particularsCtrl.length,
      (i) => {
        'particulars': _particularsCtrl[i].text.trim(),
        'amount': _amountCtrl[i].text.trim(),
        'uom': _uomCtrl[i].text.trim(),
      },
    );
    Navigator.of(context).pop<List<Map<String, String>>>(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(title: 'CSR Guide', showMenuButton: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Services',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                const SizedBox(height: 20),

                for (int i = 0; i < _particularsCtrl.length; i++) ...[
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Row ${i + 1}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                            if (_particularsCtrl.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red, size: 20),
                                onPressed: () => _removeRow(i),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Particulars'),
                        TextFormField(
                          controller: _particularsCtrl[i],
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                          decoration: _dec('e.g. Check-up'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Amount'),
                        TextFormField(
                          controller: _amountCtrl[i],
                          decoration: _dec('e.g. ₱650.00'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Unit of Measure (UoM)'),
                        TextFormField(
                          controller: _uomCtrl[i],
                          decoration: _dec('e.g. per Machine'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                TextButton.icon(
                  onPressed: _addRow,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Row'),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB)),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
    );
  }
}

InputDecoration _dec(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5)),
  );
}
