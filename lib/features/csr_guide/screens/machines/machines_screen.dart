import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'edit_machines_screen.dart';

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({Key? key}) : super(key: key);

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  List<Map<String, String>> _machines = [
    {'name': 'LG GIANT C MAX', 'price': '₱185,000.00', 'modelCode': ''},
    {'name': 'LG TITAN C MAX', 'price': '₱265,000.00', 'modelCode': ''},
    {'name': 'LG STYLER', 'price': '₱99,995.00', 'modelCode': ''},
    {'name': 'BULLABOX', 'price': '₱285,000.00', 'modelCode': ''},
  ];

  List<Map<String, String>> _packages = [
    {
      'package': '2 SETS LG GIANT C MAX',
      'price': '₱504,000.00',
      'backendSetup':
          'Water Line\nGas Line Set up\nElectrical Outlet Set up\nExhaust System Set up\nDrain Line Set up\nMachines Enclosure\n42 Gallon Pressure Tank\n1 HP Booster Pump',
      'supportInclusions':
          'Ocular Site Inspection\nOnline Service Support Group\nFree Marketing Consultation\n24 months Warranty on Major Parts\n1 year Quarterly Check-up\n1 Year Free Labor\nOperational Guideline Handouts\nActual Shop Training\nLaundry Business Seminar\n3D Shop Layout\nPricing & Guidelines\nActual Training on troubleshooting\nMachine Programing, Installation, Configuration, Commissioning & Testing',
      'freebies': 'Flyers\nWeighing Scale\nTarpaulin Guidelines\nLaundry Basket',
    },
  ];

  Future<void> _openEditScreen() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => EditMachinesScreen(
          machines: _machines,
          packages: _packages,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _machines = List<Map<String, String>>.from(
          (result['machines'] as List).map((e) => Map<String, String>.from(e)),
        );
        _packages = List<Map<String, String>>.from(
          (result['packages'] as List).map((e) => Map<String, String>.from(e)),
        );
      });
    }
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
              // ── Title row ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Machines',
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

              // ── Machines table ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: _machines.isEmpty
                    ? const _EmptyHint()
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildMachinesTable(),
                      ),
              ),

              // ── Packages table ────────────────────────────────────
              if (_packages.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildPackagesTable(),
                  ),
                ),
              ] else
                const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Machines table ──────────────────────────────────────────────────────────
  Widget _buildMachinesTable() {
    return Table(
      border: TableBorder.all(color: const Color(0xFFD1D5DB)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FixedColumnWidth(180),
        1: FixedColumnWidth(150),
        2: FixedColumnWidth(150),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFF1E3A5F)),
          children: [
            _headerCell('MACHINES'),
            _headerCell('PRICE'),
            _headerCell('Model Code', light: true),
          ],
        ),
        for (final m in _machines)
          TableRow(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(
                  m['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color.fromARGB(221, 0, 0, 0),
                  ),
                ),
              ),
              _dataCell(m['price'] ?? ''),
              _dataCell(m['modelCode'] ?? ''),
            ],
          ),
      ],
    );
  }

  Widget _headerCell(String text, {bool light = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: light ? Colors.black87 : Colors.white,
        ),
      ),
    );
  }

  Widget _dataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  // ── Packages table ──────────────────────────────────────────────────────────
  Widget _buildPackagesTable() {
    return Table(
      border: TableBorder.all(color: const Color(0xFFD1D5DB)),
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      columnWidths: const {
        0: FixedColumnWidth(160),
        1: FixedColumnWidth(130),
        2: FixedColumnWidth(180),
        3: FixedColumnWidth(220),
        4: FixedColumnWidth(160),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF0F4FF)),
          children: [
            _pkgHeader('Package'),
            _pkgHeader('Price'),
            _pkgHeader('Back-end Set Up'),
            _pkgHeader('Support Inclusions'),
            _pkgHeader('Freebies'),
          ],
        ),
        for (final pkg in _packages)
          TableRow(
            children: [
              _pkgTextCell(pkg['package'] ?? '',
                  bold: true),
              _pkgTextCell(pkg['price'] ?? ''),
              _pkgBulletCell(pkg['backendSetup'] ?? ''),
              _pkgBulletCell(pkg['supportInclusions'] ?? ''),
              _pkgBulletCell(pkg['freebies'] ?? ''),
            ],
          ),
      ],
    );
  }

  Widget _pkgHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87)),
    );
  }

  Widget _pkgTextCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _pkgBulletCell(String raw) {
    final items =
        raw.split('\n').where((s) => s.trim().isNotEmpty).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black87)),
                      Flexible(
                        child: Text(item.trim(),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black87)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Text(
          'No items yet. Tap Edit Content to add entries.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}
