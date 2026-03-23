import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class EditAccessoriesScreen extends StatefulWidget {
  final List<Map<String, String>> items;

  const EditAccessoriesScreen({Key? key, required this.items}) : super(key: key);

  @override
  State<EditAccessoriesScreen> createState() => _EditAccessoriesScreenState();
}

class _EditAccessoriesScreenState extends State<EditAccessoriesScreen> {
  final _formKey = GlobalKey<FormState>();

  late List<TextEditingController> _nameCtrl;
  late List<TextEditingController> _priceCtrl;
  late List<TextEditingController> _inclusionCtrl;

  @override
  void initState() {
    super.initState();
    final src = widget.items.isNotEmpty
        ? widget.items
        : [
            {'name': '', 'price': '', 'inclusion': ''}
          ];
    _nameCtrl = src.map((e) => TextEditingController(text: e['name'])).toList();
    _priceCtrl = src.map((e) => TextEditingController(text: e['price'])).toList();
    _inclusionCtrl =
        src.map((e) => TextEditingController(text: e['inclusion'])).toList();
  }

  @override
  void dispose() {
    for (final c in [..._nameCtrl, ..._priceCtrl, ..._inclusionCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _nameCtrl.add(TextEditingController());
      _priceCtrl.add(TextEditingController());
      _inclusionCtrl.add(TextEditingController());
    });
  }

  void _removeRow(int i) {
    if (_nameCtrl.length == 1) return;
    setState(() {
      _nameCtrl[i].dispose();
      _priceCtrl[i].dispose();
      _inclusionCtrl[i].dispose();
      _nameCtrl.removeAt(i);
      _priceCtrl.removeAt(i);
      _inclusionCtrl.removeAt(i);
    });
  }

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = List.generate(
      _nameCtrl.length,
      (i) => {
        'name': _nameCtrl[i].text.trim(),
        'price': _priceCtrl[i].text.trim(),
        'inclusion': _inclusionCtrl[i].text.trim(),
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
                  'Edit Accessories',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                const SizedBox(height: 20),

                for (int i = 0; i < _nameCtrl.length; i++) ...[
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
                            if (_nameCtrl.length > 1)
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
                        const _FieldLabel('Payment System Name'),
                        TextFormField(
                          controller: _nameCtrl[i],
                          decoration: _dec('Enter name...'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Price'),
                        TextFormField(
                          controller: _priceCtrl[i],
                          decoration: _dec('e.g. ₱165,000'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Inclusion (one item per line)'),
                        TextFormField(
                          controller: _inclusionCtrl[i],
                          maxLines: 5,
                          decoration:
                              _dec('LOS Terminal\nCash Drawer\n...'),
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
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
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
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5)),
  );
}
