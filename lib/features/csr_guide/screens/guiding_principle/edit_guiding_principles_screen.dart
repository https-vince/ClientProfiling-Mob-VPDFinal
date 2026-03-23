import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class EditGuidingPrinciplesScreen extends StatefulWidget {
  final List<Map<String, String>> principles;

  const EditGuidingPrinciplesScreen({Key? key, required this.principles})
      : super(key: key);

  @override
  State<EditGuidingPrinciplesScreen> createState() =>
      _EditGuidingPrinciplesScreenState();
}

class _EditGuidingPrinciplesScreenState
    extends State<EditGuidingPrinciplesScreen> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _titleControllers;
  late final List<TextEditingController> _bodyControllers;

  @override
  void initState() {
    super.initState();
    _titleControllers = widget.principles
        .map((p) => TextEditingController(text: p['title']))
        .toList();
    _bodyControllers = widget.principles
        .map((p) => TextEditingController(text: p['body']))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _titleControllers) {
      c.dispose();
    }
    for (final c in _bodyControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updated = List.generate(
      _titleControllers.length,
      (i) => {
        'title': _titleControllers[i].text.trim(),
        'body': _bodyControllers[i].text.trim(),
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
                  'Edit Guiding Principles',
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
                      for (int i = 0;
                          i < _titleControllers.length;
                          i++) ...[
                        _FieldLabel('Principle ${i + 1} — Title'),
                        TextFormField(
                          controller: _titleControllers[i],
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                          decoration: _inputDecoration('Enter title...'),
                        ),
                        const SizedBox(height: 12),
                        _FieldLabel('Principle ${i + 1} — Description'),
                        TextFormField(
                          controller: _bodyControllers[i],
                          maxLines: 4,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                          decoration:
                              _inputDecoration('Enter description...'),
                        ),
                        if (i < _titleControllers.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: Color(0xFFE5E7EB)),
                          ),
                      ],
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
