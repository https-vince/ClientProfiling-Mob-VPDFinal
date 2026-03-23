import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'edit_accessories_screen.dart';

class AccessoriesScreen extends StatefulWidget {
  const AccessoriesScreen({Key? key}) : super(key: key);

  @override
  State<AccessoriesScreen> createState() => _AccessoriesScreenState();
}

class _AccessoriesScreenState extends State<AccessoriesScreen> {
  List<Map<String, String>> _items = [
    {
      'name': 'SPINZ LGLOS',
      'price': '₱165,000',
      'inclusion':
          'LOS Terminal\nCash Drawer\nThermal Printer\nI/O Board\nData Communication\nWire Harness\nFinger Print Scanner\nBarcode Scanner',
    },
    {'name': 'MULTIPLEXER', 'price': '₱', 'inclusion': ''},
    {'name': 'PNC Card Reader', 'price': '₱13,000', 'inclusion': 'Wire Harness Included'},
    {'name': 'NXP Pay Buddy', 'price': '₱40,000', 'inclusion': ''},
    {'name': 'Payment Card', 'price': '₱180', 'inclusion': ''},
    {'name': 'Download Card', 'price': '₱650', 'inclusion': ''},
    {'name': 'Parameter Card', 'price': '₱650', 'inclusion': ''},
    {'name': 'PNC Harness', 'price': '₱600', 'inclusion': ''},
    {'name': 'UTP Cable', 'price': '₱120/m', 'inclusion': ''},
    {'name': '', 'price': '', 'inclusion': ''},
    {
      'name': 'BIOPAY CARD SYSTEM',
      'price': '',
      'inclusion':
          'Basic PNC\nNXP Paybuddy\nCustomer Card\nParameter Card\nDownload Card\nHarness',
    },
    {
      'name': 'PBS',
      'price': '₱130,000',
      'inclusion':
          'PBS TERMINAL\nP2P MODULE\nMULTIPLEXER\nWIRE HARNESS\nMASTER CARD\nPAYMENT CARD (OPTIONAL)\n2 YEAR SUBCRIPTIONS IN MONEYLINK (6,000 PER YEAR)\nINSTALLATION\nTRAINING',
    },
  ];

  Future<void> _openEditScreen() async {
    final result = await Navigator.of(context).push<List<Map<String, String>>>(
      MaterialPageRoute(
        builder: (_) => EditAccessoriesScreen(items: _items),
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
                        'Accessories',
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
              if (_items.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No items yet. Tap Edit Content to add entries.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: _buildTable(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Column(
        children: [
          // Header row
          Container(
            color: const Color(0xFF1E4D8C),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _headerCell('Payment Systems'),
                ),
                Expanded(
                  flex: 3,
                  child: _headerCell('Price'),
                ),
                Expanded(
                  flex: 5,
                  child: _headerCell('Inclusion'),
                ),
              ],
            ),
          ),
          // Data rows
          for (int i = 0; i < _items.length; i++)
            Container(
              decoration: BoxDecoration(
                color: i.isEven ? Colors.white : const Color(0xFFF5F5F5),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFD1D5DB)),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _dataCell(_items[i]['name'] ?? ''),
                    ),
                    const VerticalDivider(
                        width: 1, color: Color(0xFFD1D5DB)),
                    Expanded(
                      flex: 3,
                      child: _dataCell(_items[i]['price'] ?? ''),
                    ),
                    const VerticalDivider(
                        width: 1, color: Color(0xFFD1D5DB)),
                    Expanded(
                      flex: 5,
                      child: _inclusionCell(_items[i]['inclusion'] ?? ''),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
    );
  }

  Widget _dataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(text,
          style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );
  }

  Widget _inclusionCell(String raw) {
    final items = raw.split('\n').where((s) => s.trim().isNotEmpty).toList();
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black87)),
                      Expanded(
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
