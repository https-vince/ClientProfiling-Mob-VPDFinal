import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class EditStatementOfPurposeScreen extends StatefulWidget {
  final String paragraph1;
  final String paragraph2;
  final String paragraph3;

  const EditStatementOfPurposeScreen({
    Key? key,
    required this.paragraph1,
    required this.paragraph2,
    required this.paragraph3,
  }) : super(key: key);

  @override
  State<EditStatementOfPurposeScreen> createState() =>
      _EditStatementOfPurposeScreenState();
}

class _EditStatementOfPurposeScreenState
    extends State<EditStatementOfPurposeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _p1Controller;
  late final TextEditingController _p2Controller;
  late final TextEditingController _p3Controller;

  @override
  void initState() {
    super.initState();
    _p1Controller = TextEditingController(text: widget.paragraph1);
    _p2Controller = TextEditingController(text: widget.paragraph2);
    _p3Controller = TextEditingController(text: widget.paragraph3);
  }

  @override
  void dispose() {
    _p1Controller.dispose();
    _p2Controller.dispose();
    _p3Controller.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop<Map<String, String>>({
      'paragraph1': _p1Controller.text.trim(),
      'paragraph2': _p2Controller.text.trim(),
      'paragraph3': _p3Controller.text.trim(),
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
                  'Edit Statement of Purpose',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Form card ────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Paragraph 1'),
                      TextFormField(
                        controller: _p1Controller,
                        maxLines: 5,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                        decoration: _inputDecoration(
                            'Enter the first paragraph...'),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel('Paragraph 2'),
                      TextFormField(
                        controller: _p2Controller,
                        maxLines: 5,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                        decoration: _inputDecoration(
                            'Enter the second paragraph...'),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel('Paragraph 3'),
                      TextFormField(
                        controller: _p3Controller,
                        maxLines: 5,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                        decoration: _inputDecoration(
                            'Enter the third paragraph...'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Save button ──────────────────────────────────────
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
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
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  );
}
