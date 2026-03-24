import 'package:flutter/material.dart';

// Static sample data — replace with backend-fetched lists when ready
const List<String> _kShops = [
  'Shop A – Quezon City',
  'Shop B – Makati',
  'Shop C – Pasig',
  'Shop D – Mandaluyong',
];

const List<String> _kServiceTypes = [
  'Air-con Cleaning',
  'Air-con Repair',
  'Air-con Installation',
  'Electrical Works',
  'Plumbing',
  'General Maintenance',
];

const List<String> _kStatuses = [
  'Pending',
  'Tentative',
  'Final',
  'Resolved',
];

const List<String> _kTechnicians = [
  'Juan Dela Cruz',
  'Pedro Santos',
  'Maria Reyes',
  'Carlos Bautista',
  'Ana Gomez',
];

void showAddScheduleDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (_) => const _AddScheduleDialog(),
  );
}

class _AddScheduleDialog extends StatefulWidget {
  const _AddScheduleDialog({Key? key}) : super(key: key);

  @override
  State<_AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<_AddScheduleDialog> {
  // Controllers
  final _clientNameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pinLocationCtrl = TextEditingController();
  final _locationLinkCtrl = TextEditingController();
  final _vehicleCtrl = TextEditingController();
  final _tollCtrl = TextEditingController();
  final _gasCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Radio – client source
  bool _useDefault = true; // true = Default, false = Asterisk

  // Dropdowns
  String? _selectedShop;
  String? _selectedServiceType;
  String? _selectedStatus;
  String? _selectedTech1;
  String? _selectedTech2;
  String? _selectedTech3;
  String? _selectedTech4;
  String? _selectedTech5;

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _contactCtrl.dispose();
    _addressCtrl.dispose();
    _pinLocationCtrl.dispose();
    _locationLinkCtrl.dispose();
    _vehicleCtrl.dispose();
    _tollCtrl.dispose();
    _gasCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    // TODO: wire to backend / state management
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Schedule saved successfully.'),
        backgroundColor: Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 560 ? screenWidth * 0.94 : 540.0;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: (screenWidth - dialogWidth) / 2,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: _buildFormBody(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Add Schedule',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20, color: Colors.black54),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Form Body ──────────────────────────────────────────────────────────────

  Widget _buildFormBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1 – Client Name | Contact No.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFieldColumn(
                label: 'Client Name',
                child: _buildInput(
                  controller: _clientNameCtrl,
                  hint: 'AARON DE LEON (Owner)',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFieldColumn(
                label: 'Contact No.',
                child: _buildInput(
                  controller: _contactCtrl,
                  hint: 'Enter phone number',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Radio – Default / Asterisk
        Row(
          children: [
            _buildRadioOption('Default', _useDefault, () {
              setState(() => _useDefault = true);
            }),
            const SizedBox(width: 16),
            _buildRadioOption('* Asterisk', !_useDefault, () {
              setState(() => _useDefault = false);
            }),
          ],
        ),
        const SizedBox(height: 10),

        // Type Client Name button
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF2563EB)),
            foregroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Type Client Name...',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 14),

        // Shop
        _buildFieldColumn(
          label: 'Shop',
          child: _buildDropdown(
            hint: 'Select Shop',
            value: _selectedShop,
            items: _kShops,
            onChanged: (v) => setState(() => _selectedShop = v),
          ),
        ),
        const SizedBox(height: 12),

        // Address Location
        _buildFieldColumn(
          label: 'Address Location',
          child: _buildInput(
            controller: _addressCtrl,
            hint: 'Enter Address',
          ),
        ),
        const SizedBox(height: 12),

        // Row – Pin Location | Location Link
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFieldColumn(
                label: 'Pin Location',
                labelSuffix: _buildHelpIcon(),
                child: _buildInput(
                  controller: _pinLocationCtrl,
                  hint: 'Enter Pin Location',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFieldColumn(
                label: 'Location Link',
                labelSuffix: const Icon(
                  Icons.link,
                  size: 15,
                  color: Color(0xFF2563EB),
                ),
                child: _buildInput(
                  controller: _locationLinkCtrl,
                  hint: '',
                  keyboardType: TextInputType.url,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row – Type Of Service | Vehicle/s
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFieldColumn(
                label: 'Type Of Service',
                child: _buildDropdown(
                  hint: '',
                  value: _selectedServiceType,
                  items: _kServiceTypes,
                  onChanged: (v) => setState(() => _selectedServiceType = v),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFieldColumn(
                label: 'Vehicle/s',
                child: _buildInput(
                  controller: _vehicleCtrl,
                  hint: 'Enter Vehicle name',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row – Toll Amount | Gas Amount | Status
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFieldColumn(
                label: 'Toll Amount',
                child: _buildInput(
                  controller: _tollCtrl,
                  hint: 'Enter Toll amount',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFieldColumn(
                label: 'Gas Amount',
                child: _buildInput(
                  controller: _gasCtrl,
                  hint: 'Enter Gas amount',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFieldColumn(
                label: 'Status',
                child: _buildDropdown(
                  hint: 'Select Status',
                  value: _selectedStatus,
                  items: _kStatuses,
                  onChanged: (v) => setState(() => _selectedStatus = v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Technician row (up to 5 dropdowns)
        _buildFieldColumn(
          label: 'Technician',
          labelSuffix: _buildHelpIcon(),
          child: _buildTechnicianRow(),
        ),
        const SizedBox(height: 12),

        // Notes
        _buildFieldColumn(
          label: 'Notes',
          child: _buildTextArea(
            controller: _notesCtrl,
            hint: 'Enter Notes/Comments',
          ),
        ),
        const SizedBox(height: 20),

        // Save button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Save Schedule',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared sub-builders ────────────────────────────────────────────────────

  Widget _buildFieldColumn({
    required String label,
    required Widget child,
    Widget? labelSuffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (labelSuffix != null) ...[
              const SizedBox(width: 4),
              labelSuffix,
            ],
          ],
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      hint: Text(hint, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        isDense: true,
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: 4,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildRadioOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? const Color(0xFF2563EB) : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpIcon() {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[400],
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 9,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicianRow() {
    final techSlots = [
      (_selectedTech1, (String? v) => setState(() => _selectedTech1 = v)),
      (_selectedTech2, (String? v) => setState(() => _selectedTech2 = v)),
      (_selectedTech3, (String? v) => setState(() => _selectedTech3 = v)),
      (_selectedTech4, (String? v) => setState(() => _selectedTech4 = v)),
      (_selectedTech5, (String? v) => setState(() => _selectedTech5 = v)),
    ];

    return Row(
      children: techSlots.asMap().entries.map((entry) {
        final idx = entry.key;
        final slot = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: idx < techSlots.length - 1 ? 6 : 0),
            child: DropdownButtonFormField<String>(
              value: slot.$1,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              hint: Text(
                idx == 0 ? 'Select Technic…' : '',
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                overflow: TextOverflow.ellipsis,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
                isDense: true,
              ),
              items: _kTechnicians
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: slot.$2,
            ),
          ),
        );
      }).toList(),
    );
  }
}
