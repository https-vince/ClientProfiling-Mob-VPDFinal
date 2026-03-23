import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'edit_services_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<Map<String, String>> _items = [
    {'particulars': 'Check-up', 'amount': '₱650.00', 'uom': 'per Machine'},
    {'particulars': 'Repair', 'amount': '₱650.00', 'uom': 'per Machine'},
    {'particulars': 'General Maintenance Cleaning', 'amount': '₱1,900.00', 'uom': 'per set (Giant)'},
    {'particulars': 'General Maintenance Cleaning', 'amount': '₱2,400.00', 'uom': 'per set (Titan)'},
    {'particulars': 'General Maintenance Cleaning', 'amount': '₱1,300.00', 'uom': 'per Washer (Giant)'},
    {'particulars': 'General Maintenance Cleaning', 'amount': '₱1,500.00', 'uom': 'per Washer (Titan)'},
    {'particulars': 'General Maintenance Cleaning', 'amount': '₱1,000.00', 'uom': 'per Dryer (Giant)'},
    {'particulars': 'General Maintenance Cleaning', 'amount': '₱1,100.00', 'uom': 'per Dryer (Titan)'},
    {'particulars': 'Deep Cleaning', 'amount': '₱2,300.00', 'uom': 'per set (Giant)'},
    {'particulars': 'Deep Cleaning', 'amount': '₱2,500.00', 'uom': 'per set (Titan)'},
    {'particulars': 'Bearing Set (Inner, Outer & Gasket)', 'amount': '₱7,500.00', 'uom': 'Giant'},
    {'particulars': 'Bearing Set (Inner, Outer & Gasket)', 'amount': '₱8,000.00', 'uom': 'Titan'},
    {'particulars': 'Bearing Set (Inner, Outer & Gasket) w/ Spider Arm', 'amount': '₱16,000.00', 'uom': 'Giant'},
    {'particulars': 'Bearing Set (Inner, Outer & Gasket) w/ Spider Arm', 'amount': '₱16,500.00', 'uom': 'Titan'},
    {'particulars': 'Labor for Bearing Replacement', 'amount': '₱1,500.00', 'uom': 'Giant/Titan'},
    {'particulars': 'Labor for Bearing Replacement w/ Cleaning', 'amount': '₱2,400.00', 'uom': 'Giant/Titan'},
    {'particulars': 'Machine Transfer (Dismantle & Reinstallation)', 'amount': '₱2,500.00', 'uom': 'per set'},
    {'particulars': 'Transportation Charges outside Metro Manila', 'amount': '₱22.00', 'uom': 'per km'},
  ];

  Future<void> _openEditScreen() async {
    final result = await Navigator.of(context).push<List<Map<String, String>>>(
      MaterialPageRoute(
        builder: (_) => EditServicesScreen(items: _items),
      ),
    );
    if (result != null && mounted) setState(() => _items = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(title: 'CSR Guide', showMenuButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _openEditScreen,
                      icon: const Icon(Icons.edit, size: 15),
                      label: const Text('Edit Content'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              // ── Table ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: _items.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No items yet. Tap Edit Content to add entries.',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildTable(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      border: TableBorder.all(color: const Color(0xFFD1D5DB)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FixedColumnWidth(320),
        1: FixedColumnWidth(160),
        2: FixedColumnWidth(220),
      },
      children: [
        // Header row
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFF9FAFB)),
          children: [
            _HeaderCell('Particulars'),
            _HeaderCell('Amount'),
            _HeaderCell('Unit of Measure (UoM)'),
          ],
        ),
        // Data rows
        for (int i = 0; i < _items.length; i++)
          TableRow(
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : const Color(0xFFF5F5F5),
            ),
            children: [
              _dataCell(_items[i]['particulars'] ?? ''),
              _dataCell(_items[i]['amount'] ?? ''),
              _boldCell(_items[i]['uom'] ?? ''),
            ],
          ),
      ],
    );
  }

  Widget _dataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(text,
          style: const TextStyle(fontSize: 13, color: Colors.black87)),
    );
  }

  Widget _boldCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
    );
  }
}
