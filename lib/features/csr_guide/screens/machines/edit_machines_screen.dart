import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class EditMachinesScreen extends StatefulWidget {
  final List<Map<String, String>> machines;
  final List<Map<String, String>> packages;

  const EditMachinesScreen({
    Key? key,
    required this.machines,
    required this.packages,
  }) : super(key: key);

  @override
  State<EditMachinesScreen> createState() => _EditMachinesScreenState();
}

class _EditMachinesScreenState extends State<EditMachinesScreen> {
  final _formKey = GlobalKey<FormState>();

  // Machine controllers
  late List<TextEditingController> _machineNameCtrl;
  late List<TextEditingController> _machinePriceCtrl;
  late List<TextEditingController> _machineModelCtrl;

  // Package controllers
  late List<TextEditingController> _pkgPackageCtrl;
  late List<TextEditingController> _pkgPriceCtrl;
  late List<TextEditingController> _pkgBackendCtrl;
  late List<TextEditingController> _pkgSupportCtrl;
  late List<TextEditingController> _pkgFreebiesCtrl;

  @override
  void initState() {
    super.initState();
    final src = widget.machines.isNotEmpty
        ? widget.machines
        : [
            {'name': '', 'price': '', 'modelCode': ''}
          ];

    _machineNameCtrl =
        src.map((e) => TextEditingController(text: e['name'])).toList();
    _machinePriceCtrl =
        src.map((e) => TextEditingController(text: e['price'])).toList();
    _machineModelCtrl =
        src.map((e) => TextEditingController(text: e['modelCode'])).toList();

    final pkgs = widget.packages.isNotEmpty
        ? widget.packages
        : [
            {
              'package': '',
              'price': '',
              'backendSetup': '',
              'supportInclusions': '',
              'freebies': '',
            }
          ];

    _pkgPackageCtrl =
        pkgs.map((e) => TextEditingController(text: e['package'])).toList();
    _pkgPriceCtrl =
        pkgs.map((e) => TextEditingController(text: e['price'])).toList();
    _pkgBackendCtrl =
        pkgs.map((e) => TextEditingController(text: e['backendSetup'])).toList();
    _pkgSupportCtrl =
        pkgs.map((e) => TextEditingController(text: e['supportInclusions'])).toList();
    _pkgFreebiesCtrl =
        pkgs.map((e) => TextEditingController(text: e['freebies'])).toList();
  }

