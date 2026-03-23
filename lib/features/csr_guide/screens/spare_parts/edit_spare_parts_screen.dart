import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class EditSparePartsScreen extends StatefulWidget {
  final String effectiveDate;
  final List<Map<String, String>> items;

  const EditSparePartsScreen({
    Key? key,
    required this.effectiveDate,
    required this.items,
  }) : super(key: key);

  @override
  State<EditSparePartsScreen> createState() => _EditSparePartsScreenState();
}

class _EditSparePartsScreenState extends State<EditSparePartsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;

  late List<TextEditingController> _partNameControllers;
  late List<TextEditingController> _desc1Controllers;
  late List<TextEditingController> _desc2Controllers;
  late List<TextEditingController> _srpControllers;
  late List<TextEditingController> _commonTermControllers;
  late List<TextEditingController> _compatibleModelControllers;

  @override
  void initState() {
    super.initState();
    _dateController =
        TextEditingController(text: widget.effectiveDate);

    final src = widget.items.isNotEmpty
        ? widget.items
        : [
            {
              'partName': '',
              'description1': '',
              'description2': '',
              'srp': '',
              'commonTerm': '',
              'compatibleModel': '',
            }
          ];

    _partNameControllers =
        src.map((e) => TextEditingController(text: e['partName'])).toList();
    _desc1Controllers =
        src.map((e) => TextEditingController(text: e['description1'])).toList();
    _desc2Controllers =
        src.map((e) => TextEditingController(text: e['description2'])).toList();
    _srpControllers =
        src.map((e) => TextEditingController(text: e['srp'])).toList();
    _commonTermControllers =
        src.map((e) => TextEditingController(text: e['commonTerm'])).toList();
    _compatibleModelControllers =
        src.map((e) => TextEditingController(text: e['compatibleModel'])).toList();
  }

  @override
  void dispose() {
    _dateController.dispose();
    for (final c in [
      ..._partNameControllers,
      ..._desc1Controllers,
      ..._desc2Controllers,
      ..._srpControllers,
      ..._commonTermControllers,
      ..._compatibleModelControllers,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _partNameControllers.add(TextEditingController());
      _desc1Controllers.add(TextEditingController());
      _desc2Controllers.add(TextEditingController());
      _srpControllers.add(TextEditingController());
      _commonTermControllers.add(TextEditingController());
      _compatibleModelControllers.add(TextEditingController());
    });
  }

  void _removeRow(int index) {
    if (_partNameControllers.length == 1) return;
    setState(() {
      _partNameControllers[index].dispose();
      _desc1Controllers[index].dispose();
      _desc2Controllers[index].dispose();
      _srpControllers[index].dispose();
      _commonTermControllers[index].dispose();
      _compatibleModelControllers[index].dispose();

      _partNameControllers.removeAt(index);
      _desc1Controllers.removeAt(index);
      _desc2Controllers.removeAt(index);
      _srpControllers.removeAt(index);
      _commonTermControllers.removeAt(index);
      _compatibleModelControllers.removeAt(index);
    });
  }

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = List.generate(_partNameControllers.length, (i) => {
      'partName': _partNameControllers[i].text.trim(),
      'description1': _desc1Controllers[i].text.trim(),
      'description2': _desc2Controllers[i].text.trim(),
      'srp': _srpControllers[i].text.trim(),
      'commonTerm': _commonTermControllers[i].text.trim(),
      'compatibleModel': _compatibleModelControllers[i].text.trim(),
    });
    Navigator.of(context).pop<Map<String, dynamic>>({
      'effectiveDate': _dateController.text.trim(),
      'items': updated,
    });
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
                  'Edit Spare Parts',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // ── Effective Date ────────────────────────────────
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Effective Date'),
                      TextFormField(
                        controller: _dateController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                        decoration:
                            _inputDecoration('e.g. June 7, 2025'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Rows ──────────────────────────────────────────
                for (int i = 0; i < _partNameControllers.length; i++) ...[
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Row ${i + 1}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                            if (_partNameControllers.length > 1)
                              IconButton(
                                icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                    size: 20),
                                onPressed: () => _removeRow(i),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Part Name'),
                        TextFormField(
                          controller: _partNameControllers[i],
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                          decoration:
                              _inputDecoration('Enter part name...'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Part Description (1)'),
                        TextFormField(
                          controller: _desc1Controllers[i],
                          maxLines: 2,
                          decoration:
                              _inputDecoration('Enter description 1...'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Part Description (2)'),
                        TextFormField(
                          controller: _desc2Controllers[i],
                          maxLines: 2,
                          decoration:
                              _inputDecoration('Enter description 2...'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('SRP'),
                        TextFormField(
                          controller: _srpControllers[i],
                          decoration: _inputDecoration('e.g. ₱1,209.66'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Common Term'),
                        TextFormField(
                          controller: _commonTermControllers[i],
                          decoration:
                              _inputDecoration('Enter common term...'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Compatible Model'),
                        TextFormField(
                          controller: _compatibleModelControllers[i],
                          decoration:
                              _inputDecoration('e.g. All Giant'),
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

// ── Shared helpers ────────────────────────────────────────────────────────────

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

InputDecoration _inputDecoration(String hint) {
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