  @override
  void dispose() {
    for (final c in [
      ..._machineNameCtrl,
      ..._machinePriceCtrl,
      ..._machineModelCtrl,
      ..._pkgPackageCtrl,
      ..._pkgPriceCtrl,
      ..._pkgBackendCtrl,
      ..._pkgSupportCtrl,
      ..._pkgFreebiesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Machine row helpers ───────────────────────────────────────────────────
  void _addMachine() {
    setState(() {
      _machineNameCtrl.add(TextEditingController());
      _machinePriceCtrl.add(TextEditingController());
      _machineModelCtrl.add(TextEditingController());
    });
  }

  void _removeMachine(int i) {
    if (_machineNameCtrl.length == 1) return;
    setState(() {
      _machineNameCtrl[i].dispose();
      _machinePriceCtrl[i].dispose();
      _machineModelCtrl[i].dispose();
      _machineNameCtrl.removeAt(i);
      _machinePriceCtrl.removeAt(i);
      _machineModelCtrl.removeAt(i);
    });
  }

  // ── Package row helpers ────────────────────────────────────────────────────
  void _addPackage() {
    setState(() {
      _pkgPackageCtrl.add(TextEditingController());
      _pkgPriceCtrl.add(TextEditingController());
      _pkgBackendCtrl.add(TextEditingController());
      _pkgSupportCtrl.add(TextEditingController());
      _pkgFreebiesCtrl.add(TextEditingController());
    });
  }

  void _removePackage(int i) {
    if (_pkgPackageCtrl.length == 1) return;
    setState(() {
      _pkgPackageCtrl[i].dispose();
      _pkgPriceCtrl[i].dispose();
      _pkgBackendCtrl[i].dispose();
      _pkgSupportCtrl[i].dispose();
      _pkgFreebiesCtrl[i].dispose();
      _pkgPackageCtrl.removeAt(i);
      _pkgPriceCtrl.removeAt(i);
      _pkgBackendCtrl.removeAt(i);
      _pkgSupportCtrl.removeAt(i);
      _pkgFreebiesCtrl.removeAt(i);
    });
  }

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final machines = List.generate(_machineNameCtrl.length, (i) => {
      'name': _machineNameCtrl[i].text.trim(),
      'price': _machinePriceCtrl[i].text.trim(),
      'modelCode': _machineModelCtrl[i].text.trim(),
    });

    final packages = List.generate(_pkgPackageCtrl.length, (i) => {
      'package': _pkgPackageCtrl[i].text.trim(),
      'price': _pkgPriceCtrl[i].text.trim(),
      'backendSetup': _pkgBackendCtrl[i].text.trim(),
      'supportInclusions': _pkgSupportCtrl[i].text.trim(),
      'freebies': _pkgFreebiesCtrl[i].text.trim(),
    });

    Navigator.of(context).pop<Map<String, dynamic>>({
      'machines': machines,
      'packages': packages,
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
                  'Edit Machines',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // ── Machines section ─────────────────────────────────
                const _SectionHeading('Machines'),
                const SizedBox(height: 10),

                for (int i = 0; i < _machineNameCtrl.length; i++) ...[
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Machine ${i + 1}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                            if (_machineNameCtrl.length > 1)
                              IconButton(
                                icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                    size: 20),
                                onPressed: () => _removeMachine(i),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Machine Name'),
                        TextFormField(
                          controller: _machineNameCtrl[i],
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                          decoration: _dec('e.g. LG GIANT C MAX'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Price'),
                        TextFormField(
                          controller: _machinePriceCtrl[i],
                          decoration: _dec('e.g. ₱185,000.00'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Model Code'),
                        TextFormField(
                          controller: _machineModelCtrl[i],
                          decoration: _dec('Enter model code...'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                TextButton.icon(
                  onPressed: _addMachine,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Machine'),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB)),
                ),

                const SizedBox(height: 24),

                // ── Packages section ──────────────────────────────────
                const _SectionHeading('Packages'),
                const SizedBox(height: 10),

                for (int i = 0; i < _pkgPackageCtrl.length; i++) ...[
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Package ${i + 1}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                            if (_pkgPackageCtrl.length > 1)
                              IconButton(
                                icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                    size: 20),
                                onPressed: () => _removePackage(i),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Package Name'),
                        TextFormField(
                          controller: _pkgPackageCtrl[i],
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                          decoration: _dec('e.g. 2 SETS LG GIANT C MAX'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Price'),
                        TextFormField(
                          controller: _pkgPriceCtrl[i],
                          decoration: _dec('e.g. ₱504,000.00'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel(
                            'Back-end Set Up (one item per line)'),
                        TextFormField(
                          controller: _pkgBackendCtrl[i],
                          maxLines: 6,
                          decoration: _dec(
                              'Water Line\nGas Line Set up\n...'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel(
                            'Support Inclusions (one item per line)'),
                        TextFormField(
                          controller: _pkgSupportCtrl[i],
                          maxLines: 8,
                          decoration: _dec(
                              'Ocular Site Inspection\nOnline Service Support Group\n...'),
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Freebies (one item per line)'),
                        TextFormField(
                          controller: _pkgFreebiesCtrl[i],
                          maxLines: 4,
                          decoration: _dec('Flyers\nWeighing Scale\n...'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                TextButton.icon(
                  onPressed: _addPackage,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Package'),
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

// ── Shared helpers ─────────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87));
  }
}

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
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5)),
  );
}
